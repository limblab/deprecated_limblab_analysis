function [R2, nfold] = mfxval(binnedData, dataPath, foldlength, fillen, UseAllInputsOption, PolynomialOrder,varargin)
%       R2                  : returns a (numFold,numSignals) array of R2 values, and number of folds 
%
%       binnedData          : data structure to build model from
%       dataPath            : string of the path of the data folder
%       UseAllInputsOption  : 1 to use all inputs, 2 to specify a neuronID file
%       PolynomialOrder     : order of the Weiner non-linearity (0=no Polynomial)
%       varargin = {PredEMG, PredForce, PredCursPos} : flags to include
%       EMG, Force and Cursor Position in the prediction model (0=no,1=yes)

if ~isstruct(binnedData)
    binnedData = LoadDataStruct(binnedData, 'binned');
end

% default value for prediction flags
PredEMG = 1;
PredForce = 0;
PredCursPos = 0;

numSig = size(binnedData.emgguide,1);

%overwrite if specified in arguments
if nargin > 6
    PredEMG = varargin{1};
    if ~PredEMG
        numSig = 0;
    end
    if nargin > 7
        PredForce = varargin{2};
        if PredForce
            numSig = numSig+size(binnedData.forcelabels,1);
        end
        if nargin > 8
            PredCursPos = varargin{3};
            if PredCursPos
                numSig = numSig+size(binnedData.cursorposlabels,1);
            end
        end
    end
end


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


%allocate structs
testData = binnedData;
modelData = binnedData;


for i=0:nfold-1
    
    disp(sprintf('processing xval %d of %d',i+1,nfold));

    testDataStart = round(1 + i*foldlength/binsize);      %move the test block from beginning of file up to the end,round because of floating point error
    testDataEnd = round(testDataStart + foldlength/binsize - 1);    

    %copy timeframe and spikeratedata segments into testData
    testData.timeframe = binnedData.timeframe(testDataStart:testDataEnd);
    testData.spikeratedata = binnedData.spikeratedata(testDataStart:testDataEnd,:);
    
    %copy timeframe and spikeratedata segments into modelData
    if testDataStart == 1
        modelData.timeframe = binnedData.timeframe(testDataEnd+1:dataEnd);    
        modelData.spikeratedata = binnedData.spikeratedata(testDataEnd+1:dataEnd,:);
    elseif testDataEnd == dataEnd
        modelData.timeframe = binnedData.timeframe(1:testDataStart-1);
        modelData.spikeratedata = binnedData.spikeratedata(1:testDataStart-1,:);
    else
        modelData.timeframe = [ binnedData.timeframe(1:testDataStart-1); binnedData.timeframe(testDataEnd+1:dataEnd)];
        modelData.spikeratedata = [ binnedData.spikeratedata(1:testDataStart-1,:); binnedData.spikeratedata(testDataEnd+1:dataEnd,:)];        
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
    
    filter = BuildModel(modelData, dataPath, fillen, UseAllInputsOption, PolynomialOrder, PredEMG, PredForce, PredCursPos);

    PredData = predictSignals(filter, testData);
    
    TestSigs = concatSigs(testData, PredEMG, PredForce, PredCursPos);
    
    R2(i+1,:) = CalculateR2(TestSigs(round(filter.fillen/binsize):end,:),PredData.preddatabin)';
    
end
   
    
    