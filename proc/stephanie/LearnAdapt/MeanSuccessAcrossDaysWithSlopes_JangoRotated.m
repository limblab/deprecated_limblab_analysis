function MeanSuccessAcrossDaysWithSlopes_JangoRotated
% Calculate a mean success rate for each perturbation day and plot


RotatedX = [2 3 5 8 12 13 14];
ReflectedX = [1 4 6 7 9 10 11];

% 0731ref 0804rot 0805rot 0806ref 0808rot 0809ref 0824ref
% 0826rot 0828ref 0906ref 0925ref 0926rot 0929rot 1001rot

% 'July 31','Aug 4','Aug 5','Aug 6','Aug 8','Aug 9','Aug 24','Aug 25','Aug 26','Aug 28','Sep 6','Sep 28','Sep 26','Sep 29','Oct 1'

sessionSuccess = [];RotatedSlope = []; ReflectedSlope = []; BaselineSlope = [];
% For each session: get info for each trial and their outcome
% Rotated
[~, ~, ~, ~, TrialsStruct_080415_rotated] = ComputeTaskTimeMetrics(out_struct_080415_rotated);
[~, ~, ~, ~, TrialsStruct_080515_rotated] = ComputeTaskTimeMetrics(out_struct_080515_rotated);
[~, ~, ~, ~, TrialsStruct_080815_rotated] = ComputeTaskTimeMetrics(out_struct_080815_rotated);
[~, ~, ~, ~, TrialsStruct_082615_rotated] = ComputeTaskTimeMetrics(out_struct_082615_rotated);
[~, ~, ~, ~, TrialsStruct_100115_rotated] = ComputeTaskTimeMetrics(out_struct_100115_rotated);

% Reflected
[~, ~, ~, ~, TrialsStruct_073115_reflected] = ComputeTaskTimeMetrics(out_struct_073115_reflected);
[~, ~, ~, ~, TrialsStruct_080615_reflected] = ComputeTaskTimeMetrics(out_struct_080615_reflected);
% [~, ~, ~, ~, TrialsStruct_080915_reflected] = ComputeTaskTimeMetrics(out_struct_080915_reflected);
[~, ~, ~, ~, TrialsStruct_082415_reflected] = ComputeTaskTimeMetrics(out_struct_082415_reflected);
% [~, ~, ~, ~, TrialsStruct_082815_reflected] = ComputeTaskTimeMetrics(out_struct_082815_reflected);
% [~, ~, ~, ~, TrialsStruct_090615_reflected] = ComputeTaskTimeMetrics(out_struct_090615_reflected);
% [~, ~, ~, ~, TrialsStruct_092515_reflected] = ComputeTaskTimeMetrics(out_struct_092515_reflected);

% All baselines
[~, ~, ~, ~, TrialsStruct_080415_baseline] = ComputeTaskTimeMetrics(out_struct_080415_baseline);
[~, ~, ~, ~, TrialsStruct_080515_baseline] = ComputeTaskTimeMetrics(out_struct_080515_baseline);
[~, ~, ~, ~, TrialsStruct_080815_baseline] = ComputeTaskTimeMetrics(out_struct_080815_baseline);
[~, ~, ~, ~, TrialsStruct_082615_baseline] = ComputeTaskTimeMetrics(out_struct_082615_baseline);
[~, ~, ~, ~, TrialsStruct_100115_baseline] = ComputeTaskTimeMetrics(out_struct_100115_baseline);
[~, ~, ~, ~, TrialsStruct_073115_baseline] = ComputeTaskTimeMetrics(out_struct_073115_baseline);
[~, ~, ~, ~, TrialsStruct_080615_baseline] = ComputeTaskTimeMetrics(out_struct_080615_baseline);
% [~, ~, ~, ~, TrialsStruct_080915_baseline] = ComputeTaskTimeMetrics(out_struct_080915_baseline);
[~, ~, ~, ~, TrialsStruct_082415_baseline] = ComputeTaskTimeMetrics(out_struct_082415_baseline);
% [~, ~, ~, ~, TrialsStruct_082815_baseline] = ComputeTaskTimeMetrics(out_struct_082815_baseline);
% [~, ~, ~, ~, TrialsStruct_090615_baseline] = ComputeTaskTimeMetrics(out_struct_090615_baseline);
% [~, ~, ~, ~, TrialsStruct_092515_baseline] = ComputeTaskTimeMetrics(out_struct_092515_baseline);


