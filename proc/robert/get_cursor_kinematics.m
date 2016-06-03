function varargout=get_cursor_kinematics(inputItem)

% syntax varargout=get_cursor_kinematics(inputItem)
%
%              INPUT:
%                   inputItem - can either be left out, or 
%                               a path to the BDF-formatted
%                               .mat file, or a BDF-formatted
%                               struct from the workspace
%                               
%              OUTPUT:
%                   varargout - if specified, will return a BDF-formatted 
%                               struct with the .pos field having been 
%                               filled in from the BR log array.  If 
%                               unspecified, the function will save the 
%                               updated .mat file to the same location 
%                               from which the original .mat file was 
%                               read in.
%

startingPath=pwd;

if ~nargin                      % dialog for bdf
    [FileName,PathName]=uigetfile('*.mat','select a bdf file');
    pathToBDF=fullfile(PathName,FileName);
    load(pathToBDF)
    if exist('bdf','var')~=1
        if exist('out_struct','var')~=1
            error(['neither ''bdf'' or ''out_struct'' was found.\n', ...
                'if %s\n contains a properly formatted bdf structure, \n', ...
                'load it manually, then pass it as an argument.\n'])
        else
            bdf=out_struct;
            clear out_struct
            varName='out_struct';
        end
    else
        varName='bdf';
    end     % if we make it to this point we know the variable bdf exists.
else
    if ischar(inputItem) % path to bdf is input
        pathToBDF=inputItem;
        load(pathToBDF)
        if exist('bdf','var')~=1
            if exist('out_struct','var')~=1
                error(['neither ''bdf'' or ''out_struct'' was found.\n', ...
                    'if %s\n contains a properly formatted bdf structure, \n', ...
                    'load it manually, and pass it as an argument.\n'])
            else
                bdf=out_struct;
                clear out_struct
                varName='out_struct';
            end
        else
            varName='bdf';
        end     % if we make it to this point we know the variable bdf exists. 
        animal=regexp(bdf.meta.filename,'Chewie|Mini|Jaco','match','once');
        % now, re-direct to the BDF that's on citadel
        pathToBDF=findBDFonCitadel(regexprep(bdf.meta.filename,'\.plx','.mat'));
    else                % bdf has been passed in.
        bdf=inputItem;
        clear inputItem
        varName=inputname(1);
        % try to be smart about where bdf might be located.  Do something
        % with bdf.meta.filename
        CCMbank={'Chewie_8I2','Mini_7H1','Jaco_8I1'};
        animal=regexp(bdf.meta.filename,'Chewie|Mini|Jaco','match','once');
        if isempty(animal)
            % revert to dialog, because the name was not found in our
            % database.  But now, the dialog is looking for the text file
            [FileNameTxt,PathNameTxt]=uigetfile('*.txt','select the log file');
            pathToBR=fullfile(PathNameTxt,FileNameTxt);
            % this is stupid, but at least it keeps things consistent.
            % Just switch the logic on the application below.
            pathToBDF=regexprep(fullfile(PathNameTxt,FileNameTxt), ...
                {['BrainReader logs',filesep,'online'],'\.txt'},{'bdf','\.mat'});
        else
            if ismac
                % automagically, assuming /Volumes is the mount point for data.
                pathToCitadelData=fullfile('/Volumes','data', ...
                    CCMbank{cellfun(@isempty,regexp(CCMbank,animal))==0});
                [status,result]=unix(['find ',pathToCitadelData,' -name "', ...
                    regexprep(bdf.meta.filename,'\.plx','\.mat" -print')]);
            else
                % PC case.  Probably running on GOB, either during a
                % superBatch run, or stand-alone.  If stand-alone, slightly
                % more likely that the path of the data file in will be
                % citadel than local. If during superBatch, the network copy of the
                % BDF almost certainly won't exist yet.  Either way, assume
                % no local copies of brainReader logs exist.
                remoteDriveLetter=[citadelDriveLetter,':'];
                pathToCitadelData=fullfile(remoteDriveLetter, ...
                    CCMbank{cellfun(@isempty,regexp(CCMbank,animal))==0});
                [status,result]=dos(['cd /d ',pathToCitadelData,' && dir *', ...
                    regexprep(bdf.meta.filename,'\.plx','\.mat'),' /s /b']);
            end
            % evaluate, based on results of system commands to find file.
            if status==0
                pathToBDF=result;
            else
                % revert to dialog, we couldn't automagically locate the
                % BDF.  But now, the dialog is looking for the text file;
                % the pathToBDF will be reverse-lookup'd.
                [FileNameTxt,PathNameTxt]=uigetfile('*.txt','select a txt file');
                pathToBR=fullfile(PathNameTxt,FileNameTxt);
                % this is stupid, but at least it keeps things consistent.
                % Just switch the logic on the application below.
                pathToBDF=regexprep(fullfile(PathNameTxt,FileNameTxt), ...
                    {['BrainReader logs',filesep,'online'],'\.txt'},{'bdf','\.mat'});
            end
        end
    end
