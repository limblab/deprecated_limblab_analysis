%BuildDecodersMakePredictions

if exist('SprBinned')
    SpringFile = 1;
else
    SpringFile = 0;
end

% Step 1| Make sure you are using the same neurons for both files
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
if SpringFile == 1
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
end


% Step 2| Make hybrid file
%[HybridFinal AlteredIsoFinal AlteredWMFinal IsoTrain IsoTest WmTrain WmTest] = makeHybridFileFixed(IsoBinned,WmBinned);
[HybridFinal IsoTrain IsoTest WmTrain WmTest]= AppendIsoWmHalves(IsoBinned,WmBinned);
if SpringFile==1
    %[~,~,~, SprTrain, SprTest] = makeHybridFileFixed(SprBinned,WmBinned);
    [~,~,~, SprTrain, SprTest] = makeHybridFileFixed(SprBinned,WmBinned);
   % [Hybrid3] = HybridFile3Task(IsoBinned,WmBinned,SprBinned);
    [Hybrid3] = AppendIsoWmSprThirds(IsoBinned,WmBinned,SprBinned);
end

% Step 3| Build Decoders
% Build hybrid decoder ---------------------------------------------------
options=[]; options.PredEMGs = 1;
[hybridH] = quickHybridDecoder(HybridFinal); % This gets you the hybrid weights
Fakehybrid = BuildModel(HybridFinal, options); % This gives you a structure for the hybrid decoder to later input into other functions
Fakehybrid.H = hybridH;
Hmodel = Fakehybrid; % Now you have the decoder variable structure with the correct H weights in it
% Build H3 decoder --------------------------------------------------------
if SpringFile==1
options=[]; options.PredEMGs = 1;
[hybridH3] = quickHybridDecoder(Hybrid3); % This gets you the hybrid weights
Fakehybrid3 = BuildModel(Hybrid3, options); % This gives you a structure for the hybrid decoder to later input into other functions
Fakehybrid3.H = hybridH3;
H3model = Fakehybrid3; % Now you have the decoder variable structure with the correct H weights in it
end
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
     [H3onS_R2, ~, H3onSpred, H3onS_vaf, H3onS_mse, H3onSactTrunk H3onS_indivVAF]=OneDecoderOnManyFolds(H3model,SprTest,foldlength);
end

% Look at fits (train and test using the same data)
[IsoFitPredData] = predictSignals(IsoModel,IsoTrain);
IsoAct=IsoTrain.emgdatabin(10:end,:);
% Calculate multivariate VAF
for ind=1:length(IsoFitPredData.preddatabin)
    PredNorm(ind,1) = norm(IsoFitPredData.preddatabin(ind,:));
    ActNorm(ind,1) = norm(IsoAct(ind,:));
end
IsoFitVAF  = 1 - sum( (PredNorm-ActNorm).^2 ) ./ sum( (ActNorm - repmat(mean(ActNorm),size(ActNorm,1),1)).^2 );

[WmFitPredData] = predictSignals(WmModel,WmTrain);
WmAct=WmTrain.emgdatabin(10:end,:);
% Calculate multivariate VAF
for ind=1:length(WmFitPredData.preddatabin)
    PredNorm(ind,1) = norm(WmFitPredData.preddatabin(ind,:));
    ActNorm(ind,1) = norm(WmAct(ind,:));
end
WmFitVAF  = 1 - sum( (PredNorm-ActNorm).^2 ) ./ sum( (ActNorm - repmat(mean(ActNorm),size(ActNorm,1),1)).^2 );

[SprFitPredData] = predictSignals(SprModel,SprTrain);
SprAct=SprTrain.emgdatabin(10:end,:);
% Calculate multivariate VAF
for ind=1:length(SprFitPredData.preddatabin)
    PredNorm(ind,1) = norm(SprFitPredData.preddatabin(ind,:));
    ActNorm(ind,1) = norm(SprAct(ind,:));
