function [ Result, Pending, cyclenum ] = FetchAndScrub(mode, dbFormat, Pending, tt_hdr, cyclenum)
% Returns a list of databursts and the corresponding trial result
% Central must already be running
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
myWait = 1; % Number of seconds between each sub-collection interval
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
    case 'test'
        INTERVAL=0.01; % abbreviate the wait time 
        myWait = 0.01;
    otherwise
        help FetchAndScrub
        error(['unknown mode: ',mode])
end

Result = [];
collect_time = INTERVAL; % collect samples for this many seconds
t_col0 = tic; % collection timer begins
bCollect = true; % do we need to collect?

%% MAIN LOOP
% Data Collection section
while (bCollect)
    et_col = toc(t_col0); % elapsed time of collection
    if (et_col >= collect_time)
        if strcmp(mode, 'test')
            trialdata = cbmextest(cyclenum);
            cyclenum = cyclenum+1;
%            bCollect=false;
        else
            trialdata = cbmex('trialdata',1); % read some data
        end
        t_col0 = tic;   % restart timer for next collection period
        
        if size(trialdata{CHAN,2},1)==0 % no words in this raw batch
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
            if (find(raw.codes>hex2dec('F000'),1,'first') > 20) & ...
                    (Pending.MissingEND == false)
                % there is no DATABURST code in the first 20 nibbles, BAIL
                fprintf('**Had a fragment, but next data absent\n')
                Pending = InitPending();
            else
                % Now stitch pending and new raw data together. The new raw
                % timestamps start at 0, so need to add the ending timestamp.
                % TODO: Time loss in this logic, use "toc" instead.
                raw.ts=[Pending.ts; raw.ts+Pending.ts(numel(Pending.ts))];
                raw.codes=[Pending.codes; raw.codes];
                fprintf('*Stitch pending and new databurst fragments\n')
            end
        end % END if Pending.Start_ts > 0
        % Now convert raw stream of nibbles to actual databurst
        [cooked,Pending,Status,TrialRet] = ScrubData(raw,Pending);
        switch Status
            case 'Discard'
                % Normally occurs when there were no databursts during the
                % collection time
                Pending=InitPending();  % shouldn't be needed, but just in case
                continue
            case 'Fragment'
                % Need more raw data to complete the current databurst
                fragcnt = fragcnt+1;
                % Do not continue if there are completed TRialRets
                if size(TrialRet,2) == 0
                    continue
                end
            case 'Success'
                Pending = InitPending;
            otherwise
                if size(cooked,1) ~= DATABURSTSIZE
                    fprintf('**bad Databurst size = %d\n', size(cooked,1))
                    Status='Discard';
                end
                Pending=InitPending();
        end
        sztr = size(TrialRet,2);
        % In the Fragment case there will be more cooked planes than TrialRet values
        Result = ParseData(cooked(:,1:sztr),dbFormat);
        Result(tt_hdr.trial_result,:) = TrialRet;
        bCollect=false;
    else
        pause(myWait);
    end % END if (et_col >= collect_time)
end % END while bCollect. We now have collect_time worth of data
end% END FUNCTION FetchAndScrub()

%% FUNCTION ScrubData()
function [cooked,Pending,Status,TrialRet] = ScrubData(raw,Pending)
% Inputs: raw       data retrieved from Cerebus
%         Pending   Structure to preserve Start_ts across invocations, also
%                   containing data preserved across invocations.
%
% The following manipulations are done in ScrubData():
%   1. Raw data constituting reconstructed databurst bytes will be returned as
%   cooked(:,kk), one vector per databurst
%   2. Raw data that ends in the middle of a databurst will be returned as
%   Pending.ts and Pending.codes (not yet reconstructed as databursts)
%   3. Pending data was prepended to raw.ts and raw.codes prior to calling
%   ScrubData().
%   4. Raw data with initial portion being a fragment of a databurst is
%   discarded, for the initial run. Subsequent runs have the initial
%   portion prepended to raw (that were preserved in Pending).
%   5. Raw data containing no databurst codes will be discarded.

global DATABURSTSIZE
global CHAN;
global testclk;

