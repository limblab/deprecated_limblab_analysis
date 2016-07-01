%H3Kinematics

clear
% Step 1a: Initialize folders
%  monkeyname = 'Kevin';
%   BaseFolder = 'X:\limblab\User_folders\Stephanie\Data Analysis\Generalizability\Kevin\';
% SubFolder={'05-19-15s','05-21-15s','05-25-15s','05-26-15s','06-04-15s'};

 monkeyname = 'Jango';
  BaseFolder = 'Z:\limblab\User_folders\Stephanie\Data Analysis\Generalizability\Jango\';
 SubFolder = {'07-24-14s','07-25-14s','08-19-14s','08-20-14s',...
     '08-21-14s','09-23-14s','10-10-14s','10-11-14s'...
     '10-12-14s'};



for z = 1:length(SubFolder)
    
% Step 1:  Load data into workspace | Open folder directory for saving figs 
    cd([BaseFolder SubFolder{z} '\']);
    foldername = [BaseFolder SubFolder{z} '\'];
    hyphens = find(SubFolder{z}=='-'); SubFolder{z}(hyphens)=[];
    load([foldername 'HybridData_' monkeyname '_' SubFolder{z}(1,1:6)]);
    datalabel = SubFolder{z}(1:6);   
    
%Make sure you are using the same neurons for both files
badUnits = checkUnitGuides_sn(IsoBinned.neuronIDs,WmBinned.neuronIDs);
newIDs = setdiff(IsoBinned.neuronIDs, badUnits, 'rows');
if ~(isempty(badUnits))
    IsoBinned.spikeguide = []; WmBinned.spikeguide = [];
    for i = 1:length(badUnits(:,1))
        badUnitInd = find(WmBinned.neuronIDs(:,1) == badUnits(i,1) & WmBinned.neuronIDs(:,2) == badUnits(i,2));
        WmBinned.spikeratedata(:,badUnitInd) = [];
        badUnitInd = find(IsoBinned.neuronIDs(:,1) == badUnits(i,1) & IsoBinned.neuronIDs(:,2) == badUnits(i,2));
        IsoBinned.spikeratedata(:,badUnitInd) = [];
    end
    WmBinned.neuronIDs = newIDs; IsoBinned.neuronIDs = newIDs;
end

badUnits = checkUnitGuides_sn(WmBinned.neuronIDs,SprBinned.neuronIDs);
newIDs = setdiff(WmBinned.neuronIDs, badUnits, 'rows');
if ~(isempty(badUnits))
    SprBinned.spikeguide =[];
    for i = length(badUnits(:,1))
        badUnitInd = find(SprBinned.neuronIDs(:,1) == badUnits(i,1) & SprBinned.neuronIDs(:,2) == badUnits(i,2));
        SprBinned.spikeratedata(:,badUnitInd) = [];
    end
    SprBinned.neuronIDs = newIDs; SprBinned.neuronIDs = newIDs;
end


    
% Make hybrid file between wm and spr
[Hybrid3 IsoTrain IsoTest WmTrain WmTest SprTrain SprTest] = AppendIsoWmSprThirds(IsoBinned,WmBinned,SprBinned);

% Build model for kinmatics
options=[]; options.PredCursPos = 1;
%BuildNormalModels -------------------------------------------------------
Hmodel = BuildModel(Hybrid3,options);
SprModel = BuildModel(SprTrain, options);
WmModel = BuildModel(WmTrain, options);
IsoModel = BuildModel(IsoTrain, options);

% Make predictions of X force and get VAF/mse
foldlength = 60;
% Hybrid
[~,~,HonS_kin_predStruct, HonS_kin_vaf, HonS_kind_mse, HonS_kin_actTrunk] = PeriodicR2_SN(Hmodel,SprTest,foldlength);
[~,~,HonW_kin_predStruct, HonW_kin_vaf, HonW_kind_mse, HonW_kin_actTrunk] = PeriodicR2_SN(Hmodel,WmTest,foldlength);
[~,~,HonI_kin_predStruct, HonI_kin_vaf, HonI_kind_mse, HonI_kin_actTrunk] = PeriodicR2_SN(Hmodel,IsoTest,foldlength);
% Within
[~,~,SonS_kin_predStruct, SonS_kin_vaf, SonS_kind_mse, SonS_kin_actTrunk] = PeriodicR2_SN(SprModel,SprTest,foldlength);
[~,~,WonW_kin_predStruct, WonW_kin_vaf, WonW_kind_mse, WonW_kin_actTrunk] = PeriodicR2_SN(WmModel,WmTest,foldlength);
[~,~,IonI_kin_predStruct, IonI_kin_vaf, IonI_kind_mse, IonI_kin_actTrunk] = PeriodicR2_SN(IsoModel,IsoTest,foldlength);
% Across
[~,~,WonS_kin_predStruct, WonS_kin_vaf, WonS_kind_mse, WonS_kin_actTrunk] = PeriodicR2_SN(WmModel,SprTest,foldlength);
[~,~,WonI_kin_predStruct, WonI_kin_vaf, WonI_kind_mse, WonI_kin_actTrunk] = PeriodicR2_SN(WmModel,IsoTest,foldlength);
[~,~,SonW_kin_predStruct, SonW_kin_vaf, SonW_kind_mse, SonW_kin_actTrunk] = PeriodicR2_SN(SprModel,WmTest,foldlength);
[~,~,SonI_kin_predStruct, SonI_kin_vaf, SonI_kind_mse, SonI_kin_actTrunk] = PeriodicR2_SN(SprModel,IsoTest,foldlength);
[~,~,IonW_kin_predStruct, IonW_kin_vaf, IonW_kind_mse, IonW_kin_actTrunk] = PeriodicR2_SN(IsoModel,WmTest,foldlength);
[~,~,IonS_kin_predStruct, IonS_kin_vaf, IonS_kind_mse, IonS_kin_actTrunk] = PeriodicR2_SN(IsoModel,SprTest,foldlength);

if z ==1
    AllHonS_kin_vaf = HonS_kin_vaf; AllHonW_kin_vaf = HonW_kin_vaf; AllHonI_kin_vaf = HonI_kin_vaf;
    AllSonS_kin_vaf = SonS_kin_vaf; AllWonW_kin_vaf = WonW_kin_vaf; AllIonI_kin_vaf = IonI_kin_vaf;
    AllWonS_kin_vaf = WonS_kin_vaf; AllWonI_kin_vaf = WonI_kin_vaf;
    AllSonW_kin_vaf = SonW_kin_vaf; AllSonI_kin_vaf = SonI_kin_vaf;
    AllIonW_kin_vaf = IonW_kin_vaf; AllIonS_kin_vaf = IonS_kin_vaf;
else
    AllHonS_kin_vaf = [AllHonS_kin_vaf; HonS_kin_vaf];
    AllHonW_kin_vaf = [AllHonW_kin_vaf; HonW_kin_vaf];
    AllHonI_kin_vaf = [AllHonI_kin_vaf; HonI_kin_vaf];
    AllSonS_kin_vaf = [AllSonS_kin_vaf; SonS_kin_vaf];
    AllWonW_kin_vaf = [AllWonW_kin_vaf; WonW_kin_vaf];
    AllIonI_kin_vaf = [AllIonI_kin_vaf; IonI_kin_vaf];
    AllWonS_kin_vaf = [AllWonS_kin_vaf; WonS_kin_vaf];
    AllWonI_kin_vaf = [AllWonI_kin_vaf; WonI_kin_vaf];
    AllSonW_kin_vaf = [AllSonW_kin_vaf; SonW_kin_vaf];
    AllSonI_kin_vaf = [AllSonI_kin_vaf; SonI_kin_vaf];
    AllIonW_kin_vaf = [AllIonW_kin_vaf; IonW_kin_vaf];
    AllIonS_kin_vaf = [AllIonS_kin_vaf; IonS_kin_vaf];
end

% Hybrid vaf means
HonS_kin_vaf_means(z) = mean(HonS_kin_vaf(:,1)); HonS_kin_vaf_STEs(z) = std(HonS_kin_vaf(:,1))/sqrt(length(HonS_kin_vaf(:,1)));
HonW_kin_vaf_means(z) = mean(HonW_kin_vaf(:,1)); HonW_kin_vaf_STEs(z) = std(HonW_kin_vaf(:,1))/sqrt(length(HonW_kin_vaf(:,1)));
HonI_kin_vaf_means(z) = mean(HonI_kin_vaf(:,1)); HonI_kin_vaf_STEs(z) = std(HonI_kin_vaf(:,1))/sqrt(length(HonI_kin_vaf(:,1)));
% Within vaf means
SonS_kin_vaf_means(z) = mean(SonS_kin_vaf(:,1)); SonS_kin_vaf_STEs(z) = std(SonS_kin_vaf(:,1))/sqrt(length(SonS_kin_vaf(:,1)));
WonW_kin_vaf_means(z) = mean(WonW_kin_vaf(:,1)); WonW_kin_vaf_STEs(z) = std(WonW_kin_vaf(:,1))/sqrt(length(WonW_kin_vaf(:,1)));
IonI_kin_vaf_means(z) = mean(IonI_kin_vaf(:,1)); IonI_kin_vaf_STEs(z) = std(IonI_kin_vaf(:,1))/sqrt(length(IonI_kin_vaf(:,1)));
% Across vaf means
WonS_kin_vaf_means(z) = mean(WonS_kin_vaf(:,1)); WonS_kin_vaf_STEs(z) = std(WonS_kin_vaf(:,1))/sqrt(length(WonS_kin_vaf(:,1)));
WonI_kin_vaf_means(z) = mean(WonI_kin_vaf(:,1)); WonI_kin_vaf_STEs(z) = std(WonI_kin_vaf(:,1))/sqrt(length(WonI_kin_vaf(:,1)));
SonW_kin_vaf_means(z) = mean(SonW_kin_vaf(:,1)); SonW_kin_vaf_STEs(z) = std(SonW_kin_vaf(:,1))/sqrt(length(SonW_kin_vaf(:,1)));
SonI_kin_vaf_means(z) = mean(SonI_kin_vaf(:,1)); SonI_kin_vaf_STEs(z) = std(SonI_kin_vaf(:,1))/sqrt(length(SonI_kin_vaf(:,1)));
IonW_kin_vaf_means(z) = mean(IonW_kin_vaf(:,1)); IonW_kin_vaf_STEs(z) = std(IonW_kin_vaf(:,1))/sqrt(length(IonW_kin_vaf(:,1)));
IonS_kin_vaf_means(z) = mean(IonS_kin_vaf(:,1)); IonS_kin_vaf_STEs(z) = std(IonS_kin_vaf(:,1))/sqrt(length(IonS_kin_vaf(:,1)));




clearvars -except monkeyname BaseFolder SubFolder HonS_kin_vaf_means...
    HonW_kin_vaf_means SonS_kin_vaf_means WonW_kin_vaf_means WonS_kin_vaf_means...
    SonW_kin_vaf_means HonS_kin_vaf_STEs HonW_kin_vaf_STEs SonS_kin_vaf_STEs...
    WonW_kin_vaf_STEs WonS_kin_vaf_STEs  SonW_kin_vaf_STEs ...
    AllHonS_kin_vaf AllHonW_kin_vaf AllHonI_kin_vaf...
    AllSonS_kin_vaf AllWonW_kin_vaf AllIonI_kin_vaf...
    AllWonS_kin_vaf AllWonI_kin_vaf AllSonW_kin_vaf AllSonI_kin_vaf...
    AllIonW_kin_vaf AllIonS_kin_vaf...



end

[meanAllHonS_kin_vaf, steAllHonS_kin_vaf] = FindMeanAndSTE(AllHonS_kin_vaf(:,1));
[meanAllHonW_kin_vaf, steAllHonW_kin_vaf] = FindMeanAndSTE(AllHonW_kin_vaf(:,1));
[meanAllHonI_kin_vaf, steAllHonI_kin_vaf] = FindMeanAndSTE(AllHonI_kin_vaf(:,1));
[meanAllSonS_kin_vaf, steAllSonS_kin_vaf] = FindMeanAndSTE(AllSonS_kin_vaf(:,1));
[meanAllWonW_kin_vaf, steAllWonW_kin_vaf] = FindMeanAndSTE(AllWonW_kin_vaf(:,1));
[meanAllIonI_kin_vaf, steAllIonI_kin_vaf] = FindMeanAndSTE(AllIonI_kin_vaf(:,1));
[meanAllWonS_kin_vaf, steAllWonS_kin_vaf] = FindMeanAndSTE(AllWonS_kin_vaf(:,1));
[meanAllWonI_kin_vaf, steAllWonI_kin_vaf] = FindMeanAndSTE(AllWonI_kin_vaf(:,1));
[meanAllSonW_kin_vaf, steAllSonW_kin_vaf] = FindMeanAndSTE(AllSonW_kin_vaf(:,1));
[meanAllSonI_kin_vaf, steAllSonI_kin_vaf] = FindMeanAndSTE(AllSonI_kin_vaf(:,1));
[meanAllIonS_kin_vaf, steAllIonS_kin_vaf] = FindMeanAndSTE(AllIonS_kin_vaf(:,1));
[meanAllIonW_kin_vaf, steAllIonW_kin_vaf] = FindMeanAndSTE(AllIonW_kin_vaf(:,1));


figure; hold on;
h0 = errorbar(1,meanAllHonI_kin_vaf, steAllHonI_kin_vaf, steAllHonI_kin_vaf,'.c');
h1 = errorbar(1,meanAllIonI_kin_vaf, steAllIonI_kin_vaf, steAllIonI_kin_vaf,'.b');
h2 = errorbar(1,meanAllWonI_kin_vaf, steAllWonI_kin_vaf, steAllWonI_kin_vaf,'.r');
h3 = errorbar(1,meanAllSonI_kin_vaf, steAllSonI_kin_vaf, steAllSonI_kin_vaf,'.m');

h4 = errorbar(2,meanAllHonW_kin_vaf, steAllHonW_kin_vaf, steAllHonW_kin_vaf,'.c');
h5 = errorbar(2,meanAllWonW_kin_vaf, steAllWonW_kin_vaf, steAllWonW_kin_vaf,'.b');
h6 = errorbar(2,meanAllSonW_kin_vaf, steAllSonW_kin_vaf, steAllSonW_kin_vaf,'.m');
h7 = errorbar(2,meanAllIonW_kin_vaf, steAllIonW_kin_vaf, steAllIonW_kin_vaf,'.k');

h8 = errorbar(3,meanAllHonS_kin_vaf, steAllHonS_kin_vaf, steAllHonS_kin_vaf,'.c');
h9 = errorbar(3,meanAllSonS_kin_vaf, steAllSonS_kin_vaf, steAllSonS_kin_vaf,'.b');
h10 = errorbar(3,meanAllWonS_kin_vaf, steAllWonS_kin_vaf, steAllWonS_kin_vaf,'.r');
h11 = errorbar(3,meanAllIonS_kin_vaf, steAllIonS_kin_vaf, steAllIonS_kin_vaf,'.k');


set([h0 h1 h2 h3 h4 h5 h6 h7 h8 h9 h10 h11],'MarkerSize',20);
set([h0 h1 h2 h3 h4 h5 h6 h7 h8 h9 h10 h11],'LineWidth',1)
xlim=([.5 3.5]);
ylim([-2 1])
ax=gca;
ax.XTickLabel = {'','Iso','','Movem','','Spring',''};
title('Kinematic predictions')



% Plot data across days
% save =0;foldername = '';
% for a=1:length(SubFolder)
%  PlotVAFAcrossDays(a,3001,WonW_kin_vaf_means(a), WonW_kin_vaf_STEs(a), HonW_kin_vaf_means(a), HonW_kin_vaf_STEs(a), SonW_kin_vaf_means(a), SonW_kin_vaf_STEs(a), save,foldername, [monkeyname ' | ', ' Movement Kinematics VAFs Across Days'])
%  PlotVAFAcrossDays(a,3002,SonS_kin_vaf_means(a), SonS_kin_vaf_STEs(a), HonS_kin_vaf_means(a), HonS_kin_vaf_STEs(a), WonS_kin_vaf_means(a), WonS_kin_vaf_STEs(a), save,foldername, [monkeyname ' | ', ' Spring Kinematics VAFs Across Days'])
% end
