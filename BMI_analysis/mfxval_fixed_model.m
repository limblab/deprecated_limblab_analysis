function [R2, nfold, varargout] = mfxval_fixed_model(filter,binnedData,foldlength,varargin)

%       R2                  : returns a (numFold,numSignals) array of R2 values, and number of folds 
%
%       binnedData          : data structure to build model from
%       foldlength          : fold length in seconds

numSig = size(filter.outnames,1);
binsize = filter.binsize;
Lag = 0;

if nargin > 3
    Adapt = varargin{1};
    LR    = varargin{2};
    Lag   = varargin{3};
    if nargin > 6
        Smooth = varargin{7};
    else
        Smooth = false;
    end
else
    Adapt = false;
    LR = 0;
    Lag = 0;
    Smooth = false;
end


% default value for prediction flags
PredEMG = 1;
PredForce = 0;
PredCursPos = 0;

if mod(round(foldlength*1000), round(binsize*1000)) %all this rounding because of floating point errors
    disp('specified fold length must be a multiple of the data bin size');
    disp('operation aborted');
    return;
end

duration = size(binnedData.timeframe,1);
nfold = floor(round(binsize*1000)*duration/(1000*foldlength)); % again, because of floating point errors
dataEnd = round(nfold*foldlength/binsize);
R2 = zeros(nfold,numSig);

%allocate test data
testData = binnedData;

for i=0:nfold-1
    
    disp(sprintf('processing xval %d of %d',i+1,nfold));

    testDataStart = round(1 + i*foldlength/binsize);      %move the test block from beginning of file up to the end,round because of floating point error
    testDataEnd = round(testDataStart + foldlength/binsize - 1);    
    
    testData.timeframe = binnedData.timeframe(testDataStart:testDataEnd); 
    testData.spikeratedata = binnedData.spikeratedata(testDataStart:testDataEnd,:);
    if ~isempty(binnedData.emgdatabin)
        testData.emgdatabin = binnedData.emgdatabin(testDataStart:testDataEnd,:);
    end
    if ~isempty(binnedData.forcedatabin)
        testData.forcedatabin = binnedData.forcedatabin(testDataStart:testDataEnd,:);
    end
    if ~isempty(binnedData.cursorposbin)
        testData.cursorposbin = binnedData.cursorposbin(testDataStart:testDataEnd,:);
    end
    if isfield(binnedData,'words')
        testData.words = binnedData.words(binnedData.words(:,1)>=binnedData.timeframe(testDataStart) & ...
                                          binnedData.words(:,1)<=binnedData.timeframe(testDataEnd) ,:);
    end
    if ~isempty(binnedData.targets)
        testData.targets.corners = binnedData.targets.corners(binnedData.targets.corners(:,1)>= binnedData.timeframe(testDataStart) & ...
                                                              binnedData.targets.corners(:,1)<= binnedData.timeframe(testDataEnd), :);
    end
           
        
%     PredData = predictSignals(filter, testData);
%     Smooth = false;
%     LR = 1e-7;
%     lag = 0.5;
    if isfield(filter, 'PC')
        numPCs = size(filter.PC,2);
        [PredData, Hnew] = predictSignals(filter,testData,Smooth,Adapt,LR,Lag,numPCs);
    else
        [PredData, Hnew] = predictSignals(filter,testData,Smooth,Adapt,LR,Lag);
    end
    if Adapt
        filter.H = Hnew;
    end
    
    varargout = {filter};
    
    R2(i+1,:) = ActualvsOLPred(testData,PredData,0);
%     R2(i+1,:) = CalculateR2(testData.emgdatabin(round(filter.fillen/binsize):end,:),PredData.predemgbin)';
    
end
   
    
    