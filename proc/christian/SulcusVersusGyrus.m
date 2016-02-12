%function SulcusVersusGyrus(datapath)

AllNeuronIDs = spikeguide2neuronIDs(IsoBinned.spikeguide);

Sulcus = 1;
Gyrus = 1;

% Find the number of sulcal neurons by subtracting total number of neurons
%from the number of gyrus neurons
NumGyralNeurons = find(AllNeuronIDs > 96, 1, 'first')-1;
NumSulcalNeurons = length(AllNeuronIDs)-NumGyralNeurons;
% Make the sulcus spike guide
SulcalSpikeGuide = IsoBinned.spikeguide((NumGyralNeurons+1):end,:);
% Make a NeuronID vector for the sulcus
SulcusNeuronID = spikeguide2neuronIDs(SulcalSpikeGuide);

% Make decoders, make predictions ---------------------------------------

% Set parameters ----------------------------------------------------
fold_length = 60;                                % subject to change
fillen = .5; %in seconds                         % subject to change
PolynomialOrder = 1;                             % subject to change
%UseAllInputsOption = 0;                         % subject to change
PredEMG = 1; PredForce = 0; PredCursPos = 0; PredVeloc = 0;
Use_Thresh = 0; Use_EMGs = 0; Use_States = 0; plotflag = 0;
dataPath = 'Z:\Jango_12a1\BinnedData\Generalizability\';

if Sulcus == 1
    
    IsoModelSulcus = BuildModelWithNeuronIDs(IsoBinned, dataPath, fillen, SulcusNeuronID, PolynomialOrder, PredEMG, PredForce, PredCursPos, PredVeloc);
  
    
    % Within ------------------------------------------------------------------
    [IsoWithin_S_mfxval_R2, IsoWithin_S_mfxval_vaf, IsoWithin_S_mfxval_mse, Iso_S_OLPredData] = mfxvalWithNeuronIDs(IsoBinned, dataPath, fold_length, fillen, SulcusNeuronID, PolynomialOrder, PredEMG, PredForce, PredCursPos, PredVeloc, Use_States,plotflag);
    
    numVals = length(IsoWithin_S_mfxval_R2);
    mean_IonI_S_R2 = mean(IsoWithin_S_mfxval_R2);
    mean_IonI_S_vaf = mean(IsoWithin_S_mfxval_vaf);
    mean_IonI_S_mse = mean(IsoWithin_S_mfxval_mse);
    ste_IonI_S_R2 = (std(IsoWithin_S_mfxval_R2))/(sqrt(numVals));
    ste_IonI_S_vaf = (std(IsoWithin_S_mfxval_vaf))/(sqrt(numVals));
    ste_IonI_S_mse = (std(IsoWithin_S_mfxval_mse))/(sqrt(numVals));
    
    
end

if Gyrus == 1
    % Within stats variable initializations
    GyrusNeuronID_all = []; IsoWithin_G_mfxval_vaf = []; IsoWithin_G_mfxval_mse = []; IsoWithin_G_mfxval_R2 = [];
    WmWithin_G_mfxval_vaf = []; WmWithin_G_mfxval_mse = []; WmWithin_G_mfxval_R2 = [];
    for i=1:10
        RandomNumbers = randperm(NumGyralNeurons);
        RandomNumbers = RandomNumbers(1:NumSulcalNeurons);
        RandomGyrusSpikeGuide = IsoBinned.spikeguide(RandomNumbers,:);
        
        %Make a NeuronID vector for the gyrus
        GyrusNeuronID = spikeguide2neuronIDs(RandomGyrusSpikeGuide);
        GyrusNeuronID_all = cat(2,GyrusNeuronID_all, GyrusNeuronID); %Put the GyrusNeuronID files side by side
        
        IsoModelGyrus = BuildModelWithNeuronIDs(IsoBinned, dataPath, fillen, GyrusNeuronID, PolynomialOrder, PredEMG, PredForce, PredCursPos, PredVeloc);
        
        
        %Within--------------------------------------------------------------------
        [IsoWithin_G_mfxval_R2_1It, IsoWithin_G_mfxval_vaf_1It, IsoWithin_G_mfxval_mse_1It, IsoWithin_G_OLPredData] = mfxvalWithNeuronIDs(IsoBinned, dataPath, fold_length, fillen, GyrusNeuronID, PolynomialOrder, PredEMG, PredForce, PredCursPos, PredVeloc, Use_States,plotflag);
        
        % Concatenate vaf, R2, and MSE values so you can have them for all folds
        % for all iterations of gyrus neuron IDs
        IsoWithin_G_mfxval_vaf = cat(1,IsoWithin_G_mfxval_vaf, IsoWithin_G_mfxval_vaf_1It);
        IsoWithin_G_mfxval_R2 = cat(1,IsoWithin_G_mfxval_R2, IsoWithin_G_mfxval_R2_1It);
        IsoWithin_G_mfxval_mse = cat(1,IsoWithin_G_mfxval_mse, IsoWithin_G_mfxval_mse_1It);
        
        
    end
    
       numVals = length(IsoWithin_G_mfxval_R2);
    mean_IonI_G_R2 = mean(IsoWithin_G_mfxval_R2);
    mean_IonI_G_vaf = mean(IsoWithin_G_mfxval_vaf);
    mean_IonI_G_mse = mean(IsoWithin_G_mfxval_mse);
    ste_IonI_G_R2 = (std(IsoWithin_G_mfxval_R2))/(sqrt(numVals));
    ste_IonI_G_vaf = (std(IsoWithin_G_mfxval_vaf))/(sqrt(numVals));
    ste_IonI_G_mse = (std(IsoWithin_G_mfxval_mse))/(sqrt(numVals));
    
end

