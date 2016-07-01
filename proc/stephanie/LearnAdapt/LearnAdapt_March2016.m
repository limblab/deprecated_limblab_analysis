


BaseFolder = 'C:\Stephanie\Data\LearnAdapt\Kevin\ShorterPerturbationDays_Kevin\';
% FileName = {'LongPert_Kevin_04292015_rot', 'LongPert_Kevin_05012015_rot',...
%  'LongPert_Kevin_05022015_ref','LongPert_Kevin_05032015_rot',...
% 'LongPert_Kevin_05042015_ref','LongPert_Kevin_06132015_rot'...
%  'LongPert_Kevin_06142015_ref','LongPert_Kevin_06252015_ref'};
% FileName = {'ShortPert_Kevin_040215_ref','ShortPert_Kevin_040315_rot','ShortPert_Kevin_040615',...
%     'ShortPert_Kevin_040715','ShortPert_Kevin_041015_rot','ShortPert_Kevin_041515_ref',...
%     'ShortPert_Kevin_041615','ShortPert_Kevin_041715_rot','ShortPert_Kevin_042015_ref',...
%     'ShortPert_Kevin_042315_ref'};
FileName = {'ShortPert_Kevin_040315_rot','ShortPert_Kevin_040715_rot','ShortPert_Kevin_041015_rot',...
    'ShortPert_Kevin_041615_rot','ShortPert_Kevin_041715_rot'};


for a = 1:length(FileName)
    load(strcat(BaseFolder,FileName{a}))
    currentFile = FileName{a};
    date = FileName{a}(1,17:22);


    figure
    for b=1:3
        TrialsPerEpoch=20;
        [~, ~, ~, ~, TrialsStructBaseline] = ComputeTaskTimeMetrics(eval(['out_struct_' date '_normal' num2str(b)]));
        BaselineSessionSuccess(1) = ComputeSessionSuccess(TrialsStructBaseline);
        [BaselineSuccessPoints{1}, firstBinarySuccess_baseline, lastBinarySuccess_baseline] = ComputeTotalSuccessOverTime_trialbasis(TrialsStructBaseline,  TrialsPerEpoch);
        
        
        [~, ~, ~, ~, TrialsStructRotated] = ComputeTaskTimeMetrics(eval(['out_struct_' date '_rotated' num2str(b)]));
        RotatedSessionSuccess(1) = ComputeSessionSuccess(TrialsStructRotated);
        [RotatedSuccessPoints{1},firstBinarySuccess_rotated, lastBinarySuccess_rotated] = ComputeTotalSuccessOverTime_trialbasis(TrialsStructRotated,  TrialsPerEpoch);
        

        subplot(1,3,b)
        hold on;
        MarkerSize=30;
        LineWidth = 2;
        ylim([0 1]);xlim([.7 2.3])
        for j = 1:length(BaselineSuccessPoints)
            plot( (j-.1):.1:(j-.1)+.1*length(BaselineSuccessPoints{j})-.1 , BaselineSuccessPoints{j},'k.-','MarkerSize',MarkerSize,'LineWidth',LineWidth)
        end
        for k=1:length(RotatedSuccessPoints)
            plot( (j-.1):.1:(j-.1)+.1*length(RotatedSuccessPoints{j})-.1 , RotatedSuccessPoints{j},'g.-','MarkerSize',30,'LineWidth',LineWidth)
        end
        ylim([0 1]);
        MillerFigure;
        pval=getCHIpValue(RotatedSuccessPoints{1},TrialsPerEpoch);
        title(['Kevin Shorter Per ' date ' pval=' num2str(pval)])
        
        clearvars -except a BaseFolder FileName date
        
    end
end





