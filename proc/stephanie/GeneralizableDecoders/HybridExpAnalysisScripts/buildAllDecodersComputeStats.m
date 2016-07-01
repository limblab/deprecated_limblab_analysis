% buildAllDecodersComputeStats

function [meanHonI_PC_mse stdHonI_PC_mse meanWonI_PC_mse stdWonI_PC_mse meanIonI_PC_mse stdIonI_PC_mse meanHonW_PC_mse stdHonW_PC_mse meanIonW_PC_mse stdIonW_PC_mse meanWonW_PC_mse stdWonW_PC_mse] = buildAllDecodersComputeStats(IsoBinned,WmBinned)

% Created 08-10-14
% Last modified: 7/7/15

% Step 1 | Merge cerebus files and sort
% Step 2 | Unmerge and make bdfs
% Step 3 | Make binned data files (50ms bins)
foldername = num2str(IsoBinned.meta.datetime(1:9));
numlags=10;

% Step 3.5 | Make sure you are using the same neurons for both files
badUnits = checkUnitGuides_sn(IsoBinned.neuronIDs,WmBinned.neuronIDs);
newIDs = setdiff(IsoBinned.neuronIDs, badUnits, 'rows');
if ~(isempty(badUnits))
    for i = length(badUnits(:,1))
        badUnitInd = find(WmBinned.neuronIDs(:,1) == badUnits(i,1) & WmBinned.neuronIDs(:,2) == badUnits(i,2));
        WmBinned.spikeratedata(:,badUnitInd) = [];
    end
    WmBinned.neuronIDs = newIDs; IsoBinned.neuronIDs = newIDs;
end

% Step 4 | Make hybrid file
[HybridFinal AlteredIsoFinal AlteredWMFinal IsoTrain IsoTest WmTrain WmTest] = makeHybridFileFixed(IsoBinned,WmBinned);

% % Step 5 | Make H variable for the EMGs of interest
[hybridH] = quickHybridDecoder(HybridFinal);
%BuildNormalModels
options=[]; options.PredEMGs = 1;
IsoModel = BuildModel(IsoTrain, options);
WmModel = BuildModel(WmTrain, options);
%HybridUnMod = BuildModel(HybridFinal, options);
Fakehybrid = BuildModel(HybridFinal, options);
Fakehybrid.H = hybridH;
Hmodel = Fakehybrid;

% Step 6 | Use H variable to make predictions
[HonIpred,~,HonIact]=predMIMO4(IsoTest.spikeratedata,hybridH,1,1,IsoTest.emgdatabin);
[HonWpred,~,HonWact]=predMIMO4(WmTest.spikeratedata,hybridH,1,1,WmTest.emgdatabin);

[IonIpred,~,IonIact]=predMIMO4(IsoTest.spikeratedata,IsoModel.H,1,1,IsoTest.emgdatabin);
[IonWpred,~,IonWact]=predMIMO4(WmTest.spikeratedata,IsoModel.H,1,1,WmTest.emgdatabin);

[WonWpred,~,WonWact]=predMIMO4(WmTest.spikeratedata,WmModel.H,1,1,WmTest.emgdatabin);
[WonIpred,~,WonIact]=predMIMO4(IsoTest.spikeratedata,WmModel.H,1,1,IsoTest.emgdatabin);

% Step 6.5 | Use multifold cross-validation to get predictions
[~, ~,~, ~,~,~, HonI_PC_vaf, HonI_PC_mse] = PeriodicR2_SN(Hmodel,AlteredIsoFinal,60);
[~, ~,~, ~,~,~, IonI_PC_vaf, IonI_PC_mse] = PeriodicR2_SN(IsoModel,AlteredIsoFinal,60);
[~, ~,~, ~,~,~, WonI_PC_vaf, WonI_PC_mse] = PeriodicR2_SN(WmModel,AlteredIsoFinal,60);
%|
[~, ~,~, ~,~,~, HonW_PC_vaf, HonW_PC_mse] = PeriodicR2_SN(Hmodel,AlteredWMFinal,60);
[~, ~,~, ~,~,~, WonW_PC_vaf, WonW_PC_mse] = PeriodicR2_SN(WmModel,AlteredWMFinal,60);
[~, ~,~, ~,~,~, IonW_PC_vaf, IonW_PC_mse] = PeriodicR2_SN(IsoModel,AlteredWMFinal,60);

meanHonI_PC_mse = mean(HonI_PC_mse); stdHonI_PC_mse = std(HonI_PC_mse);
meanIonI_PC_mse = mean(IonI_PC_mse); stdIonI_PC_mse = std(IonI_PC_mse);
meanWonI_PC_mse = mean(WonI_PC_mse); stdWonI_PC_mse = std(WonI_PC_mse);
meanHonW_PC_mse = mean(HonW_PC_mse); stdHonW_PC_mse = std(HonW_PC_mse);
meanWonW_PC_mse = mean(WonW_PC_mse); stdWonW_PC_mse = std(WonW_PC_mse);
meanIonW_PC_mse = mean(IonW_PC_mse); stdIonW_PC_mse = std(IonW_PC_mse);


%Step 7 | Calculate VAFs -----------------------------------------------------------
HonI_vaf = calculateVAF(HonIpred,HonIact);
HonW_vaf = calculateVAF(HonWpred,HonWact);
IonI_vaf = calculateVAF(IonIpred,IonIact);
WonW_vaf = calculateVAF(WonWpred,WonWact);
IonW_vaf = calculateVAF(IonWpred,IonWact);
WonI_vaf = calculateVAF(WonIpred,WonIact);
% 
% %Step 8 | Construct data struct ----------------------------------------------
VAFstruct.IonI_vaf = IonI_vaf;
VAFstruct.HonI_vaf = HonI_vaf;
VAFstruct.WonI_vaf = WonI_vaf;
VAFstruct.WonW_vaf = WonW_vaf;
VAFstruct.HonW_vaf = HonW_vaf;
VAFstruct.IonW_vaf = IonW_vaf;

  
end
