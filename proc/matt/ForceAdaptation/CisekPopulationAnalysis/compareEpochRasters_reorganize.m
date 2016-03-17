%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find the PDs for all cells
tic;
if doGLM
    glm_pds = cell(blockCount,2);
    glm_r2s = cell(blockCount,2);
end
if doCos
    cos_pds = cell(blockCount,length(useBins));
    cos_mds = cell(blockCount,length(useBins));
    cos_bos = cell(blockCount,length(useBins));
    cos_r2s = cell(blockCount,length(useBins));
    cos_cis = cell(blockCount,length(useBins));
    cos_boots = cell(blockCount,length(useBins));
    cos_fr = cell(blockCount,length(useBins));
    cos_theta = cell(blockCount,length(useBins));
end

pertDir = zeros(1,length(plotFiles));
for iFile = 1:length(plotFiles)
    
    % load parsed file for this day
    load(fullfile(saveDir,paramSetName,'data',[useArray '_' doFiles{plotFiles(iFile),1} '_' doFiles{plotFiles(iFile),2} '.mat']),'blockFR','blockEvent1','blockEvent2');
    if doGLM
        load(fullfile(saveDir,paramSetName,'glm',[useArray '_' doFiles{plotFiles(iFile),1} '_' doFiles{plotFiles(iFile),2} '.mat']),'glmResults');
    end
    if doCos
        % load cosine results for this day
        load(fullfile(saveDir,paramSetName,'cos',[useArray '_' doFiles{plotFiles(iFile),1} '_' doFiles{plotFiles(iFile),2} '.mat']),'cosResults');
        
        % check for direction of perturbation in this file
        if flipClockwisePerts
            % gotta hack it
            dataPath = fullfile(root_dir,doFiles{plotFiles(iFile),1},'Processed',doFiles{plotFiles(iFile),2});
            expParamFile = fullfile(dataPath,[doFiles{plotFiles(iFile),2} '_experiment_parameters.dat']);
            temp = parseExpParams(expParamFile);
            pertDir(iFile) = temp.angle_dir;
            clear temp;
        else
            pertDir(iFile) = 1;
        end
    end
    
    for iBlock = 1:size(blockFR,1)
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
                % flip the PDs based on the perturbation direction
                cos_pds{iBlock,iBin} = [cos_pds{iBlock,iBin}; pertDir(iFile).*cosResults(iBlock,useBins(iBin)).tunCurves(:,3)];
                cos_mds{iBlock,iBin} = [cos_mds{iBlock,iBin}; cosResults(iBlock,useBins(iBin)).tunCurves(:,2)];
                cos_bos{iBlock,iBin} = [cos_bos{iBlock,iBin}; cosResults(iBlock,useBins(iBin)).tunCurves(:,1)];
                cos_r2s{iBlock,iBin} = [cos_r2s{iBlock,iBin}; (cosResults(iBlock,useBins(iBin)).rs)];
                cos_cis{iBlock,iBin} = [cos_cis{iBlock,iBin}; cosResults(iBlock,useBins(iBin)).confBounds{3}];
                cos_boots{iBlock,iBin} = [cos_boots{iBlock,iBin}; cosResults(iBlock,useBins(iBin)).boot_pds];
                
                fr = cosResults(iBlock,useBins(iBin)).fr';
                for unit = 1:size(fr,1)
                    cos_fr{iBlock,iBin} = [cos_fr{iBlock,iBin}; {fr(unit,:)}]; %ends up being trials x units
                    cos_theta{iBlock,iBin} = [cos_theta{iBlock,iBin}; {cosResults(iBlock,useBins(iBin)).theta}];
                end
            end
        end
    end
end
clear iFile iBlock predictions_combined fit_parameters fit_info psuedo_R2 i b iBin;

% reorganize file-based structure
allSpikes = cell(size(cos_pds,1),size(cos_pds{1},1),length(utheta),length(alignInds));
allUnitInfo = zeros(size(cos_pds{1},1),3);
count = 0;
for iFile = 1:length(plotFiles)
    load(fullfile(saveDir,paramSetName,'data',[useArray '_' doFiles{plotFiles(iFile),1} '_' doFiles{plotFiles(iFile),2} '.mat']),'spikes','unitInfo');
    
    allSpikes(:,count+1:count+size(spikes,2),:,:) = spikes;
    
    allUnitInfo(count+1:count+size(spikes,2),:) = unitInfo;
    
    count = count+size(spikes,2);
end
clear iFile temp count spikes unitInfo;
toc;

tic;
if doCos
    % See if parameter changes
    idx = ceil(((1-bootConfLevel)/2)*numBootIters):floor((bootConfLevel + (1-bootConfLevel)/2)*numBootIters);
    
    % only use the cells that fit well
    goodCells = zeros(size(cos_pds,1),length(useBins));
    goodCellsCI = zeros(size(cos_pds,1),length(useBins));
    anovaP = zeros(size(cos_pds,1),size(allSpikes,2),length(useBins));
    anovaFR = zeros(size(cos_pds,1),size(allSpikes,2),length(useBins));
    for iBin = 1:length(useBins)
        for unit = 1:size(allSpikes,2)
            
            sigTests = zeros(size(cos_pds,1),3);
            for iBlock = 1:size(cos_pds,1)
                % do tests for cosine fits
                r = sort(cos_r2s{iBlock,iBin}(unit,:),2);
                sigTests(iBlock,1) = r(idx(1)) >= minR2_cos;
                sigTests(iBlock,2) = checkTuningCISignificance([cos_pds{iBlock,iBin}(unit,:) cos_cis{iBlock,iBin}(unit,:)],sigAng*pi/180,true);
                
                temp = zeros(1,length(utheta));
                for iDir = 1:length(utheta)
                    data = allSpikes{iBlock,unit,iDir};
                    if ~iscell(data) % this happens if there were no spikes
                        data = {0};
                    end
                    temp(iDir) = mean(cellfun(@(x) length(x)/sum(window),data)) > minFR;
                end
                
                sigTests(iBlock,3) = any(temp);
                
                % do nonparametric ANOVA test to see if cell varies with direction
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
