    tic;
    clear blockFR blockEvent1 blockEvent2 blockEvent3;
    for iFile = 1:size(doFiles,1)
        disp(['Processing File ' num2str(iFile) ' of ' num2str(size(doFiles,1)) '...']);
        clear spikes spikes2 spikes3
        [~,c] = loadResults(root_dir,doFiles(iFile,:),'tuning',{'tuning','classes'},useArray,paramSetName,tuneMethod,tuneWindow);
        master_sg = c(1).sg;
        
        %%%% NOTE I'M HACKING THIS
        c.params.tuning.blocks = {[0 1],[0 0.5 1],[0 0.5 1]};
        
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
                            for iAlign = 1:length(alignInds)
                                [~, spikes{blockCount,count,iDir,iAlign}] = plotAlignedFR(units(idx).ts,mt(inds,alignInds(iAlign)),window,binSize,false);
                            end
                        end
                        
                        % now get binned firing rates for GLM
                        for iTrial = 1:size(mt,1)
                            spikeInds = units(idx).ts >= mt(iTrial,glmAlign(1))-glmWindow(1) & units(idx).ts < mt(iTrial,glmAlign(2))+glmWindow(2);
                            
                            bins = mt(iTrial,glmAlign(1))-glmWindow(1)+binSize/2:binSize:mt(iTrial,glmAlign(2))+glmWindow(2);
                            [f,~]=hist(units(idx).ts(spikeInds),bins);
                            
                            blockFR{iFile,blockCount,iTrial,count} = (f./binSize)';
                            
                            event = zeros(size(bins'));
                            event( find(bins >= mt(iTrial,glmAlign(1)),1,'first') ) = 1;
                            blockEvent1{iFile,blockCount,iTrial} = [event cos(mt(iTrial,1))*event sin(mt(iTrial,1))*event];
                            
                            event = zeros(size(bins'));
                            event( find(bins >= mt(iTrial,glmAlign(2)),1,'first') ) = 1;
                            blockEvent2{iFile,blockCount,iTrial} = [event cos(mt(iTrial,1))*event sin(mt(iTrial,1))*event];
                        end
                        blockCount = blockCount + 1;
                    end
                end
            end
        end
        
        allSpikes{iFile} = spikes;
        allUnitInfo{iFile} = unitInfo;
        
        clear data spikes spikes2 f bins inds idx mt theta movement_table units d sg c spikeInds event unitInfo blockCount;
    end
    clear iFile master_sg iEpoch unit iDir iTrial count doWidthSeparation franova iBlock whichBlock whichScript sComp slidingParams classifierBlocks dateInds iAlign;
    toc;
    
    % save output so you don't lose it
    save(fullfile(saveDir,[useArray '_fileParse_' datestr(now,'yyyymmddTHHMMSS') '.mat']),'-v7.3')