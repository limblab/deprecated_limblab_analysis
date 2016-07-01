function PlotTime2Target_ProgressReport(Time2TargetStruct, FigureTitle)



for i=1:8
    targetMean(i) = mean(Time2TargetStruct.(['Target' num2str(i)]));
    targetSTE(i) = std(Time2TargetStruct.(['Target' num2str(i)]))/sqrt(length(Time2TargetStruct.(['Target' num2str(i)])));
end

targetMean(9) = targetMean(1);
targetSTE(9) = targetSTE(1);
empty = find(isnan(targetMean));
targetMean(empty) = [];
targetSTE(empty) = [];

plusSTE = targetMean+targetSTE;
minusSTE = targetMean-targetSTE;
figure;
theta = 0:(2*pi)/8:2*pi;
theta(empty) = [];
ste1=polar(theta,plusSTE,'m.');
set( findobj(ste1, 'Type', 'line'),'MarkerSize',15);
hold on;
h=polar(theta,targetMean,'.k');
set( findobj(h, 'Type', 'line'),'MarkerSize',30);
ste2=polar(theta,minusSTE,'m.');
set( findobj(ste2, 'Type', 'line'),'MarkerSize',15);

LabelPolar4LearnAdaptProgressReport(Time2TargetStruct)
title(FigureTitle)

end

% Plot in regular cartesisan coordinates
% figure; plot(x,targetMean,'k*','MarkerSize',5)
% hold on
% plot([x;x],[minusSTE.*ones(1,length(x));plusSTE.*ones(1,length(x))],'k')
% xlim([0 9])
% xlabel('Target Number')
% MillerFigure
% title(FigureTitle)