% get PETH for each neuron
window = [0.8,0.8];
binSize = 0.01;
alignInd = 2;
alignInd2 = 4;
% [ target angle, on_time, go cue, move_time, peak_time, end_time, ]

%%
clear fr spikes fr2 spikes2;
count = 0;
for iFile = 1:size(doFiles,1)
    [~,c] = loadResults(root_dir,doFiles(iFile,:),'tuning',{'tuning','classes'},useArray,paramSetName,tuneMethod,tuneWindow);
    master_sg = c(1).sg;
    
    %%%% NOTE I'M HACKING THIS
    disp('Warning! Hack to overwrite blocks!');
    c.params.tuning.blocks = {[0 1],[0 1],[0 1]};
    
    data = cell(1,3);
    for iEpoch = 1:length(epochs)
        data{iEpoch} = loadResults(root_dir,doFiles(iFile,:),'data',[],epochs{iEpoch});
    end
    
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
                        [fr{count,blockCount,iDir}, spikes{count,blockCount,iDir}] = plotAlignedFR(units(idx).ts,mt(inds,alignInd),window,binSize,false);
                        [fr2{count,blockCount,iDir}, spikes2{count,blockCount,iDir}] = plotAlignedFR(units(idx).ts,mt(inds,alignInd2),window,binSize,false);
                    end
                    blockCount = blockCount + 1;
                end
            end
        end
    end
end

og_spikes = spikes;
og_fr = fr;
og_spikes2 = spikes2;
og_fr2 = fr2;

%% plot raster for each direction for each cell
spikes = og_spikes;
spikes2 = og_spikes2;
% okay, we have the data, now make some plots
plotPositions = [3,7,11,17,23,19,15,9];
plotColors = {'b','r','g'};
% plotColors = {[0 0 1], ...
%               [1 0 0],[1 0.2 0.2],[1 0.5,0.5] ...
%               [0 1 0],[0.2 1 0.2],[0.5 1 0.5]};
minFR = 10; % Hz
plotGap = 0.3;
useBlocks = [1,2,3];
saveFiles = true;
doDouble = true;

bins = -window(1)+binSize/2:binSize:window(2)-binSize/2;

if ~exist('figs','dir')
    mkdir('figs');
end

for unit = 1:size(spikes,1)
    % do a quick pre-check for now
    %   Only plot if baseline firing rate for at least one direction
    %   exceeds some minimum FR
    temp = zeros(1,length(utheta));
    for iDir = 1:length(utheta)
        data = spikes{unit,1,iDir};
        temp(iDir) = mean(cellfun(@(x) length(x)/sum(window),data)) > minFR;
    end
    
    if any(temp)
        
        fh = figure('Position',[200, 0, 1200, 1000]);
        subplot1(5,5);
        
        for iDir = 1:5
            for jDir = 1:5
                if ~any(ismember(plotPositions,5*(iDir-1)+jDir))
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
                
                data = spikes{unit,useBlocks(iBlock),iDir};
                data2 = spikes2{unit,useBlocks(iBlock),iDir};
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
            for iBlock = 2:length(useBlocks)
                plot(bins,maxTrial(iDir)+(0.5*maxTrial(iDir)).*(allBinned{iDir,iBlock}-allBinned{iDir,1})./maxCount,'Color',plotColors{iBlock},'LineWidth',2);
                if doDouble
                    plot(bins+window(1)+window(2)+plotGap,maxTrial(iDir)+(0.5*maxTrial(iDir)).*(allBinned2{iDir,iBlock}-allBinned2{iDir,1})./maxCount,'Color',plotColors{iBlock},'LineWidth',2);
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
        
        if saveFiles
            saveas(fh,fullfile('figs',[t '.png']),'png');
        end
        
        %pause;
        close all;
    end
end




