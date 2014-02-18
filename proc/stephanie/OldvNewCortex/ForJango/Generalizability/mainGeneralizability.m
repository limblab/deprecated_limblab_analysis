%mainGneralizability
% Main Generalizability code

Sulcus = 0; Gyrus = 0;

% Load the three types of binnedData files
%IsoBinned = load(['Z:' filesep 'Jaco_8I1' filesep 'BinnedData' filesep 'OldvNewCortex' filesep '08-13-13' filesep 'Jaco_Iso__horiz_EMGonly_08-13-13_001']);
%WmBinned = load(['Z:' filesep 'Jaco_8I1' filesep 'BinnedData' filesep 'OldvNewCortex' filesep '08-13-13' filesep 'Jaco_WMnormal_EMGonly_08-13-13_001']);
%SprBinned = load(['Z:' filesep 'Jaco_8I1' filesep 'BinnedData' filesep 'OldvNewCortex' filesep '08-13-13' filesep 'Jaco_WMspring_EMGonly_08-13-13_001']);

%Truncate files [840.05 --> 14 minutes]
[crap IsoBinned] = splitBinnedDataNew(IsoBinned,0, 840);
[crap WmBinned] = splitBinnedDataNew(WmBinned,0,840);
%SprBinned = splitBinnedData(binnedData,840,0);

%Make sure the spikeguide and spike data are the same
%badUnits = checkUnitGuides(IsoBinned.spikeguide, WmBinned.spikeguide);
%sg = setdiff(IsoBinned.spikeguide, badUnits, 'rows');

% Make a hybrid file with alternating minutes of iso and wm data
[HybBinned AlteredIso AlteredWm] = makeHybridFile(IsoBinned,WmBinned);

%Duplicate and shift
% numlags=10;
% IsoBinned.spikeratedata = DuplicateAndShift(IsoBinned.spikeratedata,numlags);
% WmBinned.spikeratedata = DuplicateAndShift(WmBinned.spikeratedata,numlags);
%SprBinned.spikeratedata = DuplicateAndShift(SprBinned.spikeratedata,numlags);

% SD = std(IsoBinned.emgdatabin);
% for a=1:length(IsoBinned.emgdatabin(1,:))
%     IsoBinned.emgdatabin(:,a) = IsoBinned.emgdatabin(:,a)/SD(a);
% end
% 
% SD = std(WmBinned.emgdatabin);
% for a=1:length(WmBinned.emgdatabin(1,:))
%     WmBinned.emgdatabin(:,a) = WmBinned.emgdatabin(:,a)/SD(a);
% end

% Make NeuronID files for all sorted neurons,
% gyrus neurons, and sulcus neurons----------------------------------------
% Get the entire NeuronID vector
AllNeuronIDs = spikeguide2neuronIDs(IsoBinned.spikeguide);

if Sulcus == 1;
    % Find the number of sulcal neurons by subtracting total number of neurons
    %from the number of gyrus neurons
    NumGyralNeurons = find(AllNeuronIDs > 96, 1, 'first')-1;
    NumSulcalNeurons = length(AllNeuronIDs)-NumGyralNeurons;
    % Make the sulcus spike guide
    SulcalSpikeGuide = IsoBinned.spikeguide((NumGyralNeurons+1):end,:);
    % Make a NeuronID vector for the sulcus
    SulcusNeuronID = spikeguide2neuronIDs(SulcalSpikeGuide);
end

%--------------------------------------------------------------------------

% Make decoders, make predictions ---------------------------------------

% Set parameters ----------------------------------------------------
fold_length = 60;                                % subject to change
fillen = .5; %in seconds                         % subject to change
PolynomialOrder = 1;                             % subject to change
%UseAllInputsOption = 0;                         % subject to change
PredEMG = 1; PredForce = 0; PredCursPos = 0; PredVeloc = 0;
Use_Thresh = 0; Use_EMGs = 0; Use_States = 0; plotflag = 0;
dataPath = 'Z:\Jango_12a1\BinnedData\Generalizability\';

