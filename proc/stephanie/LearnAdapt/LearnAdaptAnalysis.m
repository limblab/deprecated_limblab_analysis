% LearnAdapt analysis

% Convert nev files to BDF
% dataPath = 'Z:\Kevin_12A2\FES\'; % Set a base directory
% convertFolders = {'04-01-15'};
% convertCerebusToBDF(dataPath,convertFolders,0)


savefolder = 'Y:\User_folders\Stephanie\Data Analysis\LearnAdapt\04-06-2015\Figures\';
date = '04-06-2015_';
file1 = 'Reflect1';
file2 = 'Normal1';
file3 = 'Reflect2';
file4 = 'Normal2';
file5 = 'Reflect3';
file6 = 'Normal3';

Time2TargetStruct_reflect1 = ComputeTime2Target(out_struct_reflect1);
Time2TargetStruct_normal1 = ComputeTime2Target(out_struct_normal1);
Time2TargetStruct_reflect2 = ComputeTime2Target(out_struct_reflect2);
Time2TargetStruct_normal2 = ComputeTime2Target(out_struct_normal2);
Time2TargetStruct_reflect3 = ComputeTime2Target(out_struct_reflect3);
Time2TargetStruct_normal3 = ComputeTime2Target(out_struct_normal3);


PlotTime2Target(Time2TargetStruct_reflect1, 'T2T Reflect1');
saveas(gcf,strcat(savefolder,'Fig\','T2T_', date, file1,'.fig'));saveas(gcf,strcat(savefolder,'PDF\','T2T_', date, file1,'.pdf'));
PlotTime2Target(Time2TargetStruct_normal1, 'T2T Normal1')
saveas(gcf,strcat(savefolder,'Fig\','T2T_', date, file2,'.fig'));saveas(gcf,strcat(savefolder,'PDF\','T2T_', date,  file2,'.pdf'));
PlotTime2Target(Time2TargetStruct_reflect2, 'T2T Reflect2')
saveas(gcf,strcat(savefolder,'Fig\','T2T_', date, file3,'.fig'));saveas(gcf,strcat(savefolder,'PDF\','T2T_', date, file3,'.pdf'));
PlotTime2Target(Time2TargetStruct_normal2, 'T2T Normal2')
saveas(gcf,strcat(savefolder,'Fig\','T2T_', date, file4,'.fig'));saveas(gcf,strcat(savefolder,'PDF\','T2T_', date, file4,'.pdf'));
PlotTime2Target(Time2TargetStruct_reflect3, 'T2T Reflect3')
saveas(gcf,strcat(savefolder,'Fig\','T2T_', date, file5,'.fig'));saveas(gcf,strcat(savefolder,'PDF\','T2T_', date, file5,'.pdf'));
PlotTime2Target(Time2TargetStruct_normal3, 'T2T Normal3')
saveas(gcf,strcat(savefolder,'Fig\','T2T_', date, file6,'.fig'));saveas(gcf,strcat(savefolder,'PDF\','T2T_', date, file6,'.pdf'));


%Percent successful trials-------------------------------------------------
PercentSuccessfulTrials(1) = TrialSuccessPercentage(out_struct_reflect1);
PercentSuccessfulTrials(2)= TrialSuccessPercentage(out_struct_normal1);
PercentSuccessfulTrials(3) = TrialSuccessPercentage(out_struct_reflect2);
PercentSuccessfulTrials(4) = TrialSuccessPercentage(out_struct_normal2);
PercentSuccessfulTrials(5) = TrialSuccessPercentage(out_struct_reflect3);
PercentSuccessfulTrials(6) = TrialSuccessPercentage(out_struct_normal3);

figure; plot(PercentSuccessfulTrials,'.','MarkerSize',30)
ylim([0 1]); XTick = [1:1:6];
XTickLabel = {file1,file2,file3,file4,file5,file6};
hText = xticklabel_rotate(XTick,30,XTickLabel);
MillerFigure;
saveas(gcf,strcat(savefolder,'Fig\','PercentSuccessfulTrials_',date,'.fig'));saveas(gcf,strcat(savefolder,'PDF\','PercentSuccessfulTrials','.pdf'));
%--------------------------------------------------------------------------

% Make predictions -------------------------------------------------------
params = get_default_binning_params(out_struct_reflect1);params.NormData=1;
binned_reflect1 = convertBDF2binned(out_struct_reflect1,params);
plot_predsF(binned_normal1,{N2E;E2F_reflected},'cascade');
saveas(gcf,strcat(savefolder,'Fig\','Ypreds', file1,'.fig'));saveas(gcf,strcat(savefolder,'PDF\','Ypreds', file1,'.pdf'));
close
saveas(gcf,strcat(savefolder,'Fig\','Xpreds', file1,'.fig'));saveas(gcf,strcat(savefolder,'PDF\','Xpreds', file1,'.pdf'));


params = get_default_binning_params(out_struct_normal1);params.NormData=1;
binned_normal1 = convertBDF2binned(out_struct_normal1,params);
[vaf,R2,predsF] = plot_predsF(binned_normal1,{N2E;E2F},'cascade');
saveas(gcf,strcat(savefolder,'Fig\','Ypreds', file2,'.fig'));saveas(gcf,strcat(savefolder,'PDF\','Ypreds', file2,'.pdf'));
close
saveas(gcf,strcat(savefolder,'Fig\','Xpreds', file2,'.fig'));saveas(gcf,strcat(savefolder,'PDF\','Xpreds', file2,'.pdf'));