end

% strip out trailing CR, if present.
pathToBDF(regexp(pathToBDF,sprintf('\n')))='';


% load the BrainReader file
if ispc
    fsep=[filesep filesep]; % because regexp chokes on 1 backslash
else
    fsep=filesep;
end
switch animal
    case 'Mini'
        pathToBR=regexprep(pathToBDF,{'bdf','\.mat'}, ...
            {['BrainReader logs',fsep,'online'],'\.txt'});
    case 'Chewie'
        pathToBR=regexprep(pathToBDF,{'BDFs','\.mat'}, ...
            {['BrainReader logs',fsep,'online'],'\.txt'});
     case 'Jaco'
        pathToBR=regexprep(pathToBDF,{'bdf','\.mat'}, ...
            {['BrainReader logs',fsep,'online'],'\.txt'});
end
% just in case
pathToBR(regexp(pathToBR,sprintf('\n')))='';

% been burned too many times.  Check to see if file exists
if exist(pathToBR,'file')~=2
    fprintf(1,'file not found: %s\n',pathToBR)
    fprintf(1,'BDF unmodified\n')
    if nargout
        varargout{1}=bdf;
    end
    return
end
BRarray=readBrainReaderFile_function(pathToBR);

% get rid of any lead-in data
tmp=size(BRarray,1);
BRarray(BRarray(:,7)==0,:)=[];
fprintf(1,'deleted %d lines with time stamp=0\n',tmp-size(BRarray,1))

BR_original_time_vector=BRarray(:,7);
% scale time vector
BRarray(:,7)=BRarray(:,7)/1e9;
BRarray(:,7)=BRarray(:,7)-BRarray(1,7);

% to do a back-corrected BR log file: put a breakpoint at the first line of
% code that occurs below these comments. then, at the command line:
%
% BR_original_time_vector(find(BRarray(:,7)>=start_time,1,'first'))
%
% where start_time is something you've already determined in the past,
% using BRalign.m If you're going to run BRalign.m again, just do this
% operation there, it's simpler.
%
% if it comes out looking like    4.4182e+12
% just call
%
% format long g
% 
% and reissue the command.  Once you've got something more like
%
% 4418176548864
%
% copy that, open up the BR log in a text editor (NOT windows, it won't
% like the carriage returns/linefeeds/whatever), do a find on that number
% (the EXACT number should be represented in the time array), and then ON
% THE LINE ABOVE where the number was found, insert a blank line, and type 
%
% Plexon recording startup
%
% save, and re-execute this function.  It should run properly at that
% point.

if isfield(bdf.raw, 'analog') && ~isempty(bdf.raw.analog.data)
    % The highest analog sample rate (local copy)
    adfreq = max(bdf.raw.analog.adfreq);
    
    start_time = floor(1.0 + bdf.raw.analog.ts{1}(1));
    % By taking the min here, we should be accounting for the situation
    % where Reach stops writing its file, well before SortClient, either
    % because it was stopped by the user or because it crashed.
    if isfield(bdf.raw.analog,'fn')
        last_analog_time = min(cellfun(@(x) x(numel(x)),bdf.raw.analog.ts)+ ...
            (cellfun(@(x) x(numel(x)),bdf.raw.analog.fn)./bdf.raw.analog.adfreq));
    else        
        if max(cellfun(@numel,bdf.raw.analog.ts)) > 1
            warning('get_cursor_kinematics:fplength', ...
                ['bdf.raw.analog.ts > 1, while no .fn field\n\t\t was detected', ...
                'in bdf.raw.analog.\n\t\t Timing info may be inaccurate.'])
        end
        last_analog_time = min(cellfun(@(x) x(1),bdf.raw.analog.ts) + ...
            cellfun('length',bdf.raw.analog.data) / bdf.raw.analog.adfreq);
    end
    
    last_BR_time=BRarray(end,7);
    if isfield(bdf.raw,'enc') && ~isempty(bdf.raw.enc)
        last_enc_time = bdf.raw.enc(end,1);
        stop_time = floor( min( [last_enc_time last_analog_time last_BR_time] ) ) - 1;
    else
        stop_time = floor(last_analog_time)-1;
    end
    
    % Note: This uses the time base of the highest frequency analog
    % signal as the time base for interpolated signals like position
    analog_time_base = start_time:1/adfreq:stop_time;