% Build models -------------------------------------------------------
% IsoModelAll = BuildModelWithNeuronIDs(IsoBinned, dataPath, fillen, AllNeuronIDs, PolynomialOrder, PredEMG, PredForce, PredCursPos, PredVeloc);
% WmModelAll = BuildModelWithNeuronIDs(WmBinned, dataPath, fillen, AllNeuronIDs, PolynomialOrder, PredEMG, PredForce, PredCursPos, PredVeloc);
% HybModelAll = BuildModelWithNeuronIDs(HybBinned, dataPath, fillen, AllNeuronIDs, PolynomialOrder, PredEMG, PredForce, PredCursPos, PredVeloc);
%SprModelAll = BuildModelWithNeuronIDs(SprBinned, dataPath, fillen, AllNeuronIDs, PolynomialOrder, PredEMG, PredForce, PredCursPos, PredVeloc);

options.PredEMGs = 1;
IsoModelAll = BuildModel(IsoBinned, options);
WmModelAll = BuildModel(WmBinned, options);
HybModelAll = BuildModel(HybBinned, options);

% IsoModelAll = BuildModel(IsoBinned, dataPath, fillen, 1, PolynomialOrder, PredEMG, PredForce, PredCursPos, PredVeloc);
% WmModelAll = BuildModel(WmBinned, dataPath, fillen, 1, PolynomialOrder, PredEMG, PredForce, PredCursPos, PredVeloc);
% options.PredEMGs = 1;
% Make predictions --------------------------------------------------------

% Within ----(multi-fold cross-validation)-----------------------------
% [IsoWithin_All_mfxval_R2, IsoWithin_All_mfxval_vaf, IsoWithin_All_mfxval_mse, Iso_All_OLPredData] = mfxvalWithNeuronIDs(IsoBinned, dataPath, fold_length, fillen, AllNeuronIDs, PolynomialOrder, PredEMG, PredForce, PredCursPos, PredVeloc, Use_States,plotflag);
% [WmWithin_All_mfxval_R2, WmWithin_All_mfxval_vaf, WmWithin_All_mfxval_mse, Wm_All_OLPredData] = mfxvalWithNeuronIDs(WmBinned, dataPath, fold_length, fillen, AllNeuronIDs, PolynomialOrder, PredEMG, PredForce, PredCursPos, PredVeloc, Use_States,plotflag);
% 
% [IsoWithin_All_mfxval_R2, IsoWithin_All_mfxval_vaf, IsoWithin_All_mfxval_mse, Iso_All_OLPredData] = mfxval(IsoBinned, dataPath, fold_length, fillen, 1, PolynomialOrder, PredEMG, PredForce, PredCursPos, PredVeloc, Use_States,plotflag);
% [WmWithin_All_mfxval_R2, WmWithin_All_mfxval_vaf, WmWithin_All_mfxval_mse, Wm_All_OLPredData] = mfxval(WmBinned, dataPath, fold_length, fillen, 1, PolynomialOrder, PredEMG, PredForce, PredCursPos, PredVeloc, Use_States,plotflag);
[IsoWithin_All_mfxval_R2, IsoWithin_All_mfxval_vaf, IsoWithin_All_mfxval_mse, Iso_All_OLPredData] = mfxval(IsoBinned,options);
[WmWithin_All_mfxval_R2, WmWithin_All_mfxval_vaf, WmWithin_All_mfxval_mse, Wm_All_OLPredData] = mfxval(WmBinned, options);


numVals = length(IsoWithin_All_mfxval_R2);
mean_IonI_All_R2 = mean(IsoWithin_All_mfxval_R2);
mean_IonI_All_vaf = mean(IsoWithin_All_mfxval_vaf);
mean_IonI_All_mse = mean(IsoWithin_All_mfxval_mse);
ste_IonI_All_R2 = (std(IsoWithin_All_mfxval_R2))/(sqrt(numVals));
ste_IonI_All_vaf = (std(IsoWithin_All_mfxval_vaf))/(sqrt(numVals));
ste_IonI_All_mse = (std(IsoWithin_All_mfxval_mse))/(sqrt(numVals));

