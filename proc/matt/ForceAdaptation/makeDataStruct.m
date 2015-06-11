function load_success = makeDataStruct(params, fileType, convertNEVFiles)
% MAKEDATASTRUCT  Create general data struct from Cerebus data
%
%   Loads data recorded on a session and converts into my proprietary data
% struct format.
%
% INPUTS:
%   expParamFile: (string) path to file containing experimental parameters
%   dataDir: (string) root directory where data is kept
%   outDir: (string) root directory for output
%   fileType: (string) 'nev' or 'nevnsx'
%   convertNEVFiles: (bool) whether to convert NEV files to BDF
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

% highest channel to expect
maxChannel = 96;

if nargin < 3
    convertNEVFiles = true;
    if nargin < 2
        fileType = 'nev';
        if nargin < 1
            error('No parameter file provided');
        end
    end
end

outDir = params.outDir;
dataDir = params.dataDir;

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load some of the experimental parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
useUnsorted = params.useUnsorted;
useDate = params.exp.date;
monkey = params.exp.monkey;
arrays = params.exp.arrays;
bdfArray = params.exp.bdf_array;
task = params.exp.task;
adaptType = params.exp.adaptation_type;
epochs = params.exp.epochs;
rotationAngle = params.exp.rotation_angle;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% parse the date parts from useDate
y = useDate(1:4);
m = useDate(6:7);
d = useDate(9:10);

%% Before we do anything, make sure a cerebus file of correct type exists
load_success = 1;
if ~iscell(arrays)
    arrays = {arrays};
end

for iArray = 1:length(arrays)
    switch lower(fileType)
        case 'nev'
            cerName = [monkey '_' arrays{iArray} '_' task '_' adaptType '_BL_' m d y '_001-s.nev'];
            cerPath = fullfile(dataDir,arrays{iArray},'CerebusData',useDate);
            cerFile = fullfile(cerPath,cerName);
            
            if ~exist(cerFile,'file') % probably not sorted, so do this
                cerName = [monkey '_' arrays{iArray} '_' task '_' adaptType '_BL_' m d y '-s.nev'];
                cerPath = fullfile(dataDir,arrays{iArray},'CerebusData',useDate);
                cerFile = fullfile(cerPath,cerName);
                if ~exist(cerFile,'file') % probably not sorted, so do this
                    load_success = 0;
                end
            end
        case 'nevnsx'
            cerName = [monkey '_' arrays{iArray} '_' task '_' adaptType '_BL_' m d y '_001-s.mat'];
            cerPath = fullfile(dataDir,arrays{iArray},'CerebusData',useDate);
            cerFile = fullfile(cerPath,cerName);
            
            if ~exist(cerFile,'file') % probably not sorted, so do this
                cerName = [monkey '_' arrays{iArray} '_' task '_' adaptType '_BL_' m d y '-s.mat'];
                cerPath = fullfile(dataDir,arrays{iArray},'CerebusData',useDate);
                cerFile = fullfile(cerPath,cerName);
                if ~exist(cerFile,'file') % probably not sorted, so do this
                    load_success = 0;
                end
            end
    end
end

