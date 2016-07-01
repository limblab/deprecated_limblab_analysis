%BuildDecodersMakePredictions_PredictingThePC
% January 2016

if exist('SprBinned')
    Spring = 1;
else
    Spring = 0;
end

% Step 1| Make sure you are using the same neurons for both files
badUnits = checkUnitGuides_sn(IsoBinned.neuronIDs,WmBinned.neuronIDs);
newIDs = setdiff(IsoBinned.neuronIDs, badUnits, 'rows');
if ~(isempty(badUnits))
    for i = length(badUnits(:,1))
        badUnitInd = find(WmBinned.neuronIDs(:,1) == badUnits(i,1) & WmBinned.neuronIDs(:,2) == badUnits(i,2));
        WmBinned.spikeratedata(:,badUnitInd) = [];
    end
    WmBinned.neuronIDs = newIDs; IsoBinned.neuronIDs = newIDs;
end

% Step 2 | Make the PC of the real muscles
% Create PCs for the Iso muscles and replace the muscle bin with PCs
 [Coeff,PCs,Latent,Tsquared,Explained,Mu] = pca(IsoBinned.emgdatabin);
 IsoBinned.emgdatabin = (PCs(:,1)+repmat(Mu(1),length(PCs(:,1)),1));
 IsoBinned.emgguide = 'PC1';
 % PCsWithMean = (PCs+repmat(Mu,length(PCs),1))*Coeff;
 % Create PCs for the Wm muscles and replace the muscle bin with PCs
 [Coeff,PCs,Latent,Tsquared,Explained,Mu] = pca(WmBinned.emgdatabin);
 WmBinned.emgdatabin = (PCs(:,1)+repmat(Mu(1),length(PCs(:,1)),1));
 % Create PCs for the Spr muscles and replace the muscle bin with PCs
 if Spring == 1
    [Coeff,PCs,Latent,Tsquared,Explained,Mu] = pca(SprBinned.emgdatabin);
    SprBinned.emgdatabin = (PCs(:,1)+repmat(Mu(1),length(PCs(:,1)),1));
 end

% Step 3| Make hybrid file
[HybridFinal AlteredIsoFinal AlteredWMFinal IsoTrain IsoTest WmTrain WmTest] = makeHybridFileFixed(IsoBinned,WmBinned);
if Spring == 1
    [SprybridFinal AlteredWmFinal_Spr AlteredSprFinal WmTrain WmTest SprTrain SprTest] = makeHybridFileFixed(WmBinned,SprBinned);
end

% Step 4 | Build decoders
options=[]; options.PredEMGs = 1;
[hybridH] = quickHybridDecoder(HybridFinal); % This gets you the hybrid weights
Fakehybrid = BuildModel(HybridFinal, options); % This gives you a structure for the hybrid decoder to later input into other functions
Fakehybrid.H = hybridH;
Hmodel = Fakehybrid; % Now you have the decoder variable structure with the correct H weights in it
%BuildNormalModels -------------------------------------------------------
IsoModel = BuildModel(IsoTrain, options);
WmModel = BuildModel(WmTrain, options);
if Spring == 1
    SprModel = BuildModel(SprTrain, options);
end

% Step 4| Make and save predictions for the indivdual muscles
foldlength = 30;
[HonI_R2, ~, HonIpred, HonI_PC_vaf, HonI_PC_mse, HonIactTrunk]=PeriodicR2_SN(Hmodel,IsoTest,foldlength);
[IonI_R2, ~, IonIpred, IonI_PC_vaf, IonI_PC_mse, IonIactTrunk]=PeriodicR2_SN(IsoModel,IsoTest,foldlength);
[WonI_R2, ~, WonIpred, WonI_PC_vaf, WonI_PC_mse, WonIactTrunk]=PeriodicR2_SN(WmModel,IsoTest,foldlength);

[HonW_R2, ~, HonWpred, HonW_PC_vaf, HonW_PC_mse, HonWactTrunk]=PeriodicR2_SN(Hmodel,WmTest,foldlength);
[IonW_R2, ~, IonWpred, IonW_PC_vaf, IonW_PC_mse, IonWactTrunk]=PeriodicR2_SN(IsoModel,WmTest,foldlength);
[WonW_R2, ~, WonWpred, WonW_PC_vaf, WonW_PC_mse, WonWactTrunk]=PeriodicR2_SN(WmModel,WmTest,foldlength);

if Spring==1
    [HonS_R2, ~, HonSpred, HonS_PC_vaf, HonS_PC_mse, HonSactTrunk]=PeriodicR2_SN(Hmodel,SprTest,foldlength);
    [IonS_R2, ~, IonSpred, IonS_PC_vaf, IonS_PC_mse, IonSactTrunk]=PeriodicR2_SN(IsoModel,SprTest,foldlength);
    [WonS_R2, ~, WonSpred, WonS_PC_vaf, WonS_PC_mse, WonSactTrunk]=PeriodicR2_SN(WmModel,SprTest,foldlength);
    [SonS_R2, ~, SonSpred, SonS_PC_vaf, SonS_PC_mse, SonSactTrunk]=PeriodicR2_SN(SprModel,SprTest,foldlength);
end

% Make VAF struct
VAFstruct.IonI_vaf = IonI_PC_vaf;
VAFstruct.HonI_vaf = HonI_PC_vaf;
VAFstruct.WonI_vaf = WonI_PC_vaf;
VAFstruct.WonW_vaf = WonW_PC_vaf;
VAFstruct.HonW_vaf = HonW_PC_vaf;
VAFstruct.IonW_vaf = IonW_PC_vaf;
if Spring == 1
    VAFstruct.SonS_vaf = SonS_PC_vaf;
    VAFstruct.HonS_vaf = HonS_PC_vaf;
    VAFstruct.IonS_vaf = IonS_PC_vaf;
    VAFstruct.WonS_vaf = WonS_PC_vaf;
end











