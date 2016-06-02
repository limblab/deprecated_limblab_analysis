% n-folds where your training and testing data are different

% Inputs: TrainingData and TestingData
% Inputs: n folds

nfolds = 14;
%NeuronIDs = AllNeuronIDs;

testStartTime = 0; testEndTime = 60;
for n = 1:nfolds
   [DisgardedData,FoldData] = splitBinnedDataNew(binnedData,testStartTime,testEndTime);
   %Model = BuildModelWithNeuronIDs(FoldData, dataPath, fillen, NeuronIDs, PolynomialOrder, PredEMG, PredForce, PredCursPos, PredVeloc);
   testStartTime = testStartTime+60;
   testEndTime = testEndTime+60;
end