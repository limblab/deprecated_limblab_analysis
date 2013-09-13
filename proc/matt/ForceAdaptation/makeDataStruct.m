function [data, useUnsorted] = makeDataStruct(expParamFile, useUnsorted)
% MAKEDATASTRUCT  Create general data struct from Cerebus data
%
%   Loads data recorded on a session and converts into my proprietary data
% struct format.
%
% INPUTS:
%   expParamFile: (string) path to file containing experimental parameters
%   useUnsorted: (bool) whether to include unsorted units
%
% OUTPUTS:
%   data: the struct with the following main fields
%       params: experimental parameters
%       meta: meta data about the experiment and files
%       cont: continuously sampled data (kinematics etc)
%       (arraynames): struct for each array name provided with neural info
%       trial_table: table with info on each trial for the task
%       movement_table: like trial table, but based on individual movements
%   useUnsorted: (bool) whether unsorted spikes were included
%
% NOTES:
%   - This function will automatically write the data struct to a file, too
%   - See "experimental_parameters_doc.m" for documentation on expParamFile

%% sort out inputs

    if nargin < 2
        useUnsorted = false; %by default, exclude unit IDs of 0
        if nargin < 1
            error('No parameter file provided');
        end
    end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load some of the experimental parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
params = parseExpParams(expParamFile);
baseDir = params.base_dir{1};
outDir = params.out_dir{1};
useDate = params.date{1};
monkey = params.monkey{1};
useArray = params.arrays;
bdfArray = params.bdf_array{1};
task = params.task{1};
adaptType = params.adaptation_type{1};
epochs = params.epochs;
holdTime = str2double(params.target_hold_low{1});
forceMag = str2double(params.force_magnitude{1});
forceAng = str2double(params.force_angle{1});
rotationAng = str2double(params.rotation_angle{1});
clear params
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% convert the file with continuous data into bdf if not done so
convertDataToBDF(fullfile(baseDir,bdfArray),useDate);

