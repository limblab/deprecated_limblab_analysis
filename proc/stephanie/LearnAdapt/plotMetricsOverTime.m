function plotMetricsOverTime(MetricFullStruct, SecondsPerEpoch, MetricPoints, subplotTitle,plotColor)


%MetricFullStruct = T2TlastStruct_normal_0503;

figure; 
x = 1:MetricPoints;
for i = 1:8
    MetricSubStruct = MetricFullStruct.(['Target' num2str(i)]);
 MetricMeans = [];epochStart = 0; epochEnd = SecondsPerEpoch;
 MetricMeansMinusSTE = []; MetricMeansPlusSTE = [];
 for j = 1:MetricPoints
     PerturbationEpochIndices = find(MetricSubStruct(:,2) > epochStart & MetricSubStruct(:,2)< epochEnd);
     epochStart = epochEnd;
     epochEnd = epochEnd + SecondsPerEpoch;
     MetricMeans(j,1) = mean(MetricSubStruct(PerturbationEpochIndices(:,1)));
     MetricSTEs(j,1) = std(MetricSubStruct(PerturbationEpochIndices(:,1)))/(sqrt(length(MetricSubStruct(PerturbationEpochIndices(:,1)))));
     MetricMeansPlusSTE(j,1) = MetricMeans(j,1)+MetricSTEs(j,1);
     MetricMeansMinusSTE(j,1) = MetricMeans(j,1)-MetricSTEs(j,1);
     
 end
 subplot(2,4,i); hold on; plot(x,MetricMeans,'.','MarkerSize',20,'Color',plotColor);
 plot([x; x], [MetricMeansMinusSTE MetricMeansPlusSTE]','Color',plotColor)
 title(strcat(['Target ', num2str(i)]));
 xlim([1 MetricPoints]); ylim([0 8]);
 MillerFigure;
end
suptitle(subplotTitle)
end



