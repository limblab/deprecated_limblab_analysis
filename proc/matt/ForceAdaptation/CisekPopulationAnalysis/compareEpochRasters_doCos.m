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

tic;
% first get directions and firing rate for each trial, unit, day, block
cosFR = cell(size(blockFR,1),size(blockFR,2));
cosTheta = cell(size(blockFR,1),size(blockFR,2));
for iFile = 1:size(blockFR,1)
    for iBlock = 1:size(blockFR,2)
        fr_all = squeeze(blockFR(iFile,iBlock,:,:));
        allEvents{1} = squeeze(blockEvent1(iFile,iBlock,:));
        allEvents{2} = squeeze(blockEvent2(iFile,iBlock,:));
        
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
clear iFile iBlock iBin fr tunCurves confBounds rs boot_pds boot_mds boot_bos unit theta;
toc;

save(fullfile(saveDir,[useArray '_cosResults_' datestr(now,'yyyymmddTHHMMSS') '.mat']),'-v7.3')

% save('PMd_cosResults_05072015.mat','-v7.3');
