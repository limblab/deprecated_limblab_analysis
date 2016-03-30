%%% look at firing rate changes as a function of cell PD
plotColors = {[0 0 1],[1 0.6 0.6],[1 0 0],[0.6 1 0.6],[0 1 0]};
allDirFR = cell(length(compBlocks),length(useBins));
allDirFRraw = cell(length(compBlocks),length(useBins));

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
        newFRraw = cell(size(targPDs,1),1);
        for unit = 1:size(targPDs,1)
            temp = fr{unit};
            dirFR = zeros(length(utheta),2);
            dirFRraw = cell(length(utheta),1);
            for iDir = 1:length(utheta)
                idx = theta{unit}==utheta(iDir);
                dirFR(iDir,:) = [mean(temp(idx)) std(temp(idx))./sqrt(sum(idx))];
                dirFRraw{iDir} = temp(idx);
            end
            
            % get index of targets, with PD at 4
            if doNonParametricFR && useMaxFR
                [~,I] = max(dirFR(:,1));
                newFR(unit,:,:) = circshift(dirFR,4-I);
                newFRraw(unit,:) = circshift(dirFRraw,4-I);
            else
                newFR(unit,:,:) = circshift(dirFR,4-targPDs(unit));
                newFRraw{unit} = circshift(dirFRraw,4-targPDs(unit));
            end
        end
        allDirFR{iBlock,iBin} = newFR;
        allDirFRraw{iBlock,iBin} = newFRraw;
    end
end
clear iBin pds blfr d iDir targPDs iBlock fr theta getFR unit temp dirFR iDir idx newFR I;

