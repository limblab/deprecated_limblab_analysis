% close all

if doMD
    db = 0.1;
    bins = -20+db/2:db:20-db/2;
    histmin = -1;
    histmax = 1;
    
    ymin = -1;
    ymax = 1;
else
    db = 4;
    bins = -180+db/2:db:180-db/2;
    histmin = -100;
    histmax = 100;
    
    ymin = -30;
    ymax = 30;
end
figure;
subplot1(length(useBins),1);

thediff = cell(1,length(useBins));
for iBin = 1:length(useBins)
    subplot1(iBin);
    hold all;
    if doMD
        if doAbs
            thediff{iBin} = abs(cos_mds{eComp(2),iBin}(goodCells(:,iBin)==1) - cos_mds{eComp(1),iBin}(goodCells(:,iBin)==1))./cos_bos{eComp(1),iBin}(goodCells(:,iBin)==1);
        else
            thediff{iBin} = (cos_mds{eComp(2),iBin}(goodCells(:,iBin)==1) - cos_mds{eComp(1),iBin}(goodCells(:,iBin)==1))./cos_bos{eComp(1),iBin}(goodCells(:,iBin)==1);
        end
    else
        thediff{iBin} = angleDiff(cos_pds{eComp(1),iBin}(goodCells(:,iBin)==1),cos_pds{eComp(2),iBin}(goodCells(:,iBin)==1),true,~doAbs).*(180/pi);
    end
    hist(thediff{iBin},bins);
    set(gca,'Box','off','TickDir','out','XLim',[histmin,histmax],'FontSize',14);
    V = axis;
    plot([0 0],V(3:4),'k--');
    ylabel(plotLabels{iBin},'FontSize',14);
end
xlabel('PD Change (Deg)','FontSize',16);

compBlocks = [2,3,4];
refBlock = 1;
plotColors = {[1 0.6 0.6],[1 0 0],[0.6 1 0.6],[0 1 0]};

thediff = cell(length(compBlocks),length(useBins));
for iBlock = 1:length(compBlocks)
    for iBin = 1:length(useBins)
        if doMD
            if doAbs
                thediff{iBlock,iBin} = abs(cos_mds{compBlocks(iBlock),iBin}(goodCells(:,iBin)==1) - cos_mds{refBlock,iBin}(goodCells(:,iBin)==1))./cos_bos{refBlock,iBin}(goodCells(:,iBin)==1);
            else
                thediff{iBlock,iBin} = (cos_mds{compBlocks(iBlock),iBin}(goodCells(:,iBin)==1) - cos_mds{refBlock,iBin}(goodCells(:,iBin)==1))./cos_bos{refBlock,iBin}(goodCells(:,iBin)==1);
            end
        else
            thediff{iBlock,iBin} = angleDiff(cos_pds{refBlock,iBin}(goodCells(:,iBin)==1),cos_pds{compBlocks(iBlock),iBin}(goodCells(:,iBin)==1),true,~doAbs).*(180/pi);
        end
    end
end

figure('Position',[200 200 800 600]);
hold all;
for iBlock = 1:2
    for iBin = 1:length(useBins)
        plot(iBin+0.1*(iBlock-1),mean(thediff{iBlock,iBin}),'o','Color',plotColors{iBlock},'LineWidth',3);
        plot([iBin iBin]+0.1*(iBlock-1),[mean(thediff{iBlock,iBin})-std(thediff{iBlock,iBin})./sqrt(length(thediff{iBlock,iBin})), mean(thediff{iBlock,iBin})+std(thediff{iBlock,iBin})./sqrt(length(thediff{iBlock,iBin}))],'Color',plotColors{iBlock},'LineWidth',3)
    end
end
set(gca,'Box','off','TickDir','out','XLim',[0 length(useBins)+1],'YLim',[ymin ymax],'XTick',1:length(useBins),'XTickLabel',plotLabels,'FontSize',14);
ylabel('PD Change (Deg)','FontSize',14);
plot([0 length(useBins)+1],[0 0],'k--','LineWidth',1);

figure;
hold all;
for iBlock = 3:4
    for iBin = 1:length(useBins)
        plot(iBin+0.1*(iBlock-3),mean(thediff{iBlock,iBin}),'o','Color',plotColors{iBlock},'LineWidth',3);
        plot([iBin iBin]+0.1*(iBlock-3),[mean(thediff{iBlock,iBin})-std(thediff{iBlock,iBin})./sqrt(length(thediff{iBlock,iBin})), mean(thediff{iBlock,iBin})+std(thediff{iBlock,iBin})./sqrt(length(thediff{iBlock,iBin}))],'Color',plotColors{iBlock},'LineWidth',3)
    end
end
set(gca,'Box','off','TickDir','out','XLim',[0 length(useBins)+1],'YLim',[ymin ymax],'XTick',1:length(useBins),'XTickLabel',plotLabels,'FontSize',14);
ylabel('PD Change (Deg)','FontSize',14);
plot([0 length(useBins)+1],[0 0],'k--','LineWidth',1);


clear iBlock iBin V unit overlap test1 test2 test3 test4 r1 r1;