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
    [Hybrid3] = HybridFile3Task(IsoBinned,WmBinned,SprBinned);
end

% Step 3| Build Decoders
% Build hybrid decoder ---------------------------------------------------
options=[]; options.PredEMGs = 1;
[hybridH] = quickHybridDecoder(HybridFinal); % This gets you the hybrid weights
Fakehybrid = BuildModel(HybridFinal, options); % This gives you a structure for the hybrid decoder to later input into other functions
Fakehybrid.H = hybridH;
Hmodel = Fakehybrid; % Now you have the decoder variable structure with the correct H weights in it
% Build H3 decoder --------------------------------------------------------
options=[]; options.PredEMGs = 1;
[hybridH3] = quickHybridDecoder(Hybrid3); % This gets you the hybrid weights
Fakehybrid3 = BuildModel(Hybrid3, options); % This gives you a structure for the hybrid decoder to later input into other functions
Fakehybrid3.H = hybridH3;
H3model = Fakehybrid3; % Now you have the decoder variable structure with the correct H weights in it
%BuildNormalModels -------------------------------------------------------
IsoModel = BuildModel(IsoTrain, options);
WmModel = BuildModel(WmTrain, options);
if SpringFile == 1
    SprModel = BuildModel(SprTrain, options);
end

% Step 4| Make and save predictions for the indivdual muscles
foldlength = 60;
[HonI_R2, ~, HonIpred, HonI_vaf, HonI_mse, HonIactTrunk HonI_indivVAF]=OneDecoderOnManyFolds(Hmodel,IsoTest,foldlength);
[IonI_R2, ~, IonIpred, IonI_vaf, IonI_mse, IonIactTrunk IonI_indivVAF]=OneDecoderOnManyFolds(IsoModel,IsoTest,foldlength);
[WonI_R2, ~, WonIpred, WonI_vaf, WonI_mse, WonIactTrunk WonI_indivVAF]=OneDecoderOnManyFolds(WmModel,IsoTest,foldlength);

[HonW_R2, ~, HonWpred, HonW_vaf, HonW_mse, HonWactTrunk HonW_indivVAF]=OneDecoderOnManyFolds(Hmodel,WmTest,foldlength);
[IonW_R2, ~, IonWpred, IonW_vaf, IonW_mse, IonWactTrunk IonW_indivVAF]=OneDecoderOnManyFolds(IsoModel,WmTest,foldlength);
[WonW_R2, ~, WonWpred, WonW_vaf, WonW_mse, WonWactTrunk WonW_indivVAF]=OneDecoderOnManyFolds(WmModel,WmTest,foldlength);

if SpringFile==1
    [HonS_R2, ~, HonSpred, HonS_vaf, HonS_mse, HonSactTrunk HonS_indivVAF]=OneDecoderOnManyFolds(Hmodel,SprTest,foldlength);
    [IonS_R2, ~, IonSpred, IonS_vaf, IonS_mse, IonSactTrunk IonS_indivVAF]=OneDecoderOnManyFolds(IsoModel,SprTest,foldlength);
    [WonS_R2, ~, WonSpred, WonS_vaf, WonS_mse, WonSactTrunk WonS_indivVAF]=OneDecoderOnManyFolds(WmModel,SprTest,foldlength);
    [SonS_R2, ~, SonSpred, SonS_vaf, SonS_mse, SonSactTrunk SonS_indivVAF]=OneDecoderOnManyFolds(SprModel,SprTest,foldlength);
    
    % Test H3
     [H3onW_R2, ~, H3onWpred, H3onW_vaf, H3onW_mse, H3onWactTrunk H3onW_indivVAF]=OneDecoderOnManyFolds(H3model,WmTest,foldlength);
     [H3onI_R2, ~, H3onIpred, H3onI_vaf, H3onI_mse, H3onIactTrunk H3onI_indivVAF]=OneDecoderOnManyFolds(H3model,IsoTest,foldlength);
end

