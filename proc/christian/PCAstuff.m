

desiredInputs = get_desired_inputs(binnedData.spikeguide, NeuronIDs);

spikes = binnedData.spikeratedata(:,desiredInputs);

[pc,score,variances,tsquare] = princomp(spikes);

% prop_of_var = cumsum(variances)./sum(variances);
percent_explained = 100*variances/sum(variances);

figure;
pareto(percent_explained);
xlabel('Principal Component');
ylabel('Variance Explained (%)');
title('Before Standardisation');

figure;
biplot(pc(:,1:2)); title('Coeffs, before Standardisation');

numPCs = 10;
PCsignals = spikes*pc(:,1:numPCs);


%You can standardize the data by dividing each column by its standard
%deviation.
stdSpikes = std(spikes);
stdSpikes = spikes./repmat(stdSpikes, size(spikes,1),1);

[pc_s,score_s,variances_s,tsquare_s] = princomp(stdSpikes);

% prop_of_var = cumsum(variances)./sum(variances);
percent_explained_s = 100*variances_s/sum(variances_s);

figure;
pareto(percent_explained_s);
xlabel('Principal Component');
ylabel('Variance Explained (%)');
title('After Standardisation');

figure;
biplot(pc_s(:,1:2)); title('Coeffs, after Standardisation');

PCsignals_s = spikes*pc_s(:,1:numPCs);


%% Predict data using a varying number of PCs

% 1- load data - ModelData and TestData

% 2- Make sure we use only common units

desiredInputs = get_desired_inputs(TestData.spikeguide, NeuronIDs);
TestData.spikeratedata = TestData.spikeratedata(:,desiredInputs);
TestData.spikeguide = neuronIDs2spikeguide(NeuronIDs);
desiredInputs = get_desired_inputs(ModelData.spikeguide, NeuronIDs);
ModelData.spikeratedata = ModelData.spikeratedata(:,desiredInputs);
ModelData.spikeguide = neuronIDs2spikeguide(NeuronIDs);

% 3- build models and make predictions

dataPath = '';
fillen = 0.5;
UseAllInputsOption = 1;
PolynomialOrder = 0;
PredEMG      = 0;
PredForce    = 0;
PredCursPos  = 1;
Use_Thresh   = 0;
Use_PrinComp = true;
FiltPred = false;
Adapt_Enable = false;
LR = 0.0000001;
Adapt_Lag = 0.05;
R2 = zeros(size(NeuronIDs,1),2);
plotflag = false;
%H = cell(size(NeuronIDs,1),1);


% 3a- iterate model building and prediction, with an increasing number of PCs.
for numPCs = 1:size(NeuronIDs,1) %max numPCs is the max num of inputs
    filter = BuildModel(ModelData, dataPath, fillen, UseAllInputsOption, PolynomialOrder, PredEMG,PredForce,PredCursPos,Use_Thresh,numPCs);
    PredData = predictSignals(filter, TestData, FiltPred, Adapt_Enable, LR, Adapt_Lag, numPCs);
    R2(numPCs,:) = ActualvsOLPred(TestData,PredData,plotflag);
end

% 3b- iterate model building and fit, with an increasing number of PCs.
for numPCs = 1:size(NeuronIDs,1) %max numPCs is the max num of inputs
    filter = BuildModel(ModelData, dataPath, fillen, UseAllInputsOption, PolynomialOrder, PredEMG,PredForce,PredCursPos,Use_Thresh,numPCs);
    PredData = predictSignals(filter, ModelData, FiltPred, Adapt_Enable, LR, Adapt_Lag, numPCs);
    R2(numPCs,:) = ActualvsOLPred(TestData,PredData,plotflag);
end

% 4- mfxval with 13 PCs
    numPCs = 13;
    foldlength = 60;
    filter = BuildModel(ModelData, dataPath, fillen, UseAllInputsOption, PolynomialOrder, PredEMG,PredForce,PredCursPos,Use_Thresh,numPCs);
    [R2, nfold] = mfxval_fixed_model(filter,TestData,foldlength,Adapt_Enable);
    
% 5- PC and Adaptation
    Adapt_Enable = true;
    filter.H = zeros(size(filter.H));
    [R2, nfold] = mfxval_fixed_model(filter,TestData,foldlength,Adapt_Enable);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% find best LR

