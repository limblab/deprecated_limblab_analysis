
dataPath     = '';
fillen       = 0.5;
UseAllInputs = 1;
Polyn        = 3;
PredEMG      = 0;
PredForce    = 0;
PredCursPos  = 1;
PredVeloc    = 1;
Use_State    = 0;
numPCs       = 0;


numSig = 0;
if PredEMG
    numSig = numSig+size(binnedData.emgguide,1);
end
if PredForce
    numSig = numSig+size(binnedData.forcelabels,1);
end
if PredCursPos
    numSig = numSig+size(binnedData.cursorposlabels,1);
end
if PredVeloc
    numSig = numSig+size(binnedData.veloclabels,1);
end


Model    = BuildSDModel(modelData,dataPath,fillen,UseAllInputs,Polyn,PredEMG,PredForce,PredCursPos,PredVeloc,Use_State,numPCs);
PredData = PredictSDSignals(Model,testData,Use_SD);
TestSigs = concatSigs(testData,PredEMG,PredForce,PredCursorPos,PredVeloc);
R2_full  = CalculateR2(TestSigs(round(fillen/binsize):end,:),PredData.preddatabin)';
vaf_full = 1 - (var(PredData.preddatabin - TestSigs(round(fillen/binsize):end,:)) ./ var(TestSigs(round(fillen/binsize):end,:)));
mse_full = mean((PredData.preddatabin-TestSigs(round(fillen/binsize):end,:)).^2);


R2_PC  = zeros(numSig,100);
vaf_PC = zeros(numSig,100);
mse_PC = zeros(numSig,100);

for i = 1:100
    
    numPC      = i;
    Model      = BuildSDModel(modelData,dataPath,fillen,UseAllInputs,Polyn,PredEMG,PredForce,PredCursPos,PredVeloc,Use_State,numPCs);
    PredData   = PredictSDSignals(Model,testData,Use_SD);
    TestSigs   = concatSigs(testData,PredEMG,PredForce,PredCursorPos,PredVeloc);
    R2_PC(:,i) = CalculateR2(TestSigs(round(fillen/binsize):end,:),PredData.preddatabin)';
    vaf_PC(:,i)= 1 - (var(PredData.preddatabin - TestSigs(round(fillen/binsize):end,:)) ./ var(TestSigs(round(fillen/binsize):end,:)));
    mse_PC(:,i)= mean((PredData.preddatabin-TestSigs(round(fillen/binsize):end,:)).^2);
    
end