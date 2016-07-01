function plotSuccessOverTime(MetricFullStruct, MetricPoints, SecondsPerEpoch,NumOfTrials, subplotTitle,plotColor)

%x = 1:MetricPoints;
 x = 1:4;
for i = 1:8
    MetricSubStruct = MetricFullStruct.(['Target' num2str(i)]);
    SuccessPercentage = [];epochStart = 0; epochEnd = SecondsPerEpoch;
    TheIndices = -5; Counter = 1;xval=1;
    while(TheIndices(end)< length(MetricSubStruct))
       TheIndices = Counter:Counter+NumOfTrials-1;
       TheIndices(TheIndices>length(MetricSubStruct))=length(MetricSubStruct);
       TheIndices = unique(TheIndices);
        Successes = length(find(MetricSubStruct(TheIndices,1)==82));
%         PerturbationEpochIndices = find(MetricSubStruct(:,2) > epochStart & MetricSubStruct(:,2)< epochEnd);
%         Successes = length(find(MetricSubStruct(PerturbationEpochIndices,1)==82));
%         Total = length(PerturbationEpochIndices);
%         if Total == 0
%          SuccessPercentage(1,j) = nan;
%         else
%         SuccessPercentage(1,j) = Successes/Total;
         SuccessPercentage(1,xval) = Successes/(length(TheIndices));
         Counter = TheIndices(end)+1;
     
     epochStart = epochEnd;
     epochEnd = epochEnd + SecondsPerEpoch;
     xval = xval+1;

    end
 subplot(2,4,i); hold on; plot(SuccessPercentage,'.','MarkerSize',20,'LineWidth',2,'Color', plotColor);
 title(strcat(['Target ', num2str(i)]));
 xlim([1 xval]); ylim([0 1]);
 MillerFigure;
end
%suptitle(subplotTitle)
end