end
SprFitVAF  = 1 - sum( (PredNorm-ActNorm).^2 ) ./ sum( (ActNorm - repmat(mean(ActNorm),size(ActNorm,1),1)).^2 );


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
    
    VAFstruct.H3onI_vaf_mean = [];
    VAFstruct.H3onW_vaf_mean = [];
    VAFstruct.H3onS_vaf_mean = [];
    VAFstruct.H3onI_vaf_ste = [];
    VAFstruct.H3onW_vaf_ste = [];
    VAFstruct.H3onS_vaf_ste = [];

else
    VAFstruct.SonS_vaf_mean = mean(SonS_vaf);
    VAFstruct.HonS_vaf_mean = mean(HonS_vaf);
    VAFstruct.IonS_vaf_mean = mean(IonS_vaf);
    VAFstruct.WonS_vaf_mean = mean(WonS_vaf);
    VAFstruct.SonS_vaf_ste = std(SonS_vaf)/sqrt(length(SonS_vaf));
    VAFstruct.HonS_vaf_ste = std(HonS_vaf)/sqrt(length(HonS_vaf));
    VAFstruct.IonS_vaf_ste = std(IonS_vaf)/sqrt(length(IonS_vaf));
    VAFstruct.WonS_vaf_ste = std(WonS_vaf)/sqrt(length(WonS_vaf));
    
    VAFstruct.H3onI_vaf_mean = mean(H3onI_vaf);
    VAFstruct.H3onW_vaf_mean = mean(H3onW_vaf);
    VAFstruct.H3onS_vaf_mean = mean(H3onS_vaf);
    VAFstruct.H3onI_vaf_ste = std(H3onI_vaf)/sqrt(length(H3onI_vaf));
    VAFstruct.H3onW_vaf_ste = std(H3onW_vaf)/sqrt(length(H3onW_vaf));
    VAFstruct.H3onS_vaf_ste = std(H3onS_vaf)/sqrt(length(H3onS_vaf));
end




% Make VAF struct for individual muscle preds
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

    IndivVAFstruct.H3onI_vaf_mean = [];
    IndivVAFstruct.H3onW_vaf_mean = [];
    IndivVAFstruct.H3onS_vaf_mean = [];
    IndivVAFstruct.H3onI_vaf_ste = [];
    IndivVAFstruct.H3onW_vaf_ste = [];
    IndivVAFstruct.H3onS_vaf_ste = [];
    
else
    IndivVAFstruct.SonS_vaf_mean = mean(SonS_indivVAF);
    IndivVAFstruct.HonS_vaf_mean = mean(HonS_indivVAF);
    IndivVAFstruct.IonS_vaf_mean = mean(IonS_indivVAF);
    IndivVAFstruct.WonS_vaf_mean = mean(WonS_indivVAF);
    IndivVAFstruct.SonS_vaf_ste = std(SonS_indivVAF)/sqrt(length(SonS_indivVAF));
    IndivVAFstruct.HonS_vaf_ste = std(HonS_indivVAF)/sqrt(length(HonS_indivVAF));
    IndivVAFstruct.IonS_vaf_ste = std(IonS_indivVAF)/sqrt(length(IonS_indivVAF));
    IndivVAFstruct.WonS_vaf_ste = std(WonS_indivVAF)/sqrt(length(WonS_indivVAF));
    
    IndivVAFstruct.H3onI_vaf_mean = mean(H3onI_indivVAF);
    IndivVAFstruct.H3onW_vaf_mean = mean(H3onW_indivVAF);
    IndivVAFstruct.H3onS_vaf_mean = mean(H3onS_indivVAF);
    IndivVAFstruct.H3onI_vaf_ste = std(H3onI_indivVAF)/sqrt(length(H3onI_indivVAF));
    IndivVAFstruct.H3onW_vaf_ste = std(H3onW_indivVAF)/sqrt(length(H3onW_indivVAF));
    IndivVAFstruct.H3onS_vaf_ste = std(H3onS_indivVAF)/sqrt(length(H3onS_indivVAF));
end




