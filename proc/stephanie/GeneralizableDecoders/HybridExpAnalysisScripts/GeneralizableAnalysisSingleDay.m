% GeneralizableAnalysisPapaScript
% This script is a "papa script" that builds decoders, saves actual and
% predicted EMG, and then makes and saves figures in the appropriate
% folders so that I can just open a folder and look at summary figures/data
% for that day.


% Step 1a: Initialize folders
monkeyname = 'Kevin';
BaseFolder = 'Y:\User_folders\Stephanie\Data Analysis\Generalizability\Kevin\';
%SubFolder = {'05-15-15'},'05-19-15','05-20-15','05-21-15s','05-25-15s','05-26-15',...
    %'06-04-15s','06-06-15'};
    SubFolder={'05-19-15'};


for i = 1:length(SubFolder)
    % Step 1b:  Load data into workspace | Open folder directory for saving figs 
    cd([BaseFolder SubFolder{i} '\']);
    foldername = [BaseFolder SubFolder{i} '\'];
    hyphens = find(SubFolder{i}=='-'); SubFolder{i}(hyphens)=[];
    load([foldername 'CleanData_' monkeyname '_' SubFolder{i}(1,1:6)]);
    datalabel(i,:) = SubFolder{i};


% Initialize springfile variable
if SubFolder{i}(end)=='s'
    SpringFile = 1;
else SpringFile = 0;
end

% Step 2: Make and save figures showing the EMGs for the 3 different tasks
save = 0;
% First List of EMGs
TaskEMG_Isometric(IsoBinned,'FCU', 'FCR', 'ECU', 'ECR',save,foldername,'IsoEMGs1');
TaskEMG_Movement(WmBinned,'FCU', 'FCR', 'ECU', 'ECR',save,foldername,'WmEMGs1');
if SpringFile == 1
    TaskEMG_Spring(SprBinned,'FCU', 'FCR', 'ECU', 'ECR',save,foldername,'SprEMGs1');
end
% Second List of EMGs
% TaskEMG_Isometric(IsoBinned,'FDS', 'FDP', 'EDCu', 'EDCr',save,foldername,'IsoEMGs2');
% TaskEMG_Movement(WmBinned,'FDS', 'FDP', 'EDCu', 'EDCr',save,foldername,'WmEMGs2');
% if SpringFile == 1
%     TaskEMG_Spring(SprBinned,'FDS', 'FDP', 'EDCu', 'EDCr',save,foldername,'SprEMGs2');
% end

% Step 3: make and save predictions
BuildDecodersMakePredictions

% Plot MSE ratios
[meanHonI_PC_mse(i) meanIonI_PC_mse(i) meanWonI_PC_mse(i)     meanHonW_PC_mse(i) meanWonW_PC_mse(i) meanIonW_PC_mse(i)...
    stdHonI_PC_mse(i) stdIonI_PC_mse(i) stdWonI_PC_mse(i) stdHonW_PC_mse(i) stdWonW_PC_mse(i) stdIonW_PC_mse(i)] ...
    = Get_mse_meanandstd(HonI_PC_mse, IonI_PC_mse, WonI_PC_mse, HonW_PC_mse, WonW_PC_mse, IonW_PC_mse);

% Plot predictions
% VAFstruct = []; % Come back to this
%  PlotAllIsometricPredictions(IsoBinned,IsoTest,IonIactTrunk,HonIpred,IonIpred,WonIpred,VAFstruct,save,foldername, 'IsoPredictions')
%  PlotAllMovementPredictions(WmBinned,WmTest,WonWact,HonWpred,WonWpred,IonWpred,VAFstruct,save,foldername, 'WmPredictions')


% Save workspace


end

% Across Sessions Analysis-------------------------------------------------

% Plot MSE values across time
PlotMSEratio(meanIonI_PC_mse, stdIonI_PC_mse, meanHonI_PC_mse, stdHonI_PC_mse, 'Within', 'Hybrid', 'Isometric predictions | mse')
PlotMSEratio(meanWonI_PC_mse, stdWonI_PC_mse, meanHonI_PC_mse, stdHonI_PC_mse, 'Across', 'Hybrid', 'Isometric predictions | mse')

PlotMSEratio(meanWonW_PC_mse, stdWonW_PC_mse, meanHonW_PC_mse, stdHonW_PC_mse, 'Within', 'Hybrid', 'Movement predictions | mse')
PlotMSEratio(meanIonW_PC_mse, stdIonW_PC_mse, meanHonW_PC_mse, stdHonW_PC_mse, 'Across', 'Hybrid', 'Movement predictions | mse')





%% extra
 
% Step 4: plot VAF histogram
% PlotVAFhistograms(IonI_vaf(1:9),HonI_vaf(1:9),WonI_vaf(1:9),'Isometric data | Within')
% PlotVAFhistograms(WonW_vaf(1:9),HonW_vaf(1:9),IonW_vaf(1:9),'Movement data | Within')
% PlotVAFhistograms_Spring(IonS_vaf(1:9),HonS_vaf(1:9),WonI_vaf(1:9),WonS_vaf(1:9),'Spring data | Within')
