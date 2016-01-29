%
saveDir = 'F:\fr_results';

% What parts to do
doGLM = false;
doCos = true;
doFileParse = true;
doRasters = false;

%
window = [0.7,0.7];
glmWindow = [1,1];
binSize = 0.01;
alignInd = 2;
alignInd2 = 4;
alignInd3 = 5;
% [ target angle, on_time, go cue, move_time, peak_time, end_time, ]

%%
if doFileParse
    tic;
    clear blockFR blockEvent1 blockEvent2 blockEvent3;
    for iFile = 1:size(doFiles,1)
        disp(['Processing File ' num2str(iFile) ' of ' num2str(size(doFiles,1)) '...']);
        clear spikes spikes2 spikes3
        [~,c] = loadResults(root_dir,doFiles(iFile,:),'tuning',{'tuning','classes'},useArray,paramSetName,tuneMethod,tuneWindow);
        master_sg = c(1).sg;
        
        %%%% NOTE I'M HACKING THIS
        c.params.tuning.blocks = {[0 1],[0 0.45 0.55 1],[0 0.45 0.55 1]};
        
        data = cell(1,3);
        for iEpoch = 1:length(epochs)
            data{iEpoch} = loadResults(root_dir,doFiles(iFile,:),'data',[],epochs{iEpoch});
        end
        
        count = 0; clear unitInfo;
        for unit = 1:size(master_sg,1)
            if all(c(1).istuned(unit,1:4))
                count = count + 1;
                
                unitInfo(count,:) = [iFile,master_sg(unit,:)];
                
                blockCount = 1;
                for iEpoch = 1:length(epochs)
                    d = data{iEpoch};
                    units = d.(useArray).units;
                    movement_table = filterMovementTable(d,c.params,true,false);
                    
                    sg = cell2mat({units.id}');
                    for iBlock = 1:length(movement_table)
                        mt = movement_table{iBlock};
                        theta = mt(:,1);
                        utheta = unique(theta);
                        % if -pi is one of the unique, make it pi
                        if abs(utheta(1)) > utheta(end-1)
                            theta(theta==utheta(1)) = utheta(end);
                            utheta = unique(theta);
                        end
                        
                        idx = sg(:,1)==master_sg(unit,1) & sg(:,2)==master_sg(unit,2);
                        
                        for iDir = 1:length(utheta)
                            inds = theta==utheta(iDir);
                            [~, spikes{blockCount,count,iDir}] = plotAlignedFR(units(idx).ts,mt(inds,alignInd),window,binSize,false);
                            [~, spikes2{blockCount,count,iDir}] = plotAlignedFR(units(idx).ts,mt(inds,alignInd2),window,binSize,false);
                            [~, spikes3{blockCount,count,iDir}] = plotAlignedFR(units(idx).ts,mt(inds,alignInd3),window,binSize,false);
                        end
                        
                        % now get binned firing rates for GLM
                        for iTrial = 1:size(mt,1)
                            
                            spikeInds = units(idx).ts >= mt(iTrial,alignInd)-glmWindow(1) & units(idx).ts < mt(iTrial,alignInd2)+glmWindow(2);
                            
                            bins = mt(iTrial,alignInd)-glmWindow(1)+binSize/2:binSize:mt(iTrial,alignInd2)+glmWindow(2);
                            [f,~]=hist(units(idx).ts(spikeInds),bins);
                            
                            blockFR{iFile,blockCount,iTrial,count} = (f./binSize)';
                            
                            event = zeros(size(bins'));
                            event( find(bins >= mt(iTrial,alignInd),1,'first') ) = 1;
                            blockEvent1{iFile,blockCount,iTrial} = [event cos(mt(iTrial,1))*event sin(mt(iTrial,1))*event];
                            
                            event = zeros(size(bins'));
                            event( find(bins >= mt(iTrial,alignInd2),1,'first') ) = 1;
                            blockEvent2{iFile,blockCount,iTrial} = [event cos(mt(iTrial,1))*event sin(mt(iTrial,1))*event];
                            
                            event = zeros(size(bins'));
                            event( find(bins > mt(iTrial,alignInd3),1,'first') ) = 1;
                            blockEvent3{iFile,blockCount,iTrial} = [event cos(mt(iTrial,1))*event sin(mt(iTrial,1))*event];
                            
                        end
                        blockCount = blockCount + 1;
                    end
                end
            end
        end
        
        allSpikes{iFile} = spikes;
        allSpikes2{iFile} = spikes2;
        allSpikes3{iFile} = spikes3;
        allUnitInfo{iFile} = unitInfo;
        
        clear data spikes spikes2 f bins inds idx mt theta movement_table units d sg c spikeInds event unitInfo blockCount;
    end
    clear iFile master_sg iEpoch unit iDir iTrial count doWidthSeparation franova iBlock whichBlock whichScript sComp slidingParams classifierBlocks;
    toc;
    
    % save output so you don't lose it
    save(fullfile(saveDir,[useArray '_fileParse_' datestr(now,'yyyymmddTHHMMSS') '.mat']),'-v7.3')
end

%% Now, do cosine fit to several periods during movement
%
% Which bins to average over, [event,start,stop] relative to each event
% binRange = [1,0,30; ... 1
%     1,10,40; ... 2
%     1,20,50; ... 3
%     2,-70,-40; ... 4
%     2,-60,-30; ... 5
%     2,-50,-20; ... 6
%     2,-40,-10; ... 7
%     2,-30,0; ... 8
%     2,-20,10; ... 9
%     2,-10,20]; % 10
binRange = [1,0,30; ... 1
    1,5,35; ... 2
    1,10,40; ... 3
    1,15,45; ... 4
    1,20,50; ... 5
    2,-70,-40; ... 6
    2,-65,-35; ... 7
    2,-60,-30; ... 8
    2,-55,-25; ... 9
    2,-50,-20; ... 10
    2,-45,-15; ... 11
    2,-40,-10; ... 12
    2,-35,-5; ... 13
    2,-30,0; ... 14
    2,-25,5; ... 15
    2,-20,10; ... 16
    2,-15,15; ... 17
    2,-10,20]; % 18

numBootIters = 1000;
bootConfLevel = 0.95;

if doCos
    tic;
    % first get directions and firing rate for each trial, unit, day, block
    cosFR = cell(size(blockFR,1),size(blockFR,2));
    cosTheta = cell(size(blockFR,1),size(blockFR,2));
    for iFile = 1:size(blockFR,1)
        for iBlock = 1:size(blockFR,2)
            fr_all = squeeze(blockFR(iFile,iBlock,:,:));
            allEvents{1} = squeeze(blockEvent1(iFile,iBlock,:));
            allEvents{2} = squeeze(blockEvent2(iFile,iBlock,:));
            allEvents{3} = squeeze(blockEvent3(iFile,iBlock,:));
            
            % because not all files/blocks have the same number of neurons/trials,
            % there will be some empty cells. Please note this implementation is pure
            % crap and is highly inefficient. Someday I will fix.
            whichExist = cellfun(@(x) isempty(x),fr_all);
            
            neurons = 1:sum(~all(whichExist,1));
            trials = 1:sum(~all(whichExist,2));
            
            fr = fr_all(trials,neurons);
            
            theta = zeros(size(binRange,1),size(fr,1));
            binFR = zeros(size(binRange,1),size(fr,1),size(fr,2));
            for iBin = 1:size(binRange,1)
                
                events = allEvents{binRange(iBin,1)};
                for iTrial = 1:size(fr,1)
                    % get indices
                    evIdx = find(events{iTrial}(:,1));
                    trIdx = evIdx+binRange(iBin,2):evIdx+binRange(iBin,3)-1;
                    
                    theta(iBin,iTrial) = atan2(events{iTrial}(evIdx,3),events{iTrial}(evIdx,2));
                    
                    for unit = 1:size(fr,2)
                        binFR(iBin,iTrial,unit) = mean(fr{iTrial,unit}(trIdx));
                    end
                end
            end
            
            cosFR{iFile,iBlock} = binFR;
            cosTheta{iFile,iBlock} = theta;
        end
    end
    clear iFile iBlock fr_all allEvents whichExist neurons trials fr theta binFR iBin events iTrial evIdx trIdx theta binFR;
    
    % now we can start fitting the cosine models
    cosResults = repmat(struct(),[size(blockFR,1),size(blockFR,2),size(binRange,1)]);
    for iFile = 1:size(blockFR,1)
        for iBlock = 1:size(blockFR,2)
            fr = cosFR{iFile,iBlock};
            theta = cosTheta{iFile,iBlock};
            for iBin = 1:size(binRange,1)
                disp(['Cosine tuning curve fitting: File ' num2str(iFile) ', Block ' num2str(iBlock) ', Bin ' num2str(iBin)]);
                
                [tunCurves,confBounds,rs,boot_pds,boot_mds,boot_bos] = regressTuningCurves(squeeze(fr(iBin,:,:)),theta(iBin,:)',{'bootstrap',numBootIters,bootConfLevel},'doparallel',true,'doplots',false);
                
                cosResults(iFile,iBlock,iBin).tunCurves = tunCurves;
                cosResults(iFile,iBlock,iBin).confBounds = confBounds;
                cosResults(iFile,iBlock,iBin).rs = rs;
                cosResults(iFile,iBlock,iBin).boot_pds = boot_pds;
                cosResults(iFile,iBlock,iBin).boot_mds = boot_mds;
                cosResults(iFile,iBlock,iBin).boot_bos = boot_bos;
                cosResults(iFile,iBlock,iBin).fr = squeeze(fr(iBin,:,:)); %ends up being trials x units
                cosResults(iFile,iBlock,iBin).theta = theta(iBin,:);
            end
        end
    end
    clear iFile iBlock iBin fr tunCurves confBounds rs boot_pds boot_mds boot_bos;
    toc;
    
    save(fullfile(saveDir,[useArray '_cosResults_' datestr('now','yy-mm-dd-hh-mm') '.mat']),'-v7.3')
end

% save('PMd_cosResults_05072015.mat','-v7.3');

%% Now, do GLM fit for each cell
%   We have firing rate in small bins for each trial, as well as the time of each alignment event
if doGLM
    % Time bin size (in seconds)
    dt = binSize;
    
    % Type of fitting (regularization, etc.)
    fit_method = 'glmfit'; % glmfit is vanilla and what I'd recommend, lassoglm is regularized
    num_CV = 2; % Number of cross-validations. I'd use 2 (most conservative), 5, or 10.
    
    alpha = false; % If you use glmfit, these need to be false
    lambda = false;
    
    % alpha = .01; % If you try lassoglm, uncomment these
    % lambda = .05;
    
    glmResults = repmat(struct(),[size(blockFR,1),size(blockFR,2)]);
    for iFile = 1:size(blockFR,1)
        for iBlock = 1:size(blockFR,2)
            
            fr_all = squeeze(blockFR(iFile,iBlock,:,:));
            event1 = squeeze(blockEvent1(iFile,iBlock,:));
            event2 = squeeze(blockEvent2(iFile,iBlock,:));
            
            % because not all files/blocks have the same number of neurons/trials,
            % there will be some empty cells. Please note this implementation is pure
            % crap and is highly inefficient. Someday I will fix.
            whichExist = cellfun(@(x) isempty(x),fr_all);
            
            num_neurons_total = size(fr_all,2);
            num_trials_total = size(fr_all,1);
            
            % User inputs
            % Data selection
            neurons = 1:sum(~all(whichExist,1));
            trials = 1:sum(~all(whichExist,2));
            
            % Initialize
            spikes = fr_all(trials,neurons);
            
            num_trials = length(trials);
            num_nrn = length(neurons);
            
            X_cell = cell(num_trials,1);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Pre-process
            % Generate temporal basis functions
            filt_struct = VMR_define_filters();
            
            % Filter covariates
            bins_per_trial = zeros(1,length(trials));
            for idx_trial = 1:length(trials)
                % Filter movement data with temporal basis function
                x1 = full(filter_and_insert(event1{idx_trial},filt_struct(9)));
                x2 = full(filter_and_insert(event2{idx_trial},filt_struct(7)));
                
                X_cell{idx_trial,1} = [x1 x2];
                bins_per_trial(idx_trial) = size(X_cell{idx_trial},1);
                
                % for sanity checks
                %             figure; subplot1(1,3);
                %             subplot1(1); imagesc(spikes{idx_trial});
                %             subplot1(2); imagesc(x1);
                %             subplot1(3); imagesc(x2);
                %             pause; close all;
            end
            clear x1 x2;
            
            x_all = cell2mat(X_cell); % Covariate matrix for all trials
            y_all = cell2mat(spikes); % Spiking for all neurons across all trials
            
            figure
            imagesc([y_all x_all.*max(4.*mean(y_all))]) % Usually good to check that these make sense
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Fit
            % For each neuron, fit GLM
            predictions_combined = cell(length(neurons),1);
            fit_parameters = cell(length(neurons),1);
            fit_info = cell(length(neurons),1);
            pseudo_R2 = cell(length(neurons),1);
            
            parfor nrn_idx = 1:length(neurons) % Parallel
                % for nrn_idx = 1:length(neurons)
                nrn_num = neurons(nrn_idx); % I just do this in case you specify that neurons = [1 5 7] etc.
                
                disp(['Now fitting neuron: ' num2str(nrn_num)])
                [predictions_combined{nrn_idx,1}, ...
                    fit_parameters{nrn_idx,1}, ...
                    fit_info{nrn_idx,1}, ...
                    pseudo_R2{nrn_idx,1}] = ...
                    fit_poiss_GLM( x_all, y_all(:,nrn_num), ...
                    num_CV, ...
                    dt, ...
                    lambda, ...
                    alpha, ...
                    fit_method, ...
                    bins_per_trial);
            end
            glmResults(iFile,iBlock).predictions_combined = predictions_combined;
            glmResults(iFile,iBlock).fit_parameters = fit_parameters;
            glmResults(iFile,iBlock).fit_info = fit_info;
            glmResults(iFile,iBlock).pseudo_R2 = pseudo_R2;
            
            close all;
        end
    end
    clear iFile idx_trial iBlock fr_all event1 event2 whichExist predictions_combined fit_parameters fit_info psuedo_R2 nrn_idx nrn_num x_all y_all unit;
    
    % save for safekeeping
    save(fullfile(saveDir,[useArray '_glmResults_' datestr('now','yy-mm-dd-hh-mm') '.mat']),'-v7.3')
end

%%

minR2_cos = 0.2;
sigAng = 40;
minFR = 3;
doAbs = false;
doMD = false;
usePert = 'FF';
anovaAlpha = 0.1;

plotFiles = find( strcmpi(doFiles(:,3),usePert) & ~strcmpi(doFiles(:,2),'2014-02-03') );
plotFiles = plotFiles(2:end);
useBins = 1:18; % for cosine only for now
sigBlocks = [1,2,4,7];
eComp = [1 4]; %which epochs to compare
% plotLabels = {'Vis','Vis','Plan','Plan','Plan','Plan','Plan','Move','Move','Move'};
plotLabels = {'V','V','V','V','V','P','P','P','P','P','P','P','M','M','M','M','M','M'};


if doMD
    db = 0.1;
    if doAbs
        xmin = 0;
    else
        xmin = -0.8;
    end
    xmax = 0.8;
else
    db = 4;
    if doAbs
        xmin = 0;
    else
        xmin = -30;
    end
    xmax = 30;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find the PDs for all cells
tic;
glm_pds = cell(size(blockFR,2),2);
glm_r2s = cell(size(blockFR,2),2);
cos_pds = cell(size(blockFR,2),length(useBins));
cos_mds = cell(size(blockFR,2),length(useBins));
cos_bos = cell(size(blockFR,2),length(useBins));
cos_r2s = cell(size(blockFR,2),length(useBins));
cos_cis = cell(size(blockFR,2),length(useBins));
cos_boots = cell(size(blockFR,2),length(useBins));
cos_fr = cell(size(blockFR,2),length(useBins));
cos_theta = cell(size(blockFR,2),length(useBins));
for iFile = 1:length(plotFiles)
    %     if strcmpi(doFiles{iFile,1},'Chewie')
    %         useBins = [1,3];
    %     else
    %         useBins = [2,3];
    %     end
    
    for iBlock = 1:size(blockFR,2)
        % get GLM results
        if doGLM
            fit_parameters = glmResults(plotFiles(iFile),iBlock).fit_parameters;
            pseudo_R2 = glmResults(plotFiles(iFile),iBlock).pseudo_R2;
            % now, get PDs for each epoch for each cell
            for i = 1:length(fit_parameters)
                b = fit_parameters{i}{1};
                for iBin = 1:2
                    glm_pds{iBlock,iBin} = [glm_pds{iBlock,iBin}; atan2(b(1+iBin*2),b(iBin*2))];
                    glm_r2s{iBlock,iBin} = [glm_r2s{iBlock,iBin}; pseudo_R2{i}(1,1)];
                end
            end
        end
        
        % get cosine results
        if doCos
            for iBin = 1:length(useBins)
                cos_pds{iBlock,iBin} = [cos_pds{iBlock,iBin}; cosResults(plotFiles(iFile),iBlock,useBins(iBin)).tunCurves(:,3)];
                cos_mds{iBlock,iBin} = [cos_mds{iBlock,iBin}; cosResults(plotFiles(iFile),iBlock,useBins(iBin)).tunCurves(:,2)];
                cos_bos{iBlock,iBin} = [cos_bos{iBlock,iBin}; cosResults(plotFiles(iFile),iBlock,useBins(iBin)).tunCurves(:,1)];
                cos_r2s{iBlock,iBin} = [cos_r2s{iBlock,iBin}; (cosResults(plotFiles(iFile),iBlock,useBins(iBin)).rs)];
                cos_cis{iBlock,iBin} = [cos_cis{iBlock,iBin}; cosResults(plotFiles(iFile),iBlock,useBins(iBin)).confBounds{3}];
                cos_boots{iBlock,iBin} = [cos_boots{iBlock,iBin}; cosResults(plotFiles(iFile),iBlock,useBins(iBin)).boot_pds];
                
                fr = cosResults(plotFiles(iFile),iBlock,useBins(iBin)).fr';
                for unit = 1:size(fr,1)
                    cos_fr{iBlock,iBin} = [cos_fr{iBlock,iBin}; {fr(unit,:)}]; %ends up being trials x units
                    cos_theta{iBlock,iBin} = [cos_theta{iBlock,iBin}; {cosResults(plotFiles(iFile),iBlock,useBins(iBin)).theta}];
                end
            end
        end
    end
end
clear iFile iBlock predictions_combined fit_parameters fit_info psuedo_R2 i b iBin;

% reorganize file-based structure
spikes = cell(size(cos_pds,1),size(cos_pds{1},1),length(utheta));
spikes2 = cell(size(cos_pds,1),size(cos_pds{1},1),length(utheta));
spikes3 = cell(size(cos_pds,1),size(cos_pds{1},1),length(utheta));
unitInfo = zeros(size(cos_pds{1},1),3);
count = 0;
for iFile = 1:length(plotFiles)
    temp = allSpikes{plotFiles(iFile)};
    spikes(:,count+1:count+size(temp,2),:) = temp;
    
    temp = allSpikes2{plotFiles(iFile)};
    spikes2(:,count+1:count+size(temp,2),:) = temp;
    
    temp = allSpikes2{plotFiles(iFile)};
    spikes3(:,count+1:count+size(temp,2),:) = temp;
    
    unitInfo(count+1:count+size(temp,2),:) = allUnitInfo{plotFiles(iFile)};
    
    count = count+size(temp,2);
end
clear iFile temp count;
toc;

tic;
if doCos
    % See if parameter changes
    idx = ceil(((1-bootConfLevel)/2)*numBootIters):floor((bootConfLevel + (1-bootConfLevel)/2)*numBootIters);
    
    % only use the cells that fit well
    goodCells = zeros(size(cos_pds,1),length(useBins));
    goodCellsCI = zeros(size(cos_pds,1),length(useBins));
    anovaP = zeros(size(cos_pds,1),size(spikes,2),length(useBins));
    anovaFR = zeros(size(cos_pds,1),size(spikes,2),length(useBins));
    for iBin = 1:length(useBins)
        for unit = 1:size(spikes,2)
            
            sigTests = zeros(size(cos_pds,1),3);
            for iBlock = 1:size(cos_pds,1)
                % do tests for cosine fits
                r = sort(cos_r2s{iBlock,iBin}(unit,:),2);
                sigTests(iBlock,1) = r(idx(1)) >= minR2_cos;
                sigTests(iBlock,2) = checkTuningCISignificance([cos_pds{iBlock,iBin}(unit,:) cos_cis{iBlock,iBin}(unit,:)],sigAng*pi/180,true);
                
                temp = zeros(1,length(utheta));
                for iDir = 1:length(utheta)
                    data = spikes{iBlock,unit,iDir};
                    if ~iscell(data) % this happens if there were no spikes
                        data = {0};
                    end
                    temp(iDir) = mean(cellfun(@(x) length(x)/sum(window),data)) > minFR;
                end
                
                sigTests(iBlock,3) = any(temp);
                
                % do nonparametric ANOVA test
                fr = cos_fr{iBlock,iBin}{unit};
                theta = cos_theta{iBlock,iBin}{unit};
                
                anovaP(iBlock,unit,iBin) = anova1(fr,theta,'off');
                anovaFR(iBlock,unit,iBin) = any(temp);
            end
            
            goodCells(unit,iBin) = all(all(sigTests(sigBlocks,:)));
        end
    end
    clear iBin unit iBlock iDir r sigTests fr theta temp;
    
    goodCellsANOVA = squeeze(all(anovaP(sigBlocks,:,:) < anovaAlpha,1) & all(anovaFR(sigBlocks,:,:),1));
    
    % Ensures that we only look at cells that are well-tuned in all bins
    % temp = goodCells;
    % for iBin = 1:length(useBins)
    %     for unit = 1:size(spikes,2)
    %         goodCells(unit,iBin) = all(temp(unit,:));
    %     end
    % end
    % clear temp;
end

% Now look for statistical differences in PD fits
% diffTuning = zeros(size(cos_pds,1),length(useBins));
% for iBin = 1:length(useBins)
%
%     bootDiff = sort(angleDiff(cos_boots{eComp(1),iBin}, cos_boots{eComp(2),iBin}, true, true),2);
%
%     % now get 95% confidence
%     for unit = 1:size(bootDiff,1)
%         overlap = range_intersection([0 0],bootDiff(unit,idx));
%         if isempty(overlap) && goodCells(unit,iBin)
%             diffTuning(unit,iBin) = 1;
%         end
%     end
% end
toc;

% Make some plots
if 0
    close all
    
    if doMD
        bins = -20+db/2:db:20-db/2;
        histmin = -1;
        histmax = 1;
    else
        bins = -180+db/2:db:180-db/2;
        histmin = -100;
        histmax = 100;
    end
    figure;
    subplot1(length(useBins),1);
    
    thediff = cell(1,length(useBins));
    for iBin = 1:length(useBins)
        subplot1(iBin);
        hold all;
        if doMD
            if doAbs
                thediff{iBin} = abs(cos_mds{eComp(2),iBin}(goodCells(:,iBin)==1) - cos_mds{eComp(1),iBin}(goodCells(:,iBin)==1))./cos_bos{eComp(1),iBin}(goodCells(:,iBin)==1);
            else
                thediff{iBin} = (cos_mds{eComp(2),iBin}(goodCells(:,iBin)==1) - cos_mds{eComp(1),iBin}(goodCells(:,iBin)==1))./cos_bos{eComp(1),iBin}(goodCells(:,iBin)==1);
            end
        else
            thediff{iBin} = angleDiff(cos_pds{eComp(1),iBin}(goodCells(:,iBin)==1),cos_pds{eComp(2),iBin}(goodCells(:,iBin)==1),true,~doAbs).*(180/pi);
        end
        hist(thediff{iBin},bins);
        set(gca,'Box','off','TickDir','out','XLim',[histmin,histmax],'FontSize',14);
        V = axis;
        plot([0 0],V(3:4),'k--');
        ylabel(plotLabels{iBin},'FontSize',14);
    end
    xlabel('PD Change (Deg)','FontSize',16);
    
    compBlocks = [2,4,5,7];
    refBlock = 1;
    plotColors = {[1 0.6 0.6],[1 0 0],[0.6 1 0.6],[0 1 0]};
    
    thediff = cell(length(compBlocks),length(useBins));
    for iBlock = 1:length(compBlocks)
        for iBin = 1:length(useBins)
            if doMD
                if doAbs
                    thediff{iBlock,iBin} = abs(cos_mds{compBlocks(iBlock),iBin}(goodCells(:,iBin)==1) - cos_mds{refBlock,iBin}(goodCells(:,iBin)==1))./cos_bos{refBlock,iBin}(goodCells(:,iBin)==1);
                else
                    thediff{iBlock,iBin} = (cos_mds{compBlocks(iBlock),iBin}(goodCells(:,iBin)==1) - cos_mds{refBlock,iBin}(goodCells(:,iBin)==1))./cos_bos{refBlock,iBin}(goodCells(:,iBin)==1);
                end
            else
                thediff{iBlock,iBin} = angleDiff(cos_pds{refBlock,iBin}(goodCells(:,iBin)==1),cos_pds{compBlocks(iBlock),iBin}(goodCells(:,iBin)==1),true,~doAbs).*(180/pi);
            end
        end
    end
    
    figure('Position',[200 200 800 600]);
    hold all;
    for iBlock = 1:2
        for iBin = 1:length(useBins)
            plot(iBin+0.1*(iBlock-1),mean(thediff{iBlock,iBin}),'o','Color',plotColors{iBlock},'LineWidth',3);
            plot([iBin iBin]+0.1*(iBlock-1),[mean(thediff{iBlock,iBin})-std(thediff{iBlock,iBin})./sqrt(length(thediff{iBlock,iBin})), mean(thediff{iBlock,iBin})+std(thediff{iBlock,iBin})./sqrt(length(thediff{iBlock,iBin}))],'Color',plotColors{iBlock},'LineWidth',3)
        end
    end
    set(gca,'Box','off','TickDir','out','XLim',[0 length(useBins)+1],'YLim',[xmin xmax],'XTick',1:length(useBins),'XTickLabel',plotLabels,'FontSize',14);
    ylabel('PD Change (Deg)','FontSize',14);
    plot([0 length(useBins)+1],[0 0],'k--','LineWidth',1);
    
    figure;
    hold all;
    for iBlock = 3:4
        for iBin = 1:length(useBins)
            plot(iBin+0.1*(iBlock-3),mean(thediff{iBlock,iBin}),'o','Color',plotColors{iBlock},'LineWidth',3);
            plot([iBin iBin]+0.1*(iBlock-3),[mean(thediff{iBlock,iBin})-std(thediff{iBlock,iBin})./sqrt(length(thediff{iBlock,iBin})), mean(thediff{iBlock,iBin})+std(thediff{iBlock,iBin})./sqrt(length(thediff{iBlock,iBin}))],'Color',plotColors{iBlock},'LineWidth',3)
        end
    end
    set(gca,'Box','off','TickDir','out','XLim',[0 length(useBins)+1],'YLim',[xmin xmax],'XTick',1:length(useBins),'XTickLabel',plotLabels,'FontSize',14);
    ylabel('PD Change (Deg)','FontSize',14);
    plot([0 length(useBins)+1],[0 0],'k--','LineWidth',1);
end

clear iBlock iBin V unit overlap test1 test2 test3 test4 r1 r1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% look at firing rate changes as a function of cell PD
useBins = 1:18;
% useBins = 1:9;
compBlocks = [1,2,4,5,7];
plotColors = {[0 0 1],[1 0.6 0.6],[1 0 0],[0.6 1 0.6],[0 1 0]};
allDirFR = cell(length(compBlocks),length(useBins));

doNonParametricFR = true;

if doNonParametricFR
    goodCells = goodCellsANOVA;
end

for iBin = 1:length(useBins)
    % find baseline PD of cell
    pds = cos_pds{1,useBins(iBin)};
    
    % find target ID that is nearest to this PD
    d = zeros(length(pds),length(utheta));
    for iDir = 1:length(utheta)
        d(:,iDir) = angleDiff(pds,utheta(iDir),true,true);
    end
    [~,targPDs] = min(abs(d),[],2);
    
    for iBlock = 1:length(compBlocks)
        fr = cos_fr{compBlocks(iBlock),useBins(iBin)};
        theta = cos_theta{compBlocks(iBlock),useBins(iBin)};
        newFR = zeros(size(targPDs,1),length(utheta),2);
        for unit = 1:size(targPDs,1)
            temp = fr{unit};
            dirFR = zeros(length(utheta),2);
            for iDir = 1:length(utheta)
                idx = theta{unit}==utheta(iDir);
                dirFR(iDir,:) = [mean(temp(idx)) std(temp(idx))./sqrt(sum(idx))];
            end
            
            % get index of targets, with PD at 4
            %             if doNonParametricFR
            %                 [~,I] = max(dirFR(:,1));
            %                 newFR(unit,:,:) = circshift(dirFR,4-I);
            %             else
            newFR(unit,:,:) = circshift(dirFR,4-targPDs(unit));
            %             end
        end
        allDirFR{iBlock,iBin} = newFR;
    end
end
clear iBin pds blfr d iDir targPDs iBlock fr theta getFR unit temp dirFR iDir idx newFR I;


close all;
% now, make a plot
for iBin = 1:size(allDirFR,2)
    figure('Position',[200 200 800 600]);
    hold all;
    
    for iBlock = [1,3,5]
        fr = allDirFR{iBlock,iBin}(:,:,1);
        
        dfr = zeros(size(fr,1),length(utheta));
        for iDir = 1:length(utheta)
            dfr(:,iDir) = (fr(:,iDir)-cos_mds{compBlocks(iBlock),useBins(iBin)})./cos_bos{compBlocks(iBlock),useBins(iBin)};
        end
        
        idx = goodCells(:,useBins(iBin))==1;
        
        %plot(dfr(goodCells(:,useBins(iBin))==1,:)');
        
        plot(mean(dfr(idx,:),1),'Color',plotColors{iBlock},'LineWidth',2);
        plot(mean(dfr(idx,:),1) + std(dfr(idx,:),1)./sqrt(sum(idx)),'--','LineWidth',2,'Color',plotColors{iBlock});
        plot(mean(dfr(idx,:),1) - std(dfr(idx,:),1)./sqrt(sum(idx)),'--','LineWidth',2,'Color',plotColors{iBlock});
    end
    set(gca,'Box','off','TickDir','out','FontSize',14,'XLim',[1 8],'YLim',[-1,2],'XTick',[4 8],'XTickLabel',{'PD','Anti-PD'});
    xlabel('Target Directions','FontSize',16);
    ylabel('Normalized Firing Rate','FontSize',16);
end
clear iBin iBlock iDir fr dfr idx;

close all;
% now, make a plot
binFR = nan(size(allDirFR,2),size(cos_pds{1,1},1),length(utheta));
binFR2 = nan(size(allDirFR,2),size(cos_pds{1,1},1),length(utheta));
binFR3 = nan(size(allDirFR,2),size(cos_pds{1,1},1),length(utheta));
for iBin = 1:size(allDirFR,2)
    figure('Position',[200 200 800 600]);
    hold all;
    
    blfr = allDirFR{1,iBin}(:,:,1);
    
    for iBlock = [1,2,3,5]
        fr = allDirFR{iBlock,iBin}(:,:,1);
        
        dfr = zeros(size(fr,1),length(utheta));
        for iDir = 1:length(utheta)
            bl = (blfr(:,iDir)-cos_mds{1,useBins(iBin)})./cos_bos{1,useBins(iBin)};
            temp = (fr(:,iDir)-cos_mds{compBlocks(iBlock),useBins(iBin)})./cos_bos{compBlocks(iBlock),useBins(iBin)};
            dfr(:,iDir) = temp-bl;
        end
        
        idx = goodCells(:,useBins(iBin))==1;
        temp = dfr(idx,:);
        
        if iBlock==2
            binFR(iBin,idx,:) = temp;
        elseif iBlock==3
            binFR2(iBin,idx,:) = temp;
        elseif iBlock==5
            binFR3(iBin,idx,:) = temp;
        end
        
        %         plot(dfr(goodCells(:,useBins(iBin))==1,:)');
        
        plot(nanmean(temp,1),'Color',plotColors{iBlock},'LineWidth',2);
        plot(nanmean(temp,1) + nanstd(temp,1)./sqrt(sum(idx)),'--','LineWidth',2,'Color',plotColors{iBlock});
        plot(nanmean(temp,1) - nanstd(temp,1)./sqrt(sum(idx)),'--','LineWidth',2,'Color',plotColors{iBlock});
    end
    set(gca,'Box','off','TickDir','out','FontSize',14,'XLim',[1 8],'YLim',[-0.5,0.5],'XTick',[4 8],'XTickLabel',{'PD','Anti-PD'});
    xlabel('Target Directions','FontSize',16);
    ylabel('Difference in Normalized Firing Rate','FontSize',16);
end
clear iBin blfr iBlock fr dfr bl idx;

figure('Position',[200 200 800 800]);
subplot(3,1,1);
imagesc((squeeze(nanmean(binFR,2))')); colorbar;
set(gca,'Xtick',[],'YTick',[4,8],'YTickLabel',{'PD','Anti-PD'},'FontSize',14,'Box','off','TickDir','out');
caxis([-0.45 0.3]);
if strcmpi(usePert,'VR')
    title('Early Rotation','FontSize',16);
else
    title('Early Force','FontSize',16);
end
subplot(3,1,2);
imagesc((squeeze(nanmean(binFR2,2))')); colorbar;
set(gca,'Xtick',[],'YTick',[4,8],'YTickLabel',{'PD','Anti-PD'},'FontSize',14,'Box','off','TickDir','out');
caxis([-0.45 0.3]);
if strcmpi(usePert,'VR')
    title('Late Rotation','FontSize',16);
else
    title('Late Force','FontSize',16);
end
subplot(3,1,3);
imagesc((squeeze(nanmean(binFR3,2))')); colorbar;
% set(gca,'Xtick',[1,3,8],'XTickLabel',{'Visual','Planning','Movement'},'YTick',[4,8],'YTickLabel',{'PD','Anti-PD'},'FontSize',14,'Box','off','TickDir','out');
set(gca,'Xtick',[1,5,14],'XTickLabel',{'Visual','Planning','Movement'},'YTick',[4,8],'YTickLabel',{'PD','Anti-PD'},'FontSize',14,'Box','off','TickDir','out');
caxis([-0.45 0.3]);
title('Washout','FontSize',16);

%%
figure('Position',[200 200 700 500]);
subplot(2,1,1);
imagesc((squeeze(nanmean(pmd_binFR,2))')); colorbar;
set(gca,'Xtick',[],'YTick',[4,8],'YTickLabel',{'PD','Anti-PD'},'FontSize',14,'Box','off','TickDir','out');
caxis([-0.45 0.3]);
if strcmpi(usePert,'VR')
    title('Early Rotation','FontSize',16);
else
    title('Early Force','FontSize',16);
end
ylabel('PMd','FontSize',16);
subplot(2,1,2);
imagesc((squeeze(nanmean(m1_binFR,2))')); colorbar;
set(gca,'Xtick',[1,5,14],'XTickLabel',{'Visual','Planning','Movement'},'YTick',[4,8],'YTickLabel',{'PD','Anti-PD'},'FontSize',14,'Box','off','TickDir','out');
caxis([-0.45 0.3]);
ylabel('M1','FontSize',16);

figure('Position',[200 200 700 500]);
subplot(2,1,1);
imagesc((squeeze(nanmean(pmd_binFR2,2))')); colorbar;
set(gca,'Xtick',[],'YTick',[4,8],'YTickLabel',{'PD','Anti-PD'},'FontSize',14,'Box','off','TickDir','out');
caxis([-0.45 0.3]);
if strcmpi(usePert,'VR')
    title('Late Rotation','FontSize',16);
else
    title('Late Force','FontSize',16);
end
ylabel('PMd','FontSize',16);
subplot(2,1,2);
imagesc((squeeze(nanmean(m1_binFR2,2))')); colorbar;
set(gca,'Xtick',[1,3,8],'XTickLabel',{'Visual','Planning','Movement'},'YTick',[4,8],'YTickLabel',{'PD','Anti-PD'},'FontSize',14,'Box','off','TickDir','out');
caxis([-0.45 0.3]);
ylabel('M1','FontSize',16);

figure('Position',[200 200 700 500]);
subplot(2,1,1);
imagesc((squeeze(nanmean(pmd_binFR3,2))')); colorbar;
set(gca,'Xtick',[],'YTick',[4,8],'YTickLabel',{'PD','Anti-PD'},'FontSize',14,'Box','off','TickDir','out');
caxis([-0.45 0.3]);
title('Washout','FontSize',16);
ylabel('PMd','FontSize',16);
subplot(2,1,2);
imagesc((squeeze(nanmean(m1_binFR3,2))')); colorbar;
set(gca,'Xtick',[1,5,14],'XTickLabel',{'Visual','Planning','Movement'},'YTick',[4,8],'YTickLabel',{'PD','Anti-PD'},'FontSize',14,'Box','off','TickDir','out');
caxis([-0.45 0.3]);
ylabel('M1','FontSize',16);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% plot raster for each direction for each cell
if doRasters
    % from trial table, the direction indices are as follows:
    %       targ_angs = [pi/2, pi/4, 0, -pi/4, -pi/2, -3*pi/4, pi, 3*pi/4];
    %       plotPositions = [3,7,11,17,23,19,15,9];
    % however, from unique(theta), the direction indices are as follows
    %       targ_angs = [-3*pi/4, -pi/2, -pi/4, 0, pi/4, pi/2, 3*pi/4, pi];
    plotPositions = [17,23,19,15,9,3,7,11];
    plotGap = 0.1;
    useBlocks = [1,2,4,5,7];
    useBlocksTune = [1 2 4 5 7];
    saveFiles = true;
    doDouble = true;
    
    minR2_glm = 0.1;
    minR2_cos = -1;
    binSize = 0.01;
    
%     % only use the cells that fit well
%     for iBin = 1:length(useBins)
%         for unit = 1:size(spikes,2)
%             goodCells(unit,iBin) = 1;
% %             if doGLM && doCos
% %                 goodCells(unit,iBin) = glm_r2s{1,iBin}(unit) >= minR2_glm & cos_r2s{3,iBin}(unit) >= minR2_cos;
% %             elseif doGLM && ~doCos
% %                 goodCells(unit,iBin) = glm_r2s{1,iBin}(unit) >= minR2_glm & glm_r2s{3,iBin}(unit) >= minR2_glm;
% %             elseif doCos && ~doGLM
% %                 goodCells(unit,iBin) = cos_r2s{1,iBin}(unit) >= minR2_cos & cos_r2s{3,iBin}(unit) >= minR2_cos & cos_r2s{5,iBin}(unit) >= minR2_cos;
% %             end
%         end
%     end
goodCells = ones(size(spikes,2),length(useBins));
    
    bins = -window(1)+binSize/2:binSize:window(2)-binSize/2;
    
    % if directory for saving doesn't exist, create it
    if ~exist('figs','dir')
        mkdir('figs');
    end
    
    if length(useBlocks)==3
        plotColors = {'b','r','g'};
    elseif length(useBlocks)==5
        plotColors = {[0 0 1], ...
            [1 0.5,0.5],[1 0 0], ...
            [0.5 1 0.5],[0 1 0],};
    elseif length(useBlocks)==8
        plotColors = {[0 0 1],[0.5 0.5 1], ...
            [1 0 0],[1 0.2 0.2],[1 0.5,0.5] ...
            [0 1 0],[0.2 1 0.2],[0.5 1 0.5]};
    end
    
    if length(useBlocksTune)==3
        plotColorsTune = {'b','r','g'};
    elseif length(useBlocksTune)==5
        plotColorsTune = {[0 0 1], ...
            [1 0.5,0.5],[1 0 0], ...
            [0.5 1 0.5],[0 1 0],};
    elseif length(useBlocksTune)==8
        plotColorsTune = {[0 0 1],[0.5 0.5 1], ...
            [1 0 0],[1 0.2 0.2],[1 0.5,0.5] ...
            [0 1 0],[0.2 1 0.2],[0.5 1 0.5]};
    end
    
    useCells = find(all(goodCells,2));
    
    tic;
    disp(['Now plotting rasters for ' num2str(length(useCells)) ' cells...']);
    for iCell = 1:length(useCells)
        unit = useCells(iCell);
        fh = figure('Position',[200, 0, 1200, 1000]);
        subplot1(5,5);
        
        for iDir = 1:5
            for jDir = 1:5
                if ~any(ismember([plotPositions 13],5*(iDir-1)+jDir))
                    subplot1(5*(iDir-1)+jDir);
                    axis('off');
                end
            end
        end
        
        allBinned = cell(length(utheta),length(useBlocks));
        allBinned2 = cell(length(utheta),length(useBlocks));
        maxTrial = zeros(1,length(utheta));
        for iDir = 1:length(utheta)
            subplot1(plotPositions(iDir));
            hold all;
            for iBlock = 1:length(useBlocks)
                binCounts = zeros(size(bins));
                binCounts2 = zeros(size(bins));
                
                data = spikes{useBlocks(iBlock),unit,iDir};
                data2 = spikes2{useBlocks(iBlock),unit,iDir};
                for iTrial = 1:length(data)
                                        plot([data{iTrial};data{iTrial}],maxTrial(iDir)+[(iTrial-1)*ones(1,length(data{iTrial})); iTrial*ones(1,length(data{iTrial}))],'-','LineWidth',1,'Color',plotColors{iBlock});
                    % get count of spikes in small bins
                    binCounts = binCounts + hist(data{iTrial},bins);
                    
                    if doDouble
                                                plot([data2{iTrial}+window(1)+window(2)+plotGap;data2{iTrial}+window(1)+window(2)+plotGap],maxTrial(iDir)+[(iTrial-1)*ones(1,length(data2{iTrial})); iTrial*ones(1,length(data2{iTrial}))],'-','LineWidth',1,'Color',plotColors{iBlock});
                        binCounts2 = binCounts2 + hist(data2{iTrial},bins);
                    end
                end
                maxTrial(iDir) = iTrial+maxTrial(iDir);
                
                allBinned{iDir,iBlock} = binCounts/length(data);
                if doDouble
                    allBinned2{iDir,iBlock} = binCounts2/length(data2);
                end
            end
        end
        
        % get maximum count over all epochs and directions
        maxCount = 0;
        for iDir = 1:length(utheta)
            for iBlock = 1:length(useBlocks)
                data = allBinned{iDir,iBlock};
                maxCount = max([maxCount,data]);
                if doDouble
                    data = allBinned2{iDir,iBlock};
                    maxCount = max([maxCount,data]);
                end
            end
        end
        
        for iDir = 1:length(utheta)
            subplot1(plotPositions(iDir));
            
            % now plot sums as lines
            for iBlock = 1:length(useBlocks)
                plot(bins,maxTrial(iDir)+(0.5*maxTrial(iDir)).*(allBinned{iDir,iBlock})./maxCount,'Color',plotColors{iBlock},'LineWidth',2);
                if doDouble
                    plot(bins+window(1)+window(2)+plotGap,maxTrial(iDir)+(0.5*maxTrial(iDir)).*(allBinned2{iDir,iBlock})./maxCount,'Color',plotColors{iBlock},'LineWidth',2);
                end
            end
            %             for iBlock = 1:length(useBlocks)
            %                 plot(bins,maxTrial(iDir)+(0.5*maxTrial(iDir)).*allBinned{iDir,iBlock}./maxCount,'Color',plotColors{iBlock},'LineWidth',2);
            %                 if doDouble
            %                     plot(bins+window(1)+window(2)+plotGap,maxTrial(iDir)+(0.5*maxTrial(iDir)).*allBinned2{iDir,iBlock}./maxCount,'Color',plotColors{iBlock},'LineWidth',2);
            %                 end
            %             end
            
            axis('tight')
            V = axis;
            axis([V(1:3) maxTrial(iDir)+0.5*maxTrial(iDir)]);
            V = axis;
            
            set(gca,'Box','off','TickDir','out','FontSize',14);
            
            plot([0 0],V(3:4),'k--','LineWidth',1);
            if doDouble
                plot([window(1)+window(2)+plotGap window(1)+window(2)+plotGap],V(3:4),'k--','LineWidth',1);
            end
            h = findobj(gca,'Type','patch');
            set(h,'EdgeColor','w','facealpha',0.5,'edgealpha',0);
            if plotPositions(iDir)==3
                t = [doFiles{unitInfo(unit,1),2} '_e' num2str(unitInfo(unit,2)) '_u' num2str(unitInfo(unit,3))];
                title(t,'FontSize',14);
            end
            
        end
        
        % now, add center plot with tuning information
        subplot1(13);
        for iBlock = 1:length(useBlocksTune)
            if doGLM
                for iBin = 1:length(useBins)
                    gpd = glm_pds{useBlocks(iBlock),iBin}(unit);
                    plot([(iBin-1)*cos(gpd) iBin*cos(gpd)],[(iBin-1)*sin(gpd) iBin*sin(gpd)],'--','Color',plotColorsTune{iBlock},'LineWidth',2);
                end
            end
            
            if doCos
                for iBin = 1:length(useBins)
                    cpd = cos_pds{useBlocks(iBlock),iBin}(unit);
                    plot([(iBin-1)*cos(cpd) iBin*cos(cpd)],[(iBin-1)*sin(cpd) iBin*sin(cpd)],'-','Color',plotColorsTune{iBlock},'LineWidth',2);
                end
            end
        end
        set(gca,'XLim',[-2 2],'YLim',[-2 2]);
        set(gca,'Box','off','TickDir','out','FontSize',14);
        
        if saveFiles
            saveas(fh,fullfile('figs',[t '.png']),'png');
        end
        
        %pause;
        close all;
    end
    
    clear unit iDir temp data jDir allBinned allBinned2 maxTrial iDir iBlock binCounts binCounts2 data2 iTrial maxCount bins t V h fh;
    
end