mean_WonW_All_R2 = mean(WmWithin_All_mfxval_R2);
mean_WonW_All_vaf = mean(WmWithin_All_mfxval_vaf);
mean_WonW_All_mse = mean(WmWithin_All_mfxval_mse);
ste_WonW_All_R2 = (std(WmWithin_All_mfxval_R2))/(sqrt(numVals));
ste_WonW_All_vaf = (std(WmWithin_All_mfxval_vaf))/(sqrt(numVals));
ste_WonW_All_mse = (std(WmWithin_All_mfxval_mse))/(sqrt(numVals));

% Across ------------------------------------------------------------------

% Isometric applied across to Wrist movement and vice versa
% All Neurons
% [IonW_All_PredData, IonW_All_newH] = predictSignals(IsoModelAll,WmBinned);
% [IonW_All_R2 IonW_All_vaf IonW_All_mse] = ActualvsOLPred(WmBinned,IonW_All_PredData);
% [WonI_All_PredData, WonI_All_newH] = predictSignals(WmModelAll,IsoBinned);
% [WonI_All_R2 WonI_All_vaf WonI_All_mse] = ActualvsOLPred(IsoBinned,WonI_All_PredData);

foldlength = 60;
[IonW_All_R2, ~, IonW_PredData,  IonW_All_vaf, IonW_All_mse] = PeriodicR2(IsoModelAll,WmBinned,foldlength);
[WonI_All_R2, ~,WonI_PredData, WonI_All_vaf, WonI_All_mse] = PeriodicR2(WmModelAll,IsoBinned,foldlength);

mean_IonW_All_R2 = mean(IonW_All_R2);
mean_IonW_All_vaf = mean(IonW_All_vaf);
mean_IonW_All_mse = mean(IonW_All_mse);
ste_IonW_All_R2 = (std(IonW_All_R2))/(sqrt(numVals));
ste_IonW_All_vaf = (std(IonW_All_vaf))/(sqrt(numVals));
ste_IonW_All_mse = (std(IonW_All_mse))/(sqrt(numVals));

mean_WonI_All_R2 = mean(WonI_All_R2);
mean_WonI_All_vaf = mean(WonI_All_vaf);
mean_WonI_All_mse = mean(WonI_All_mse);
ste_WonI_All_R2 = (std(WonI_All_R2))/(sqrt(numVals));
ste_WonI_All_vaf = (std(WonI_All_vaf))/(sqrt(numVals));
ste_WonI_All_mse = (std(WonI_All_mse))/(sqrt(numVals));



%Hybrid in action ------------------------------------------------------
% ----------------------------------------------------------------------
[HonI_All_R2, ~, HonI_PredData, HonI_All_vaf, HonI_All_mse] = PeriodicR2(HybModelAll, AlteredIso,foldlength);
[HonW_All_R2, ~, HonW_PredData, HonW_All_vaf, HonW_All_mse] = PeriodicR2(HybModelAll,AlteredWm,foldlength);

numVals = length(HonI_All_R2);
mean_HonI_All_R2 = mean(HonI_All_R2);
mean_HonI_All_vaf = mean(HonI_All_vaf);
mean_HonI_All_mse = mean(HonI_All_mse);
ste_HonI_All_R2 = (std(HonI_All_R2))/(sqrt(numVals));
ste_HonI_All_vaf = (std(HonI_All_vaf))/(sqrt(numVals));
ste_HonI_All_mse = (std(HonI_All_mse))/(sqrt(numVals));