% Baseline stats
BaselineSessionSuccess(1) = ComputeSessionSuccess(TrialsStruct_073115_baseline);
BaselineSessionSuccess(2) = ComputeSessionSuccess(TrialsStruct_080415_baseline);
BaselineSessionSuccess(3) = ComputeSessionSuccess(TrialsStruct_080515_baseline);
BaselineSessionSuccess(4) = ComputeSessionSuccess(TrialsStruct_080615_baseline);
BaselineSessionSuccess(5) = ComputeSessionSuccess(TrialsStruct_080815_baseline);
BaselineSessionSuccess(6) = ComputeSessionSuccess(TrialsStruct_082415_baseline);
BaselineSessionSuccess(7) = ComputeSessionSuccess(TrialsStruct_082615_baseline);
BaselineSessionSuccess(8) = ComputeSessionSuccess(TrialsStruct_100115_baseline);



% Baseline slope
BaselineSlope(1) = GetSlopeOfLearningForOneDay(TrialsStruct_073115_baseline);
BaselineSlope(2) = GetSlopeOfLearningForOneDay(TrialsStruct_080415_baseline);
BaselineSlope(3) = GetSlopeOfLearningForOneDay(TrialsStruct_080515_baseline);
BaselineSlope(4) = GetSlopeOfLearningForOneDay(TrialsStruct_080615_baseline);
BaselineSlope(5) = GetSlopeOfLearningForOneDay(TrialsStruct_080815_baseline);
BaselineSlope(6) = GetSlopeOfLearningForOneDay(TrialsStruct_082415_baseline);
BaselineSlope(7) = GetSlopeOfLearningForOneDay(TrialsStruct_082615_baseline);
BaselineSlope(8) = GetSlopeOfLearningForOneDay(TrialsStruct_100115_baseline);

% Rotated stats
RotatedSessionSuccess(1) = ComputeSessionSuccess(TrialsStruct_080415_rotated);
RotatedSessionSuccess(2) = ComputeSessionSuccess(TrialsStruct_080515_rotated);
RotatedSessionSuccess(3) = ComputeSessionSuccess(TrialsStruct_080815_rotated);
RotatedSessionSuccess(4) = ComputeSessionSuccess(TrialsStruct_082615_rotated);
RotatedSessionSuccess(5) = ComputeSessionSuccess(TrialsStruct_100115_rotated);

% Get the slope of performance for each individual session
TrialsPerEpoch = 20;
RotatedSlope(1) = GetSlopeOfLearningForOneDay(TrialsStruct_080415_rotated, TrialsPerEpoch);
RotatedSlope(2) = GetSlopeOfLearningForOneDay(TrialsStruct_080515_rotated, TrialsPerEpoch);
RotatedSlope(3) = GetSlopeOfLearningForOneDay(TrialsStruct_080815_rotated, TrialsPerEpoch);
RotatedSlope(4) = GetSlopeOfLearningForOneDay(TrialsStruct_082615_rotated, TrialsPerEpoch);
RotatedSlope(5) = GetSlopeOfLearningForOneDay(TrialsStruct_100115_rotated, TrialsPerEpoch);

% Reflected stats
ReflectedSessionSuccess(1) = ComputeSessionSuccess(TrialsStruct_073115_reflected);
ReflectedSessionSuccess(2) = ComputeSessionSuccess(TrialsStruct_080615_reflected);
ReflectedSessionSuccess(3) = ComputeSessionSuccess(TrialsStruct_082415_reflected);

% Reflected slopes
ReflectedSlope(1) = GetSlopeOfLearningForOneDay(TrialsStruct_073115_reflected, TrialsPerEpoch);
ReflectedSlope(2) = GetSlopeOfLearningForOneDay(TrialsStruct_080615_reflected, TrialsPerEpoch);
ReflectedSlope(3) = GetSlopeOfLearningForOneDay(TrialsStruct_082415_reflected, TrialsPerEpoch);


% Plot mean
figure;
%plot(sessionSuccess,'.','MarkerSize',20)
ylim([0 1]); xlim([0 8]); hold on
for i = 1:length(RotatedSessionSuccess)
    EndOfLine = RotatedSlope*0.5+RotatedSessionSuccess(i);
    plot([i i+0.5],[ReflectedSessionSuccess(i), EndOfLine(i)],'-k','LineWidth',1.5)
end
MillerFigure
%set(gca,'XTick',[0:1:5])
%set(gca,'XTickLabel',{'';'Aug 4';'Aug 5';'Aug 8';'Aug 26';'June 18'})
title('Jango Percent Success in Rotated Sessions')


figure;
%plot(sessionSuccess,'.','MarkerSize',20)
ylim([0 1]); xlim([0 8]); hold on
for i = 1:length(ReflectedSessionSuccess)
    EndOfLine = ReflectedSlope*0.5+ReflectedSessionSuccess(i);
    plot([i i+0.5],[ReflectedSessionSuccess(i), EndOfLine(i)],'-k','LineWidth',1.5)
end
MillerFigure
%set(gca,'XTick',[0:1:5])
%set(gca,'XTickLabel',{'';'Aug 4';'Aug 5';'Aug 8';'Aug 26';'June 18'})
title('Jango Percent Success in Reflected Sessions')


end
