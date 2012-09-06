function PlotIsoMetrics(IsoTaskMetrics)

close all;

% Get the maximum number of targets
NumOfTargets = length(IsoTaskMetrics.Time2Target.Time2TargetSummary)-1;


theData = [];
theGroup = [];
for N =1:NumOfTargets
    theData = [theData; IsoTaskMetrics.Time2Target.(['Target' num2str(N)])];
    theGroup = [theGroup; N*ones(length(IsoTaskMetrics.Time2Target.(['Target' num2str(N)])),1)];
end

%figure; 
boxplot(theData,theGroup); title('Time to Target')


theData = [];
theGroup = [];
for N =1:NumOfTargets
    theData = [theData; IsoTaskMetrics.PathLength.(['Target' num2str(N)])];
    theGroup = [theGroup; N*ones(length(IsoTaskMetrics.PathLength.(['Target' num2str(N)])),1)];
end

figure; boxplot(theData,theGroup); title('Path Length')