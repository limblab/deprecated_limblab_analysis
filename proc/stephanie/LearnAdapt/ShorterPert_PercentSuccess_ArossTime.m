% ShorterPert_PercentSuccess_ArossTime
% This script plots all the successful trials for the different short
% perturbation blocks across time


BaseFolder = 'C:\Stephanie\Data\LearnAdapt\Kevin\ShorterPerturbationDays_Kevin\';
FileName = {'ShortPert_Kevin_040215_ref','ShortPert_Kevin_040315_rot','ShortPert_Kevin_040615_ref',...
    'ShortPert_Kevin_040715_rot','ShortPert_Kevin_041015_rot','ShortPert_Kevin_041515_ref',...
    'ShortPert_Kevin_041615_rot','ShortPert_Kevin_041715_rot','ShortPert_Kevin_042015_ref',...
    'ShortPert_Kevin_042315_ref'};

PointsCounter=1;
for a = 1:length(FileName)
    load(strcat(BaseFolder,FileName{a}))
    currentFile = FileName{a};
    date = FileName{a}(1,17:22);
    
    
    if (FileName{a}(end-2:end)) == 'rot'
     %   figure
        %PointsCounter=1;
        for b=1:3
            
            TrialsPerEpoch=20;
            [~, ~, ~, ~, TrialsStructBaseline] = ComputeTaskTimeMetrics(eval(['out_struct_' date '_normal' num2str(b)]));
            BaselineSessionSuccess(1) = ComputeSessionSuccess(TrialsStructBaseline);
            [BaselineSuccessPoints{1}, firstBinarySuccess_baseline, lastBinarySuccess_baseline] = ComputeTotalSuccessOverTime_trialbasis(TrialsStructBaseline,  TrialsPerEpoch);
         
            
            [~, ~, ~, ~, TrialsStructRotated] = ComputeTaskTimeMetrics(eval(['out_struct_' date '_rotated' num2str(b)]));
            RotatedSessionSuccess(1) = ComputeSessionSuccess(TrialsStructRotated);
            [RotatedSuccessPoints{1},firstBinarySuccess_rotated, lastBinarySuccess_rotated] = ComputeTotalSuccessOverTime_trialbasis(TrialsStructRotated,  TrialsPerEpoch);
            
            hold on;
            MarkerSize=30;
            LineWidth = 2;
            ylim([0 1]);
            
            plot([PointsCounter-1:PointsCounter+length(BaselineSuccessPoints{1})-2],BaselineSuccessPoints{1},'k.-','MarkerSize',MarkerSize,'LineWidth',LineWidth)
            PointsCounter=PointsCounter+length(BaselineSuccessPoints{1})-1;
            plot([PointsCounter-1:PointsCounter+length(RotatedSuccessPoints{1})-2],RotatedSuccessPoints{1},'g.-','MarkerSize',30,'LineWidth',LineWidth)
            PointsCounter=PointsCounter+length(RotatedSuccessPoints{1})-1;
        end
        %MillerFigure;
        %title(['Kevin Shorter Per ' date ' Rotated'])
        
        
        
    else
     %   figure
        %PointsCounter=1;
        for c=1:3
            
            TrialsPerEpoch=20;
            [~, ~, ~, ~, TrialsStructBaseline] = ComputeTaskTimeMetrics(eval(['out_struct_' date '_normal' num2str(c)]));
            BaselineSessionSuccess(1) = ComputeSessionSuccess(TrialsStructBaseline);
            [BaselineSuccessPoints{1}, firstBinarySuccess_baseline, lastBinarySuccess_baseline] = ComputeTotalSuccessOverTime_trialbasis(TrialsStructBaseline,  TrialsPerEpoch);
            
            
            [~, ~, ~, ~, TrialsStructReflected] = ComputeTaskTimeMetrics(eval(['out_struct_' date '_reflected' num2str(c)]));
            ReflectedSessionSuccess(1) = ComputeSessionSuccess(TrialsStructReflected);
            [ReflectedSuccessPoints{1},firstBinarySuccess_reflected, lastBinarySuccess_reflected] = ComputeTotalSuccessOverTime_trialbasis(TrialsStructReflected,  TrialsPerEpoch);
            
            hold on;
            MarkerSize=30;
            LineWidth = 2;
            ylim([0 1]);
            
            plot([PointsCounter-1:PointsCounter+length(BaselineSuccessPoints{1})-2],BaselineSuccessPoints{1},'k.-','MarkerSize',MarkerSize,'LineWidth',LineWidth)
            PointsCounter=PointsCounter+length(BaselineSuccessPoints{1})-1;
            plot([PointsCounter-1:PointsCounter+length(ReflectedSuccessPoints{1})-2],ReflectedSuccessPoints{1},'r.-','MarkerSize',30,'LineWidth',LineWidth)
            PointsCounter=PointsCounter+length(ReflectedSuccessPoints{1})-1;
        end
       % MillerFigure;
        %title(['Kevin Shorter Per ' date ' Reflected'])
    end
    
    x=[PointsCounter PointsCounter]; y = [0 1];
    plot(x,y)
    
    clearvars -except a BaseFolder FileName date PointsCounter
    
    MillerFigure

end






