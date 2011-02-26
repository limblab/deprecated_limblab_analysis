% dataPath     = 'C:\Monkey\Keedoo\BinnedData\11-11-10\';
% filename     = 'Keedoo_Spike_11111000_testdata-modeldata';

fillen       = 0.5;
UseAllInputs = 1;
Polyn        = 3;
PredEMG      = 0;
PredForce    = 0;
PredCursPos  = 1;
PredVeloc    = 1;
Use_State    = 0;
numPCs       = 0;
dataPath     = '';
binsize      = modelData.timeframe(2)-modelData.timeframe(1);
FiltPred     = 0;
Adapt_Enable = 0;
Adapt_lag    = 0.2;
LR           = 1e-7;

numSig = 0;
if PredEMG
    numSig = numSig+size(modelData.emgguide,1);
end
if PredForce
    numSig = numSig+size(modelData.forcelabels,1);
end
if PredCursPos
    numSig = numSig+size(modelData.cursorposlabels,1);
end
if PredVeloc
    numSig = numSig+size(modelData.veloclabels,1);
end


Model    = BuildSDModel(modelData,dataPath,fillen,UseAllInputs,Polyn,PredEMG,PredForce,PredCursPos,PredVeloc,Use_State,numPCs);
PredData = predictSignals(Model,testData);
TestSigs = concatSigs(testData,PredEMG,PredForce,PredCursPos,PredVeloc);
R2_full  = CalculateR2(TestSigs(round(fillen/binsize):end,:),PredData.preddatabin)';
vaf_full = 1 - (var(PredData.preddatabin - TestSigs(round(fillen/binsize):end,:)) ./ var(TestSigs(round(fillen/binsize):end,:)));
mse_full = mean((PredData.preddatabin-TestSigs(round(fillen/binsize):end,:)).^2);


R2_PC  = zeros(100,numSig);
vaf_PC = zeros(100,numSig);
mse_PC = zeros(100,numSig);

Inputs = DuplicateAndShift(modelData.spikeratedata,10);
[PCoeffs,Inputs, Latent] = princomp(Inputs);
modelData.PC = PCoeffs;
maxPCs = length(PCoeffs);

stepPCs = maxPCs/2;

for i = maxPCs:stepPCs:1
    numPCs      = i;
    disp(sprintf('using %g PCs',numPCs));    
    Model      = BuildSDModel(modelData,dataPath,fillen,UseAllInputs,Polyn,PredEMG,PredForce,PredCursPos,PredVeloc,Use_State,numPCs);
    PredData   = predictSignals(Model,testData,FiltPred,Adapt_Enable,LR,Adapt_lag,numPCs);
    TestSigs   = concatSigs(testData,PredEMG,PredForce,PredCursPos,PredVeloc);
    R2_PC(i,:) = CalculateR2(TestSigs,PredData.preddatabin)';
    vaf_PC(i,:)= 1 - (var(PredData.preddatabin - TestSigs) ./ var(TestSigs));
    mse_PC(i,:)= mean((PredData.preddatabin-TestSigs).^2);
    stepPCs = floor(numPCs/2);
end