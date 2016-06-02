% get PETH for each neuron
window = [0.5,0.5];
binSize = 0.05;
alignInd = 2;
% [ target angle, on_time, go cue, move_time, peak_time, end_time, ]

bins = -window(1)+binSize/2:binSize:window(2)-binSize/2;

%%
clear fr;
count = 0;
for iFile = 1:size(doFiles,1)
    [~,c] = loadResults(root_dir,doFiles(iFile,:),'tuning',{'tuning','classes'},useArray,paramSetName,tuneMethod,tuneWindow);
    master_sg = c(1).sg;
    
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
                        fr{count,blockCount,iDir} = plotAlignedFR(units(idx).ts,mt(inds,alignInd),window,binSize,false);
                    end
                    blockCount = blockCount + 1;
                end
            end
        end
    end
end

og_fr = fr;

%% Plot population average of difference aligned on PD
close all;
plotPositions = [3,7,11,17,23,19,15,9];
% plotPositions = [3,9,15,19,23,17,11,7];
plotColors = {'k','b','r','g'};
minFR = 0; % Hz
doAbs = true;
useBlocks = [1,2,4,7];
saveFiles = true;

if doAbs
    maxFR = 1.5;
else
maxFR = 0.5;
end

fr = og_fr;

if ~exist('figs','dir')
    mkdir('figs');
end

for unit = 1:size(fr,1)
    
    % do a quick pre-check for now
    %   Only plot if baseline firing rate for at least one direction
    %   exceeds some minimum FR
    temp = zeros(1,length(utheta));
    for iDir = 1:length(utheta)
        data = fr{unit,1,iDir};
        temp(iDir) = any(mean(data,1) > minFR);
    end
    
    if any(temp)
        % need to align by PD, so make it the first element
        %   First, find the PD as maximum overall FR direction
        data = squeeze(fr(unit,1,:));
        [~,I] = max(cellfun(@(x) mean(rms(x,2),1),data));
        %   Now, shift
        for iBlock = 1:length(useBlocks)
            data = squeeze(fr(unit,useBlocks(iBlock),:));
            data = circshift(data,1-I);
            fr(unit,useBlocks(iBlock),:) = data;
        end
        
        % get overall baseline mean for normalization
        for iDir = 1:length(utheta)
            bl = mean(squeeze(fr{unit,1,iDir}),1);
            blMean(iDir) = mean(bl);
        end
        
        % now take difference from baseline
        for iDir = 1:length(utheta)
            bl = mean(squeeze(fr{unit,1,iDir}),1);
            for iBlock = 1:length(useBlocks)
                data = squeeze(fr{unit,useBlocks(iBlock),iDir});
                if doAbs
                    fr{unit,useBlocks(iBlock),iDir} = abs(data - repmat(bl,size(data,1),1))./mean(blMean);
                else
                    fr{unit,useBlocks(iBlock),iDir} = (data - repmat(bl,size(data,1),1))./mean(blMean);
                end
            end
        end
    end
end

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

for iDir = 1:length(utheta)
    subplot1(plotPositions(iDir));
    hold all;
    for iBlock = 1:length(useBlocks)
        temp = squeeze(fr(:,useBlocks(iBlock),iDir));
        %data = cell2mat(cellfun(@(x) mean(x),temp,'UniformOutput',false));
        data = [];
        for j = 1:length(temp)
            data = [data; temp{j}];
        end
        m = mean(data);
        s = std(data)./sqrt(size(data,1));
        
        plot(bins,m,'-','LineWidth',2,'Color',plotColors{iBlock});
        patch([bins fliplr(bins)],[m-s fliplr(m+s)],plotColors{iBlock},'EdgeColor',plotColors{iBlock});
        
        % plot(bins,m+s,'--','LineWidth',1,'Color',plotColors{iBlock});
        % plot(bins,m-s,'--','LineWidth',1,'Color',plotColors{iBlock});
    end
    
    axis('tight');
    V = axis;
    if doAbs
        axis([V(1:2) 0.5 maxFR]);
    else
    axis([V(1:2) -maxFR maxFR]);
    end
    set(gca,'Box','off','TickDir','out','FontSize',14);
    
    if doAbs
        plot([0 0],[0.5 maxFR],'k--','LineWidth',1);
    else
    plot([0 0],[-maxFR maxFR],'k--','LineWidth',1);
    end
    h = findobj(gca,'Type','patch');
    set(h,'EdgeColor','w','facealpha',0.5,'edgealpha',0);
end



