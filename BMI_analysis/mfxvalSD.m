function [R2, varargout] = mfxvalSD(binnedData, options)
%       R2                  : returns a (numFold,numSignals) array of R2 values 
%
%       binnedData          : data structure to build model from
%       options             : structure with fields:
%           dataPath            : string of the path of the data folder
%           foldlength          : fold length in seconds (typically 60)
%           fillen              : filter length in seconds (tipically 0.5)
%           UseAllInputsOption  : 1 to use all inputs, 2 to specify a neuronID file
%           PolynomialOrder     : order of the Weiner non-linearity (0=no Polynomial)
%           PredEMG, PredForce, PredCursPos, PredVeloc, Use_SD,plotflag, EMGcascade:
%                                 flags to include EMG, Force, CursPos, Velocity in the prediction model (0=no,1=yes)
%                                 also options to use State-dependent or EMG cascade dec.
%                                 Note on Use_SD      : The value of Use_SD should be set to correspond to the column index in binnedData.states
%                                 that the user wants to use. In other words, its value determines the classification method
%                                 to be used.
%           EMGcascade          : will call BuildModel twice, to
%                                 provide a neuron-to-emg decoder followed 
%                                 by an emg-to-cursorposition decoder
%           plotflag            : plot predictions after xval
%
%       Note on options: not all the fields have to be present in the
%       'option' structure provided in arguments. Those that are not will
%       be filled with the values from 'ModelBuildingDefault.m'
%
%       Note on Use_SD      : The value of Use_SD should be set to correspond to the column index in binnedData.states
%                             that the user wants to use. In other words, its value determines the classification method
%                             to be used.
%
%       varargout = {vaf, mse, AllPredData, binnedData};

%% Argument Options
if ~isstruct(binnedData)
    binnedData = LoadDataStruct(binnedData, 'binned');
end

% default values for options:
default_options = ModelBuildingDefault();
% fill other options as provided
all_option_names = fieldnames(default_options);
for i=1:numel(all_option_names)
    if ~isfield(options,all_option_names(i))
        options.(all_option_names{i}) = default_options.(all_option_names{i});
    end
end
clear default_options all_option_names;

%% 
binsize = binnedData.timeframe(2)-binnedData.timeframe(1);

if mod(round(foldlength*1000), round(binsize*1000)) %all this rounding because of floating point errors
    disp('specified fold length must be a multiple of the data bin size');
    disp('operation aborted');
    return;
end

duration = size(binnedData.timeframe,1);
nfold = floor(round(binsize*1000)*duration/(1000*foldlength)); % again, because of floating point errors
dataEnd = round(nfold*foldlength/binsize);


R2 = zeros(nfold,numSig);
vaf= zeros(nfold,numSig);
mse= zeros(nfold,numSig);

%allocate structs
testData = binnedData;
modelData = binnedData;

% nfold = 1; % for testing

