%Analyze All Jango Data
% This script computes percent success and chi statistics
function [Baseline_pValue, Reflected_pValue, Rotated_pValue] = AnalyzeAllJangoData
% make cd('Y:\User_folders\Stephanie\Data Analysis\LearnAdapt\Jango')

% BaseFolder = 'C:\Stephanie\Data\LearnAdapt\Jango\';
% FileName = {'LongPert_Jango_073115_ref', 'LongPert_Jango_080415_rot',...
%     'LongPert_Jango_080515_rot',...
%      'LongPert_Jango_080815_rot','LongPert_Jango_080915_ref',...
%      'LongPert_Jango_082015_rot','LongPert_Jango_082415_ref',...
%     'LongPert_Jango_082615_rot', 'LongPert_Jango_082815_ref',...
%     'LongPert_Jango_090615_ref','LongPert_Jango_092515_ref',...
%     'LongPert_Jango_092615_rot', 'LongPert_Jango_092915_rot',...
%     'LongPert_Jango_100115_rot'};

BaseFolder = 'C:\Stephanie\Data\LearnAdapt\Kevin\LongerPerturbationDays_Kevin\';
% FileName = {'LongPert_Kevin_04292015_rot', 'LongPert_Kevin_05012015_rot',...
%  'LongPert_Kevin_05022015_ref','LongPert_Kevin_05032015_rot',...
% 'LongPert_Kevin_05042015_ref','LongPert_Kevin_06132015_rot'...
%  'LongPert_Kevin_06142015_ref','LongPert_Kevin_06252015_ref'};



ReflectedSessionSuccess = -1*ones(1,length(FileName));
RotatedSessionSuccess = -1*ones(1,length(FileName));
BaselineSuccessPoints = cell(length(FileName),1);
ReflectedSuccessPoints = cell(length(FileName),1);
RotatedSuccessPoints = cell(length(FileName),1);
Baseline_pValue = cell(length(FileName),1);
Rotated_pValue = cell(length(FileName),1);
Reflected_pValue = cell(length(FileName),1);
TrialsPerEpoch = 40;

for i = 1:length(FileName)
    load(strcat(BaseFolder,FileName{i}))
    currentFile = FileName{i};
    date = FileName{i}(1,16:21); %for jango
%date = FileName{i}(1,16:23); %for kevin
    

[~, ~, ~, ~, TrialsStructBaseline] = ComputeTaskTimeMetrics(eval(['out_struct_' date '_baseline']));
BaselineSessionSuccess(i) = ComputeSessionSuccess(TrialsStructBaseline);
[BaselineSuccessPoints{i}, firstBinarySuccess_baseline, lastBinarySuccess_baseline] = ComputeTotalSuccessOverTime_trialbasis(TrialsStructBaseline, 30);
% BASELINE STATS
% calculate significance of the slope for the baseline points. Test: is slope significantly different than 0?
 Baseline_pValue{i} = getCHIpValue(BaselineSuccessPoints{i},30);

% If reflected
if (FileName{i}(end-2:end)) == 'ref'
    
    [~, ~, ~, ~, TrialsStructReflected] = ComputeTaskTimeMetrics(eval(['out_struct_' date '_reflected']));
    ReflectedSessionSuccess(i) = ComputeSessionSuccess(TrialsStructReflected);
    [ReflectedSuccessPoints{i},firstBinarySuccess_reflected, lastBinarySuccess_reflected] = ComputeTotalSuccessOverTime_trialbasis(TrialsStructReflected, TrialsPerEpoch);
    % REFLECTED STATS
    Reflected_pValue{i} = getCHIpValue(ReflectedSuccessPoints{i},TrialsPerEpoch);
    
else if (FileName{i}(end-2:end)) == 'rot' % else if rotated
        [~, ~, ~, ~, TrialsStructRotated] = ComputeTaskTimeMetrics(eval(['out_struct_' date '_rotated']));
        RotatedSessionSuccess(i) = ComputeSessionSuccess(TrialsStructRotated);
        [RotatedSuccessPoints{i},firstBinarySuccess_rotated, lastBinarySuccess_rotated] = ComputeTotalSuccessOverTime_trialbasis(TrialsStructRotated, TrialsPerEpoch);
        % ROTATED STATS
        Rotated_pValue{i} = getCHIpValue(RotatedSuccessPoints{i},TrialsPerEpoch);
    end
end

clearvars -except BaseFolder FileName TrialsPerEpoch BaselineSuccessPoints ...
ReflectedSuccessPoints RotatedSuccessPoints BaselineSessionSuccess ...
ReflectedSessionSuccess RotatedSessionSuccess...
Baseline_pValue Reflected_pValue Rotated_pValue

end



% figure; hold on;
% MarkerSize = 20;
% plot(BaselineSessionSuccess,'.k','MarkerSize',MarkerSize)
% plot(RotatedSessionSuccess,'.b','MarkerSize',MarkerSize)
% plot(ReflectedSessionSuccess,'.g','MarkerSize',MarkerSize)
% ylim([0 1])
% title(BaseFolder(1,end-5:end-1))

figure; hold on;
MarkerSize=30;
LineWidth = 2;
ylim([0 1]);xlim([.7 9])
for j = 1:length(BaselineSuccessPoints)
    
%     if ~isempty(RotatedSuccessPoints{j}) %if rotated session
%         rectangle('Position',[j-.1 0.01 length(RotatedSuccessPoints{j})*.1-.1 1],'FaceColor',[0.9 0.9 0.9],'EdgeColor','none')
%     end
    plot( (j-.1):.1:(j-.1)+.1*length(BaselineSuccessPoints{j})-.1 , BaselineSuccessPoints{j},'k.-','MarkerSize',MarkerSize,'LineWidth',LineWidth)
    if ~isempty(Reflected_pValue{j})
        if (Reflected_pValue{j})<=.05
            plot( (j-.1):.1:(j-.1)+.1*length(ReflectedSuccessPoints{j})-.1 , ReflectedSuccessPoints{j},'r.-','MarkerSize',30,'LineWidth',LineWidth)
        else
            plot( (j-.1):.1:(j-.1)+.1*length(ReflectedSuccessPoints{j})-.1 , ReflectedSuccessPoints{j},'r.-','MarkerSize',MarkerSize,'LineWidth',LineWidth)
        end
    end
    if ~isempty(Rotated_pValue{j})
        if (Rotated_pValue{j})<=.05
            plot( (j-.1):.1:(j-.1)+.1*length(RotatedSuccessPoints{j})-.1 , RotatedSuccessPoints{j},'g.-','MarkerSize',30,'LineWidth',LineWidth)
        else
            plot( (j-.1):.1:(j-.1)+.1*length(RotatedSuccessPoints{j})-.1 , RotatedSuccessPoints{j},'g.-','MarkerSize',MarkerSize,'LineWidth',LineWidth)
        end
    end
end
%forkevin
%set(gca,'Xtick',1:8,'XTickLabel',{'April 29', 'May 1', 'May 2', 'May 3', 'May 4', 'June 13', 'June 14', 'June 25'})
%forjango



end



