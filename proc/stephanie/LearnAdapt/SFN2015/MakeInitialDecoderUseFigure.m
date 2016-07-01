
% Load Kevin 4/2 data
% revised: load any data
[~, ~, ~, ~, TrialsStruct_normal1] = ComputeTaskTimeMetrics(out_struct_normal1);
[~, ~, ~, ~, TrialsStruct_normal2] = ComputeTaskTimeMetrics(out_struct_normal2);
[~, ~, ~, ~, TrialsStruct_normal3] = ComputeTaskTimeMetrics(out_struct_normal3);

[~, ~, ~, ~, TrialsStruct_reflect1] = ComputeTaskTimeMetrics(out_struct_reflect1);
[~, ~, ~, ~, TrialsStruct_reflect2] = ComputeTaskTimeMetrics(out_struct_reflect2);
[~, ~, ~, ~, TrialsStruct_reflect3] = ComputeTaskTimeMetrics(out_struct_reflect3);

figure; hold on;
rectangle('Position',[0.1 0.01 4 1],'FaceColor',[0.93 0.93 0.93],'EdgeColor','none')
rectangle('Position',[8 0.01 4 1],'FaceColor',[0.93 0.93 0.93],'EdgeColor','none')
rectangle('Position',[16 0.01 3 1],'FaceColor',[0.93 0.93 0.93],'EdgeColor','none')
PlotTotalSuccessOverTime(TrialsStruct_reflect1,[0 1 2 3 4],'g')
PlotTotalSuccessOverTime(TrialsStruct_normal1,[4 5 6 7 8 ],'b')
PlotTotalSuccessOverTime(TrialsStruct_reflect2,[8 9 10 11 12],'g')
PlotTotalSuccessOverTime(TrialsStruct_normal2, [12 13 14 15 16],'b')
PlotTotalSuccessOverTime(TrialsStruct_reflect3, [16 17 18 19 20],'g')
PlotTotalSuccessOverTime(TrialsStruct_normal3, [19 20 21 22 23],'b')
ylim([0 1]); xlim([0 22])
legend('Reflected','Normal')
MillerFigure


%%


% Load Kevin 4/3 data
% revised: or any other data
[~, ~, ~, ~, TrialsStruct_normal1] = ComputeTaskTimeMetrics(out_struct_normal1);
[~, ~, ~, ~, TrialsStruct_normal2] = ComputeTaskTimeMetrics(out_struct_normal2);
[~, ~, ~, ~, TrialsStruct_normal3] = ComputeTaskTimeMetrics(out_struct_normal3);

[~, ~, ~, ~, TrialsStruct_rotated1] = ComputeTaskTimeMetrics(out_struct_rotated1);
[~, ~, ~, ~, TrialsStruct_rotated2] = ComputeTaskTimeMetrics(out_struct_rotated2);
[~, ~, ~, ~, TrialsStruct_rotated3] = ComputeTaskTimeMetrics(out_struct_rotated3);

figure; hold on;
rectangle('Position',[0.1 0.01 3 1],'FaceColor',[0.93 0.93 0.93],'EdgeColor','none')
rectangle('Position',[7 0.01 4 1],'FaceColor',[0.93 0.93 0.93],'EdgeColor','none')
rectangle('Position',[15 0.01 3 1],'FaceColor',[0.93 0.93 0.93],'EdgeColor','none')
PlotTotalSuccessOverTime(TrialsStruct_rotated1,[0 1 2 3 4],'g')
PlotTotalSuccessOverTime(TrialsStruct_normal1,[3 4 5 6 7  ],'b')
PlotTotalSuccessOverTime(TrialsStruct_rotated2,[7 8 9 10 11 ],'g')
PlotTotalSuccessOverTime(TrialsStruct_normal2, [11 12 13 14 15 ],'b')
PlotTotalSuccessOverTime(TrialsStruct_rotated3, [15 16 17 18 19 ],'g')
PlotTotalSuccessOverTime(TrialsStruct_normal3, [18 19 20 21 22],'b')
ylim([0 1]); xlim([0 21])
legend('Rotated','Normal')
MillerFigure