for i=0:nfold-1
    
    disp(sprintf('processing xval %d of %d',i+1,nfold));

    testDataStart = round(1 + i*foldlength/binsize);      %move the test block from beginning of file up to the end,round because of floating point error
    testDataEnd = round(testDataStart + foldlength/binsize - 1);    

    %copy timeframe and spikeratedata segments into testData
    testData.timeframe = binnedData.timeframe(testDataStart:testDataEnd);
    testData.spikeratedata = binnedData.spikeratedata(testDataStart:testDataEnd,:);
    if Use_SD
        testData.states = binnedData.states(testDataStart:testDataEnd,:);
    end
    
    %copy timeframe and spikeratedata segments into modelData
    if testDataStart == 1
        modelData.timeframe = binnedData.timeframe(testDataEnd+1:dataEnd);    
        modelData.spikeratedata = binnedData.spikeratedata(testDataEnd+1:dataEnd,:);
        if Use_SD
            modelData.states = binnedData.states(testDataEnd+1:dataEnd,:);
        end
    elseif testDataEnd == dataEnd
        modelData.timeframe = binnedData.timeframe(1:testDataStart-1);
        modelData.spikeratedata = binnedData.spikeratedata(1:testDataStart-1,:);
        if Use_SD
            modelData.states = binnedData.states(1:testDataStart-1,:);
        end
    else
        modelData.timeframe = [ binnedData.timeframe(1:testDataStart-1); binnedData.timeframe(testDataEnd+1:dataEnd)];
        modelData.spikeratedata = [ binnedData.spikeratedata(1:testDataStart-1,:); binnedData.spikeratedata(testDataEnd+1:dataEnd,:)];        
        if Use_SD
            modelData.states = [ binnedData.states(1:testDataStart-1,:); binnedData.states(testDataEnd+1:dataEnd,:)];
        end
    end

    % copy emgdatabin segment into modelData only if PredEMG
    if PredEMG
        testData.emgdatabin = binnedData.emgdatabin(testDataStart:testDataEnd,:);    
        if testDataStart == 1
            modelData.emgdatabin = binnedData.emgdatabin(testDataEnd+1:dataEnd,:);    
        elseif testDataEnd == dataEnd
            modelData.emgdatabin = binnedData.emgdatabin(1:testDataStart-1,:);
        else
            modelData.emgdatabin = [ binnedData.emgdatabin(1:testDataStart-1,:); binnedData.emgdatabin(testDataEnd+1:dataEnd,:)];
        end
    end

    % copy forcedatabin segment into modelData only if PredForce
    if PredForce
        testData.forcedatabin = binnedData.forcedatabin(testDataStart:testDataEnd,:);    
        if testDataStart == 1
            modelData.forcedatabin = binnedData.forcedatabin(testDataEnd+1:dataEnd,:);    
        elseif testDataEnd == dataEnd
            modelData.forcedatabin = binnedData.forcedatabin(1:testDataStart-1,:);
        else
            modelData.forcedatabin = [ binnedData.forcedatabin(1:testDataStart-1,:); binnedData.forcedatabin(testDataEnd+1:dataEnd,:)];
        end
    end

    % copy cursorposbin segment into modelData only if PredCursPos
    if PredCursPos
        testData.cursorposbin = binnedData.cursorposbin(testDataStart:testDataEnd,:);    
        if testDataStart == 1
            modelData.cursorposbin = binnedData.cursorposbin(testDataEnd+1:dataEnd,:);    
        elseif testDataEnd == dataEnd
            modelData.cursorposbin = binnedData.cursorposbin(1:testDataStart-1,:);
        else
            modelData.cursorposbin = [ binnedData.cursorposbin(1:testDataStart-1,:); binnedData.cursorposbin(testDataEnd+1:dataEnd,:)];
        end
    end    
    
    % copy velocbin segement into modelData only if PredVeloc
    if PredVeloc
        testData.velocbin = binnedData.velocbin(testDataStart:testDataEnd,:);    
        if testDataStart == 1
            modelData.velocbin = binnedData.velocbin(testDataEnd+1:dataEnd,:);    
        elseif testDataEnd == dataEnd
            modelData.velocbin = binnedData.velocbin(1:testDataStart-1,:);
        else
            modelData.velocbin = [ binnedData.velocbin(1:testDataStart-1,:); binnedData.velocbin(testDataEnd+1:dataEnd,:)];
        end
    end

    if Use_SD
    
        % Train classifiers using modelData - Predict testData states
        fprintf('Classification...');
        tic;
        [modelData.states,modelData.statemethods,modelData.classifiers] = findStates(modelData,0,Use_SD);
        [testData.states,testData.statemethods,testData.classifiers] = testClassifiers(modelData,testData,Use_SD);
        toc;

        % Build 2 different models, one for each state:
        fprintf('Model Building...');
        tic;
        filter = BuildSDModel(modelData, dataPath, fillen, UseAllInputsOption, PolynomialOrder, PredEMG, PredForce, PredCursPos, PredVeloc, Use_SD);
        toc;

        general_decoder = filter{1};
        posture_decoder = filter{2};
        movement_decoder= filter{3};

        filter = struct('general_decoder',general_decoder,...
                        'posture_decoder',posture_decoder,...
                        'movement_decoder',movement_decoder);
        tic;
        PredData = predictSDSignals(filter, testData, Use_SD);
        toc;

    else

        model = BuildModel(modelData, dataPath, fillen, UseAllInputsOption, PolynomialOrder, PredEMG, PredForce, PredCursPos, PredVeloc);
        PredData = predictSignals(model, testData);

    end
    
    TestSigs = concatSigs(testData, PredEMG, PredForce, PredCursPos, PredVeloc); 
    R2(i+1,:,1) = CalculateR2(TestSigs(round(fillen/binsize):end,:),PredData.preddatabin)';
%     vaf(i+1,:,1)= 1-var(PredData.preddatabin - TestSigs(round(fillen/binsize):end,:)) ./var(TestSigs(round(fillen/binsize):end,:));
    vaf(i+1,:,1) = 1 - sum( (PredData.preddatabin-TestSigs(round(fillen/binsize):end,:)).^2 ) ./ ...
        sum( (TestSigs(round(fillen/binsize):end,:) - ...
        repmat(mean(TestSigs(round(fillen/binsize):end,:)),...
        size(TestSigs(round(fillen/binsize):end,:),1),1)).^2 );  
    mse(i+1,:,1)= mean((PredData.preddatabin-TestSigs(round(fillen/binsize):end,:)).^2);

    %Concatenate predicted Data if we want to plot it later:
    %Skip this for the first fold
    if i == 0
        AllPredData = PredData;
        AllPredData.states = testData.states((end-size(PredData.preddatabin,1)+1):end,:);
    else
        AllPredData.timeframe = [AllPredData.timeframe; PredData.timeframe];
        AllPredData.preddatabin=[AllPredData.preddatabin;PredData.preddatabin];
        AllPredData.states = [AllPredData.states; testData.states((end-size(PredData.preddatabin,1)+1):end,:)];
    end
                
end %for i=1:nfold




% Plot Actual and Predicted Data
idx = false(size(binnedData.timeframe));
for i = 1:length(AllPredData.timeframe)
    idx = idx | binnedData.timeframe == AllPredData.timeframe(i);
end    

if PredEMG
    binnedData.emgdatabin = binnedData.emgdatabin(idx,:);
end
if PredForce
    binnedData.forcedatabin = binnedData.forcedatabin(idx,:);
end
if PredCursPos
    binnedData.cursorposbin = binnedData.cursorposbin(idx,:);
end
if PredVeloc
    binnedData.velocbin = binnedData.velocbin(idx,:);
end

binnedData.timeframe = binnedData.timeframe(idx);

if plotflag
    ActualvsOLPred(binnedData,AllPredData,plotflag);
end

AllPredData.mfxval.R2 = R2;
AllPredData.mfxval.vaf= vaf;
AllPredData.mfxval.mse= mse;

% varargout{1} = AllPredData;
% varargout{2} = nfold;
varargout = {vaf, mse, AllPredData, binnedData};