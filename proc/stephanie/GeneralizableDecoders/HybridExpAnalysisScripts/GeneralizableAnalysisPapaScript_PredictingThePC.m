% GeneralizableAnalysisPapaScript
% This script is a "papa script" that builds decoders, saves actual and
% predicted EMG, and then makes and saves figures in the appropriate
% folders so that I can just open a folder and look at summary figures/data
% for that day.

clear
% Step 1a: Initialize folders
  monkeyname = 'Kevin';
  BaseFolder = 'Y:\User_folders\Stephanie\Data Analysis\Generalizability\Kevin\';
%SubFolder={'05-15-15','05-19-15','05-20-15','05-21-15s','06-04-15s','06-06-15'};
SubFolder = {'05-25-15s'};
% Leaving out '05-25-15s', '05-26-15'
%SubFolder = {'05-25-15s','05-21-15s','06-04-15s'};
% 
%  monkeyname = 'Jango';
%  BaseFolder = 'Y:\User_folders\Stephanie\Data Analysis\Generalizability\Jango\';
% % %SubFolder = {'05-15-15s','08-19-14s','08-20-14s','09-23-14s','09-25-14','10-11-14s'};
%  %SubFolder = {'05-15-15s','08-19-14s','08-20-14s','09-25-14'};
% SubFolder = {'05-15-15s'};