% Make VAF struct
VAFstruct.IonI_vaf_mean = mean(IonI_vaf);
VAFstruct.HonI_vaf_mean = mean(HonI_vaf);
VAFstruct.WonI_vaf_mean = mean(WonI_vaf);
VAFstruct.WonW_vaf_mean = mean(WonW_vaf);
VAFstruct.HonW_vaf_mean = mean(HonW_vaf);
VAFstruct.IonW_vaf_mean = mean(IonW_vaf);
VAFstruct.IonI_vaf_ste = std(IonI_vaf)/sqrt(length(IonI_vaf));
VAFstruct.HonI_vaf_ste = std(HonI_vaf)/sqrt(length(HonI_vaf));
VAFstruct.WonI_vaf_ste = std(WonI_vaf)/sqrt(length(WonI_vaf));
VAFstruct.WonW_vaf_ste = std(WonW_vaf)/sqrt(length(WonW_vaf));
VAFstruct.HonW_vaf_ste = std(HonW_vaf)/sqrt(length(HonW_vaf));
VAFstruct.IonW_vaf_ste = std(IonW_vaf)/sqrt(length(IonW_vaf));
if SpringFile==0
    VAFstruct.SonS_vaf_mean = [];
    VAFstruct.HonS_vaf_mean = [];
    VAFstruct.IonS_vaf_mean = [];
    VAFstruct.WonS_vaf_mean = [];
    VAFstruct.SonS_vaf_ste = [];
    VAFstruct.HonS_vaf_ste = [];
    VAFstruct.IonS_vaf_ste = [];
    VAFstruct.WonS_vaf_ste = [];
else
    VAFstruct.SonS_vaf_mean = mean(SonS_vaf);
    VAFstruct.HonS_vaf_mean = mean(HonS_vaf);
    VAFstruct.IonS_vaf_mean = mean(IonS_vaf);
    VAFstruct.WonS_vaf_mean = mean(WonS_vaf);
    VAFstruct.SonS_vaf_ste = std(SonS_vaf)/sqrt(length(SonS_vaf));
    VAFstruct.HonS_vaf_ste = std(HonS_vaf)/sqrt(length(HonS_vaf));
    VAFstruct.IonS_vaf_ste = std(IonS_vaf)/sqrt(length(IonS_vaf));
    VAFstruct.WonS_vaf_ste = std(WonS_vaf)/sqrt(length(WonS_vaf));
end


% Make VAF struct for individual neuron preds
IndivVAFstruct.IonI_vaf_mean = mean(IonI_indivVAF);
IndivVAFstruct.HonI_vaf_mean = mean(HonI_indivVAF);
IndivVAFstruct.WonI_vaf_mean = mean(WonI_indivVAF);
IndivVAFstruct.WonW_vaf_mean = mean(WonW_indivVAF);
IndivVAFstruct.HonW_vaf_mean = mean(HonW_indivVAF);
IndivVAFstruct.IonW_vaf_mean = mean(IonW_indivVAF);
IndivVAFstruct.IonI_vaf_ste = std(IonI_indivVAF)/sqrt(length(IonI_indivVAF));
IndivVAFstruct.HonI_vaf_ste = std(HonI_indivVAF)/sqrt(length(HonI_indivVAF));
IndivVAFstruct.WonI_vaf_ste = std(WonI_indivVAF)/sqrt(length(WonI_indivVAF));
IndivVAFstruct.WonW_vaf_ste = std(WonW_indivVAF)/sqrt(length(WonW_indivVAF));
IndivVAFstruct.HonW_vaf_ste = std(HonW_indivVAF)/sqrt(length(HonW_indivVAF));
IndivVAFstruct.IonW_vaf_ste = std(IonW_indivVAF)/sqrt(length(IonW_indivVAF));
if SpringFile==0
    IndivVAFstruct.SonS_vaf_mean = [];
    IndivVAFstruct.HonS_vaf_mean = [];
    IndivVAFstruct.IonS_vaf_mean = [];
    IndivVAFstruct.WonS_vaf_mean = [];
    IndivVAFstruct.SonS_vaf_ste = [];
    IndivVAFstruct.HonS_vaf_ste = [];
    IndivVAFstruct.IonS_vaf_ste = [];
    IndivVAFstruct.WonS_vaf_ste = [];
else
    IndivVAFstruct.SonS_vaf_mean = mean(SonS_indivVAF);
    IndivVAFstruct.HonS_vaf_mean = mean(HonS_indivVAF);
    IndivVAFstruct.IonS_vaf_mean = mean(IonS_indivVAF);
    IndivVAFstruct.WonS_vaf_mean = mean(WonS_indivVAF);
    IndivVAFstruct.SonS_vaf_ste = std(SonS_indivVAF)/sqrt(length(SonS_indivVAF));
    IndivVAFstruct.HonS_vaf_ste = std(HonS_indivVAF)/sqrt(length(HonS_indivVAF));
    IndivVAFstruct.IonS_vaf_ste = std(IonS_indivVAF)/sqrt(length(IonS_indivVAF));
    IndivVAFstruct.WonS_vaf_ste = std(WonS_indivVAF)/sqrt(length(WonS_indivVAF));
end




