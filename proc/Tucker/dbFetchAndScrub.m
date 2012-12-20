function [ Result, Pending ] = FetchAndScrub(mode, dbFormat, Pending)
% dbFetch,Scrub(mode, dbFormat, Pending)
%   Returns a list of databursts
% Central must previously have been opened
%
% mode: 'open'      Used the first time called, for a series of trials
%       'update'    Used for successive calls
% dbFormat: databurst format string, one char per byte
%       b                   byte
%       h                   halfword (16 bits)
%       s                  	single (32 bits)
%       d                   float (64 bits)
%
% When called for update, the Pending structure values are saved from the
% previous invocation. This is needed to stitch together databursts that
% are partially acquired across two invocations.
%

% TDOD: implement format conversions. DONE.
% TODO: validate start of data read as begining a databurst/delete if
% missing start. DONE
% TODO: read in multiple databursts from a single stream. DONE
% TODO: stitch together databursts split by two reads. DONE
% TODO: merge multiple databursts as tt array
% TODO: provide a control on the count of databursts to be collected

% Number of bytes in databurst. Must match byte count in first field
global DATABURSTSIZE;
DATABURSTSIZE=91;
% Cerebus Channel number for data words
global CHAN;
CHAN=151;
global testclk;
testclk = 0;
fragcnt=0;
INTERVAL = 1;       % Repeat interval for fetching raw data (seconds).
                    % This can be changed as convenient, as long as
                    % internal Cerebus buffer does not overflow; code will
                    % block during this period (unless it is reprogrammed
                    % to run in its own thread)
                    
%% Initialization
% Validate arguments
%
% Check  the format request
if ~ischar(dbFormat)
    help FetchAndAScrub
    error('Function FetchAndScrub() requires a string format list ')
end

if nargin > 2
    szfmt = size(dbFormat,2);
    if szfmt ~= DATABURSTSIZE
        fprintf('DataBurst formate must match size, hard coded as %d\n',DATABURSTSIZE)
        error(['Failed format request:\n ',dbFormat]);
    end
end

% generate header data needed for psychometric displays
tt_hdr = make_hdr();
%% Set up Cerebus.
% 
% OpenCerebus(mode)
switch mode
    case 'open'
        try
            [c i] = cbmex('open',1);
        catch
            try
                cbmex close
                [c i] = cbmex('open',1);
            catch
                %    addpath('C:\Users\Ted\Dropbox\TedBallou\Windows\v6.03.00.01\SDK\lib')
                %addpath('../SDK/')
                addpath('C:\Program Files\Blackrock Microsystems\Cerebus Windows Suite\SDK')
                try
                    [c i] = cbmex('open',1);
                catch
                    error 'cannot open cbmex via Central'
                end
            end
        end
        Pending = InitPending();
        cbmex('mask',0,0)       % disable all channels
        cbmex('mask',CHAN,1)     % enable word channel
        cbmex('trialconfig',1)  % empty the buffer and begin collecting data
    case 'update'
        % Here for repeated calls, no setup required. New data will be
        % appended to Pending data; controls for next index and nibble are
        % contained in the Pending structure. Cerebus is assumed to be
        % already collecting data.
        try
            isstruct(Pending);
        catch
            error 'Cannot call FetchAndScrub() for update without first calling for open'
        end
    otherwise
        help FetchAndScrub
        error(['unknown mode: ',mode])
end

collect_time = INTERVAL; % collect samples for this many seconds
myWait = 1; % Number of seconds between each sub-collection interval
t_col0 = tic; % collection timer begins
bCollect = true; % do we need to collect?

%% MAIN LOOP
% Data Collection section
while (bCollect)
    et_col = toc(t_col0); % elapsed time of collection
    if (et_col >= collect_time)
        trialdata = cbmex('trialdata',1); % read some data
        t_col0 = tic;   % restart timer for next collection period

        if size(trialdata{CHAN,2},1)==0
            t_col0 = tic; % re-start collection time clock
            continue
        end
        raw.ts=trialdata{CHAN,2};
        raw.codes=trialdata{CHAN,3};
        if Pending.Start_ts > 0 % there was previously a fragment
            if testclk
                testcol=toc(testclk);
            else
                testcol = 0;
            end
            if min(find(raw.codes>hex2dec('F000'))) > 20
                % there is no DATA code in the first 20 nibbles, BAIL
                fprintf('**Had a fragment, but next data absent\n')
                Pending = InitPending;
            else
                % Now stitch pending and new raw data together
                raw.ts=[Pending.ts; raw.ts+Pending.ts(numel(Pending.ts))];
                raw.codes=[Pending.codes; raw.codes];
                fprintf('*Stitch pending and new databurst fragments\n')
            end
        end
        % Now convert raw stream of nibbles to actual databurst
        [cooked,Pending,Status] = ScrubData(raw,Pending);
        switch Status
            case 'Discard'
                % Normally occurs when there were no databursts during the
                % collection time
                Pending=InitPending();  % shouldn't be needed, but just in case
                continue
            case 'Fragment'
                % Need more raw data to complete the current databurst
                fragcnt = fragcnt+1;
                continue
            otherwise
                if size(cooked,1) ~= DATABURSTSIZE
                    fprintf('**bad Databurst size = %d\n', size(cooked,1))
                    Status='Discard';
                else
                    Result = ParseData(cooked,dbFormat);
                    bCollect=false;
                end
                Pending=InitPending();
        end
    else
        pause(myWait);
    end
