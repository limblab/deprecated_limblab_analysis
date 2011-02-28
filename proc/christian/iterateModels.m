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
% binsize      = binnedData.timeframe(2)-binnedData.timeframe(1);
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

% 
% Model    = BuildSDModel(modelData,dataPath,fillen,UseAllInputs,Polyn,PredEMG,PredForce,PredCursPos,PredVeloc,Use_State,numPCs);
% PredData = predictSignals(Model,testData);
% TestSigs = concatSigs(testData,PredEMG,PredForce,PredCursPos,PredVeloc);
% R2_full  = CalculateR2(TestSigs(round(fillen/binsize):end,:),PredData.preddatabin)';
% vaf_full = 1 - (var(PredData.preddatabin - TestSigs(round(fillen/binsize):end,:)) ./ var(TestSigs(round(fillen/binsize):end,:)));
% mse_full = mean((PredData.preddatabin-TestSigs(round(fillen/binsize):end,:)).^2);


Use_State = 1; %Vel Thresh


%------numPCs------
% Inputs = DuplicateAndShift(modelData.spikeratedata,10);
% [PCoeffs,Inputs, Latent] = princomp(Inputs);
% modelData.PC = PCoeffs;
%------------------

%--------RC--------
% RC = 0:0.01:1;
% numIter = length(RC);
%------------------

%------Thresh------
% velMagn = binnedData.velocbin(:,3);
% vel = 0:0.2:20;
% numvel = length(vel);
% for i=1:numvel
%     states(:,i) = velMagn >= vel(i);
% end
% binnedData.states = states;
thresh_levels = 0:0.2:20;
numIter = length(thresh_levels);
%------------------

R2_test  = zeros(numIter,numSig);
vaf_test = zeros(numIter,numSig);
mse_test = zeros(numIter,numSig);

for i = 2:numIter
    Use_State = i;
    disp(sprintf('iteration %g of %g',i,numIter));
    Model      = BuildSDModel(modelData,dataPath,fillen,UseAllInputs,Polyn,PredEMG,PredForce,PredCursPos,PredVeloc,Use_State,numPCs);
    PredData   = predictSDSignals(Model,testData,Use_State,FiltPred,Adapt_Enable,LR,Adapt_lag,numPCs,RC(i));
    TestSigs   = concatSigs(testData,PredEMG,PredForce,PredCursPos,PredVeloc);
    R2_test(i,:) = CalculateR2(TestSigs,PredData.preddatabin)';
    vaf_test(i,:)= 1 - (var(PredData.preddatabin - TestSigs) ./ var(TestSigs));
    mse_test(i,:)= mean((PredData.preddatabin-TestSigs).^2);
%     R2_test(i,:) = CalculateR2(TestSigs(round(fillen/binsize):end,:),PredData.preddatabin)';
%     vaf_test(i,:)= 1 - (var(PredData.preddatabin - TestSigs(round(fillen/binsize):end,:)) ./ var(TestSigs(round(fillen/binsize):end,:)));
%     mse_test(i,:)= mean((PredData.preddatabin-TestSigs(round(fillen/binsize):end,:)).^2);
end