%% Now, do cosine fit to several periods during movement
if ~exist(fullfile(saveDir,paramSetName,'cos'),'dir')
    mkdir(fullfile(saveDir,paramSetName,'cos'));
end

load(fullfile(saveDir,paramSetName,[useArray '_otherVars.mat']));

tic;
% first get directions and firing rate for each trial, unit, day, block
cosFR = cell(size(doFiles,1),blockCount);
cosTheta = cell(size(doFiles,1),blockCount);
for iFile = 1:size(doFiles,1)
    
    % load parsed file for this day
    load(fullfile(saveDir,paramSetName,'data',[useArray '_' doFiles{iFile,1} '_' doFiles{iFile,2} '.mat']),'blockFR','blockEvent1','blockEvent2');
    
    for iBlock = 1:size(blockFR,1)
        fr_all = squeeze(blockFR(iBlock,:,:));
        allEvents{1} = squeeze(blockEvent1(iBlock,:));
        allEvents{2} = squeeze(blockEvent2(iBlock,:));
        
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
cosResults = repmat(struct(),[size(blockFR,1),size(binRange,1)]);
for iFile = 1:size(doFiles,1)
    for iBlock = 1:size(blockFR,1)
        fr = cosFR{iFile,iBlock};
        theta = cosTheta{iFile,iBlock};
        for iBin = 1:size(binRange,1)
            disp(['Cosine tuning curve fitting: File ' num2str(iFile) ', Block ' num2str(iBlock) ', Bin ' num2str(iBin)]);
            
            [tunCurves,confBounds,rs,boot_pds,boot_mds,boot_bos] = regressTuningCurves(squeeze(fr(iBin,:,:)),theta(iBin,:)',{'bootstrap',numBootIters,bootConfLevel},'doparallel',true,'doplots',false);
            
            cosResults(iBlock,iBin).tunCurves = tunCurves;
            cosResults(iBlock,iBin).confBounds = confBounds;
            cosResults(iBlock,iBin).rs = rs;
            cosResults(iBlock,iBin).boot_pds = boot_pds;
            cosResults(iBlock,iBin).boot_mds = boot_mds;
            cosResults(iBlock,iBin).fr = squeeze(fr(iBin,:,:)); %ends up being trials x units
            cosResults(iBlock,iBin).theta = theta(iBin,:);
        end
    end
    % save the data for this file
    save(fullfile(saveDir,paramSetName,'cos',[useArray '_' doFiles{iFile,1} '_' doFiles{iFile,2} '.mat']),'cosResults');
end
clear iFile iBlock iBin fr tunCurves confBounds rs boot_pds boot_mds boot_bos unit theta cosTheta cosFR;
toc;
