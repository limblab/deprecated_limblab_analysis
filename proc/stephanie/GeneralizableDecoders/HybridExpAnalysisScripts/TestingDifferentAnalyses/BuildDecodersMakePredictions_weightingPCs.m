%BuildDecodersMakePredictions

if exist('SprBinned')
    SpringFile = 1;
else
    SpringFile = 0;
end

% Step 1| Make sure you are using the same neurons for both files
badUnits = checkUnitGuides_sn(IsoBinned.neuronIDs,WmBinned.neuronIDs);
newIDs = setdiff(IsoBinned.neuronIDs, badUnits, 'rows');
IsoBinned.spikeguide = []; WmBinned.spikeguide = [];
if ~(isempty(badUnits))
    for i = 1:length(badUnits(:,1))
        badUnitInd = find(WmBinned.neuronIDs(:,1) == badUnits(i,1) & WmBinned.neuronIDs(:,2) == badUnits(i,2));
        WmBinned.spikeratedata(:,badUnitInd) = [];
         badUnitInd = find(IsoBinned.neuronIDs(:,1) == badUnits(i,1) & IsoBinned.neuronIDs(:,2) == badUnits(i,2));
         IsoBinned.spikeratedata(:,badUnitInd) = [];
    end
    WmBinned.neuronIDs = newIDs; IsoBinned.neuronIDs = newIDs;
end
if SpringFile == 1
    SprBinned.spikeguide =[];
    badUnits = checkUnitGuides_sn(WmBinned.neuronIDs,SprBinned.neuronIDs);
    newIDs = setdiff(WmBinned.neuronIDs, badUnits, 'rows');
    if ~(isempty(badUnits))
        for i = length(badUnits(:,1))
            badUnitInd = find(SprBinned.neuronIDs(:,1) == badUnits(i,1) & SprBinned.neuronIDs(:,2) == badUnits(i,2));
            SprBinned.spikeratedata(:,badUnitInd) = [];
        end
        SprBinned.neuronIDs = newIDs; SprBinned.neuronIDs = newIDs;
    end
end
    
    
% Step 2| Make hybrid file
[HybridFinal AlteredIsoFinal AlteredWMFinal IsoTrain IsoTest WmTrain WmTest] = makeHybridFileFixed(IsoBinned,WmBinned);
if SpringFile==1
    [~,~,~, SprTrain, SprTest] = makeHybridFileFixed(SprBinned,WmBinned);
end
% Step 3| Build Decoders
% Build hybrid decoder ---------------------------------------------------
options=[]; options.PredEMGs = 1;
[hybridH] = quickHybridDecoder(HybridFinal); % This gets you the hybrid weights
Fakehybrid = BuildModel(HybridFinal, options); % This gives you a structure for the hybrid decoder to later input into other functions
Fakehybrid.H = hybridH;
Hmodel = Fakehybrid; % Now you have the decoder variable structure with the correct H weights in it
%BuildNormalModels -------------------------------------------------------
IsoModel = BuildModel(IsoTrain, options);
WmModel = BuildModel(WmTrain, options);
if SpringFile == 1
    SprModel = BuildModel(SprTrain, options);
end

% Step 4| Make and save predictions for the indivdual muscles
foldlength = 60;
[HonI_R2, ~, HonIpred, HonI_vaf, HonI_mse, HonIactTrunk]=PeriodicR2_SN(Hmodel,IsoTest,foldlength);
[IonI_R2, ~, IonIpred, IonI_vaf, IonI_mse, IonIactTrunk]=PeriodicR2_SN(IsoModel,IsoTest,foldlength);
[WonI_R2, ~, WonIpred, WonI_vaf, WonI_mse, WonIactTrunk]=PeriodicR2_SN(WmModel,IsoTest,foldlength);

[HonW_R2, ~, HonWpred, HonW_vaf, HonW_mse, HonWactTrunk]=PeriodicR2_SN(Hmodel,WmTest,foldlength);
[IonW_R2, ~, IonWpred, IonW_vaf, IonW_mse, IonWactTrunk]=PeriodicR2_SN(IsoModel,WmTest,foldlength);
[WonW_R2, ~, WonWpred, WonW_vaf, WonW_mse, WonWactTrunk]=PeriodicR2_SN(WmModel,WmTest,foldlength);

