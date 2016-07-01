% GeneralizableAnalysisPapaScript
% This script is a "papa script" that builds decoders, saves actual and
% predicted EMG, and then makes and saves figures in the appropriate
% folders so that I can just open a folder and look at summary figures/data
% for that day.

clear
% Step 1a: Initialize folders
  monkeyname = 'Kevin';
  HybridEMGlist=Kevin_HybridData_EMGQualityInfo();
  BaseFolder = 'X:\limblab\User_folders\Stephanie\Data Analysis\Generalizability\Kevin\';
SubFolder={'05-15-15','05-19-15s','05-21-15s','05-25-15s','05-26-15s','06-03-15','06-04-15s','06-06-15','06-08-15'};
SubFolder = {'05-19-15s'};

% monkeyname = 'Jango';
% HybridEMGlist=Jango_HybridData_EMGQualityInfo();
% BaseFolder = 'X:\limblab\User_folders\Stephanie\Data Analysis\Generalizability\Jango\';
%   SubFolder = {'07-23-14','07-24-14s','07-25-14s','08-19-14s','08-20-14s',...
%      '08-21-14s','09-23-14s','09-25-14','09-26-14','10-10-14s','10-11-14s'...
%      '10-12-14s','11-06-14','11-07-14'};


for z = 1:length(SubFolder)
    % Step 1b:  Load data into workspace | Open folder directory for saving figs 
    cd([BaseFolder SubFolder{z} '\']);
    foldername = [BaseFolder SubFolder{z} '\'];
    hyphens = find(SubFolder{z}=='-'); SubFolder{z}(hyphens)=[];
    load([foldername 'HybridData_' monkeyname '_' SubFolder{z}(1,1:6)]);
    datalabel = SubFolder{z}(1:6);

% Initialize springfile variable
if SubFolder{z}(end)=='s'
    SpringFile = 1;
else SpringFile = 0;
end

% Find the right EMGlist
% Only keep EMG data for the 4 wrist muscles
EMGlistIndex = find(strcmp(HybridEMGlist,datalabel));
binnedData = IsoBinned;
IsoBinned.emgguide = cellstr(IsoBinned.emgguide); WmBinned.emgguide = cellstr(WmBinned.emgguide);
for j=1:length(HybridEMGlist{EMGlistIndex,2})
    EMGindtemp = strmatch(HybridEMGlist{EMGlistIndex,2}(j,:),(binnedData.emgguide)); emg_vector(j) = EMGindtemp(1);
end
IsoBinned.emgguide = IsoBinned.emgguide(emg_vector); IsoBinned.emgdatabin = IsoBinned.emgdatabin(:,emg_vector);
WmBinned.emgguide = WmBinned.emgguide(emg_vector); WmBinned.emgdatabin = WmBinned.emgdatabin(:,emg_vector);
if SpringFile == 1
    SprBinned.emgguide = cellstr(SprBinned.emgguide);
    SprBinned.emgguide = SprBinned.emgguide(emg_vector); SprBinned.emgdatabin = SprBinned.emgdatabin(:,emg_vector);
end

% Step 2: Make and save figures showing the EMGs for the 3 different tasks
save = 0;
%First List of EMGs
% TaskEMG_Isometric(IsoBinned,'FCU', 'FCR', 'ECU', 'ECR',save,foldername,'IsoEMGs1');
% TaskEMG_Movement(WmBinned,'FCU', 'FCR', 'ECU', 'ECR',save,foldername,'WmEMGs1');
% if SpringFile == 1
%     TaskEMG_Spring(SprBinned,'FCU', 'FCR', 'ECU', 'ECR',save,foldername,'SprEMGs1');
% end
% Second List of EMGs
% TaskEMG_Isometric(IsoBinned,'FDS', 'FDP', 'EDCu', 'EDCr',save,foldername,'IsoEMGs2');
% TaskEMG_Movement(WmBinned,'FDS', 'FDP', 'EDCu', 'EDCr',save,foldername,'WmEMGs2');
% if SpringFile == 1
%     TaskEMG_Spring(SprBinned,'FDS', 'FDP', 'EDCu', 'EDCr',save,foldername,'SprEMGs2');
% end

% Step 3: make and save predictions
BuildDecodersMakePredictions

% Get MSE stats
[meanHonI_PC_mse(z) meanIonI_PC_mse(z) meanWonI_PC_mse(z)     meanHonW_PC_mse(z) meanWonW_PC_mse(z) meanIonW_PC_mse(z)...
    stdHonI_PC_mse(z) stdIonI_PC_mse(z) stdWonI_PC_mse(z) stdHonW_PC_mse(z) stdWonW_PC_mse(z) stdIonW_PC_mse(z)] ...
    = Get_mse_meanandstd(HonI_PC_mse, IonI_PC_mse, WonI_PC_mse, HonW_PC_mse, WonW_PC_mse, IonW_PC_mse);
if SpringFile == 1
    [meanHonS_PC_mse(z) meanIonS_PC_mse(z) meanWonS_PC_mse(z) meanSonS_PC_mse(z) ...
        stdHonS_PC_mse(z) stdIonS_PC_mse(z) stdWonS_PC_mse(z) stdSonS_PC_mse(z)] ...
        = Get_mse_meanandstd_Spring(HonS_PC_mse, IonS_PC_mse, WonS_PC_mse, SonS_PC_mse);
end

% Plot individual EMG predictions
 PlotAllIsometricPredictions(IsoBinned,IsoTest,IonIactTrunk,HonIpred.preddatabin,IonIpred.preddatabin,WonIpred.preddatabin,VAFstruct,save,foldername, [monkeyname '_' datalabel 'IsoPredictions'])
 PlotAllMovementPredictions(WmBinned,WmTest,WonWactTrunk,HonWpred.preddatabin,WonWpred.preddatabin,IonWpred.preddatabin,VAFstruct,save,foldername, [monkeyname '_' datalabel 'WmPredictions'])
 if SpringFile == 1
     PlotAllSpringPredictions(SprBinned,SprTest,SonSactTrunk,SonSpred.preddatabin,HonSpred.preddatabin,IonSpred.preddatabin,WonSpred.preddatabin, VAFstruct,save,foldername, 'SprPredictions')
 end

 % Plot PC predictions
 PlotPCpredictions(ActualI_PCs(:,1), IonI_predPCs(:,1), HonI_predPCs(:,1), WonI_predPCs(:,1), mean(IonI_PC_vaf), mean(HonI_PC_vaf), mean(WonI_PC_vaf),save,foldername, [monkeyname ' | ' datalabel ' | IsoPCpredictions'])
 PlotPCpredictions(ActualW_PCs(:,1), WonW_predPCs(:,1), HonW_predPCs(:,1), IonW_predPCs(:,1), mean(WonW_PC_vaf), mean(HonW_PC_vaf), mean(IonW_PC_vaf),save,foldername, [monkeyname ' | ' datalabel ' | WmPCpredictions'])
 if SpringFile == 1
      PlotPCpredictions_Spring(ActualS_PCs(:,1), SonS_predPCs(:,1), HonS_predPCs(:,1), IonS_predPCs(:,1), WonS_predPCs(:,1), mean(WonS_PC_vaf), mean(HonS_PC_vaf), mean(IonS_PC_vaf),mean(WonS_PC_vaf),save,foldername, [monkeyname ' | ' datalabel ' | SprPCpredictions'])
 end
 
% Save workspace

% Plot VAF across days
IonI_PC_vaf_means(z) = mean(IonI_PC_vaf); IonI_PC_vaf_STEs(z) = std(IonI_PC_vaf)/sqrt(length(IonI_PC_vaf));
HonI_PC_vaf_means(z) = mean(HonI_PC_vaf); HonI_PC_vaf_STEs(z) = std(HonI_PC_vaf)/sqrt(length(HonI_PC_vaf));
WonI_PC_vaf_means(z) = mean(WonI_PC_vaf); WonI_PC_vaf_STEs(z) = std(WonI_PC_vaf)/sqrt(length(WonI_PC_vaf));
%
WonW_PC_vaf_means(z) = mean(WonW_PC_vaf); WonW_PC_vaf_STEs(z) = std(WonW_PC_vaf)/sqrt(length(WonW_PC_vaf));
HonW_PC_vaf_means(z) = mean(HonW_PC_vaf); HonW_PC_vaf_STEs(z) = std(HonW_PC_vaf)/sqrt(length(HonW_PC_vaf));
IonW_PC_vaf_means(z) = mean(IonW_PC_vaf); IonW_PC_vaf_STEs(z) = std(IonW_PC_vaf)/sqrt(length(IonW_PC_vaf));

if SpringFile == 1
SonS_PC_vaf_means(z) = mean(SonS_PC_vaf); SonS_PC_vaf_STEs(z) = std(SonS_PC_vaf)/sqrt(length(SonS_PC_vaf));
HonS_PC_vaf_means(z) = mean(HonS_PC_vaf); HonS_PC_vaf_STEs(z) = std(HonS_PC_vaf)/sqrt(length(HonS_PC_vaf));
WonS_PC_vaf_means(z) = mean(WonS_PC_vaf); WonS_PC_vaf_STEs(z) = std(WonS_PC_vaf)/sqrt(length(WonS_PC_vaf));
IonS_PC_vaf_means(z) = mean(IonS_PC_vaf); IonS_PC_vaf_STEs(z) = std(IonS_PC_vaf)/sqrt(length(IonS_PC_vaf));
end

% Clear variables
clearvars -except monkeyname BaseFolder SubFolder meanHonI_PC_mse meanIonI_PC_mse meanWonI_PC_mse meanHonW_PC_mse meanWonW_PC_mse meanIonW_PC_mse...
    stdHonI_PC_mse stdIonI_PC_mse stdWonI_PC_mse stdHonW_PC_mse stdWonW_PC_mse stdIonW_PC_mse meanHonS_PC_mse meanIonS_PC_mse meanWonS_PC_mse meanSonS_PC_mse ...
        stdHonS_PC_mse stdIonS_PC_mse stdWonS_PC_mse stdSonS_PC_mse z ...
    IonI_PC_vaf_means IonI_PC_vaf_STEs HonI_PC_vaf_means HonI_PC_vaf_STEs WonI_PC_vaf_means WonI_PC_vaf_STEs...
    WonW_PC_vaf_means WonW_PC_vaf_STEs HonW_PC_vaf_means HonW_PC_vaf_STEs IonW_PC_vaf_means IonW_PC_vaf_STEs...
    SonS_PC_vaf_means HonS_PC_vaf_means WonS_PC_vaf_means IonS_PC_vaf_means...
    SonS_PC_vaf_STEs HonS_PC_vaf_STEs WonS_PC_vaf_STEs IonS_PC_vaf_STEs HybridEMGlist

end

%close all
save =0;foldername = '';
for a=1:length(SubFolder)
    PlotVAFAcrossDays(a,1000,IonI_PC_vaf_means(a), IonI_PC_vaf_STEs(a),HonI_PC_vaf_means(a), HonI_PC_vaf_STEs(a), WonI_PC_vaf_means(a), WonI_PC_vaf_STEs(a), save,foldername, [monkeyname ' | ', ' Iso PC VAFs Across Days'])
    PlotVAFAcrossDays(a,1001,WonW_PC_vaf_means(a), WonW_PC_vaf_STEs(a),HonW_PC_vaf_means(a), HonW_PC_vaf_STEs(a), IonW_PC_vaf_means(a), IonW_PC_vaf_STEs(a), save,foldername, [monkeyname ' | ', ' Wm PC VAFs Across Days'])

    PlotVAFAcrossDays(a,1002,meanIonI_PC_mse(a), stdIonI_PC_mse(a), meanHonI_PC_mse(a), stdHonI_PC_mse(a), meanWonI_PC_mse(a), stdWonI_PC_mse(a), save,foldername, [monkeyname ' | ', ' Iso PC MSE Across Days'])
    PlotVAFAcrossDays(a,1003,meanWonW_PC_mse(a), stdWonW_PC_mse(a), meanHonW_PC_mse(a), stdHonW_PC_mse(a), meanIonW_PC_mse(a), stdIonW_PC_mse(a), save,foldername, [monkeyname ' | ', ' Wm PC MSE Across Days'])
end

    for a=1:length(SubFolder)
    PlotVAFAcrossDays_wSpring(a,1004,SonS_PC_vaf_means(a), SonS_PC_vaf_STEs(a),HonS_PC_vaf_means(a), HonS_PC_vaf_STEs(a), WonS_PC_vaf_means(a), WonS_PC_vaf_STEs(a), IonS_PC_vaf_means(a), IonS_PC_vaf_STEs(a),save,foldername, [monkeyname ' | ', 'Spring PC VAFs Across Days'])
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
