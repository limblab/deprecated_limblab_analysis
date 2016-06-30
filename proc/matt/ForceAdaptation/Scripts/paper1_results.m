%% Get different values and statistics for the paper, make figures, etc
% These are the sessions I will use
clear;
close all;
clc;

root_dir = 'F:\';
save_file = 'm1_cf_summary_results.mat';

rewriteFiles = false;

exclude_files = {'Mihili','2014-12-11','FF','CO'};

%% process or load data
if exist(fullfile(root_dir,save_file),'file') && ~rewriteFiles % load it up
    disp('Loading data...');
    load(fullfile(root_dir,save_file));
    disp('Done.');
    
else % gotta do the summary analysis
    dataSummary;
    
    useArray = 'M1';
    monkeys = {'Chewie','Mihili'};
    epochs = {'BL','AD','WO'};
    tasks = {'CO'};
    perts = {'FF','CS'};
    
    cbs.FF = [1 4 7];
    cbs.CS = [1 2 3];
    tuningMethod = 'regression';
    tuningPeriod = 'onpeak';
    psn.FF = 'movement';
    psn.CS = 'movement_cs';

    % get the files that are relevant
    allFiles = sessionList(ismember(sessionList(:,1),monkeys) & ismember(sessionList(:,3),perts) & ismember(sessionList(:,4),tasks),:);
    
    % Check to ensure the matlab pool is open if parallel is desired
    if isempty(gcp('nocreate'))
        disp('Matlab pool not found. Opening pool...');
        parpool;
    end
    
    %%% Do a statistical comparison of beginning and end of adaptation
    % Pick some metric, make sure every session meets requirements
    summary = struct();
    
    %%% Get the number of sessions of each type from each monkey
    for iTask = 1:length(tasks)
        for iMonk = 1:length(monkeys)
            numSessions = sum( strcmpi(allFiles(:,1),monkeys{iMonk}) & strcmpi(allFiles(:,4),tasks{iTask}) );
            summary.sessions.(monkeys{iMonk}).(tasks{iTask}) = numSessions;
        end
    end
    
    %%% Now, get the mean number of trials in each epoch for each task
    %   Also, get peak velocity and peak force
    disp('Getting trial info...');
    for iTask = 1:length(tasks)
        disp(['Task ' num2str(iTask) ' / ' num2str(length(tasks))]);
        for iMonk = 1:length(monkeys)
            disp(['Monkey ' num2str(iMonk) ' / ' num2str(length(monkeys))]);
            
            doFiles = allFiles( strcmpi(allFiles(:,1),monkeys{iMonk}) & strcmpi(allFiles(:,4),tasks{iTask}), :);
            
            groupTrials = zeros(size(doFiles,1),length(epochs));
            groupF = cell(size(doFiles,1),length(epochs));
            groupV = cell(size(doFiles,1),length(epochs));
            groupFrms = cell(size(doFiles,1),length(epochs));
            groupVrms = cell(size(doFiles,1),length(epochs));
            for iFile = 1:size(doFiles,1)
                disp(['File ' num2str(iFile) ' / ' num2str(size(doFiles,1))]);
                tic;
                sessInfo = doFiles(iFile,:);
                parfor iEpoch = 1:length(epochs)
                    % load data
                    data = loadResults(root_dir,sessInfo,'data',[],epochs{iEpoch});
                    if isstruct(data) % returns NaN if it can't load file
                        % filter the movement table
                        [mt,~] = filterMovementTable(data,data.params,false,false);
                        mt = mt{1};
                        
                        % get the number of trials
                        groupTrials(iFile,iEpoch) = size(mt,1);
                        
                        % While I have the data loaded... get the peak velocity for
                        % each movement and the peak force for each movement
                        t = data.cont.t;
                        vel = data.cont.vel;
                        force = data.cont.force;
                        %clear data;
                        
                        % [ target angle, on_time, go cue, move_time, peak_time, end_time ]
                        if ~isempty(force)
                            peakF = zeros(size(mt,1),1);
                            rmsF = zeros(size(mt,1),1);
                            for iMove = 1:size(mt,1)
                                % get peak over entire movement
                                inds = t >= mt(iMove,2) & t <= mt(iMove,6);
                                peakF(iMove) = max( sqrt( force(inds,1).^2 + force(inds,2).^2 ) );
                                
                                % get RMS from onset to peak
                                inds = t >= mt(iMove,4) & t <= mt(iMove,5);
                                rmsF(iMove) = rms( sqrt( force(inds,1).^2 + force(inds,2).^2 ) );
                            end
                        else
                            disp('HEY! Problem with the force.');
                            peakF = NaN;
                            rmsF = NaN;
                        end
                        
                        if ~isempty(vel)
                            peakV = zeros(size(mt,1),1);
                            rmsV = zeros(size(mt,1),1);
                            for iMove = 1:size(mt,1)
                                % get peak over entire movement
                                inds = t >= mt(iMove,2) & t <= mt(iMove,6);
                                peakV(iMove) = max( sqrt( vel(inds,1).^2 + vel(inds,2).^2 ) );
                                
                                % get RMS from onset to peak
                                inds = t >= mt(iMove,4) & t <= mt(iMove,5);
                                rmsV(iMove) = rms( sqrt( vel(inds,1).^2 + vel(inds,2).^2 ) );
                            end
                        else
                            disp('HEY! Problem with the velocity.');
                            peakV = NaN;
                            rmsV = NaN;
                        end
                    else
                        disp(['No data found for the ' epochs{iEpoch} ' epoch...']);
                        peakF = NaN;
                        peakV = NaN;
                        rmsF = NaN;
                        rmsV = NaN;
                    end
                    
                    groupFrms{iFile,iEpoch} = rmsF;
                    groupVrms{iFile,iEpoch} = rmsV;
                    groupF{iFile,iEpoch} = peakF;
                    groupV{iFile,iEpoch} = peakV;
                end
                toc;
                clear data peakV peakF rmsF rmsV iMove force vel t mt fn sessInfo;
            end
            
            summary.trials.(monkeys{iMonk}).(tasks{iTask}) = groupTrials;
            summary.force.(monkeys{iMonk}).(tasks{iTask}) = groupF;
            summary.vel.(monkeys{iMonk}).(tasks{iTask}) = groupV;
            summary.rmsforce.(monkeys{iMonk}).(tasks{iTask}) = groupFrms;
            summary.rmsvel.(monkeys{iMonk}).(tasks{iTask}) = groupVrms;
        end
    end
    disp('Done.');
    
    clear iEpoch iFile iMonk iTask fdir groupTrials groupF groupV epochs;
    
    
    %%% Now get data on neurons
    % Find the total number of cells for each monkey by task type
    % Find the percentage of cells that meet tuning criteria
    % Find the average PD change in adaptation period by task
    
    % for excluding cells:
    %   1) Waveform SNR
    %   2) ISI Percentage
    %   3) FR threshold
    %   4) Neuron Tracking
    %   5) PD CI
    %   6) Cosine R2
    disp('Getting neural data...');
    for iTask = 1:length(tasks)
        disp(['Task ' num2str(iTask) ' / ' num2str(length(tasks))]);
        
        for iMonk = 1:length(monkeys)
            disp(['Monkey ' num2str(iMonk) ' / ' num2str(length(monkeys))]);
            doFiles = allFiles( strcmpi(allFiles(:,1),monkeys{iMonk}) & strcmpi(allFiles(:,4),tasks{iTask}), :);
            
            groupCells = zeros(size(doFiles,1),1);
            groupTuned = zeros(size(doFiles,1),1);
            groupDiffPD = zeros(size(doFiles,1),2);
            groupOther = zeros(size(doFiles,1),1);
            groupAdapting = zeros(size(doFiles,1),1);
            groupMemoryI = zeros(size(doFiles,1),1);
            groupMemoryII = zeros(size(doFiles,1),1);
            groupMemIDiff = zeros(size(doFiles,1),1);
            groupMemIIDiff = zeros(size(doFiles,1),1);
            groupKinDiff = zeros(size(doFiles,1),1);
            groupKinCount = zeros(size(doFiles,1),2);
            groupMemInd = cell(size(doFiles,1),1);
            for iFile = 1:size(doFiles,1)
                disp(['File ' num2str(iFile) ' / ' num2str(size(doFiles,1))]);
                
                classifierBlocks = cbs.(doFiles{iFile,3});
                paramSetName = psn.(doFiles{iFile,3});
                
                [t,c] = loadResults(root_dir,doFiles(iFile,:),'tuning',{'tuning','classes'},useArray,paramSetName,tuningMethod,tuningPeriod);
                
                % find the cells that meet inclusion criteria
                goodCells = all(c.istuned(:,1:4),2);
                tunedCells = all(c.istuned,2);
                
                t_sg = c.tuned_cells;
                
                % number of cells
                groupCells(iFile) = sum(goodCells,1);
                % percent of tuned cells
                groupTuned(iFile) = sum(tunedCells,1);
                
                % for tuned cells, get average PD change in each epoch
                bl_pds = t(classifierBlocks(1)).pds(:,1);
                ad_pds = t(classifierBlocks(2)).pds(:,1);
                wo_pds = t(classifierBlocks(3)).pds(:,1);
                
                bl_sg = t(classifierBlocks(1)).sg;
                ad_sg = t(classifierBlocks(2)).sg;
                wo_sg = t(classifierBlocks(3)).sg;
                
                % find the tuned cells
                [~,bl_ind,~] = intersect(bl_sg,t_sg,'rows');
                [~,ad_ind,~] = intersect(ad_sg,t_sg,'rows');
                [~,wo_ind,~] = intersect(wo_sg,t_sg,'rows');
                
                ad_diff = angleDiff(bl_pds(bl_ind),ad_pds(ad_ind),true,true);
                wo_diff = angleDiff(bl_pds(bl_ind),wo_pds(wo_ind),true,true);
                
                tuned_classes = c.classes(tunedCells,1);
                
                inds = find(tuned_classes==5);
                bl_pds = bl_pds(bl_ind);
                ad_pds = ad_pds(ad_ind);
                wo_pds = wo_pds(wo_ind);
                mem_ind = [];
                for i = 1:length(inds)
                    mem_ind(i) = angleDiff(bl_pds(inds(i)),wo_pds(inds(i)),true,false) / min( angleDiff(bl_pds(inds(i)),ad_pds(inds(i)),true,false ) , angleDiff(wo_pds(inds(i)),ad_pds(inds(i)),true,false) );
                end
                
                % mean pd change
                groupDiffPD(iFile,:) = [mean(ad_diff), mean(wo_diff)];
                groupKinDiff(iFile) = mean(ad_diff(tuned_classes==1 | tuned_classes==4));
                groupKinCount(iFile,:) = [sum(ad_diff(tuned_classes==1 | tuned_classes==4) > 0), sum(tuned_classes==1 | tuned_classes==4)];
                groupAdapting(iFile) = sum(tuned_classes==2 | tuned_classes==3);
                groupOther(iFile) = sum(tuned_classes==5);
                groupMemoryI(iFile) = sum(tuned_classes==3);
                groupMemoryII(iFile) = sum(tuned_classes==4);
                groupMemIDiff(iFile) = mean(wo_diff(tuned_classes==3));
                groupMemIIDiff(iFile) = mean(wo_diff(tuned_classes==4));
                groupMemInd{iFile} = mem_ind;
                
                clear ad_diff wo_diff bl_ind ad_ind wo_ind bl_sg ad_sg wo_sg bl_pds ad_pds wo_pds t_sg tunedCells goodCells c tuned_classes fn t tuning fn fdir i mem_ind inds;
            end
            summary.numcells.(monkeys{iMonk}).(tasks{iTask}) = groupCells;
            summary.numtuned.(monkeys{iMonk}).(tasks{iTask}) = groupTuned;
            summary.diffpd.(monkeys{iMonk}).(tasks{iTask}) = groupDiffPD;
            summary.other.(monkeys{iMonk}).(tasks{iTask}) = groupOther;
            summary.kindiff.(monkeys{iMonk}).(tasks{iTask}) = groupKinDiff;
            summary.kincount.(monkeys{iMonk}).(tasks{iTask}) = groupKinCount;
            summary.adapting.(monkeys{iMonk}).(tasks{iTask}) = groupAdapting;
            summary.memoryi.(monkeys{iMonk}).(tasks{iTask}) = groupMemoryI;
            summary.memoryii.(monkeys{iMonk}).(tasks{iTask}) = groupMemoryII;
            summary.memidiff.(monkeys{iMonk}).(tasks{iTask}) = groupMemIDiff;
            summary.memiidiff.(monkeys{iMonk}).(tasks{iTask}) = groupMemIIDiff;
            summary.memind.(monkeys{iMonk}).(tasks{iTask}) = groupMemInd;
        end
    end
    disp('Done.');
    
    clear iFile iMonk iTask groupCells groupTuned groupDiffPD groupOther groupAdapting groupMemoryI groupMemoryII groupMemIIDiff groupMemInd groupKinDiff epochs classifierBlocks paramSetName;
    
    %%%
    % Save that data!
    disp('Saving data...');
    save(fullfile(root_dir,save_file));
    disp('Done.');