%% now plot difference for each cell
if 0
    plotPositions = [3,7,11,17,23,19,15,9];
    plotColors = {'k','b','r','g'};
    minFR = 30; % Hz
    
    if ~exist('figs','dir')
        mkdir('figs');
    end
    
    for unit = 1:size(fr,1)
        
        % do a quick pre-check for now
        %   Only plot if baseline firing rate for at least one direction
        %   exceeds some minimum FR
        temp = zeros(1,length(utheta));
        for iDir = 1:length(utheta)
            data = fr{unit,1,iDir};
            temp(iDir) = any(mean(data,1) > minFR);
        end
        
        if any(temp)
            maxFR = zeros(1,length(utheta));
            for iDir = 1:length(utheta)
                for iEpoch = 1:size(fr,2)
                    data = fr{unit,iEpoch,iDir};
                    maxFR(iEpoch,iDir) = max(mean(data,1));
                end
            end
            
            maxFR = max(max(maxFR));
            
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
            
            % need to align by PD, so make it = 0 (iDir = 3)
            %   First, find the PD as maximum overall FR direction
            data = squeeze(fr(unit,1,:));
            [~,I] = max(cellfun(@(x) mean(mean(x)),data));
            %   Now, shift
            for iBlock = 1:length(useBlocks)
                data = squeeze(fr(unit,useBlocks(iBlock),:));
                data = circshift(data,3-I);
                fr(unit,useBlocks(iBlock),:) = data;
            end
            
            for iDir = 1:length(utheta)
                bl = mean(squeeze(fr{unit,1,iDir}),1);
                for iBlock = 1:length(useBlocks)
                    data = squeeze(fr{unit,useBlocks(iBlock),iDir});
                    fr{unit,useBlocks(iBlock),iDir} = data - repmat(bl,size(data,1),1);
                end
            end
            %blfr = circshift(blfr',3-I)';
            for iDir = 1:length(utheta)
                subplot1(plotPositions(iDir));
                hold all;
                for iBlock = 1:length(useBlocks)
                    data = fr{unit,useBlocks(iBlock),iDir};
                    m = mean(data);
                    s = std(data)./sqrt(size(data,1));
                    
                    plot(bins,m,'-','LineWidth',2,'Color',plotColors{iBlock});
                    patch([bins fliplr(bins)],[m-s fliplr(m+s)],plotColors{iBlock},'EdgeColor',plotColors{iBlock});
                    
                    % plot(bins,m+s,'--','LineWidth',1,'Color',plotColors{iBlock});
                    % plot(bins,m-s,'--','LineWidth',1,'Color',plotColors{iBlock});
                end
                
                axis('tight');
                V = axis;
                axis([V(1:2) -maxFR maxFR]);
                set(gca,'Box','off','TickDir','out','FontSize',14);
                
                plot([0 0],[-maxFR maxFR],'k--','LineWidth',1);
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
end


%% plot PSTH for each cell
if 1
    % okay, we have the data, now make some plots
    plotPositions = [3,7,11,17,23,19,15,9];
    plotColors = {'k','b','r','g'};
    minFR = 3; % Hz
    
    if ~exist('figs','dir')
        mkdir('figs');
    end
    
    for unit = 1:size(fr,1)
        
        % do a quick pre-check for now
        %   Only plot if baseline firing rate for at least one direction
        %   exceeds some minimum FR
        temp = zeros(1,length(utheta));
        for iDir = 1:length(utheta)
            data = fr{unit,1,iDir};
            temp(iDir) = any(mean(data,1) > minFR);
        end
        
        if any(temp)
            maxFR = zeros(1,length(utheta));
            for iDir = 1:length(utheta)
                for iEpoch = 1:length(useBlocks)
                    data = fr{unit,useBlocks(iEpoch),iDir};
                    maxFR(iEpoch,iDir) = max(mean(data,1)+std(data,0,1)./sqrt(size(data,1)));
                end
            end

            maxFR = max(max(maxFR));
            
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
            
            for iDir = 1:length(utheta)
                subplot1(plotPositions(iDir));
                hold all;
                for iBlock = 1:length(useBlocks)
                    data = fr{unit,useBlocks(iBlock),iDir};
                    m = mean(data);
                    s = std(data)./sqrt(size(data,1));
                    
                    plot(bins,m,'-','LineWidth',2,'Color',plotColors{iBlock});
                    patch([bins fliplr(bins)],[m-s fliplr(m+s)],plotColors{iBlock},'EdgeColor',plotColors{iBlock});
                end
                
                axis('tight');
                V = axis;
                axis([V(1:2) 0 maxFR]);
                set(gca,'Box','off','TickDir','out','FontSize',14);
                
                plot([0 0],[0 maxFR],'k--','LineWidth',1);
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
    
end




