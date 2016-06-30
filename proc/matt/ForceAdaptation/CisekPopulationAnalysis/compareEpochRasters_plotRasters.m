% from trial table, the direction indices are as follows:
%       targ_angs = [pi/2, pi/4, 0, -pi/4, -pi/2, -3*pi/4, pi, 3*pi/4];
%       plotPositions = [3,7,11,17,23,19,15,9];
% however, from unique(theta), the direction indices are as follows
%       targ_angs = [-3*pi/4, -pi/2, -pi/4, 0, pi/4, pi/2, 3*pi/4, pi];

% spikes is now 4D cell... {# blocks, # cells, # directions, # alignments}

% only use the cells that fit well
goodCells = ones(size(spikes,2),length(useBins));
% for iBin = 1:length(useBins)
%     for unit = 1:size(spikes,2)
%         goodCells(unit,iBin) = 1;
%         if doGLM && doCos
%             goodCells(unit,iBin) = glm_r2s{1,iBin}(unit) >= minR2_glm & cos_r2s{3,iBin}(unit) >= minR2_cos;
%         elseif doGLM && ~doCos
%             goodCells(unit,iBin) = glm_r2s{1,iBin}(unit) >= minR2_glm & glm_r2s{3,iBin}(unit) >= minR2_glm;
%         elseif doCos && ~doGLM
%             goodCells(unit,iBin) = all(cellfun(@(x) x(unit),cos_r2s(useBlocksTune,iBin)) > minR2_cos);
%         end
%     end
% end

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
    
    allBinned = cell(length(utheta),length(useBlocks),length(useAligns));
    allBinned2 = cell(length(utheta),length(useBlocks));
    maxTrial = zeros(1,length(utheta));
    for iDir = 1:length(utheta)
        subplot1(plotPositions(iDir));
        hold all;
        for iBlock = 1:length(useBlocks)
            binCounts = zeros(size(bins));
            
            for iAlign = 1:length(useAligns)
                data = spikes{useBlocks(iBlock),unit,iDir,useAligns(iAlign)};
                for iTrial = 1:length(data)
                    plot([data{iTrial} + (iAlign-1)*(window(1)+window(2)+plotGap);data{iTrial} + (iAlign-1)*(window(1)+window(2)+plotGap)],maxTrial(iDir)+[(iTrial-1)*ones(1,length(data{iTrial})); iTrial*ones(1,length(data{iTrial}))],'-','LineWidth',1,'Color',plotColors{iBlock});
                    % get count of spikes in small bins
                    binCounts = binCounts + hist(data{iTrial},bins);
                end
                allBinned{iDir,iBlock,iAlign} = binCounts/length(data);
            end
            maxTrial(iDir) = iTrial+maxTrial(iDir);
        end
    end
    
    % get maximum count over all epochs and directions
    maxCount = 0;
    for iDir = 1:length(utheta)
        for iBlock = 1:length(useBlocks)
            for iAlign = 1:length(useAligns)
                data = allBinned{iDir,iBlock,iAlign};
                maxCount = max([maxCount,data]);
            end
        end
    end
    
    for iDir = 1:length(utheta)
        subplot1(plotPositions(iDir));
        
        % now plot sums as lines
        for iBlock = 1:length(useBlocks)
            for iAlign = 1:length(useAligns)
                plot(bins + (iAlign-1)*(window(1)+window(2)+plotGap),maxTrial(iDir)+(0.5*maxTrial(iDir)).*(allBinned{iDir,iBlock,iAlign})./maxCount,'Color',plotColors{iBlock},'LineWidth',2);
            end
        end
        
        axis('tight')
        V = axis;
        axis([V(1:3) maxTrial(iDir)+0.5*maxTrial(iDir)]);
        V = axis;
        
        set(gca,'Box','off','TickDir','out','FontSize',14);
        
        plot([0 0],V(3:4),'k--','LineWidth',1);

        plot((length(useAligns)-1).*[window(1)+window(2)+plotGap window(1)+window(2)+plotGap],V(3:4),'k--','LineWidth',1);

        h = findobj(gca,'Type','patch');
        set(h,'EdgeColor','w','facealpha',0.5,'edgealpha',0);
        if plotPositions(iDir)==3
            t = [doFiles{allUnitInfo(unit,1),2} '_e' num2str(allUnitInfo(unit,2)) '_u' num2str(allUnitInfo(unit,3))];
            title(t,'FontSize',14);
        end
        
    end
    
    % now, add center plot with tuning information
    subplot1(13);
    hold on;
    plotSymbolsBin = {'-','--'};
    for iBlock = 1:length(useBlocksTune)
            data = zeros(length(utheta),2);
            for iDir = 1:length(utheta)
                temp = allBinned{iDir,iBlock,1};
                data(iDir,1) = mean(temp(32:48));
                temp = allBinned{iDir,iBlock,2};
                data(iDir,2) = mean(temp(24:32));
            end
            polar([-pi; utheta],[data(end,1); data(:,1)],[plotColorsTune{iBlock} plotSymbolsBin{1}]);
            polar([-pi; utheta],[data(end,2); data(:,2)],[plotColorsTune{iBlock} plotSymbolsBin{2}]);
        
%         if doCos
%             for iBin = 1:length(useBinsTune)
%                 cpd = cos_pds{useBlocks(iBlock),useBinsTune(iBin)}(unit);
%                 cmd = cos_mds{useBlocks(iBlock),useBinsTune(iBin)}(unit);
%                 cbo = cos_bos{useBlocks(iBlock),useBinsTune(iBin)}(unit);
%                 % plot radial tuning curve
%                 hold on;
%                 polar((-pi:pi/16:pi),cmd*cos((-pi:pi/16:pi) + cpd),[plotColorsTune{iBlock} plotSymbolsBin{iBin}]);
%                 
%                 % %             for iBin = 1:length(useBins)
%                 % %                 cpd = cos_pds{useBlocks(iBlock),iBin}(unit);
%                 % %                 plot([(iBin-1)*cos(cpd) iBin*cos(cpd)],[(iBin-1)*sin(cpd) iBin*sin(cpd)],'-','Color',plotColorsTune{iBlock},'LineWidth',2);
%                 % %             end
%                 polar([-cpd -cpd],[0 cmd],[plotColorsTune{iBlock} plotSymbolsBin{iBin}])
%             end
%         end
    end
    axis tight;
        axis square;
        V = axis;
    set(gca,'XLim',[-max(abs(V)) max(abs(V))],'YLim',[-max(abs(V)) max(abs(V))]);
    set(gca,'Box','off','TickDir','out','FontSize',14,'XTick',[],'YTick',[]);
    
    V = axis;
    plot(V(1:2),[0 0],'k--');
    plot([0,0],V(1:2),'k--');
    
    if saveFiles
        saveas(fh,fullfile('figs',[t '.png']),'png');
    else
        pause;
    end
    
    close all;
end

clear unit iDir temp data jDir allBinned allBinned2 maxTrial iDir iBlock binCounts binCounts2 data2 iTrial maxCount bins t V h fh;