end

%% Now process for some results
clc;

% filter out files to exclude
allFiles( strcmpi(allFiles(:,1),exclude_files{:,1}) & strcmpi(allFiles(:,2),exclude_files{:,2}) & strcmpi(allFiles(:,3),exclude_files{:,3}) & strcmpi(allFiles(:,4),exclude_files{:,4}), :) = [];

% The average number of movements in CO and RT including all monkeys
for iPert = 1:length(perts)
    
    for iTask = 1:length(tasks)
        data = [];
        for iMonk = 1:length(monkeys)
            doFiles = allFiles( strcmpi(allFiles(:,1),monkeys{iMonk}) & strcmpi(allFiles(:,4),tasks{iTask}), :);
            useFiles = strcmpi(doFiles(:,3),perts{iPert});
            
            temp = summary.trials.(monkeys{iMonk}).(tasks{iTask});
            temp = temp(useFiles,:);
            data = [data; temp];
        end
        disp([perts{iPert} ': MEAN NUMBER OF ' tasks{iTask} ' TRIALS:']);
        disp(['BL: ' num2str(mean(data(:,1),1)) ' +/- ' num2str(std(data(:,1),1))]);
        disp(['AD: ' num2str(mean(data(:,2),1)) ' +/- ' num2str(std(data(:,2),1))]);
        disp(['WO: ' num2str(mean(data(:,3),1)) ' +/- ' num2str(std(data(:,3),1))]);
        
        disp(' ');
    end
    disp(' ');
    
    % get average force for each monkey
    for iMonk = 1:length(monkeys)
        data = [];
        for iTask = 1:length(tasks)
            doFiles = allFiles( strcmpi(allFiles(:,1),monkeys{iMonk}) & strcmpi(allFiles(:,4),tasks{iTask}), :);
            useFiles = strcmpi(doFiles(:,3),perts{iPert});
            
            temp = summary.force.(monkeys{iMonk}).(tasks{iTask});
            temp = temp(useFiles,:);
            for iFile = 1:size(temp,1)
                data = [data; temp{iFile,2}];
            end
        end
        disp([perts{iPert} ': MEAN FORCE OF ' monkeys{iMonk} ': ' num2str(mean(data,1)) ' +/- ' num2str(std(data,1))]);
    end
    
    disp(' ');
    disp(' ');
    
    velName = 'rmsvel';
    
    % Compare speeds across epochs
    for iMonk = 1:length(monkeys)
        data = [];
        for iTask = 1:length(tasks)
            doFiles = allFiles( strcmpi(allFiles(:,1),monkeys{iMonk}) & strcmpi(allFiles(:,4),tasks{iTask}), :);
            useFiles = strcmpi(doFiles(:,3),perts{iPert});
            
            temp = summary.(velName).(monkeys{iMonk}).(tasks{iTask});
            temp = temp(useFiles,:);
            for iFile = 1:size(temp,1)
                data = [data; temp{iFile,1}];
            end
        end
        disp([perts{iPert} ': MEAN VELOCITY OF ' monkeys{iMonk} ':']);
        disp(['BL: ' num2str(mean(data,1)) ' +/- ' num2str(std(data,1))]);
        data = [];
        for iTask = 1:length(tasks)
            doFiles = allFiles( strcmpi(allFiles(:,1),monkeys{iMonk}) & strcmpi(allFiles(:,4),tasks{iTask}), :);
            useFiles = strcmpi(doFiles(:,3),perts{iPert});
            
            temp = summary.(velName).(monkeys{iMonk}).(tasks{iTask});
            temp = temp(useFiles,:);
            for iFile = 1:size(temp,1)
                data = [data; temp{iFile,2}];
            end
        end
        disp(['AD: ' num2str(mean(data,1)) ' +/- ' num2str(std(data,1))]);
        data = [];
        for iTask = 1:length(tasks)
            doFiles = allFiles( strcmpi(allFiles(:,1),monkeys{iMonk}) & strcmpi(allFiles(:,4),tasks{iTask}), :);
            useFiles = strcmpi(doFiles(:,3),perts{iPert});
            
            temp = summary.(velName).(monkeys{iMonk}).(tasks{iTask});
            temp = temp(useFiles,:);
            for iFile = 1:size(temp,1)
                data = [data; temp{iFile,3}];
            end
        end
        disp(['WO: ' num2str(mean(data,1)) ' +/- ' num2str(std(data,1))]);
        disp(' ');
    end
    
    % Compare speeds in between tasks
    for iTask = 1:length(tasks)
        data = [];
        for iMonk = 1:length(monkeys)
            doFiles = allFiles( strcmpi(allFiles(:,1),monkeys{iMonk}) & strcmpi(allFiles(:,4),tasks{iTask}), :);
            useFiles = strcmpi(doFiles(:,3),perts{iPert});
            
            temp = summary.(velName).(monkeys{iMonk}).(tasks{iTask});
            temp = temp(useFiles,:);
            for iFile = 1:size(temp,1)
                data = [data; temp{iFile,1}];
            end
        end
        figure;
        bins = 1:2:40;
        [f,x]=hist(data,bins);
        bar(x,f/sum(f));
        axis('tight')
        set(gca,'XLim',[0,40],'TickDir','out','FontSize',14);
        xlabel('Peak Speed (cm/s)','FontSize',14);
        ylabel('Count','FontSize',14);
        box off;
        disp([perts{iPert} ': MEAN VELOCITY DURING ' tasks{iTask} ': ' num2str(mean(data,1)) ' +/- ' num2str(std(data,1))]);
    end
    
    disp(' ');
    disp(' ');
    
    % Get the number of neurons in all sessions by task
    for iTask = 1:length(tasks)
        data = [];
        for iMonk = 1:length(monkeys)
            doFiles = allFiles( strcmpi(allFiles(:,1),monkeys{iMonk}) & strcmpi(allFiles(:,4),tasks{iTask}), :);
            useFiles = strcmpi(doFiles(:,3),perts{iPert});
            
            temp = summary.numcells.(monkeys{iMonk}).(tasks{iTask});
            temp = temp(useFiles,:);
            data = [data; temp];
        end
        
        disp([perts{iPert} ': TOTAL CELLS IN ' tasks{iTask} ': ' num2str(sum(data,1))]);
    end
    
    disp(' ');
    
    % Get the number of neurons that are tuned
    for iTask = 1:length(tasks)
        data = [];
        for iMonk = 1:length(monkeys)
            doFiles = allFiles( strcmpi(allFiles(:,1),monkeys{iMonk}) & strcmpi(allFiles(:,4),tasks{iTask}), :);
            useFiles = strcmpi(doFiles(:,3),perts{iPert});
            
            temp = summary.numtuned.(monkeys{iMonk}).(tasks{iTask});
            temp = temp(useFiles,:);
            data = [data; temp];
        end
        out1 = sum(data,1);
        
        data = [];
        for iMonk = 1:length(monkeys)
            doFiles = allFiles( strcmpi(allFiles(:,1),monkeys{iMonk}) & strcmpi(allFiles(:,4),tasks{iTask}), :);
            useFiles = strcmpi(doFiles(:,3),perts{iPert});
            
            temp = summary.numcells.(monkeys{iMonk}).(tasks{iTask});
            temp = temp(useFiles,:);
            data = [data; temp];
        end
        
        disp([perts{iPert} ': TOTAL TUNED CELLS IN ' tasks{iTask} ': ' num2str(out1) ' ( ' num2str(100*out1/sum(data,1)) '% )']);
    end
    
    % Get the number of neurons that are tuned
    data = [];
    for iTask = 1:length(tasks)
        for iMonk = 1:length(monkeys)
            doFiles = allFiles( strcmpi(allFiles(:,1),monkeys{iMonk}) & strcmpi(allFiles(:,4),tasks{iTask}), :);
            useFiles = strcmpi(doFiles(:,3),perts{iPert});
            
            temp = summary.numtuned.(monkeys{iMonk}).(tasks{iTask});
            temp = temp(useFiles,:);
            data = [data; temp];
        end
    end
    out1 = nansum(data,1);
    data = [];
    for iTask = 1:length(tasks)
        for iMonk = 1:length(monkeys)
            doFiles = allFiles( strcmpi(allFiles(:,1),monkeys{iMonk}) & strcmpi(allFiles(:,4),tasks{iTask}), :);
            useFiles = strcmpi(doFiles(:,3),perts{iPert});
            
            temp = summary.numcells.(monkeys{iMonk}).(tasks{iTask});
            temp = temp(useFiles,:);
            data = [data; temp];
        end
    end
    out2 = nansum(data,1);
    
    disp([perts{iPert} ': TOTAL TUNED CELLS OVERALL: ' num2str(out1) ' ( ' num2str(100*out1/out2) '% )']);
    
    disp(' ');
    
    % Get the mean PD change
    for iMonk = 1:length(monkeys)
        data = [];
        for iTask = 1:length(tasks)
            doFiles = allFiles( strcmpi(allFiles(:,1),monkeys{iMonk}) & strcmpi(allFiles(:,4),tasks{iTask}), :);
            useFiles = strcmpi(doFiles(:,3),perts{iPert});
            
            temp = summary.diffpd.(monkeys{iMonk}).(tasks{iTask});
            temp = temp(useFiles,:);
            data = [data; temp];
        end
        out1 = nanmean(data,1);
        out2 = nanstd(data,1);
        disp([perts{iPert} ': MEAN PD CHANGE BL->AD ' monkeys{iMonk} ': ' num2str(out1(1).*(180/pi)) ' +/- ' num2str(out2(1).*(180/pi))]);
        disp([perts{iPert} ': MEAN PD CHANGE BL->WO ' monkeys{iMonk} ': ' num2str(out1(2).*(180/pi)) ' +/- ' num2str(out2(2).*(180/pi))]);
        disp(' ');
    end
    
    disp(' ');
    
    % Get the mean PD change across all monkeys
    data = [];
    for iMonk = 1:length(monkeys)
        for iTask = 1:length(tasks)
            doFiles = allFiles( strcmpi(allFiles(:,1),monkeys{iMonk}) & strcmpi(allFiles(:,4),tasks{iTask}), :);
            useFiles = strcmpi(doFiles(:,3),perts{iPert});
            
            temp = summary.diffpd.(monkeys{iMonk}).(tasks{iTask});
            temp = temp(useFiles,:);
            data = [data; temp];
        end
    end
    out1 = nanmean(data,1);
    out2 = nanstd(data,1);
    
    disp([perts{iPert} ': OVERALL MEAN PD CHANGE BL->AD: ' num2str(out1(1).*(180/pi)) ' +/- ' num2str(out2(1).*(180/pi))]);
    disp([perts{iPert} ': OVERALL MEAN PD CHANGE BL->WO: ' num2str(out1(2).*(180/pi)) ' +/- ' num2str(out2(2).*(180/pi))]);
    
    disp(' ');
    disp(' ');
    
    % Get the mean PD change of cells with no significant change
    data = [];
    for iMonk = 1:length(monkeys)
        for iTask = 1:length(tasks)
            doFiles = allFiles( strcmpi(allFiles(:,1),monkeys{iMonk}) & strcmpi(allFiles(:,4),tasks{iTask}), :);
            useFiles = strcmpi(doFiles(:,3),perts{iPert});
            
            temp =  summary.kindiff.(monkeys{iMonk}).(tasks{iTask});
            temp = temp(useFiles,:);
            data = [data; temp];
        end
    end
    out1 = nanmean(data,1);
    out2 = nanstd(data,1);
    disp([perts{iPert} ': OVERALL MEAN KINEMATIC CELL PD CHANGE BL->AD: ' num2str(out1(1).*(180/pi)) ' +/- ' num2str(out2(1).*(180/pi))]);
    
    disp(' ');
    
    data = [];
    for iMonk = 1:length(monkeys)
        for iTask = 1:length(tasks)
            doFiles = allFiles( strcmpi(allFiles(:,1),monkeys{iMonk}) & strcmpi(allFiles(:,4),tasks{iTask}), :);
            useFiles = strcmpi(doFiles(:,3),perts{iPert});
            
            temp = summary.kincount.(monkeys{iMonk}).(tasks{iTask});
            temp = temp(useFiles,:);
            data = [data; temp];
        end
    end
    out1 = nansum(data(:,1),1);
    out2 = nansum(data(:,2),1);
    disp([perts{iPert} ': NUMBER KINEMATIC CELLS WITH POSITIVE PD CHANGE BL->AD: ' num2str(100*out1/out2) '%']);
    
    disp(' ');
    disp(' ');
    
    % Get percent of cells with significant change in tuning in AD
    
    data = [];
    for iTask = 1:length(tasks)
        for iMonk = 1:length(monkeys)
            doFiles = allFiles( strcmpi(allFiles(:,1),monkeys{iMonk}) & strcmpi(allFiles(:,4),tasks{iTask}), :);
            useFiles = strcmpi(doFiles(:,3),perts{iPert});
            
            temp = summary.adapting.(monkeys{iMonk}).(tasks{iTask});
            temp = temp(useFiles,:);
            data = [data; temp];
        end
    end
    out1 = nansum(data,1);
    data = [];
    for iTask = 1:length(tasks)
        for iMonk = 1:length(monkeys)
            doFiles = allFiles( strcmpi(allFiles(:,1),monkeys{iMonk}) & strcmpi(allFiles(:,4),tasks{iTask}), :);
            useFiles = strcmpi(doFiles(:,3),perts{iPert});
            
            temp = summary.numtuned.(monkeys{iMonk}).(tasks{iTask});
            temp = temp(useFiles,:);
            data = [data; temp];
        end
    end
    out2 = nansum(data,1);
    
    disp([perts{iPert} ': TOTAL CELLS with change in AD: ' num2str(out1) ' ( ' num2str(100*out1/out2) '% )']);
    
    
    % Get the percentage of "memory I" cells
    data = [];
    for iTask = 1:length(tasks)
        for iMonk = 1:length(monkeys)
            doFiles = allFiles( strcmpi(allFiles(:,1),monkeys{iMonk}) & strcmpi(allFiles(:,4),tasks{iTask}), :);
            useFiles = strcmpi(doFiles(:,3),perts{iPert});
            
            temp = summary.memoryi.(monkeys{iMonk}).(tasks{iTask});
            temp = temp(useFiles,:);
            data = [data; temp];
        end
    end
    out1 = nansum(data,1);
    data = [];
    for iTask = 1:length(tasks)
        for iMonk = 1:length(monkeys)
            doFiles = allFiles( strcmpi(allFiles(:,1),monkeys{iMonk}) & strcmpi(allFiles(:,4),tasks{iTask}), :);
            useFiles = strcmpi(doFiles(:,3),perts{iPert});
            
            temp = summary.numtuned.(monkeys{iMonk}).(tasks{iTask});
            temp = temp(useFiles,:);
            data = [data; temp];
        end
    end
    out2 = nansum(data,1);
    disp([perts{iPert} ': TOTAL MEMORY I CELLS: ' num2str(out1) ' ( ' num2str(100*out1/out2) '% )']);
    
    % Get the percentage of "memory II" cells
    data = [];
    for iTask = 1:length(tasks)
        for iMonk = 1:length(monkeys)
            doFiles = allFiles( strcmpi(allFiles(:,1),monkeys{iMonk}) & strcmpi(allFiles(:,4),tasks{iTask}), :);
            useFiles = strcmpi(doFiles(:,3),perts{iPert});
            
            temp = summary.memoryii.(monkeys{iMonk}).(tasks{iTask});
            temp = temp(useFiles,:);
            data = [data; temp];
        end
    end
    out1 = nansum(data,1);
    data = [];
    for iTask = 1:length(tasks)
        for iMonk = 1:length(monkeys)
            doFiles = allFiles( strcmpi(allFiles(:,1),monkeys{iMonk}) & strcmpi(allFiles(:,4),tasks{iTask}), :);
            useFiles = strcmpi(doFiles(:,3),perts{iPert});
            
            temp = summary.numtuned.(monkeys{iMonk}).(tasks{iTask});
            temp = temp(useFiles,:);
            data = [data; temp];
        end
    end
    out2 = nansum(data,1);
    disp([perts{iPert} ': TOTAL MEMORY II CELLS: ' num2str(out1) ' ( ' num2str(100*out1/out2) '% )']);
    
    % Get the percentage of "other" cells and memory cell index for those cells
    data = [];
    for iTask = 1:length(tasks)
        for iMonk = 1:length(monkeys)
            doFiles = allFiles( strcmpi(allFiles(:,1),monkeys{iMonk}) & strcmpi(allFiles(:,4),tasks{iTask}), :);
            useFiles = strcmpi(doFiles(:,3),perts{iPert});
            
            temp = summary.other.(monkeys{iMonk}).(tasks{iTask});
            temp = temp(useFiles,:);
            data = [data; temp];
        end
    end
    out1 = nansum(data,1);
    data = [];
    for iTask = 1:length(tasks)
        for iMonk = 1:length(monkeys)
            doFiles = allFiles( strcmpi(allFiles(:,1),monkeys{iMonk}) & strcmpi(allFiles(:,4),tasks{iTask}), :);
            useFiles = strcmpi(doFiles(:,3),perts{iPert});
            
            temp = summary.numtuned.(monkeys{iMonk}).(tasks{iTask});
            temp = temp(useFiles,:);
            data = [data; temp];
        end
    end
    out2 = nansum(data,1);
    disp([perts{iPert} ': TOTAL OTHER CELLS: ' num2str(out1) ' ( ' num2str(100*out1/out2) '% )']);
    
    data = [];
    for iTask = 1:length(tasks)
        for iMonk = 1:length(monkeys)
            doFiles = allFiles( strcmpi(allFiles(:,1),monkeys{iMonk}) & strcmpi(allFiles(:,4),tasks{iTask}), :);
            useFiles = strcmpi(doFiles(:,3),perts{iPert});
            
            temp = summary.memind.(monkeys{iMonk}).(tasks{iTask});
            temp = temp(useFiles,:);
            for iFile = 1:length(temp)
                u = temp{iFile};
                for unit = 1:length(u)
                    data = [data; u(unit)];
                end
            end
        end
    end
    
    disp([perts{iPert} ': MEAN MEMORY INDEX FOR "OTHER" CELLS: ' num2str(mean(data)) ]);
    disp([perts{iPert} ': MAX MEMORY INDEX FOR "OTHER" CELLS: ' num2str(max(data)) ]);
    
    disp(' ');
    
    % Get the mean PD change of Memory II cells
    data = [];
    for iMonk = 1:length(monkeys)
        for iTask = 1:length(tasks)
            doFiles = allFiles( strcmpi(allFiles(:,1),monkeys{iMonk}) & strcmpi(allFiles(:,4),tasks{iTask}), :);
            useFiles = strcmpi(doFiles(:,3),perts{iPert});
            
            temp = summary.memidiff.(monkeys{iMonk}).(tasks{iTask});
            temp = temp(useFiles,:);
            data = [data; temp];
        end
    end
    out1 = nanmean(data,1);
    out2 = nanstd(data,1);
    disp([perts{iPert} ': MEAN PD CHANGE BL->WO for Mem II: ' num2str(out1(1).*(180/pi)) ' +/- ' num2str(out2(1).*(180/pi))]);
    disp(' ');
    
    clear data temp out1 out2 iTask iMonk iFile u unit;
    
    disp(' ');
    disp(' ');
    
end
clear iPert;