mean_HonW_All_R2 = mean(HonW_All_R2);
mean_HonW_All_vaf = mean(HonW_All_vaf);
mean_HonW_All_mse = mean(HonW_All_mse);
ste_HonW_All_R2 = (std(HonW_All_R2))/(sqrt(numVals));
ste_HonW_All_vaf = (std(HonW_All_vaf))/(sqrt(numVals));
ste_HonW_All_mse = (std(HonW_All_mse))/(sqrt(numVals));




if Sulcus == 1
    
    IsoModelSulcus = BuildModelWithNeuronIDs(IsoBinned, dataPath, fillen, SulcusNeuronID, PolynomialOrder, PredEMG, PredForce, PredCursPos, PredVeloc);
    WmModelSulcus = BuildModelWithNeuronIDs(WmBinned, dataPath, fillen, SulcusNeuronID, PolynomialOrder, PredEMG, PredForce, PredCursPos, PredVeloc);
    HybModelSulcus = BuildModelWithNeuronIDs(HybBinned, dataPath, fillen, SulcusNeuronID, PolynomialOrder, PredEMG, PredForce, PredCursPos, PredVeloc);
    
    
    
    % Within ------------------------------------------------------------------
    [IsoWithin_S_mfxval_R2, IsoWithin_S_mfxval_vaf, IsoWithin_S_mfxval_mse, Iso_S_OLPredData] = mfxvalWithNeuronIDs(IsoBinned, dataPath, fold_length, fillen, SulcusNeuronID, PolynomialOrder, PredEMG, PredForce, PredCursPos, PredVeloc, Use_States,plotflag);
    [WmWithin_S_mfxval_R2, WmWithin_S_mfxval_vaf, WmWithin_S_mfxval_mse, Wm_S_OLPredData] = mfxvalWithNeuronIDs(WmBinned, dataPath, fold_length, fillen, SulcusNeuronID, PolynomialOrder, PredEMG, PredForce, PredCursPos, PredVeloc, Use_States,plotflag);
    
    numVals = length(IsoWithin_S_mfxval_R2);
    mean_IonI_S_R2 = mean(IsoWithin_S_mfxval_R2);
    mean_IonI_S_vaf = mean(IsoWithin_S_mfxval_vaf);
    mean_IonI_S_mse = mean(IsoWithin_S_mfxval_mse);
    ste_IonI_S_R2 = (std(IsoWithin_S_mfxval_R2))/(sqrt(numVals));
    ste_IonI_S_vaf = (std(IsoWithin_S_mfxval_vaf))/(sqrt(numVals));
    ste_IonI_S_mse = (std(IsoWithin_S_mfxval_mse))/(sqrt(numVals));
    
    mean_WonW_S_R2 = mean(WmWithin_S_mfxval_R2);
    mean_WonW_S_vaf = mean(WmWithin_S_mfxval_vaf);
    mean_WonW_S_mse = mean(WmWithin_S_mfxval_mse);
    ste_WonW_S_R2 = (std(WmWithin_S_mfxval_R2))/(sqrt(numVals));
    ste_WonW_S_vaf = (std(WmWithin_S_mfxval_vaf))/(sqrt(numVals));
    ste_WonW_S_mse = (std(WmWithin_S_mfxval_mse))/(sqrt(numVals));
    
    % Across ------------------------------------------------------------------
    foldlength = 60;
    [IonW_S_R2, ~, ~,  IonW_S_vaf, IonW_S_mse] = PeriodicR2(IsoModelSulcus,WmBinned,foldlength);
    [WonI_S_R2, ~,~, WonI_S_vaf, WonI_S_mse] = PeriodicR2(WmModelSulcus,IsoBinned,foldlength);
    
    mean_IonW_S_R2 = mean(IonW_S_R2);
    mean_IonW_S_vaf = mean(IonW_S_vaf);
    mean_IonW_S_mse = mean(IonW_S_mse);
    
    ste_IonW_S_R2 = (std(IonW_S_R2))/(sqrt(numVals));
    ste_IonW_S_vaf = (std(IonW_S_vaf))/(sqrt(numVals));
    ste_IonW_S_mse = (std(IonW_S_mse))/(sqrt(numVals));
    
    mean_WonI_S_R2 = mean(WonI_S_R2);
    mean_WonI_S_vaf = mean(WonI_S_vaf);
    mean_WonI_S_mse = mean(WonI_S_mse);
    
    ste_WonI_S_R2 = (std(WonI_S_R2))/(sqrt(numVals));
    ste_WonI_S_vaf = (std(WonI_S_vaf))/(sqrt(numVals));
    ste_WonI_S_mse = (std(WonI_S_mse))/(sqrt(numVals));
    
    
    % Hybrid ------------------------------------------------------------------
    
    [HonI_S_R2, ~,~, HonI_S_vaf, HonI_S_mse] = PeriodicR2(HybModelSulcus,AlteredIso,foldlength);
    [HonW_S_R2,~,~, HonW_S_vaf, HonW_S_mse] = PeriodicR2(HybModelSulcus,AlteredWm,foldlength);
    
    numVals = length(HonI_S_R2);
    mean_HonI_S_R2 = mean(HonI_S_R2);
    mean_HonI_S_vaf = mean(HonI_S_vaf);
    mean_HonI_S_mse = mean(HonI_S_mse);
    
    ste_HonI_S_R2 = (std(HonI_S_R2))/(sqrt(numVals));
    ste_HonI_S_vaf = (std(HonI_S_vaf))/(sqrt(numVals));
    ste_HonI_S_mse = (std(HonI_S_mse))/(sqrt(numVals));
    
    mean_HonW_S_R2 = mean(HonW_S_R2);
    mean_HonW_S_vaf = mean(HonW_S_vaf);
    mean_HonW_S_mse = mean(HonW_S_mse);
    
    ste_HonW_S_R2 = (std(HonW_S_R2))/(sqrt(numVals));
    ste_HonW_S_vaf = (std(HonW_S_vaf))/(sqrt(numVals));
    ste_HonW_S_mse = (std(HonW_S_mse))/(sqrt(numVals));
    
    