end
% We now have collect_time worth of data
end
% END FUNCTION FetchAndScrub()

%% FUNCTION ScrubData()
function [cooked,Pending,Status] = ScrubData(raw,Pending)
% Inputs: raw       data retrieved from Cerebus
%         Pending   Structure to preserve Start_ts across invocations, also
%                   containing data preserved across invocations.
%
% The following manipulations are done in ScrubData():
%   1. Raw data constituting  reconstructed databursts will be returned as
%   cooked(:,kk), one vector per databurst
%   2. Raw data that ends in the middle of a databurst will be returned as
%   Pending.ts and Pending.codes (not yet reconstructed as databursts)
%   3. Pending data is prepended to raw.ts and raw.codes prior to calling
%   ScrubData().
%   4. Raw data with initial portion being a fragment of a databurst is
%   discarded, for the initial run. Subsequent runs have the initial
%   portion prepended to raw (that were preserved in Pending).
%   5. Raw data containing no databurst codes will be discarded.
% Data words are the (16-bit) words that have the top 4 bits set.
% Here are their indices in the raw buffer

global DATABURSTSIZE
global CHAN;
global testclk;

% Time increment between successive databurst nibbles, equals Cerebus
% ticks per millisecond
INC = 30;
Status='Success';
cooked = [];    % Buffer for output: reconstructed databurst words
kk=1;           % Index into cooked buffer, for multiple planes

RawIndices = find(raw.codes>hex2dec('F000'));
if size(RawIndices,1)==0
    Status = 'Discard';   % There are no data words in this sample
    return
end
if raw.ts(RawIndices(1))<= INC
    % The first element is a databurst; this raw buffer is a fragment
    Fragment = true;
    if Pending.Start_ts == -1
        % This is NOT a continuation run; discard databurst fragment with
        % unknown beginning
        Status = 'Discard';
        fprintf('**Discard non-continuation databurst at start of data\n')
        return
    end
else
    Fragment = false;
    % Save the starting timestamp for the databurst
    Pending.Start_ts = raw.ts(RawIndices(1));
end
if raw.ts(RawIndices(numel(RawIndices))) < Pending.Start_ts + ...
        (DATABURSTSIZE-1)*INC*2
    % Here for an ending fragment. Just return, scrub this databurst after
    % it's completed via next acquisition
    fprintf('*ending fragment\n')
    Status='Fragment';
    Pending.ts = raw.ts;
    Pending.codes = raw.codes;
%    Status='Discard';   % If This is not working enable the Discard option
    return
end

% Choose these indices, mask these words with FF00, then shift right 8
% bits, to get just the upper byte.
dbC=bitshift(bitand(raw.codes(RawIndices),hex2dec('FF00')),-8);
% For databursts the upper nibble (4 bits) is 0XF, so mask that off to get
% the databurst code.
dbc=bitand(dbC,hex2dec('F'));
% Now get the timestamps corresponding to these databurst codes.
dbI=raw.ts(RawIndices);

% the next two lines may be helpful for debuggung
%plot(dbI, dbc)
%db=[dbI, uint32(dbc)];
% To validate databurst duration on the plot: Set cursors at beginning and
% end of putative databurst and check the difference, divided by 60 because
% the rate is 30 kHz and there are two bytes ber databurst byte. We get
% about 90.5, which corresponds to 91 bytes in the ddataburst.
%   (cursor_info(1).Position(1)- cursor_info(2).Position(1))/60 = 90.5

