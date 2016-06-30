
if ~exist(fullfile(saveDir,paramSetName,'data'),'dir')
    mkdir(fullfile(saveDir,paramSetName,'data'));
end

tic;
clear blockFR blockEvent1 blockEvent2 blockEvent3;
for iFile = 1:size(doFiles,1)
    disp(['Processing File ' num2str(iFile) ' of ' num2str(size(doFiles,1)) '...']);
    clear spikes spikes2 spikes3
    [~,c] = loadResults(root_dir,doFiles(iFile,:),'tuning',{'tuning','classes'},useArray,'movement','regression','onpeak');
    master_sg = c(1).sg;
    
    %%%% NOTE I'M HACKING THIS
    c.params.tuning.blocks = tuningBlocks;
    
    data = cell(1,3);
    for iEpoch = 1:length(epochs)
        % we don't need continuous data so load everything else to save time
        data{iEpoch} = loadResults(root_dir,doFiles(iFile,:),'data',{useArray,'meta','params','trial_table','movement_table','movement_centers'},epochs{iEpoch});
    end
    
    count = 0; clear unitInfo;
    for unit = 1:size(master_sg,1)
        if all(c(1).istuned(unit,1:4))
            count = count + 1;
            
            unitInfo(count,:) = [iFile,master_sg(unit,:)];
            
            blockCount = 0;
            for iEpoch = 1:length(epochs)
                d = data{iEpoch};
                units = d.(useArray).units;
                movement_table = filterMovementTable(d,c.params,true,false);
                
                sg = cell2mat({units.id}');
                for iBlock = 1:length(movement_table)
                    blockCount = blockCount + 1;
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
                        for iAlign = 1:length(alignInds)
                            [~, spikes{blockCount,count,iDir,iAlign}] = plotAlignedFR(units(idx).ts,mt(inds,alignInds(iAlign)),window,binSize,false);
                        end
                    end
                    
                    % now get binned firing rates for GLM
                    for iTrial = 1:size(mt,1)
                        spikeInds = units(idx).ts >= mt(iTrial,glmAlign(1))-glmWindow(1) & units(idx).ts < mt(iTrial,glmAlign(2))+glmWindow(2);
                        
                        bins = mt(iTrial,glmAlign(1))-glmWindow(1)+binSize/2:binSize:mt(iTrial,glmAlign(2))+glmWindow(2);
                        [f,~]=hist(units(idx).ts(spikeInds),bins);
                        
                        blockFR{blockCount,iTrial,count} = (f./binSize)';
                        
                        event = zeros(size(bins'));
                        event( find(bins >= mt(iTrial,glmAlign(1)),1,'first') ) = 1;
                        blockEvent1{blockCount,iTrial} = [event cos(mt(iTrial,1))*event sin(mt(iTrial,1))*event];
                        
                        event = zeros(size(bins'));
                        event( find(bins >= mt(iTrial,glmAlign(2)),1,'first') ) = 1;
                        blockEvent2{blockCount,iTrial} = [event cos(mt(iTrial,1))*event sin(mt(iTrial,1))*event];
                    end
                end
            end
        end
    end
    
    % save the data for this file
    save(fullfile(saveDir,paramSetName,'data',[useArray '_' doFiles{iFile,1} '_' doFiles{iFile,2} '.mat']),'spikes','unitInfo','blockFR','blockEvent1','blockEvent2');
    
    clear data spikes spikes2 f bins inds idx mt theta movement_table units d sg c spikeInds event unitInfo blockFR blockEvent1 blockEvent2;
end
clear iFile master_sg iEpoch unit iDir iTrial count doWidthSeparation franova iBlock whichBlock whichScript sComp slidingParams classifierBlocks dateInds iAlign;

% now, save the parameters used for this
save(fullfile(saveDir,paramSetName,[useArray '_otherVars.mat']));
toc;