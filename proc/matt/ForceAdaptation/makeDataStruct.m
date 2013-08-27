function data = makeDataStruct(expParamFile, useUnsorted)
%%
if nargin < 2
    useUnsorted = false; %by default, exclude unit IDs of 0
    if nargin < 1
        expParamFile = 'Z:\MrT_9I4\Matt\2013-08-13_experiment_parameters.dat';
    end
end

%% get parameters from file
params = parseExpParams(expParamFile);

baseDir = params.baseDir{1};
outDir = params.outDir{1};
useDate = params.useDate{1};
monkey = params.monkey{1};
useArray = params.useArray;
bdfArray = params.bdfArray{1};
taskType = params.taskType{1};
adaptType = params.adaptType{1};
epochs = params.epochs;
numWF = str2double(params.numWF{1});
holdTime = str2double(params.holdTime{1});
forceMag = str2double(params.forceMag{1});
forceAng = str2double(params.forceAng{1});

clear params

paramFile = fullfile(outDir, useDate, [ useDate '_analysis_parameters.dat']);
params = parseExpParams(paramFile);
latency = str2double(params.pmd_latency{1});
binSize = str2double(params.angle_bin_size{1});
moveThresh = str2double(params.movement_threshold{1});
winSize = str2double(params.movement_time{1});
curvWin = str2double(params.curvature_window{1});
clear params;


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
    
    bdfName = [monkey '_' bdfArray '_' taskType '_' adaptType '_' currEpoch '_' m d y '_' filenum '.mat'];
    outName = [taskType '_' adaptType '_' currEpoch '_' y '-' m '-' d '.mat'];
    
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
    spd = sqrt(vel(:,1).^2 + vel(:,2).^2);
    
    %% Get the trial table
    tt = ff_trial_table(taskType,out_struct,holdTime);
    
    %% Turn that into a movement table
    mt = getMovementTable(tt,taskType);
    
    %% Here's what I want to do... get movement windows based on mt
    % find fr and theta for each movement window
    % do ANOVA on peak and pre (?) to see if it's tuned for direction?
    % compute tcs for each window and save them?
    
    %% Get movement information
    % find times when velocity goes above that threshold
    disp('Getting movement data...')
    moveInds = diff(spd > moveThresh);
    moveOn = find(moveInds > 0);
    moveOff = find(moveInds < 0);
    % check to make sure nothing fishy is going on
    if moveOff(1) < moveOn(1)
        moveOff(1) = [];
    end
    
    moveWins = zeros(length(moveOff),2);
    for iMove = 1:length(moveOff)
        mStart = t(moveOn(iMove));
        mEnd = t(moveOff(iMove));
        
        % get the relevant velocity data
        useT = t(t >= mStart & t < mEnd,:);
        
        % find the time of peak speed in that window
        [~,idx] = max(spd(t >= mStart & t < mEnd,:));
        mPeak = useT(idx);
        
        moveWins(iMove,:) = [mPeak-winSize/2, mPeak+winSize/2];
    end
    
    disp('Getting curvature adaptation data...')
    % now group curvatures in blocks to track adaptation
    blockTimes = t(1):curvWin:t(end);
    curvMeans = zeros(1,length(blockTimes)-1);
    curvSTDs = zeros(1,length(blockTimes)-1);
    for tMove = 1:length(blockTimes)-1
        relMoves = moveWins(:,1) >= blockTimes(tMove) & moveWins(:,1) < blockTimes(tMove+1);
        relMoves = moveWins(relMoves,:);
        allInds = [];
        for iMove = 1:size(relMoves,1)
            idx = find(t >= relMoves(iMove,1) & t < relMoves(iMove,2));
            allInds = [allInds; idx];
        end
        %compute mean curvature over movement
        moveCurvs = ( vel(allInds,1).*acc(allInds,2) - vel(allInds,2).*acc(allInds,1) )./( (vel(allInds,1).^2 + vel(allInds,2).^2).^(3/2) );
        curvMeans(tMove) = mean(moveCurvs);
        curvSTDs(tMove) = std(moveCurvs);
    end

    % has info on movement
    r.curvature_block_times = blockTimes(1:end-1)';
    r.curvature_means = curvMeans;
    r.curvature_stds = curvSTDs;
    r.movement_table = mt;

    clear moveWins moveCurvs allInds useT idx mPeak mStart mEnd iMove tMove relMoves blockTimes moveCurves mt spd;
    
    %% Get neural data
    disp('Getting neural data...')
    for iArray = 1:length(useArray)
        currArray = useArray{iArray};
        cerName = [monkey '_' currArray '_' taskType '_' adaptType '_' currEpoch '_' m d y '_' filenum '_sorted.nev'];
        cerPath = fullfile(baseDir,currArray,'CerebusData',useDate);
        cerFile = fullfile(cerPath,cerName);
        
        
        if ~exist(cerFile,'file') % probably not sorted, so do this
            cerName = [monkey '_' currArray '_' expType '_' currEpoch '_' m d y '_' filenum '.nev'];
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
            disp('Retrying with 64 bit version...');
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
            
            % Load the first numWF waveforms on each seelected channel
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
                    
                    misi = mean(diff(ts)); %mean isi
                    
                    u.(chanName).(['unit' num2str(units(iu))]).wf = wf;
                    u.(chanName).(['unit' num2str(units(iu))]).ts = ts;
                    u.(chanName).(['unit' num2str(units(iu))]).ns = ns;
                    u.(chanName).(['unit' num2str(units(iu))]).p2p = p2p;
                    u.(chanName).(['unit' num2str(units(iu))]).misi = misi;
                    
                    % make a spike guide to make it easy to compare units in each file
                    sg = [sg; str2double(chanName(isstrprop(chanName,'digit'))), iu];
                end
            else
                disp('no units');
            end
        end
        
        [~,idx] = sort(sg(:,1));
        sg = sg(idx,:);
        
        ns_CloseFile(hfile);
        
        % store unit data in the struct
        data.(currArray).units = u;
        data.(currArray).unit_guide = sg;
        data.(currArray).tuning = []; % initialize tuning field to be filled in later
        
        clear iu units unitIDs waveforms timestamps_wf remInds nsresult sampleCount channel chanName wf ts p2p ns hfile inds seg_list unit_list FileInfo EntityInfo iMove
        
    end
    
    clear m d y;
    
    disp('Writing data to struct...')
    % has continuously sampled data
    c.t = t;
    c.force = out_struct.force(:,2:3);
    c.pos = pos;
    c.vel = vel;
    
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
    m.task = taskType;
    m.epoch = epochs{iEpoch};
    
    p.hold_time = holdTime;
    p.window_size = winSize;
    p.force_mag = forceMag;
    p.force_ang = forceAng;
    p.unit_count = unitCount;
    p.latency = latency;
    
    data.meta = m;
    data.movements = r;
    data.cont = c;
    data.params = p;
    data.trial_table = tt;
    
    clear m t u c;
    
    disp('Saving data...')
    save(outFile,'data');
    
end