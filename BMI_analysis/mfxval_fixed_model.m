function [R2, nfold, varargout] = mfxval_fixed_model(filter,binnedData,foldlength,varargin)

%       R2                  : returns a (numFold,numSignals) array of R2 values, and number of folds 
%
%       binnedData          : data structure to build model from
%       foldlength          : fold length in seconds
%       varargin            : [Adapt Smooth];

numSig = size(filter.outnames,1);
binsize = filter.binsize;

if nargin > 3
    Adapt = varargin{1};
    if nargin > 4
        Smooth = varargin{2};
    else
        Smooth = false;
    end
else
    Adapt.Enable = false;
    Adapt.LR = 0;
    Adapt.Lag = 0;
    Smooth = false;
end


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

%allocate test data
testData = binnedData;

for i=0:nfold-1
    
%     disp(sprintf('processing xval %d of %d',i+1,nfold));

    testDataStart = round(1 + i*foldlength/binsize);      %move the test block from beginning of file up to the end,round because of floating point error
    testDataEnd = round(testDataStart + foldlength/binsize - 1);    
    
    testData.timeframe = binnedData.timeframe(testDataStart:testDataEnd); 
    testData.spikeratedata = binnedData.spikeratedata(testDataStart:testDataEnd,:);
    if isfield(binnedData,'emgdatabin')
        if ~isempty(binnedData.emgdatabin)
            testData.emgdatabin = binnedData.emgdatabin(testDataStart:testDataEnd,:);
        end
    end
    if isfield(binnedData,'forcedatabin')
        if ~isempty(binnedData.forcedatabin)
            testData.forcedatabin = binnedData.forcedatabin(testDataStart:testDataEnd,:);
        end
    end
    if isfield(binnedData,'cursorposbin')
        if ~isempty(binnedData.cursorposbin)
            testData.cursorposbin = binnedData.cursorposbin(testDataStart:testDataEnd,:);
        end
    end
    if isfield(binnedData,'words')
        if isfield(binnedData,'words')
            testData.words = binnedData.words(binnedData.words(:,1)>=binnedData.timeframe(testDataStart) & ...
                binnedData.words(:,1)<=binnedData.timeframe(testDataEnd) ,:);
        end
    end
    if isfield(binnedData,'targets')
        if ~isempty(binnedData.targets)
            testData.targets.corners = binnedData.targets.corners(binnedData.targets.corners(:,1)>= binnedData.timeframe(testDataStart) & ...
                binnedData.targets.corners(:,1)<= binnedData.timeframe(testDataEnd), :);
        end
    end
    if isfield(binnedData,'trialtable')
        if isfield(binnedData,'trialtable')
            %this will work only for MG trial table for now
            testData.trialtable = binnedData.trialtable( binnedData.trialtable(:,1)>=binnedData.timeframe(testDataStart) & ...
                binnedData.trialtable(:,11)<=binnedData.timeframe(testDataEnd) , :);
        end
    end

    if isfield(filter, 'PC')
        numPCs = size(filter.PC,2);
        [PredData, Hnew] = predictSignals(filter,testData,Smooth,Adapt,numPCs);
    else
        [PredData, Hnew] = predictSignals(filter,testData,Smooth,Adapt);
    end
    if Adapt.Enable
        filter.H = Hnew;
    end
       
    [R2(i+1,:), vaf(i+1,:), mse(i+1,:)] = ActualvsOLPred(testData,PredData,0);
%     R2(i+1,:) = CalculateR2(testData.emgdatabin(round(filter.fillen/binsize):end,:),PredData.predemgbin)';

    %Concatenate predicted Data if we want to plot it later:
    %Skip this for the first fold
    if i == 0
        AllPredData = PredData;
    else
        AllPredData.timeframe = [AllPredData.timeframe; PredData.timeframe];
        AllPredData.preddatabin=[AllPredData.preddatabin;PredData.preddatabin];
    end

end



% keep only actual data corresponding to times
% at which we have predictions values
idx = false(size(binnedData.timeframe));
for i = 1:length(AllPredData.timeframe)
    idx = idx | binnedData.timeframe == AllPredData.timeframe(i);
end    
if isfield(binnedData,'emgdatabin')
    if ~isempty(binnedData.emgdatabin)
        binnedData.emgdatabin = binnedData.emgdatabin(idx,:);
    end
end        
if isfield(binnedData,'forcedatabin')
    if ~isempty(binnedData.forcedatabin)
        binnedData.forcedatabin = binnedData.forcedatabin(idx,:);
    end
end
if isfield(binnedData,'cursorposbin')
    if ~isempty(binnedData.cursorposbin)
        binnedData.cursorposbin = binnedData.cursorposbin(idx,:);
    end
end
if isfield(binnedData,'velocbin')
    if ~isempty(binnedData.velocbin)
        binnedData.velocbin = binnedData.velocbin(idx,:);
    end
end
binnedData.timeframe = binnedData.timeframe(idx);

AllPredData.mfxval.R2 = R2;
AllPredData.mfxval.vaf= vaf;
AllPredData.mfxval.mse= mse;

varargout = {filter, vaf, mse, AllPredData, binnedData};
   
    
    