%% start building the structs, new file for each epoch
for iEpoch = 1:length(epochs)
    currEpoch = epochs{iEpoch};
    % assume that each epoch file has a particular number appended
    
    disp(['Getting data for the ' currEpoch ' file...']);
    
    filenum = ''; % gives the option of overriding the assumed numbers
    if isempty(filenum)
        switch currEpoch
            case 'BL'
                filenum = '001';
            case 'AD'
                filenum = '002';
            case 'WO'
                filenum = '003';
        end
    end
    
    % parse the date parts from useDate
    y = useDate(1:4);
    m = useDate(6:7);
    d = useDate(9:10);
    
    bdfName = [monkey '_' bdfArray '_' task '_' adaptType '_' currEpoch '_' m d y '_' filenum '.mat'];
    outName = [task '_' adaptType '_' currEpoch '_' y '-' m '-' d '.mat'];
    
    bdfPath = fullfile(baseDir,bdfArray,'BDFStructs',useDate);
    outPath = fullfile(outDir,useDate);
    bdfFile = fullfile(bdfPath,bdfName);
    outFile = fullfile(outPath,outName);
    
    if ~exist(outPath,'dir')
        mkdir(outPath);
    end
    
    %% load the bdf with the continuous data
    disp('Loading BDF file with continuous data...')
    load(bdfFile);
    t = out_struct.pos(:,1);
    pos = out_struct.pos(:,2:3);
    vel = out_struct.vel(:,2:3);
    acc = out_struct.acc(:,2:3);
    
    %% Get the trial table
    %  CRC is a case where Center Out is BL and WO and AD is RT
    if strcmpi(task,'CRC') && strcmpi(epochs{iEpoch},'AD')
        tempTask = 'RT';
    elseif strcmpi(task,'CRC') && ~strcmpi(epochs{iEpoch},'AD')
        tempTask = 'CO';
    else
        tempTask = task;
    end
    
    tt = ff_trial_table(tempTask,out_struct);
    
    %% Turn that into a movement table
    mt = getMovementTable(tt,tempTask);

    clear moveWins moveCurvs allInds useT idx mPeak mStart mEnd iMove tMove relMoves blockTimes moveCurves spd;
    
    %% Get neural data
    disp('Getting neural data...')
    for iArray = 1:length(useArray)
        currArray = useArray{iArray};
        cerName = [monkey '_' currArray '_' task '_' adaptType '_' currEpoch '_' m d y '_sorted.nev'];
        cerPath = fullfile(baseDir,currArray,'CerebusData',useDate);
        cerFile = fullfile(cerPath,cerName);
        
        
        if ~exist(cerFile,'file') % probably not sorted, so do this
            cerName = [monkey '_' currArray '_' task '_' adaptType '_' currEpoch '_' m d y '_' filenum '.nev'];
            cerPath = fullfile(baseDir,currArray,'CerebusData',useDate);
            cerFile = fullfile(cerPath,cerName);
            useUnsorted = true; % include unsorted units since none will be sorted
            
            if ~exist(cerFile,'file') % now we're really in trouble
                error('ERROR: Could not find either a sorted or unsorted file with the specified name.');
            end
        end
        
        % load cerebus data to make waveform plots
        % Load the Cerebus library
        [nsresult] = ns_SetLibrary(which('nsNEVLibrary.dll'));
        if (nsresult ~= 0)
            %try again with 64 bit library...
            [nsresult] = ns_SetLibrary(which('nsNEVLibrary64.dll'));
            %disp('Retrying with 64 bit version...');
            if (nsresult ~=0)
                close(h);
                error('Error opening library!');
            end
        end
        
        % Load the file
        [nsresult, hfile] = ns_OpenFile(cerFile);
        if (nsresult ~= 0)
            error('Error opening file!');
        end
        
        % Get general file info (EntityCount, TimeStampResolution and TimeSpan)
        [nsresult, FileInfo] = ns_GetFileInfo(hfile);
        if (nsresult ~= 0)
            close(h);
            error('Data file information did not load!');
        end
        
        [nsresult, EntityInfo] = ns_GetEntityInfo(hfile, 1:FileInfo.EntityCount);
        unit_list = find([EntityInfo.EntityType] == 4);
        seg_list = find([EntityInfo.EntityType] == 3);
        
        unitCount = 0;
        sg = [];
        for channel = 1:length(seg_list)
            chanName = EntityInfo(channel).EntityLabel;
            %     [nsresult, nsSegmentInfo] = ns_GetSegmentInfo(hfile, seg_list(channel));
            %     [nsresult, nsSegmentSourceInfo] = ns_GetSegmentSourceInfo(hfile, seg_list(channel), 1);
            numWF = EntityInfo(channel).ItemCount; % how many waveforms are there?
            
            % Load the waveforms on each seelected channel
            [nsresult, timestamps_wf, waveforms, ~, unitIDs] = ns_GetSegmentData(hfile, seg_list(channel), 1:numWF);
            % remove any indices that don't exist, or are unsorted/invalidated
            if useUnsorted
                remInds = unitIDs == 255;
            else
                remInds = unitIDs == 0 | unitIDs == 255;
            end
            timestamps_wf(remInds) = [];
            waveforms(:,remInds) = [];
            unitIDs(remInds) = [];
            
            units = unique(unitIDs);
            if ~isempty(units)
                for iu=1:length(units)
                    unitCount = unitCount + 1;
                    
                    idx = unitIDs == units(iu);
                    wf = waveforms(:,idx);
                    ts = timestamps_wf(idx);
                    
                    p2p = mean(max(wf,[],1) - min(wf,[],1)); % average peak to peak of waveforms
                    ns = size(wf,2); % number of spikes
                    mfr = ns/ts(end); % mean firing rate over trial
                    
                    isi = diff(ts);
                    
                    misi = mean(isi(isi < 1)); %mean isi
                    
                    % make a spike guide to make it easy to compare units in each file
                    id = [str2double(chanName(isstrprop(chanName,'digit'))), iu];
                    sg = [sg; id];
                    
                    u.(chanName).(['unit' num2str(units(iu))]).id = id;
                    u.(chanName).(['unit' num2str(units(iu))]).wf = wf;
                    u.(chanName).(['unit' num2str(units(iu))]).ts = ts;
                    u.(chanName).(['unit' num2str(units(iu))]).ns = ns;
                    u.(chanName).(['unit' num2str(units(iu))]).p2p = p2p;
                    u.(chanName).(['unit' num2str(units(iu))]).misi = misi;
                    u.(chanName).(['unit' num2str(units(iu))]).mfr = mfr;
                    
                    
                end
            end
        end
        
        [~,idx] = sort(sg(:,1));
        sg = sg(idx,:);
        
        ns_CloseFile(hfile);
        
        % store unit data in the struct
        data.(currArray).units = u;
        data.(currArray).unit_guide = sg;
        
        clear iu units unitIDs waveforms timestamps_wf remInds nsresult sampleCount channel chanName wf ts p2p ns hfile inds seg_list unit_list FileInfo EntityInfo iMove
        
    end
    
    clear m d y;
    
    disp('Writing data to struct...')
    % has continuously sampled data
    c.t = t;
    c.force = out_struct.force(:,2:3);
    c.pos = pos;
    c.vel = vel;
    c.acc = acc;
    
    clear out_struct t pos vel acc;
    
    % some metadata
    m.cont_file = bdfFile;
    m.neur_file = cerFile;
    m.out_directory = outPath;
    m.time_created = datestr(now);
    m.recording_date = useDate;
    m.arrays = useArray;
    m.monkey = monkey;
    m.perturbation = adaptType;
    m.task = task;
    m.epoch = epochs{iEpoch};
    
    p.hold_time = holdTime;
    p.force_magnitude = forceMag;
    p.force_angle = forceAng;
    p.rotation_angle = rotationAng;
    p.unit_count = unitCount;
    
    data.meta = m;
    data.cont = c;
    data.params = p;
    data.trial_table = tt;
    data.movement_table = mt;
    
    clear m t u c;
    
    disp(['Saving data to ' outFile '...'])
    
    save(outFile,'data');
    
end