end


if Gyrus == 1
    % Within stats variable initializations
    GyrusNeuronID_all = []; IsoWithin_G_mfxval_vaf = []; IsoWithin_G_mfxval_mse = []; IsoWithin_G_mfxval_R2 = [];
    WmWithin_G_mfxval_vaf = []; WmWithin_G_mfxval_mse = []; WmWithin_G_mfxval_R2 = [];
    % Across stats variable initializations
    IonW_G_R2 = []; IonW_G_vaf = []; IonW_G_mse = [];
    WonI_G_R2 = []; WonI_G_vaf = []; WonI_G_mse = [];
    % Hybrid stats variable initalizations
    HonW_G_R2 = []; HonW_G_vaf = []; HonW_G_mse = [];
    HonI_G_R2 = []; HonI_G_vaf = []; HonI_G_mse = [];
    for i=1:10
        RandomNumbers = randperm(NumGyralNeurons);
        RandomNumbers = RandomNumbers(1:NumSulcalNeurons);
        RandomGyrusSpikeGuide = IsoBinned.spikeguide(RandomNumbers,:);
        
        %Make a NeuronID vector for the gyrus
        GyrusNeuronID = spikeguide2neuronIDs(RandomGyrusSpikeGuide);
        GyrusNeuronID_all = cat(2,GyrusNeuronID_all, GyrusNeuronID); %Put the GyrusNeuronID files side by side
        
        IsoModelGyrus = BuildModelWithNeuronIDs(IsoBinned, dataPath, fillen, GyrusNeuronID, PolynomialOrder, PredEMG, PredForce, PredCursPos, PredVeloc);
        WmModelGyrus = BuildModelWithNeuronIDs(WmBinned, dataPath, fillen, GyrusNeuronID, PolynomialOrder, PredEMG, PredForce, PredCursPos, PredVeloc);
        HybModelGyrus = BuildModelWithNeuronIDs(HybBinned, dataPath, fillen, GyrusNeuronID, PolynomialOrder, PredEMG, PredForce, PredCursPos, PredVeloc);
        
        %Within--------------------------------------------------------------------
        [IsoWithin_G_mfxval_R2_1It, IsoWithin_G_mfxval_vaf_1It, IsoWithin_G_mfxval_mse_1It, IsoWithin_G_OLPredData] = mfxvalWithNeuronIDs(IsoBinned, dataPath, fold_length, fillen, GyrusNeuronID, PolynomialOrder, PredEMG, PredForce, PredCursPos, PredVeloc, Use_States,plotflag);
        [WmWithin_G_mfxval_R2_1It, WmWithin_G_mfxval_vaf_1It, WmWithin_G_mfxval_mse_1It, WmWithin_G_OLPredData] = mfxvalWithNeuronIDs(WmBinned, dataPath, fold_length, fillen, GyrusNeuronID, PolynomialOrder, PredEMG, PredForce, PredCursPos, PredVeloc, Use_States,plotflag);
        % Concatenate vaf, R2, and MSE values so you can have them for all folds
        % for all iterations of gyrus neuron IDs
        IsoWithin_G_mfxval_vaf = cat(1,IsoWithin_G_mfxval_vaf, IsoWithin_G_mfxval_vaf_1It);
        IsoWithin_G_mfxval_R2 = cat(1,IsoWithin_G_mfxval_R2, IsoWithin_G_mfxval_R2_1It);
        IsoWithin_G_mfxval_mse = cat(1,IsoWithin_G_mfxval_mse, IsoWithin_G_mfxval_mse_1It);
        
        WmWithin_G_mfxval_vaf = cat(1,WmWithin_G_mfxval_vaf, WmWithin_G_mfxval_vaf_1It);
        WmWithin_G_mfxval_R2 = cat(1,WmWithin_G_mfxval_R2, WmWithin_G_mfxval_R2_1It);
        WmWithin_G_mfxval_mse = cat(1,WmWithin_G_mfxval_mse, WmWithin_G_mfxval_mse_1It);
        
        
        
        % Across ------------------------------------------------------------------
        foldlength = 60;
        [IonW_G_R2_1It, ~, ~,  IonW_G_vaf_1It, IonW_G_mse_1It] = PeriodicR2(IsoModelGyrus,WmBinned,foldlength);
        [WonI_G_R2_1It, ~,~, WonI_G_vaf_1It, WonI_G_mse_1It] = PeriodicR2(WmModelGyrus,IsoBinned,foldlength);
        % Concatenate vaf, R2, and MSE values so you can have them for all folds
        % for all iterations of gyrus neuron IDs
        IonW_G_R2 = cat(1,IonW_G_R2, IonW_G_R2_1It);
        IonW_G_vaf = cat(1,IonW_G_vaf, IonW_G_vaf_1It);
        IonW_G_mse = cat(1,IonW_G_mse, IonW_G_mse_1It);
        
        WonI_G_R2 = cat(1,WonI_G_R2, WonI_G_R2_1It);
        WonI_G_vaf = cat(1,WonI_G_vaf, WonI_G_vaf_1It);
        WonI_G_mse = cat(1,WonI_G_mse, WonI_G_mse_1It);
        
        % Hybrid ------------------------------------------------------------------
        [HonW_G_R2_1It, ~,~, HonW_G_vaf_1It, HonW_G_mse_1It] = PeriodicR2(HybModelGyrus,AlteredWm,foldlength);
        [HonI_G_R2_1It, ~,~, HonI_G_vaf_1It, HonI_G_mse_1It] = PeriodicR2(HybModelGyrus,AlteredIso,foldlength);
         % Concatenate vaf, R2, and MSE values so you can have them for all folds
        % for all iterations of gyrus neuron IDs
        HonW_G_R2 = cat(1,HonW_G_R2, HonW_G_R2_1It);
        HonW_G_vaf = cat(1,HonW_G_vaf, HonW_G_vaf_1It);
        HonW_G_mse = cat(1,HonW_G_mse, HonW_G_mse_1It);
        
        HonI_G_R2 = cat(1,HonI_G_R2, HonI_G_R2_1It);
        HonI_G_vaf = cat(1,HonI_G_vaf, HonI_G_vaf_1It);
        HonI_G_mse = cat(1,HonI_G_mse, HonI_G_mse_1It);
        
              
        
    end
    
    %Within Summary -----------------------------------------------------------
    numVals = length(IsoWithin_G_mfxval_R2);
    mean_IonI_G_R2 = mean(IsoWithin_G_mfxval_R2);
    mean_IonI_G_vaf = mean(IsoWithin_G_mfxval_vaf);
    mean_IonI_G_mse = mean(IsoWithin_G_mfxval_mse);
    ste_IonI_G_R2 = (std(IsoWithin_G_mfxval_R2))/(sqrt(numVals));
    ste_IonI_G_vaf = (std(IsoWithin_G_mfxval_vaf))/(sqrt(numVals));
    ste_IonI_G_mse = (std(IsoWithin_G_mfxval_mse))/(sqrt(numVals));
    
    mean_WonW_G_R2 = mean(WmWithin_G_mfxval_R2);
    mean_WonW_G_vaf = mean(WmWithin_G_mfxval_vaf);
    mean_WonW_G_mse = mean(WmWithin_G_mfxval_mse);
    ste_WonW_G_R2 = (std(WmWithin_G_mfxval_R2))/(sqrt(numVals));
    ste_WonW_G_vaf = (std(WmWithin_G_mfxval_vaf))/(sqrt(numVals));
    ste_WonW_G_mse = (std(WmWithin_G_mfxval_mse))/(sqrt(numVals));
    
    %Across Summary -----------------------------------------------------------
    numVals = length(IonW_G_R2);
    mean_IonW_G_R2 = mean(IonW_G_R2);
    mean_IonW_G_vaf = mean(IonW_G_vaf);
    mean_IonW_G_mse = mean(IonW_G_mse);
    ste_IonW_G_R2 = (std(IonW_G_R2))/(sqrt(numVals));
    ste_IonW_G_vaf = (std(IonW_G_vaf))/(sqrt(numVals));
    ste_IonW_G_mse = (std(IonW_G_mse))/(sqrt(numVals));
    
    mean_WonI_G_R2 = mean(WonI_G_R2);
    mean_WonI_G_vaf = mean(WonI_G_vaf);
    mean_WonI_G_mse = mean(WonI_G_mse);
    
    ste_WonI_G_R2 = (std(WonI_G_R2))/(sqrt(numVals));
    ste_WonI_G_vaf = (std(WonI_G_vaf))/(sqrt(numVals));
    ste_WonI_G_mse = (std(WonI_G_mse))/(sqrt(numVals));
    
    %Hybrid Summary -----------------------------------------------------------
    numVals = length(HonI_G_R2);
    mean_HonI_G_R2 = mean(HonI_G_R2);
    mean_HonI_G_vaf = mean(HonI_G_vaf);
    mean_HonI_G_mse = mean(HonI_G_mse);
    ste_HonI_G_R2 = (std(HonI_G_R2))/(sqrt(numVals));
    ste_HonI_G_vaf = (std(HonI_G_vaf))/(sqrt(numVals));
    ste_HonI_G_mse = (std(HonI_G_mse))/(sqrt(numVals));
    
    mean_HonW_G_R2 = mean(HonW_G_R2);
    mean_HonW_G_vaf = mean(HonW_G_vaf);
    mean_HonW_G_mse = mean(HonW_G_mse);
    ste_HonW_G_R2 = (std(HonW_G_R2))/(sqrt(numVals));
    ste_HonW_G_vaf = (std(HonW_G_vaf))/(sqrt(numVals));
    ste_HonW_G_mse = (std(HonW_G_mse))/(sqrt(numVals));

    
end


