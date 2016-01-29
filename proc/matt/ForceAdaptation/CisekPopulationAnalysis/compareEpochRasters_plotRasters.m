% from trial table, the direction indices are as follows:
%       targ_angs = [pi/2, pi/4, 0, -pi/4, -pi/2, -3*pi/4, pi, 3*pi/4];
%       plotPositions = [3,7,11,17,23,19,15,9];
% however, from unique(theta), the direction indices are as follows
%       targ_angs = [-3*pi/4, -pi/2, -pi/4, 0, pi/4, pi/2, 3*pi/4, pi];



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
