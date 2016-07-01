
savefolder = 'Y:\User_folders\Stephanie\Data Analysis\LearnAdapt\04-06-2015\Figures\';
date = '04-06-2015_';
file2 = 'Reflect1';
file1 = 'Normal1';
file4 = 'Reflect2';
file3 = 'Normal2';

PercentSuccessfulTrials(1) = TrialSuccessPercentage(out_struct_normal1_refDay);
PercentSuccessfulTrials(2)= TrialSuccessPercentage(out_struct_reflect1);
PercentSuccessfulTrials(3) = TrialSuccessPercentage(out_struct_normal2_refDay);
PercentSuccessfulTrials(4) = TrialSuccessPercentage(out_struct_reflect2);
PercentSuccessfulTrials(5) = TrialSuccessPercentage(out_struct_normal3_refDay);
PercentSuccessfulTrials(6) = TrialSuccessPercentage(out_struct_reflect3);


subplot(2,1,1)
 plot(PercentSuccessfulTrials(1:4),'.','MarkerSize',30)
ylim([0 1]); XTick = [1:1:4]; set(gca,'YTick',[[0:0.2:1]]);
XTickLabel = {file1,file2,file3,file4};
hText = xticklabel_rotate(XTick,30,XTickLabel);
MillerFigure;

file2a = 'Rotate1';
file1a = 'Normal1';
file4a = 'Rotate2';
file3a = 'Normal2';

title('Percent of Successful Trials');

PercentSuccessfulTrials_Rot(1) = TrialSuccessPercentage(out_struct_normal1_rotDay);
PercentSuccessfulTrials_Rot(2)= TrialSuccessPercentage(out_struct_rotate1);
PercentSuccessfulTrials_Rot(3) = TrialSuccessPercentage(out_struct_normal2_rotDay);
PercentSuccessfulTrials_Rot(4) = TrialSuccessPercentage(out_struct_rotate2);

savefolderPR = 'Y:\User_folders\Stephanie\Data Analysis\LearnAdapt\ProgressReport\';


saveas(gcf,strcat(savefolderPR,'PercentSuccessfulTrialsSummary','.eps'));
saveas(gcf,strcat(savefolderPR,'PercentSuccessfulTrialsSummary','.fig'));
saveas(gcf,strcat(savefolderPR,'PercentSuccessfulTrialsSummary','.pdf'));





subplot(2,1,2)
 plot(PercentSuccessfulTrials_Rot(1:4),'g.','MarkerSize',30)
ylim([0 1]); XTick = [1:1:4]; set(gca,'YTick',[[0:0.2:1]]);
XTickLabel = {file1a,file2a,file3a,file4a};
hText = xticklabel_rotate(XTick,30,XTickLabel);
MillerFigure;


saveas(gcf,strcat(savefolder,'Fig\','PercentSuccessfulTrials_',date,'.fig'));saveas(gcf,strcat(savefolder,'PDF\','PercentSuccessfulTrials','.pdf'));
saveas(gcf,strcat(savefolder,'EPS\','PercentSuccessfulTrials','.eps'));



%T2T
Time2TargetStruct_rotate1 = ComputeTime2Target(out_struct_rotate1);
Time2TargetStruct_normal1_rotDay = ComputeTime2Target(out_struct_normal1_rotDay);
Time2TargetStruct_reflect1 = ComputeTime2Target(out_struct_reflect1);
Time2TargetStruct_normal1_refDay = ComputeTime2Target(out_struct_normal1_refDay);

% Subplot polar plots from the two days: rotated and reflected
subplot(2,2,1)
PlotTime2Target_ProgressReport(Time2TargetStruct_normal1_refDay, 'Normal')
subplot(2,2,2)
PlotTime2Target_ProgressReport(Time2TargetStruct_reflect1, 'Reflected')
subplot(2,2,3)
PlotTime2Target_ProgressReport(Time2TargetStruct_normal1_rotDay, 'Normal')
subplot(2,2,4)
PlotTime2Target_ProgressReport(Time2TargetStruct_rotate1, 'Rotated')


savefolderPR = 'Y:\User_folders\Stephanie\Data Analysis\LearnAdapt\ProgressReport\';


saveas(gcf,strcat(savefolderPR,'Time2TargetSummary','.eps'));
saveas(gcf,strcat(savefolderPR,'Time2TargetSummary','.fig'));
saveas(gcf,strcat(savefolderPR,'Time2TargetSummary','.pdf'));
