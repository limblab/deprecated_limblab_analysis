%KinematicsVsKinetics_IsoandMoveFeb252016

clear
% Step 1a: Initialize folders
monkeyname = 'Kevin';
 BaseFolder = 'X:\limblab\User_folders\Stephanie\Data Analysis\Generalizability\Kevin\';
 SubFolder={'05-15-15','05-19-15s','05-21-15s','05-25-15s','05-26-15s','06-03-15','06-04-15s','06-06-15','06-08-15'};

%  monkeyname = 'Jango';
%  BaseFolder = 'X:\limblab\User_folders\Stephanie\Data Analysis\Generalizability\Jango\';
%  SubFolder = {'07-23-14','07-24-14s','07-25-14s','08-19-14s','08-20-14s',...
%      '08-21-14s','09-23-14s','09-25-14','09-26-14','10-10-14s','10-11-14s'...
%      '10-12-14s','11-06-14','11-07-14'};

for z = 1:length(SubFolder)
    
% Step 1:  Load data into workspace | Open folder directory for saving figs 
    cd([BaseFolder SubFolder{z} '\']);
    foldername = [BaseFolder SubFolder{z} '\'];
    hyphens = find(SubFolder{z}=='-'); SubFolder{z}(hyphens)=[];
    load([foldername 'HybridData_' monkeyname '_' SubFolder{z}(1,1:6)]);
    datalabel = SubFolder{z}(1:6);   
    
 
% Make sure you are using the same neurons for both files
badUnits = checkUnitGuides_sn(IsoBinned.neuronIDs,WmBinned.neuronIDs);
newIDs = setdiff(IsoBinned.neuronIDs, badUnits, 'rows');
IsoBinned.spikeguide = []; WmBinned.spikeguide = [];
if ~(isempty(badUnits))
    for q = 1:length(badUnits(:,1))
        badUnitInd = find(WmBinned.neuronIDs(:,1) == badUnits(q,1) & WmBinned.neuronIDs(:,2) == badUnits(q,2));
        WmBinned.spikeratedata(:,badUnitInd) = [];
         badUnitInd = find(IsoBinned.neuronIDs(:,1) == badUnits(q,1) & IsoBinned.neuronIDs(:,2) == badUnits(q,2));
         IsoBinned.spikeratedata(:,badUnitInd) = [];
    end
    WmBinned.neuronIDs = newIDs; IsoBinned.neuronIDs = newIDs;
end
    
% Make hybrid file between iso and wm and alter iso position so it's just 0
IsoBinnedZeroPos = IsoBinned; IsoBinnedZeroPos.cursorposbin = .001*ones(length(IsoBinned.cursorposbin),2);
[ComboFinal AlteredIsoFinal AlteredWMFinal IsoTrain IsoTest WmTrain WmTest] = makeHybridFileFixed(IsoBinnedZeroPos,WmBinned);


% Build model for kinmatics
options=[]; options.PredCursPos = 1;
%BuildNormalModels -------------------------------------------------------
Cmodel = BuildModel(ComboFinal,options);
IsoModel = BuildModel(IsoTrain, options);
WmModel = BuildModel(WmTrain, options);

% Make predictions of X force and get VAF/mse
foldlength = 30;
% Hybrid
[~,~,ConI_kin_predStruct, ConI_kin_vaf, ConI_kind_mse, ConI_kin_actTrunk] = PeriodicR2_SN(Cmodel,IsoTest,foldlength);
[~,~,ConW_kin_predStruct, ConW_kin_vaf, ConW_kind_mse, ConW_kin_actTrunk] = PeriodicR2_SN(Cmodel,WmTest,foldlength);
% Within
[~,~,IonI_kin_predStruct, IonI_kin_vaf, IonI_kind_mse, IonI_kin_actTrunk] = PeriodicR2_SN(IsoModel,IsoTest,foldlength);
[~,~,WonW_kin_predStruct, WonW_kin_vaf, WonW_kind_mse, WonW_kin_actTrunk] = PeriodicR2_SN(WmModel,WmTest,foldlength);
% Across
[~,~,WonI_kin_predStruct, WonI_kin_vaf, WonI_kind_mse, WonI_kin_actTrunk] = PeriodicR2_SN(WmModel,IsoTest,foldlength);
[~,~,IonW_kin_predStruct, IonW_kin_vaf, IonW_kind_mse, IonW_kin_actTrunk] = PeriodicR2_SN(IsoModel,WmTest,foldlength);

% Hybrid vaf means
ConI_kin_vaf_means(z) = mean(ConI_kin_vaf(:,1)); ConI_kin_vaf_STEs(z) = std(ConI_kin_vaf(:,1))/sqrt(length(ConI_kin_vaf(:,1)));
ConW_kin_vaf_means(z) = mean(ConW_kin_vaf(:,1)); ConW_kin_vaf_STEs(z) = std(ConW_kin_vaf(:,1))/sqrt(length(ConW_kin_vaf(:,1)));
% Within vaf means
IonI_kin_vaf_means(z) = mean(IonI_kin_vaf(:,1)); IonI_kin_vaf_STEs(z) = std(IonI_kin_vaf(:,1))/sqrt(length(IonI_kin_vaf(:,1)));
WonW_kin_vaf_means(z) = mean(WonW_kin_vaf(:,1)); WonW_kin_vaf_STEs(z) = std(WonW_kin_vaf(:,1))/sqrt(length(WonW_kin_vaf(:,1)));
% Across vaf means
WonI_kin_vaf_means(z) = mean(WonI_kin_vaf(:,1)); WonI_kin_vaf_STEs(z) = std(WonI_kin_vaf(:,1))/sqrt(length(WonI_kin_vaf(:,1)));
IonW_kin_vaf_means(z) = mean(IonW_kin_vaf(:,1)); IonW_kin_vaf_STEs(z) = std(IonW_kin_vaf(:,1))/sqrt(length(IonW_kin_vaf(:,1)));


    end
 

% Make hybrid file between iso and wm
% Need to make the cursorpos for the iso portions 0. This means make a new
% 'makehybridfile' script


clearvars -except monkeyname BaseFolder SubFolder ConI_kin_vaf_means...
    ConW_kin_vaf_means IonI_kin_vaf_means WonW_kin_vaf_means WonI_kin_vaf_means...
    SonW_kin_vaf_means ConI_kin_vaf_STEs ConW_kin_vaf_STEs IonI_kin_vaf_STEs...
    WonW_kin_vaf_STEs WonI_kin_vaf_STEs  SonW_kin_vaf_STEs...
    IonW_kin_vaf_means IonW_kin_vaf_STEs



end

% Plot data across days
save =0;foldername = '';
for a=1:length(SubFolder)
 PlotVAFAcrossDays(a,3001,WonW_kin_vaf_means(a), WonW_kin_vaf_STEs(a), ConW_kin_vaf_means(a), ConW_kin_vaf_STEs(a), IonW_kin_vaf_means(a), IonW_kin_vaf_STEs(a), save,foldername, [monkeyname ' | ', ' Movement Kinematics I&M VAFs Across Days'])
 PlotVAFAcrossDays(a,3002,IonI_kin_vaf_means(a), IonI_kin_vaf_STEs(a), ConI_kin_vaf_means(a), ConI_kin_vaf_STEs(a), WonI_kin_vaf_means(a), WonI_kin_vaf_STEs(a), save,foldername, [monkeyname ' | ', ' Iso Kinematics I&M VAFs Across Days'])
end