if load_success
    
    % convert the file with continuous data into bdf if not done so
    if convertNEVFiles
        convertDataToBDF(fullfile(dataDir,bdfArray,'CerebusData'),useDate);
    end
    
    %% start building the structs, new file for each epoch
    for iEpoch = 1:length(epochs)
        currEpoch = epochs{iEpoch};
        % assume that each epoch file has a particular number appended
        
        disp(['Getting data for the ' currEpoch ' file...']);
        
        switch currEpoch
            case 'BL'
                filenum = '001';
            case 'AD'
                filenum = '002';
            case 'WO'
                filenum = '003';
        end
        
        bdfName = [monkey '_' bdfArray '_' task '_' adaptType '_' currEpoch '_' m d y '.mat'];
        outName = [task '_' adaptType '_' currEpoch '_' useDate '.mat'];
        
        bdfPath = fullfile(dataDir,bdfArray,'BDFStructs',useDate);
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
        
        disp('Getting trial table...');
        [tt, x_offset, y_offset, tgt_size] = ff_trial_table(tempTask,out_struct);
        
        pos(:,1) = pos(:,1)+(x_offset-2);
        pos(:,2) = pos(:,2)+(y_offset+2);
        
        %% Turn that into a movement table
        if strcmpi(tempTask,'RT')
            % rotate position to get target directions
            
            if strcmpi(adaptType,'VR') || strcmpi(adaptType,'VRFF')
                R = [cos(rotationAngle) -sin(rotationAngle); sin(rotationAngle) cos(rotationAngle)];
                newPos = zeros(size(pos));
                for j = 1:length(pos)
                    newPos(j,:) = R*(pos(j,:)');
                end
                newPos = zeros(size(pos));
                for j = 1:length(pos)
                    newPos(j,:) = R*(pos(j,:)');
                end
                
                % adjust for an offset from my math above
                offset = [newPos(1,1)-pos(1,1), newPos(1,2)-pos(1,2)];
                newPos(:,1) = pos(:,1)+offset(1);
                newPos(:,2) = pos(:,2)+offset(2);
            else
                newPos = pos;
            end
            
            [mt,centers] = getMovementTable(tt,tempTask);
            clear newPos;
        else
            [mt,centers] = getMovementTable(tt,tempTask);
        end
        
        clear moveWins moveCurvs allInds useT idx mPeak mStart mEnd iMove tMove relMoves blockTimes moveCurves spd;
        
        %% Get neural data
        load_success = 1;
        disp('Getting neural data...')
        for iArray = 1:length(arrays)
            currArray = arrays{iArray};
            
            switch fileType
                case 'nev' % loading the data from nev files
                    cerName = [monkey '_' currArray '_' task '_' adaptType '_' currEpoch '_' m d y '_' filenum '-s.nev'];
                    cerPath = fullfile(dataDir,currArray,'CerebusData',useDate);
                    cerFile = fullfile(cerPath,cerName);
                    
                    if ~exist(cerFile,'file') % probably not sorted, so do this
                        cerName = [monkey '_' currArray '_' task '_' adaptType '_' currEpoch '_' m d y '-s.nev'];
                        cerPath = fullfile(dataDir,currArray,'CerebusData',useDate);
                        cerFile = fullfile(cerPath,cerName);
                        if ~exist(cerFile,'file') % probably not sorted, so do this
                            load_success = 0;
                        end
                    end
                    
                    if load_success
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
                            % never will have ones higher than this
                            if ~isempty(units) && channel <= maxChannel
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
                                    
                                    u(unitCount).id = id;
                                    u(unitCount).wf = wf;
                                    u(unitCount).ts = ts;
                                    u(unitCount).ns = ns;
                                    u(unitCount).p2p = p2p;
                                    u(unitCount).misi = misi;
                                    u(unitCount).mfr = mfr;
                                    u(unitCount).offline_sorter_channel = channel;
                                    
                                    
                                end
                            end
                        end
                        
                        [~,idx] = sort(sg(:,1));
                        sg = sg(idx,:);
                        
                        ns_CloseFile(hfile);
                        
                        % store unit data in the struct
                        data.(currArray).units = u;
                        data.(currArray).sg = sg;
                    end
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                case 'nevnsx' % loading the data from nevnsx structs
                    nevnsxSampRate = 30000;
                    
                    %                 cerName = [monkey '_' currArray '_' task '_' adaptType '_' currEpoch '_' m d y '-s.mat'];
                    cerName = [monkey '_' currArray '_' task '_' adaptType '_' currEpoch '_' m d y '_' filenum '-s.mat'];
                    cerPath = fullfile(dataDir,currArray,'CerebusData',useDate);
                    cerFile = fullfile(cerPath,cerName);
                    
                    if ~exist(cerFile,'file') % probably not sorted, so do this
                        
                        cerName = [monkey '_' currArray '_' task '_' adaptType '_' currEpoch '_' m d y '-s.mat'];
                        cerPath = fullfile(dataDir,currArray,'CerebusData',useDate);
                        cerFile = fullfile(cerPath,cerName);
                        if ~exist(cerFile,'file') % probably not sorted, so do this
                            load_success = 0;
                        end
                    end
                    
                    
                    load(cerFile,'NEV');
                    
                    electrodes = NEV.Data.Spikes.Electrode;
                    
                    uelecs = unique(electrodes);
                    
                    % for now, hard code to be 96 channels
                    uelecs = uelecs(uelecs <= 96);
                    
                    unitCount = 0;
                    sg = [];
                    for channel = 1:length(uelecs)
                        
                        inds = electrodes == uelecs(channel);
                        
                        unitIDs = NEV.Data.Spikes.Unit(inds);
                        timestamps = double(NEV.Data.Spikes.TimeStamp(inds))/nevnsxSampRate;
                        waveforms = NEV.Data.Spikes.Waveform(:,inds);
                        
                        chanName = ['elec' num2str(uelecs(channel))];
                        
                        % remove any indices that don't exist, or are unsorted/invalidated
                        if useUnsorted
                            remInds = unitIDs == 255;
                        else
                            remInds = unitIDs == 0 | unitIDs == 255;
                        end
                        unitIDs(remInds) = [];
                        timestamps(remInds) = [];
                        waveforms(:,remInds) = [];
                        
                        units = unique(unitIDs);
                        % never will have ones higher than this
                        if ~isempty(units) && channel <= maxChannel
                            for iu=1:length(units)
                                unitCount = unitCount + 1;
                                
                                idx = unitIDs == units(iu);
                                wf = waveforms(:,idx);
                                ts = timestamps(idx);
                                
                                p2p = mean(max(wf,[],1) - min(wf,[],1)); % average peak to peak of waveforms
                                ns = size(wf,2); % number of spikes
                                mfr = ns/ts(end); % mean firing rate over trial
                                
                                isi = diff(ts);
                                
                                misi = mean(isi(isi < 1)); %mean isi
                                
                                % make a spike guide to make it easy to compare units in each file
                                id = [double(uelecs(channel)), iu];
                                sg = [sg; id];
                                
                                u(unitCount).id = id;
                                u(unitCount).wf = wf;
                                u(unitCount).ts = ts;
                                u(unitCount).ns = ns;
                                u(unitCount).p2p = p2p;
                                u(unitCount).misi = misi;
                                u(unitCount).mfr = mfr;
                                u(unitCount).offline_sorter_channel = channel;
                                
                            end
                        end
                    end
                    
                    [~,idx] = sort(sg(:,1));
                    sg = sg(idx,:);
                    
                    % store unit data in the struct
                    data.(currArray).units = u;
                    data.(currArray).sg = sg;
                    
            end
            
            clear iu units unitIDs waveforms timestamps_wf remInds nsresult sampleCount channel chanName wf ts p2p ns hfile inds seg_list unit_list FileInfo EntityInfo iMove
            
        end
        
        disp('Writing data to struct...')
        % has continuously sampled data
        c.t = t;
        if isfield(out_struct,'force')
            c.force = out_struct.force(:,2:3);
        else
            c.force = [];
        end
        c.pos = pos;
        c.vel = vel;
        c.acc = acc;
        
        clear out_struct t pos vel acc;
        
        % some metadata
        meta.cont_file = bdfFile;
        meta.neur_file = cerFile;
        meta.out_directory = outPath;
        meta.time_created = datestr(now);
        meta.recording_date = useDate;
        meta.arrays = arrays;
        meta.monkey = monkey;
        meta.perturbation = adaptType;
        meta.task = task;
        meta.epoch = epochs{iEpoch};
        
        data.meta = meta;
        data.cont = c;
        data.params = params;
        data.trial_table = tt;
        data.movement_table = mt;
        data.movement_centers = centers;
        
        clear meta t u c;
        
        disp(['Saving data to ' outFile '...'])
        
        save(outFile,'-struct','data');
        
    end
end