%figure(200); figure(201);
for i = 1:length(SubFolder)
    % Step 1b:  Load data into workspace | Open folder directory for saving figs 
    cd([BaseFolder SubFolder{i} '\']);
    foldername = [BaseFolder SubFolder{i} '\'];
    hyphens = find(SubFolder{i}=='-'); SubFolder{i}(hyphens)=[];
    load([foldername 'CleanData_' monkeyname '_' SubFolder{i}(1,1:6)]);
    datalabel = SubFolder{i}(1:6);

% Initialize springfile variable
if SubFolder{i}(end)=='s'
    SpringFile = 1;
else SpringFile = 0;
end

% Only keep EMG data for the 4 wrist muscles
binnedData = IsoBinned;
IsoBinned.emgguide = cellstr(IsoBinned.emgguide); WmBinned.emgguide = cellstr(WmBinned.emgguide);
EMGind1 = strmatch('FCR',(binnedData.emgguide)); EMGind1 = EMGind1(1);
EMGind2 = strmatch('FCU',(binnedData.emgguide)); EMGind2 = EMGind2(1);
EMGind3 = strmatch('ECR',(binnedData.emgguide)); EMGind3 = EMGind3(1);
EMGind4 = strmatch('ECU',(binnedData.emgguide)); EMGind4 = EMGind4(1);
emg_vector = [EMGind1 EMGind2 EMGind3 EMGind4];
IsoBinned.emgguide = IsoBinned.emgguide(emg_vector); IsoBinned.emgdatabin = IsoBinned.emgdatabin(:,emg_vector);
WmBinned.emgguide = WmBinned.emgguide(emg_vector); WmBinned.emgdatabin = WmBinned.emgdatabin(:,emg_vector);
if SpringFile == 1
    SprBinned.emgguide = cellstr(SprBinned.emgguide);
    SprBinned.emgguide = SprBinned.emgguide(emg_vector); SprBinned.emgdatabin = SprBinned.emgdatabin(:,emg_vector);
end

% Step 2: Make and save figures showing the EMGs for the 3 different tasks
save = 0;
%First List of EMGs
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

% Only use a certain subset of muscles ----------------------------------
% binnedData = IsoBinned;
% EMGind1 = strmatch('FCR',binnedData.emgguide(1,:)); EMGind1 = EMGind1(1);
% EMGind3 = strmatch('FCU',binnedData.emgguide(1,:)); EMGind3 = EMGind3(1);
% EMGind4 = strmatch('ECU',binnedData.emgguide(1,:)); EMGind4 = EMGind4(1);
% emg_vector = [EMGind1 EMGind3 EMGind4];
% IsoBinned.emgguide = IsoBinned.emgguide(emg_vector); IsoBinned.emgdatabin = IsoBinned.emgdatabin(:,emg_vector);
% WmBinned.emgguide = WmBinned.emgguide(emg_vector); WmBinned.emgdatabin = WmBinned.emgdatabin(:,emg_vector);
% if SpringFile == 1
%     SprBinned.emgguide = SprBinned.emgguide(emg_vector); SprBinned.emgdatabin = SprBinned.emgdatabin(:,emg_vector);
% end

% Step 3: make and save predictions
%BuildDecodersMakePredictions
BuildDecodersMakePredictions_PredictingThePC

% Get MSE stats
[meanHonI_PC_mse(i) meanIonI_PC_mse(i) meanWonI_PC_mse(i)     meanHonW_PC_mse(i) meanWonW_PC_mse(i) meanIonW_PC_mse(i)...
    stdHonI_PC_mse(i) stdIonI_PC_mse(i) stdWonI_PC_mse(i) stdHonW_PC_mse(i) stdWonW_PC_mse(i) stdIonW_PC_mse(i)] ...
    = Get_mse_meanandstd(HonI_PC_mse(:,1), IonI_PC_mse(:,1), WonI_PC_mse(:,1), HonW_PC_mse(:,1), WonW_PC_mse(:,1), IonW_PC_mse(:,1));
if Spring == 1
    [meanHonS_PC_mse(i) meanIonS_PC_mse(i) meanWonS_PC_mse(i) meanSonS_PC_mse(i) ...
        stdHonS_PC_mse(i) stdIonS_PC_mse(i) stdWonS_PC_mse(i) stdSonS_PC_mse(i)] ...
        = Get_mse_meanandstd_Spring(HonS_PC_mse(:,1), IonS_PC_mse(:,1), WonS_PC_mse(:,1), SonS_PC_mse(:,1));
end

% Plot individual EMG predictions
 PlotAllIsometricPredictions(IsoBinned,IsoTest,IonIactTrunk,HonIpred.preddatabin,IonIpred.preddatabin,WonIpred.preddatabin,VAFstruct,save,foldername, [monkeyname '_' datalabel 'IsoPredictions'])
 PlotAllMovementPredictions(WmBinned,WmTest,WonWactTrunk,HonWpred.preddatabin,WonWpred.preddatabin,IonWpred.preddatabin,VAFstruct,save,foldername, [monkeyname '_' datalabel 'WmPredictions'])
 if SpringFile == 1
     PlotAllSpringPredictions(SprBinned,SprTest,SonSactTrunk,SonSpred.preddatabin,HonSpred.preddatabin,IonSpred.preddatabin,WonSpred.preddatabin, VAFstruct,save,foldername, 'SprPredictions')
 end


% Plot VAF across days
IonI_PC_vaf_means(i) = mean(IonI_PC_vaf(:,1)); IonI_PC_vaf_STEs(i) = std(IonI_PC_vaf(:,1))/sqrt(length(IonI_PC_vaf(:,1)));
HonI_PC_vaf_means(i) = mean(HonI_PC_vaf(:,1)); HonI_PC_vaf_STEs(i) = std(HonI_PC_vaf(:,1))/sqrt(length(HonI_PC_vaf(:,1)));
WonI_PC_vaf_means(i) = mean(WonI_PC_vaf(:,1)); WonI_PC_vaf_STEs(i) = std(WonI_PC_vaf(:,1))/sqrt(length(WonI_PC_vaf(:,1)));
%
WonW_PC_vaf_means(i) = mean(WonW_PC_vaf(:,1)); WonW_PC_vaf_STEs(i) = std(WonW_PC_vaf(:,1))/sqrt(length(WonW_PC_vaf(:,1)));
HonW_PC_vaf_means(i) = mean(HonW_PC_vaf(:,1)); HonW_PC_vaf_STEs(i) = std(HonW_PC_vaf(:,1))/sqrt(length(HonW_PC_vaf(:,1)));
IonW_PC_vaf_means(i) = mean(IonW_PC_vaf(:,1)); IonW_PC_vaf_STEs(i) = std(IonW_PC_vaf(:,1))/sqrt(length(IonW_PC_vaf(:,1)));

if SpringFile == 1
SonS_PC_vaf_means(i) = mean(SonS_PC_vaf(:,1)); SonS_PC_vaf_STEs(i) = std(SonS_PC_vaf(:,1))/sqrt(length(SonS_PC_vaf(:,1)));
HonS_PC_vaf_means(i) = mean(HonS_PC_vaf(:,1)); HonS_PC_vaf_STEs(i) = std(HonS_PC_vaf(:,1))/sqrt(length(HonS_PC_vaf(:,1)));
WonS_PC_vaf_means(i) = mean(WonS_PC_vaf(:,1)); WonS_PC_vaf_STEs(i) = std(WonS_PC_vaf(:,1))/sqrt(length(WonS_PC_vaf(:,1)));
IonS_PC_vaf_means(i) = mean(IonS_PC_vaf(:,1)); IonS_PC_vaf_STEs(i) = std(IonS_PC_vaf(:,1))/sqrt(length(IonS_PC_vaf(:,1)));
end

% Clear variables
clearvars -except monkeyname SpringFile BaseFolder SubFolder meanHonI_PC_mse meanIonI_PC_mse meanWonI_PC_mse meanHonW_PC_mse meanWonW_PC_mse meanIonW_PC_mse...
    stdHonI_PC_mse stdIonI_PC_mse stdWonI_PC_mse stdHonW_PC_mse stdWonW_PC_mse stdIonW_PC_mse meanHonS_PC_mse meanIonS_PC_mse meanWonS_PC_mse meanSonS_PC_mse ...
        stdHonS_PC_mse stdIonS_PC_mse stdWonS_PC_mse stdSonS_PC_mse i ...
    IonI_PC_vaf_means IonI_PC_vaf_STEs HonI_PC_vaf_means HonI_PC_vaf_STEs WonI_PC_vaf_means WonI_PC_vaf_STEs...
    WonW_PC_vaf_means WonW_PC_vaf_STEs HonW_PC_vaf_means HonW_PC_vaf_STEs IonW_PC_vaf_means IonW_PC_vaf_STEs...
    SonS_PC_vaf_means HonS_PC_vaf_means WonS_PC_vaf_means IonS_PC_vaf_means...
    SonS_PC_vaf_STEs HonS_PC_vaf_STEs WonS_PC_vaf_STEs IonS_PC_vaf_STEs

end

%close all
save =0;foldername = '';
for a=1:length(SubFolder)
    PlotVAFAcrossDays(a,1000,IonI_PC_vaf_means(a), IonI_PC_vaf_STEs(a),HonI_PC_vaf_means(a), HonI_PC_vaf_STEs(a), WonI_PC_vaf_means(a), WonI_PC_vaf_STEs(a), save,foldername, [monkeyname ' | ', ' Iso PC VAFs Across Days'])
    PlotVAFAcrossDays(a,1001,WonW_PC_vaf_means(a), WonW_PC_vaf_STEs(a),HonW_PC_vaf_means(a), HonW_PC_vaf_STEs(a), IonW_PC_vaf_means(a), IonW_PC_vaf_STEs(a), save,foldername, [monkeyname ' | ', ' Wm PC VAFs Across Days'])

    PlotVAFAcrossDays(a,1002,meanIonI_PC_mse(a), stdIonI_PC_mse(a), meanHonI_PC_mse(a), stdHonI_PC_mse(a), meanWonI_PC_mse(a), stdWonI_PC_mse(a), save,foldername, [monkeyname ' | ', ' Iso PC MSE Across Days'])
    PlotVAFAcrossDays(a,1003,meanWonW_PC_mse(a), stdWonW_PC_mse(a), meanHonW_PC_mse(a), stdHonW_PC_mse(a), meanIonW_PC_mse(a), stdIonW_PC_mse(a), save,foldername, [monkeyname ' | ', ' Wm PC MSE Across Days'])
end

if SpringFile ==1
    for a=1:length(SubFolder)
    PlotVAFAcrossDays_wSpring(a,1004,SonS_PC_vaf_means(a), SonS_PC_vaf_STEs(a),HonS_PC_vaf_means(a), HonS_PC_vaf_STEs(a), WonS_PC_vaf_means(a), WonS_PC_vaf_STEs(a), IonS_PC_vaf_means(a), IonS_PC_vaf_STEs(a),save,foldername, [monkeyname ' | ', 'Spring PC VAFs Across Days'])
    end
end



% Across Sessions Analysis-------------------------------------------------

% Plot MSE values across time
% If the markers are less than the x=y line, the y axis is better than x
% PlotMSEratio(meanIonI_PC_mse, stdIonI_PC_mse, meanHonI_PC_mse, stdHonI_PC_mse, 'Within', 'Hybrid', [monkeyname,' Isometric predictions | mse'])
% PlotMSEratio(meanWonI_PC_mse, stdWonI_PC_mse, meanHonI_PC_mse, stdHonI_PC_mse, 'Across', 'Hybrid', [monkeyname,' Isometric predictions | mse'])
% 
% PlotMSEratio(meanWonW_PC_mse, stdWonW_PC_mse, meanHonW_PC_mse, stdHonW_PC_mse, 'Within', 'Hybrid', [monkeyname,' Movement predictions | mse'])
% PlotMSEratio(meanIonW_PC_mse, stdIonW_PC_mse, meanHonW_PC_mse, stdHonW_PC_mse, 'Across', 'Hybrid', [monkeyname,' Movement predictions | mse'])
% 
% if SpringFile == 1
% PlotMSEratio(meanSonS_PC_mse, stdSonS_PC_mse, meanHonS_PC_mse, stdHonS_PC_mse, 'Within', 'Hybrid', [monkeyname,' Spring predictions | mse'])
% PlotMSEratio(meanSonS_PC_mse, stdSonS_PC_mse, meanIonS_PC_mse, stdIonS_PC_mse, 'Within', 'Isometric', [monkeyname,' Spring predictions | mse'])
% PlotMSEratio(meanHonS_PC_mse, stdHonS_PC_mse, meanIonS_PC_mse, stdIonS_PC_mse, 'Hybrid', 'Isometric', [monkeyname,' Spring predictions | mse'])
% PlotMSEratio(meanSonS_PC_mse, stdSonS_PC_mse, meanWonS_PC_mse, stdWonS_PC_mse, 'Within', 'Movement', [monkeyname,' Spring predictions | mse'])
% end



%% extra
 
% Step 4: plot VAF histogram
% PlotVAFhistograms(IonI_vaf(1:9),HonI_vaf(1:9),WonI_vaf(1:9),'Isometric data | Within')
% PlotVAFhistograms(WonW_vaf(1:9),HonW_vaf(1:9),IonW_vaf(1:9),'Movement data | Within')
% PlotVAFhistograms_Spring(IonS_vaf(1:9),HonS_vaf(1:9),WonI_vaf(1:9),WonS_vaf(1:9),'Spring data | Within')
