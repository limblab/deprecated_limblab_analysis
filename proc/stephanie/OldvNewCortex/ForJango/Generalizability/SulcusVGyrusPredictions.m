% Make predictions with a random set up gyrus neurons that equals the
% number of sulcal neurons

% Initialize variables for mfxval predictions
dataPath = 'Z:\Jango_12a1\Cross-Validation\Generalizability\';
fold_length =  60; %(in seconds)   
fillen = 0.5; %(in seconds)
PolynomialOrder = 1;
PredEMG = 1;
PredForce = 1;
PredCursPos = 0;
PredVeloc = 0;
Use_States = 0;
plotflag = 0;

% Get the entire NeuronID vector
AllNeuronIDs = spikeguide2neuronIDs(binnedData.spikeguide);

% Find the number of sulcal neurons by subtracting total number of neurons 
%from the number of gyrus neurons
NumGyralNeurons = find(AllNeuronIDs > 96, 1, 'first')-1;
NumSulcalNeurons = length(AllNeuronIDs)-NumGyralNeurons;
% Make the sulcus spike guide
SulcalSpikeGuide = binnedData.spikeguide((NumGyralNeurons+1):end,:);

[crap binnedData] = splitBinnedDataNew(binnedData,0, 840);

% Generate a vector of random numbers to make the Gyrus spikeguide
% Run through 10 iterations of gyrus predictions
GyrusNeuronID_all = []; G_mfxval_vaf_all = []; G_mfxval_mse_all = []; G_mfxval_R2_all = [];
for i=1:10
RandomNumbers = randperm(NumGyralNeurons);
RandomNumbers = RandomNumbers(1:NumSulcalNeurons);
RandomGyrusSpikeGuide = binnedData.spikeguide(RandomNumbers,:);

%Make a NeuronID vector for the gyrus
GyrusNeuronID = spikeguide2neuronIDs(RandomGyrusSpikeGuide);
GyrusNeuronID_all = cat(2,GyrusNeuronID_all, GyrusNeuronID); %Put the GyrusNeuronID files side by side

[G_mfxval_R2, G_mfxval_vaf, G_mfxval_mse, G_OLPredData] = mfxvalWithNeuronIDs(binnedData, dataPath, fold_length, fillen, GyrusNeuronID, PolynomialOrder, PredEMG, PredForce, PredCursPos, PredVeloc, Use_States,plotflag);

% Concatenate vaf, R2, and MSE values so you can have them for all folds
% for all iterations of gyrus neuron IDs
G_mfxval_vaf_all = cat(1,G_mfxval_vaf_all, G_mfxval_vaf);
G_mfxval_R2_all = cat(1,G_mfxval_R2_all, G_mfxval_R2);
G_mfxval_mse_all = cat(1,G_mfxval_mse_all, G_mfxval_mse);

end

% Make a NeuronID vector for the sulcus
SulcusNeuronID = spikeguide2neuronIDs(SulcalSpikeGuide);
% Get predictions (crossvalidation) using the sulcus cells
[S_mfxval_R2, S_mfxval_vaf, S_mfxval_mse, S_OLPredData] = mfxvalWithNeuronIDs(binnedData, dataPath, fold_length, fillen, SulcusNeuronID, PolynomialOrder, PredEMG, PredForce, PredCursPos, PredVeloc, Use_States,plotflag);


%K-S test | if h is 1, the test rejects the 
%null hypothesis at the 5% level (aka: significant)
for i=1:length(S_mfxval_vaf(1,:)) % iterate through all the variables you are predicting (i.e. EMG, force)
    [h(i),p(i)] = kstest2(S_mfxval_vaf(:,i), G_mfxval_vaf_all(:,i));
end

% Mean across all folds for all gyrus iterations
% mean_G_mfxval_vaf_all = mean(G_mfxval_vaf_all);
% mean_G_mfxval_R2_all = mean(G_mfxval_R2_all);
% mean_G_mfxval_mse_all = mean(G_mfxval_mse_all);
% Mean across all folds for the one sulcus iteration
numVals = length(S_mfxval_vaf);
mean_S_mfxval_vaf = mean(S_mfxval_vaf);
mean_S_mfxval_R2 = mean(S_mfxval_R2);
mean_S_mfxval_mse = mean(S_mfxval_mse);
ste_S_mfxval_vaf = (std(S_mfxval_vaf))/(sqrt(numVals));
ste_S_mfxval_R2 = (std(S_mfxval_R2))/(sqrt(numVals));
ste_S_mfxval_mse = (std(S_mfxval_mse))/(sqrt(numVals));


