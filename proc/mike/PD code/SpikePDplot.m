%Plot spike PDs

%SPDdir_ByBand = sortrows(SPDdir, -1);
SPDdir_sorted = SPDdir_ByBand(:,1:length(Chewie_SpikesDuringLFP1BC_filenames_ConstSpikeNum)); 
[Chewie_SpikesDuringLFP1BC_filenames_ConstSpikeNum] = CalcDecoderAge(Chewie_SpikesDuringLFP1BC_filenames_ConstSpikeNum,'09-01-2011');
[~,SPDdir_sorted_DayAvg,ChewieLFP2DayNames] = DayAverage(SPDdir_sorted, SPDdir_sorted, Chewie_SpikesDuringLFP1BC_filenames_ConstSpikeNum(:,1), Chewie_SpikesDuringLFP1BC_filenames_ConstSpikeNum(:,2));

SPDdir_sorted_DayAvg = [SPDdir_sorted_DayAvg bestcAllFeat_Spikes(:,2)];
SPDdir_sorted_DayAvg = sortrows(SPDdir_sorted_DayAvg,[size(SPDdir_sorted_DayAvg,2) -1]);
imagesc(SPDdir_sorted_DayAvg(:,1:end-1));figure(gcf);
Xlabels=ChewieLFP2DayNames;
Xticks=[1:5:size(Xlabels,1)-5 size(Xlabels,1)];
allXticks= [ChewieLFP2DayNames(1:5:16,2); ChewieLFP2DayNames(end,2)];
set(gca,'XTick',Xticks,'XTickLabel',allXticks)
title('Chewie Spike PDs (cos fit) during LFP2 BC by Freq Band')
xlabel('Decoder Age')

%y-label
bandLabelsY=bestcAllFeat_Spikes(:,2);
[uBands,uBandYticks,~]=unique(bandLabelsY);
uBandYticks=[1; uBandYticks(1:end-1)+1];
allBands={'LMP','Delta','Mu','70-100','130-200','200-300'};
set(gca,'YTick',uBandYticks,'YTickLabel',allBands(uBands))

%x-label - Chewie
Xlabels=ChewieLFP2DayNames;
Xticks=[1:5:size(Xlabels,1)];% size(Xlabels,1)];
allXticks= [ChewieLFP2DayNames(1:5:end,2); ChewieLFP2DayNames(end,2)];
set(gca,'XTick',Xticks,'XTickLabel',allXticks)

sd_PDs = std(LFPOfflineSorted_NoNan(:,1:end-1),0,2);

[uBands,uBandYticks,~]=unique(AllFreq_Ind);
uBandYticks=[1; uBandYticks(1:end-1)+1];

%% 
color = ['r'; 'g'; 'c','b','m'];

for i = 1:length(uBandYticks)-1 
    hist(sd_PDs(uBandYticks(i):uBandYticks(i+1)-1,1))
    h = findobj(gca,'Type','patch')
    hold on 
    set(h(1),'facecolor','none','EdgeColor',color(i),'linewidth',4.0)
    if i == length(uBandYticks)-1
        hist(sd_PDs(uBandYticks(i+1):end,1))
        h = findobj(gca,'Type','patch')
        set(h(1),'facecolor','none','EdgeColor',color(i+1),'linewidth',4.0)
    end
end

allBands={'LMP','Delta','Mu','70-100','130-200','200-300'};
legend(allBands(uBands))

for i = 1:size(AllFreq_DayAvg_Valid,2)-2
    
    deltaPDs_ByDays(i,:) = [AllFreq_DayAvg_Valid(:,i) - AllFreq_DayAvg_Valid(:,i+1); 0];
    deltaPDs_ByDays(i,size(AllFreq_DayAvg_Valid,1)+1) = AllFreq_DayNames{i+1,2} - AllFreq_DayNames{i,2};
    
end

deltaPDs_ByDays = sortrows(deltaPDs_ByDays,size(deltaPDs_ByDays,2))';
deltaPDs_ByDays = [deltaPDs_ByDays [AllFreq_Ind; 0]];

[columnLabel columnInd] = unique(deltaPDs_ByDays(end,:));
columnInd = [1 columnInd(2:end)];

[rowLabel rowInd] = unique(deltaPDs_ByDays(:,end));
rowInd = [1; rowInd(2:end)];

set(gca,'XTick',columnInd(1:end)+1,'XTickLabel',columnLabel(2:end))
set(gca,'YTick',rowInd,'YTickLabel',allBands(uBands))


% for k = 1:length(rowInd)-1
%     for j = 1:length(columnInd)-1
%         Temp_deltaPDs_ByDays_Bands = deltaPDs_ByDays(rowInd(k)+1:rowInd(k+1),columnInd(j)+1:columnInd(j+1));
% 
%         Temp_deltaPDs_ByDays_Bands = reshape(deltaPDs_ByDays_Bands,columnInd(j+1)*rowInd(k+1),1)
% 
%         deltaPDs_ByDays_Bands = [Temp_deltaPDs_ByDays_Bands repmat(columnlabel(j)
% 
%     end
% end