else
    % There was no analog data, so we need a default timebase for
    % the encoder
    adfreq = 1000; %Arbitrarily 1KHz
    start_time = 1.0;
    last_enc_time = bdf.raw.enc(end,1);
    stop_time = floor(last_enc_time) - 1;
    analog_time_base = start_time:1/adfreq:stop_time;
end

% interpolate BRarray to 50msec bins before substituting in for bdf.pos.
% newTvector=0:0.05:0.05*(size(BRarray,1)-1);
% if Reach crashed at the end, e.g. because the linux box ran out of
% memory, the gaps between successive time points will be wider than 50
% msec.  Does this have an effect on predicted velocities?  If so, we need
% to account for that effect when looking at the velocty values.

% mark times where Reach was lagging.  We may want to cut these out later,
% since these predictions may be more inaccurate than the rest.
excessDT={0.06,BRarray(find(diff(BRarray(:,7))>0.06)+1,7)};

newTvector=start_time:0.05:stop_time;

newXpos=interp1(BRarray(:,7),BRarray(:,3),newTvector);
newYpos=interp1(BRarray(:,7),BRarray(:,4),newTvector);
bdf.pos=[newTvector' newXpos' newYpos'];

newXvel=interp1(BRarray(:,7),BRarray(:,5),newTvector);
newYvel=interp1(BRarray(:,7),BRarray(:,6),newTvector);
bdf.vel=[newTvector' newXvel' newYvel'];

% bdf.vel=BRarray(:,[7 5 6]);
% bdf.pos=BRarray(:,[7 3 4]);

bdf.meta.brain_control=1;
decoderDate=decoderDateFromLogFile(pathToBR);
bdf.meta.control=decoderTypeFromLogFile(pathToBR);
% could just floor the datenum, you know...
bdfDate=datenum(regexp(bdf.meta.datetime,'\s*[0-9]+/\s*[0-9]+/[0-9]+','match','once'));
bdf.meta.decoder_age=bdfDate-decoderDate;
% could look into the brainReader file as it's read in, guess from the
% decoder file's name whether it was spike control or LFP control, and save
% that info in bdf.meta.brain_control, rather than just a 1.

original_words=bdf.words;
try
    opts=evalin('caller','opts');
catch exception
    if strcmp(exception.identifier,'MATLAB:UndefinedFunction')
        opts=struct('version',2,'includeFails',0);
    else
        rethrow(exception)
    end
end
if floor(datenum(bdf.meta.datetime)) <= datenum('09-12-2011')
    opts.version=1; opts.hold_time=0.1;
    % Inside get_cursor_kinematics.m, we can assume brain control.
    % Insert a target_entry_word into bdf.words.  Only for success trials.
    % make sure to start with the first complete trial in the recording
    beginFirstTrial=find(bdf.words(:,2)==18,1,'first');
    if beginFirstTrial > 1
        bdf.words(1:beginFirstTrial-1,:)=[];
    end
    successTrials=bdf.words(bdf.words(:,2)==32,:);
    for n=1:size(successTrials,1)
        bdfWordsPosition=find(bdf.words(:,1)<successTrials(n,1));
        bdf.words=[bdf.words(bdfWordsPosition,:); [successTrials(n,1) 49]; ...
            bdf.words(bdfWordsPosition(end)+1:end,:)];
    end
end
[bdf.kin.path_length,bdf.kin.time_to_target,bdf.kin.hitRate,bdf.kin.hitRate2, ...
    bdf.kin.speedProfile,bdf.kin.pathReversals,bdf.kin.trialTS, ...
    bdf.kin.intertarget_distance,bdf.kin.slidingAccuracy, ...
    bdf.kin.slidingTime]=kinematicsHandControl2(bdf,opts);
bdf.words=original_words;

[workspaceList,~]=dbstack;
if ~isequal(workspaceList(length(workspaceList)).file,[mfilename,'.m'])
    % means ISN'T being called from the command line
    assignin('caller','decoder_age',bdf.meta.decoder_age)
end

if nargout
    varargout{1}=bdf;
else
    % automatically re-save the bdf
    if strcmp(varName,'out_struct')
        out_struct=bdf;
        clear bdf
    end
    save(pathToBDF,varName)
end
% make sure we end where we started.
cd(startingPath)