function MeanSuccessAcrossDaysWithSlopes
% Calculate a mean success rate for each perturbation day and plot

sessionSuccess = [];slope = [];
% For each session: get info for each trial and their outcome
[~, ~, ~, ~, TrialsStruct_04292015_rotated] = ComputeTaskTimeMetrics(out_struct_04292015_rotated);
[~, ~, ~, ~, TrialsStruct_05012015_rotated] = ComputeTaskTimeMetrics(out_struct_05012015_rotated);
[~, ~, ~, ~, TrialsStruct_05032015_rotated] = ComputeTaskTimeMetrics(out_struct_05032015_rotated);
[~, ~, ~, ~, TrialsStruct_06132015_rotated] = ComputeTaskTimeMetrics(out_struct_06132015_rotated);
[~, ~, ~, ~, TrialsStruct_06182015_rotated] = ComputeTaskTimeMetrics(out_struct_06182015_rotated);

sessionSuccess(1) = ComputeSessionSuccess(TrialsStruct_04292015_rotated);
sessionSuccess(2) = ComputeSessionSuccess(TrialsStruct_05012015_rotated);
sessionSuccess(3) = ComputeSessionSuccess(TrialsStruct_05032015_rotated);
sessionSuccess(4) = ComputeSessionSuccess(TrialsStruct_06132015_rotated);
sessionSuccess(5) = ComputeSessionSuccess(TrialsStruct_06182015_rotated);

% Get the slope of performance for each individual session
TrialsPerEpoch = 20;
slope(1) = GetSlopeOfLearningForOneDay(TrialsStruct_04292015_rotated, TrialsPerEpoch);
slope(2) = GetSlopeOfLearningForOneDay(TrialsStruct_05012015_rotated, TrialsPerEpoch);
slope(3) = GetSlopeOfLearningForOneDay(TrialsStruct_05032015_rotated, TrialsPerEpoch);
slope(4) = GetSlopeOfLearningForOneDay(TrialsStruct_06132015_rotated, TrialsPerEpoch);
slope(5) = GetSlopeOfLearningForOneDay(TrialsStruct_06182015_rotated, TrialsPerEpoch);

% Plot mean
figure;
plot(sessionSuccess,'.','MarkerSize',20)
ylim([0 1]); xlim([0 6]); hold on
for i = 1:length(sessionSuccess)
    EndOfLine = slope*0.5+sessionSuccess(i);
    plot([i i+0.5],[sessionSuccess(i), EndOfLine(i)],'-k','LineWidth',1.5)
end
MillerFigure
set(gca,'XTick',[0:1:5])
set(gca,'XTickLabel',{'';'April 29';'May 1';'May 3';'June 13';'June 18'})
title('Kevin Percent Success in Rotated Sessions')

end