if SpringFile==1
    [HonS_R2, ~, HonSpred, HonS_vaf, HonS_mse, HonSactTrunk]=PeriodicR2_SN(Hmodel,SprTest,foldlength);
    [IonS_R2, ~, IonSpred, IonS_vaf, IonS_mse, IonSactTrunk]=PeriodicR2_SN(IsoModel,SprTest,foldlength);
    [WonS_R2, ~, WonSpred, WonS_vaf, WonS_mse, WonSactTrunk]=PeriodicR2_SN(WmModel,SprTest,foldlength);
    [SonS_R2, ~, SonSpred, SonS_vaf, SonS_mse, SonSactTrunk]=PeriodicR2_SN(SprModel,SprTest,foldlength);
end

% Make VAF struct
VAFstruct.IonI_vaf = mean(IonI_vaf);
VAFstruct.HonI_vaf = mean(HonI_vaf);
VAFstruct.WonI_vaf = mean(WonI_vaf);
VAFstruct.WonW_vaf = mean(WonW_vaf);
VAFstruct.HonW_vaf = mean(HonW_vaf);
VAFstruct.IonW_vaf = mean(IonW_vaf);
if SpringFile == 1
    VAFstruct.SonS_vaf = mean(SonS_vaf);
    VAFstruct.HonS_vaf = mean(HonS_vaf);
    VAFstruct.IonS_vaf = mean(IonS_vaf);
    VAFstruct.WonS_vaf = mean(WonS_vaf);
end


% Step 5| PC Analysis
% 5a: Get and plot lambda values

% Get periodic mfxval values
foldlengthPC = 60;
[~, ~,~, ~,~,~, HonI_PC_vaf, HonI_PC_mse, ~, HonI_predPCs weightedAveVAF_HonI EigenVAF_HonI] = PeriodicR2_SNwPCs_weightingPCs(Hmodel,IsoTest,foldlengthPC);
[~, ~,~, ~,~,~, IonI_PC_vaf, IonI_PC_mse, ActualI_PCs, IonI_predPCs weightedAveVAF_IonI EigenVAF_IonI] = PeriodicR2_SNwPCs_weightingPCs(IsoModel,IsoTest,foldlengthPC);
[~, ~,~, ~,~,~, WonI_PC_vaf, WonI_PC_mse, ~, WonI_predPCs weightedAveVAF_WonI EigenVAF_WonI] = PeriodicR2_SNwPCs_weightingPCs(WmModel,IsoTest,foldlengthPC);

%|
[~, ~,~, ~,~,~, HonW_PC_vaf, HonW_PC_mse, ~, HonW_predPCs weightedAveVAF_HonW EigenVAF_HonW] = PeriodicR2_SNwPCs_weightingPCs(Hmodel,WmTest,foldlengthPC);
[~, ~,~, ~,~,~, WonW_PC_vaf, WonW_PC_mse, ActualW_PCs, WonW_predPCs weightedAveVAF_WonW EigenVAF_WonW] = PeriodicR2_SNwPCs_weightingPCs(WmModel,WmTest,foldlengthPC);
[~, ~,~, ~,~,~, IonW_PC_vaf, IonW_PC_mse, ~, IonW_predPCs weightedAveVAF_IonW EigenVAF_IonW] = PeriodicR2_SNwPCs_weightingPCs(IsoModel,WmTest,foldlengthPC);

if SpringFile == 1
    [~, ~,~, ~,~,~, HonS_PC_vaf, HonS_PC_mse, ~, HonS_predPCs weightedAveVAF_HonS EigenVAF_HonS] = PeriodicR2_SNwPCs_weightingPCs(Hmodel,SprTest,foldlengthPC);
    [~, ~,~, ~,~,~, WonS_PC_vaf, WonS_PC_mse, ~, WonS_predPCs weightedAveVAF_WonS EigenVAF_WonS] = PeriodicR2_SNwPCs_weightingPCs(WmModel,SprTest,foldlengthPC);
    [~, ~,~, ~,~,~, IonS_PC_vaf, IonS_PC_mse, ~, IonS_predPCs weightedAveVAF_IonS EigenVAF_IonS] = PeriodicR2_SNwPCs_weightingPCs(IsoModel,SprTest,foldlengthPC);
    [~, ~,~, ~,~,~, SonS_PC_vaf, SonS_PC_mse, ActualS_PCs, SonS_predPCs weightedAveVAF_SonS EigenVAF_SonS] = PeriodicR2_SNwPCs_weightingPCs(SprModel,SprTest,foldlengthPC);
end







