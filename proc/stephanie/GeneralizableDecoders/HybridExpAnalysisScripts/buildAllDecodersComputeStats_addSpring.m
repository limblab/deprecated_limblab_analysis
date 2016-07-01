 buildAllDecodersComputeStats_addSpring


% | Make sure you are using the same neurons for both files
badUnits = checkUnitGuides_sn(IsoBinned.neuronIDs,SprBinned.neuronIDs);
newIDs = setdiff(IsoBinned.neuronIDs, badUnits, 'rows');
if ~(isempty(badUnits))
    for i = length(badUnits(:,1))
        badUnitInd = find(SprBinned.neuronIDs(:,1) == badUnits(i,1) & SprBinned.neuronIDs(:,2) == badUnits(i,2));
        SprBinned.spikeratedata(:,badUnitInd) = [];
    end
    SprBinned.neuronIDs = newIDs; IsoBinned.neuronIDs = newIDs;
end

% Separate spring file into training and testing data
SprTest = cutBinnedDataFile(SprBinned, 1, 12001);
SprTrain = cutBinnedDataFile(SprBinned, 12001, length(SprTest.timeframe));

%BuildNormalModels
options=[]; options.PredEMGs = 1;
SprModel = BuildModel(SprTrain, options);

% Make predictions
[SonSpred,~,SonSact]=predMIMO4(SprTest.spikeratedata,SprModel.H,1,1,SprTest.emgdatabin);
[HonSpred,~,HonSact]=predMIMO4(SprTest.spikeratedata,hybridH,1,1,SprTest.emgdatabin);
[IonSpred,~,IonSact]=predMIMO4(SprTest.spikeratedata,IsoModel.H,1,1,SprTest.emgdatabin);
[WonSpred,~,WonSact]=predMIMO4(SprTest.spikeratedata,WmModel.H,1,1,SprTest.emgdatabin);



% Calculate VAFs -----------------------------------------------------------
SonS_vaf = calculateVAF(SonSpred,SonSact);
HonS_vaf = calculateVAF(HonSpred,HonSact);
IonS_vaf = calculateVAF(IonSpred,IonSact);
WonS_vaf = calculateVAF(WonSpred,WonSact);

%Step 8 | Construct data struct ----------------------------------------------
VAFstruct.SonS_vaf= SonS_vaf;
VAFstruct.HonS_vaf = HonS_vaf;
VAFstruct.IonS_vaf = IonS_vaf;
VAFstruct.WonS_vaf  = WonS_vaf;