% The following code sxtracts databurst content, one timestamp and data
% element at 30 (INC) ticks per millisecond. The code permits +- (1/30) msec
% jitter. This extraction is neeeded when collection was done on both
% rising and falling edges of data.
running = true;
ii = 1; % index into databurst nibble list
jj=1;   % index into reconstructed databurst byte stream
looking4upper = true;   % Each databurst byte is transmitted as 2 nibbles, lower first
MAXraw = size(dbc,1);
lower = dbc(ii);    % The first nibble of the first byte of the next databurst
was = lower;
cki=ii;     % debugging variable
st_time = dbI(ii);  % timestamp to begin analysis for the next nibble 
maybeC = dbc(ii);   % initialize the candidate for the next nibble
while running
    % now seek the next entry that either has a different code, or is inc
    % (30) time units +-1 later, whichever comes first. If a different code
    % comes first this is too soon, abort.
    while dbI(ii) < (st_time+INC) ...% current time is within INC-1 later than start
            && (maybeC == was) &&...   % code is unchanged
            (ii < MAXraw)        % did not yet use up the raw data
        ii=ii+1;
        maybeC = dbc(ii);
    end
    % Here when either there is a new code nibble value, or the time for
    % the next databurst nibble is up, or the last DATA word has been
    % copied. In all cases, maybeC now contains the next candidate code
    % nibble.
    cki=[cki ii];   % debugging variable

    if dbI(ii) < st_time+INC-1 && ii ~= MAXraw%
        toosoon=1; 
        %fprintf('*Index %d-%d-%d, code change early: %d\n',ii,jj,kk,dbI(ii)-st_time) %possible error?
    else
        toosoon=0;% time to pick out these nibbles
    end
    
    if dbI(ii) > st_time + 4*INC    % next raw data is for NEXT databurst
        % Validate the previously processed "cooked" buffer
        if jj < DATABURSTSIZE   % this is an error case
            fprintf('**cooked smaller than expected (continuing): %d\n',jj)
            Status = 'Discard';
        end
        
        % save the timestamp value for start of next databurst
        Pending.Start_ts = dbI(ii);
        
        % If the remaining raw data do not make a complete databurst,
        % put the raw buffer into Pending and return.
        if dbI(MAXraw) < Pending.Start_ts+(DATABURSTSIZE-1)*INC*2
            disp('*Fragment in second databurst')
            testclk=tic;
            StartPendingIdx = find(raw.ts==dbI(ii));
            Pending.ts = raw.ts(StartPendingIdx:numel(raw.ts));
            Pending.codes = raw.codes(StartPendingIdx:numel(raw.ts));
            Status = 'Fragment';
            return
        end
        
        % Here begin scrub of next databurst
        jj = 1;     % Begin the next plane of the cooked buffer
        kk=kk+1;
        cooked(1,kk) = 0;
        % Return to loop and process next databurst, continuing from the
        % current ii value
        % TODO: check that looking4uppper is correct on each return case
        
        looking4upper = true;   % Each databurst byte is transmitted as 2 nibbles, lower first
        MAXraw = size(dbc,1);
        lower = dbc(ii);    % The first nibble of the first byte of the next databurst
        was = lower;
        cki=ii;     % debugging variable
        st_time = dbI(ii);  % timestamp to begin analysis for the next nibble
        maybeC = dbc(ii);   % initialize the candidate for the next nibble
        
        continue
    end
    
    % Now process the code nibble just retrieved from dbc(ii)
    if looking4upper
        if jj > DATABURSTSIZE   % databurst is too big, abort
            fprintf('**databurst too big: %d\n', jj)
            status = 'Discard';
            return
        end
        was = maybeC;
        cooked(jj,kk) = lower + bitshift(maybeC,4);
        jj=jj+1;    % increment the "cooked" index
        looking4upper=false;
    else
        was = maybeC;
        lower = maybeC;
        looking4upper = true;
    end
    
    % Exit loop when current time is EITHER too soon (error) or too late
    % (next databurst)
    if  ii == MAXraw  % have scrubbed all available raw data
        % Note that the scenario of a starting fragment of a databurst was
        % handled above, where status='Fragment' was returned
        Pending = InitPending();
        if jj < DATABURSTSIZE   % this is an error case
            fprintf('**cooked smaller than expected (end): %d\n',jj)
            Status = 'Discard';
        end
        return
    end

    st_time = dbI(ii);  % timestamp for last nibble analyzed
    ii = ii+1;  % get next raw item for "while" loop above
    maybeC = dbc(ii);
end

end     % END FUNCTION ScrubData()
%%
% FUNCTION parsed = ParseData(cooked, format)
% Now parse the data using the requested format
function parsed = ParseData(cooked, format)
parsed=[];
jj=1;   % will be index for formatted data
ii=1;
szfmt = size(format,2);
for kk=1:size(cooked,2)
    while ii < szfmt+1
        switch format(ii)
            case 'b'
                parsed(jj,kk)=cooked(ii,kk);
                jj=jj+1;
                ii=ii+1;
            case 'f'
                parsed(jj,kk)=typecast(uint8(cooked(ii:ii+3,kk)),'single');
                jj=jj+1;
                ii=ii+4;
        end
    end
    ii=1;
    jj=1;
end
end