% close all;
% % now, make a plot
% for iBin = 1:size(allDirFR,2)
%     figure('Position',[200 200 800 600]);
%     hold all;
%     
%     for iBlock = [1,3,5]
%         fr = allDirFR{iBlock,iBin}(:,:,1);
%         
%         dfr = zeros(size(fr,1),length(utheta));
%         for iDir = 1:length(utheta)
%             dfr(:,iDir) = (fr(:,iDir)-cos_mds{compBlocks(iBlock),useBins(iBin)})./cos_bos{compBlocks(iBlock),useBins(iBin)};
%         end
%         
%         idx = goodCells(:,useBins(iBin))==1;
%         
%         %plot(dfr(goodCells(:,useBins(iBin))==1,:)');
%         
%         
%         
%         plot(mean(dfr(idx,:),1),'Color',plotColors{iBlock},'LineWidth',2);
%         plot(mean(dfr(idx,:),1) + std(dfr(idx,:),1)./sqrt(sum(idx)),'--','LineWidth',2,'Color',plotColors{iBlock});
%         plot(mean(dfr(idx,:),1) - std(dfr(idx,:),1)./sqrt(sum(idx)),'--','LineWidth',2,'Color',plotColors{iBlock});
%     end
%     set(gca,'Box','off','TickDir','out','FontSize',14,'XLim',[1 8],'YLim',[-1,2],'XTick',[4 8],'XTickLabel',{'PD','Anti-PD'});
%     xlabel('Target Directions','FontSize',16);
%     ylabel('Normalized Firing Rate','FontSize',16);
% end
% clear iBin iBlock iDir fr dfr idx;

close all;
% now, make a plot
binFRbl = nan(size(allDirFR,2),size(cos_pds{1,1},1),length(utheta));
binFR = nan(size(allDirFR,2),size(cos_pds{1,1},1),length(utheta));
binFR2 = nan(size(allDirFR,2),size(cos_pds{1,1},1),length(utheta));
binFR3 = nan(size(allDirFR,2),size(cos_pds{1,1},1),length(utheta));
for iBin = 1:size(allDirFR,2)
    figure('Position',[200 200 800 600]);
    hold all;
    
    blfr = allDirFR{1,iBin}(:,:,1);
    blfrRaw = allDirFRraw{1,iBin};
    
    for iBlock = [1,2,3,4]
        fr = allDirFR{iBlock,iBin}(:,:,1);
        frRaw = allDirFRraw{iBlock,iBin};
        
        dfr = zeros(size(fr,1),length(utheta));
        for iDir = 1:length(utheta)
            bl = (blfr(:,iDir)-cos_mds{1,useBins(iBin)})./cos_bos{1,useBins(iBin)};
            temp = (fr(:,iDir)-cos_mds{compBlocks(iBlock),useBins(iBin)})./cos_bos{compBlocks(iBlock),useBins(iBin)};
            dfr(:,iDir) = temp-bl;
        end
        
        idx = goodCells(:,useBins(iBin))==1;
        temp = dfr(idx,:);
        
        if iBlock==1
            binFRbl(iBin,idx,:) = temp;
        elseif iBlock==2
            binFR(iBin,idx,:) = temp;
        elseif iBlock==3
            binFR2(iBin,idx,:) = temp;
        elseif iBlock==4
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

% check which directions are significantly different
for iDir = 1:size(temp,2)

end


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



% % % figure('Position',[200 200 700 500]);
% % % subplot(2,1,1);
% % % imagesc((squeeze(nanmean(pmd_binFR,2))')); colorbar;
% % % set(gca,'Xtick',[],'YTick',[4,8],'YTickLabel',{'PD','Anti-PD'},'FontSize',14,'Box','off','TickDir','out');
% % % caxis([-0.45 0.3]);
% % % if strcmpi(usePert,'VR')
% % %     title('Early Rotation','FontSize',16);
% % % else
% % %     title('Early Force','FontSize',16);
% % % end
% % % ylabel('PMd','FontSize',16);
% % % subplot(2,1,2);
% % % imagesc((squeeze(nanmean(m1_binFR,2))')); colorbar;
% % % set(gca,'Xtick',[1,5,14],'XTickLabel',{'Visual','Planning','Movement'},'YTick',[4,8],'YTickLabel',{'PD','Anti-PD'},'FontSize',14,'Box','off','TickDir','out');
% % % caxis([-0.45 0.3]);
% % % ylabel('M1','FontSize',16);
% % % 
% % % figure('Position',[200 200 700 500]);
% % % subplot(2,1,1);
% % % imagesc((squeeze(nanmean(pmd_binFR2,2))')); colorbar;
% % % set(gca,'Xtick',[],'YTick',[4,8],'YTickLabel',{'PD','Anti-PD'},'FontSize',14,'Box','off','TickDir','out');
% % % caxis([-0.45 0.3]);
% % % if strcmpi(usePert,'VR')
% % %     title('Late Rotation','FontSize',16);
% % % else
% % %     title('Late Force','FontSize',16);
% % % end
% % % ylabel('PMd','FontSize',16);
% % % subplot(2,1,2);
% % % imagesc((squeeze(nanmean(m1_binFR2,2))')); colorbar;
% % % set(gca,'Xtick',[1,3,8],'XTickLabel',{'Visual','Planning','Movement'},'YTick',[4,8],'YTickLabel',{'PD','Anti-PD'},'FontSize',14,'Box','off','TickDir','out');
% % % caxis([-0.45 0.3]);
% % % ylabel('M1','FontSize',16);
% % % 
% % % figure('Position',[200 200 700 500]);
% % % subplot(2,1,1);
% % % imagesc((squeeze(nanmean(pmd_binFR3,2))')); colorbar;
% % % set(gca,'Xtick',[],'YTick',[4,8],'YTickLabel',{'PD','Anti-PD'},'FontSize',14,'Box','off','TickDir','out');
% % % caxis([-0.45 0.3]);
% % % title('Washout','FontSize',16);
% % % ylabel('PMd','FontSize',16);
% % % subplot(2,1,2);
% % % imagesc((squeeze(nanmean(m1_binFR3,2))')); colorbar;
% % % set(gca,'Xtick',[1,5,14],'XTickLabel',{'Visual','Planning','Movement'},'YTick',[4,8],'YTickLabel',{'PD','Anti-PD'},'FontSize',14,'Box','off','TickDir','out');
% % % caxis([-0.45 0.3]);
% % % ylabel('M1','FontSize',16);