% Time increment between successive databurst nibbles, equals Cerebus
% ticks per millisecond
INC = 30;
Status='Success';
TrialRet=[];    % One return value for each cooked buffer plane
cooked = [];    % Buffer for output: reconstructed databurst words
kk=1;           % Index into cooked buffer, for multiple planes

% Databurst words are the (16-bit) words that have the top 4 bits set.
% Here are their indices in the raw buffer
RawIndices = find(raw.codes>hex2dec('F000'));

if size(RawIndices,1)==0
    Status = 'Discard';   % There are no databurst words in this sample
    return
end
if raw.ts(RawIndices(1))<= INC
    % The first element is a databurst; this raw buffer is a fragment
    Fragment = true;
    if Pending.Start_ts == -1
        % This is NOT a continuation run; discard databurst fragment with
        % unknown beginning (unlikely that the first nibble is at the start)
        Status = 'Discard';
        fprintf('**Discard non-continuation databurst at start of data\n')
        return
    end
else
    Fragment = false;
    % Save the starting timestamp for the databurst
    Pending.Start_ts = raw.ts(RawIndices(1));
end

MAXraw = numel(RawIndices); %

if raw.ts(RawIndices(MAXraw)) < Pending.Start_ts + (DATABURSTSIZE-1)*INC*2
    % Here for an initial end-fragment. Just return; scrub this databurst after
    % it's completed via next acquisition. TrialRet was alrady set to [].
    fprintf('*ending fragment\n')
    Status='Fragment';
    Pending.ts = raw.ts;
    Pending.codes = raw.codes;
    %    Status='Discard';   % If This is not working enable the Discard option
    % This case is a fragment at the end of the first databurst, so there are no 
    % TrialRet values to calculate
    return
end

% Choose these indices, mask these words with FF00, then shift right 8
% bits, to get just the upper byte.
dbC=bitshift(bitand(raw.codes(RawIndices),hex2dec('FF00')),-8);
% For databursts the upper nibble (4 bits) is 0XF, so mask that off to get
% the databurst code.
dbc=bitand(dbC,hex2dec('F'));
% Now get the timestamps corresponding to these databurst codes.
DBts=raw.ts(RawIndices);

% The next two lines may be helpful for debugging
%     plot(DBts, dbc)
%     db=[DBts, uint32(dbc)];
% To validate databurst duration on the plot: Set cursors at beginning and
% end of putative databurst and check the difference, divided by 60 because
% the rate is 30 kHz and there are two bytes ber databurst byte. We get
% about 90.5, which corresponds to 91 bytes in the ddataburst.
%   (cursor_info(1).Position(1)- cursor_info(2).Position(1))/60 = 90.5

% Here are the START words (ANDed with 0x1000) (may not need these)
StartI = find(bitand(raw.codes,hex2dec('F000'))==2^12);
Start.ts = raw.ts(StartI);
Start.codes = bitshift(raw.codes(StartI),-8);
Start.codes = bitand(Start.codes,15); % just take the bottom nibble

% Here are the END words (ANDed with 0x2000)
EndI = find(bitand(raw.codes,hex2dec('F000'))==2^13);
End.ts = raw.ts(EndI);
End.codes = bitshift(raw.codes(EndI),-8);
End.codes = bitand(End.codes,15); % just take the bottom nibble

