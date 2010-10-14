
dataPath = '';
fillen = 0.5;
UseAllInputsOption = 1;
PolynomialOrder = 0;
PredEMG      = 0;
PredForce    = 0;
PredCursPos  = 1;
Use_Thresh   = 0;
FiltPred     = 0;
R2 = zeros(10,2);
plotflag = 0;

binsize = round(1000*(binnedData.timeframe(2)-binnedData.timeframe(1)))/1000;
one_minute = 60/binsize;   
num_mins = floor(length(binnedData.timeframe)/one_minute);

for i = 1:num_mins-10 %use continuous 10 mins to build model, and predict next minute

    
    start_bin_model = (i-1)*one_minute + 1;
    end_bin_model   = start_bin_model  + 10*one_minute -1;
    start_bin_test  = end_bin_model    + 1;
    end_bin_test    = start_bin_test   + one_minute    -1;
    
%     disp(sprintf('MStart:\t%d\tMStop:\t%d\nTStart:\t%d\tTStop:\t%d',...
%             start_bin_model, end_bin_model, start_bin_test, end_bin_test));
        
    desiredInputs = get_desired_inputs(binnedData.spikeguide, NeuronIDs);
    
    ModelData.timeframe = binnedData.timeframe(start_bin_model:end_bin_model,:);
    ModelData.cursorposbin = binnedData.cursorposbin(start_bin_model:end_bin_model,:);
    ModelData.spikeratedata= binnedData.spikeratedata(start_bin_model:end_bin_model,desiredInputs);
    ModelData.spikeguide = neuronIDs2spikeguide(NeuronIDs);
    ModelData.cursorposlabels = binnedData.cursorposlabels;
    
    TestData.timeframe = binnedData.timeframe(start_bin_test:end_bin_test,:);
    TestData.cursorposbin = binnedData.cursorposbin(start_bin_test:end_bin_test,:);
    TestData.spikeratedata= binnedData.spikeratedata(start_bin_test:end_bin_test,:);
    TestData.spikeguide = binnedData.spikeguide;
    TestData.cursorposlabels = binnedData.cursorposlabels;
    TestData.emgdatabin =[];
    TestData.forcedatabin = [];
    
    %build model
	filter = BuildModel(ModelData, dataPath, fillen, UseAllInputsOption, PolynomialOrder, PredEMG,PredForce,PredCursPos,Use_Thresh);
    %Predic data
    PredData = predictSignals(filter, TestData);
    R2(i,:) = ActualvsOLPred(TestData,PredData,plotflag);
end