function PlotTotalSuccessOverTime(TrialsStruct,x,color)

TimeLength = 180;
TotalFileTime = 900; %in seconds
MetricSubStruct = TrialsStruct.TrialsFull;  %change each time
EpochStart = 0;
for i=1:TotalFileTime/TimeLength
EpochEnd = EpochStart + TimeLength;
     TrialsinEpoch = (find(MetricSubStruct(:,2)>=EpochStart&MetricSubStruct(:,2)<=EpochEnd));
     NumTotalTrials = length(TrialsinEpoch);
     TrialsinEpochResults = MetricSubStruct(TrialsinEpoch);
     Successes = length(find(TrialsinEpochResults==82));
  SuccessPercentForEpoch(i) = Successes/NumTotalTrials;

EpochStart = EpochStart+TimeLength;

end


%plot(SuccessPercentForEpoch,'.','MarkerSize',20,'LineWidth',2,'Color', 'k');
plot(x,SuccessPercentForEpoch,'*-','Color',color,'MarkerSize',5,'LineWidth',2);
ylim([0 1])

end
% 
% % different options for labels
% title('Rotated | Success over time ')
% xlabel('Epochs | 1 Epoch = 5 minutes')
% 
% title('Reflected | Success over time ')
% xlabel('Epochs | 1 Epoch = 5 minutes')
% 
% title('Baseline | Success over time ')
% xlabel('Epochs | 1 Epoch = 3 minutes')
% MillerFigure
% 