% The following code extracts databurst content, one timestamp and data
% element at 30 (INC) ticks per millisecond. The code permits +- (1/30) msec
% jitter. This extraction is needed when collection was done on both
% rising and falling edges of data.
running = true;
ii = 1; % index into databurst nibble list
jj=1;   % index into reconstructed databurst byte stream
looking4upper = true;   % Each databurst byte is transmitted as 2 nibbles, lower first
lower = dbc(ii);    % The first nibble of the first byte of the next databurst
was = lower; % Use to look for nibble-to-nibble code changes
cki=ii;     % debugging variable
st_time = DBts(ii);  % timestamp to begin analysis for the next nibble 
maybeC = dbc(ii);   % initialize the candidate for the next nibble
while running % sit in this loop until we run out of databurst nibbles
    % Now seek the next entry that either has a different code, or is inc
    % (30) time units +-1 later, whichever comes first. If a different code
    % comes first this is too soon, abort.
    while DBts(ii) < (st_time+INC) ...% current time is within INC-1 later than start
            && (maybeC == was) &&...   % code is unchanged
            (ii < MAXraw)        % did not yet use up the raw databurst data
        ii=ii+1; % increment index, then assign maybeC. These are values on loop exit.
        maybeC = dbc(ii);
    end
    % Here when there is a new code nibble value, or the time for
    % the next databurst nibble is up, or the last DATABURST word has been
    % copied. In all cases, maybeC now contains the next candidate code
    % nibble, equaling dbc(ii)
    cki=[cki ii];   % debugging variable

    if (DBts(ii) < st_time+INC-1)
        toosoon=1; 
        fprintf('*Index %d-%d-%d, code change early: %d\n',ii,jj,kk,DBts(ii)-st_time) %possible error?
    else
        toosoon=0;% time to pick out these nibbles
    end
    
    if DBts(ii) > st_time + 4*INC    % further raw data is for NEXT databurst
        % Validate the previously processed "cooked" buffer
        if jj < DATABURSTSIZE   % this is an error case
            fprintf('**cooked smaller than expected (continuing): %d\n',jj)
        end
        
        % Get the first END word later than the just-completed databurst but
        % earlier than the next databurst
        TrialRetI = find(End.ts > DBts(ii-1), 1, 'first');
        % append to end of TrialRet array (one value for each cooked DB)
        if jj > DATABURSTSIZE & TrialRetI & End.ts(TrialRetI) < DBts(ii) 
            TrialRet = End.codes(TrialRetI);
        else
            % No END word between the previous and the next databursts; flag as error
            % & discard it.
            fprintf('**No END word between the previous and the next databursts\n')
            szckd = size(cooked,2);
            if kk ~= szckd
                error('no match in cooked size\n')
            end
            if szckd > 1
                cooked = cooked(:,szckd-1);
                TrialRet = TrialRet(1:szckd-1)
                kk=kk-1; % the prior databurst must be discarded
            else
                cooked = [];
                TrialRet=[];
                kk=0;
            end
            Pending.Start_ts = DBts(ii);
        end
        
        % save the timestamp value for start of next databurst
        Pending.Start_ts = DBts(ii);
        
        % If the remaining raw data do not make a complete databurst,
        % put the raw buffer into Pending and return.
        if DBts(MAXraw) < Pending.Start_ts+(DATABURSTSIZE-1)*INC*2
            disp('*Fragment in subsequent databurst')
            testclk=tic;
            StartPendingIdx = find(raw.ts==DBts(ii));
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
        st_time = DBts(ii);  % timestamp to begin analysis for the next nibble
        maybeC = dbc(ii);   % initialize the candidate for the next nibble
        
        continue
    end % END if DBts(ii) > st_time + 4*INC
    
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
    
    % Exit loop when current time is EITHER too soon (error) or too late, OR done
    % (next databurst)
    if  ii == MAXraw  % have scrubbed all available raw data
        % Note that the scenario of a starting fragment of a databurst was
        % handled above, where status='Fragment' was returned
        if jj < DATABURSTSIZE   % this is an error case
            fprintf('**cooked smaller than expected (end): %d\n',jj)
            Status = 'Discard';
        end
        % Get the first "end" word later than the just-completed databurst
        TrialRetI = find(End.ts > DBts(ii), 1, 'first');
        if TrialRetI % append to end of TrialRet array (one value for each cooked DB)
            TrialRet = [TrialRet End.codes(TrialRetI)];
        else
            % No END word in this batch; put current databurst into Pending,
            % flag it as a fragment, and return
            fprintf('*ending fragment, need END word\n')
            Status='Fragment';
            rawThisDBStartI = find(raw.ts==Pending.Start_ts);
            Pending.ts = raw.ts(rawThisDBStartI:numel(raw.ts));
            Pending.codes = raw.codes(rawThisDBStartI:numel(raw.ts));
            Pending.MissingEND = true;
            return;
        end
        Pending = InitPending();
        % default Status was set as Success at opening of function
        return
    end

    st_time = DBts(ii);  % timestamp for last nibble analyzed
    ii = ii+1;  % get next raw item for "while" loop above
    maybeC = dbc(ii);
end % END while running

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
