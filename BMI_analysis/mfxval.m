function [R2, nfold] = mfxval(binnedData, dataPath, foldlength, fillen, UseAllInputsOption, PolynomialOrder)

if ~isstruct(binnedData)
    binnedData = LoadDataStruct(binnedData, 'binned');
end

numEMGs = size(binnedData.emgguide,1);
binsize = binnedData.timeframe(2)-binnedData.timeframe(1);


if mod(round(foldlength*1000), round(binsize*1000)) %all this complicated rounding because of floating point errors
    disp('specified fold length must be a multiple of the data bin size');
    disp('operation aborted');
    return;
end

duration = size(binnedData.timeframe,1);
nfold = floor(round(binsize*1000)*duration/(1000*foldlength)); % again, because of floating point errors
dataEnd = round(nfold*foldlength/binsize);
R2 = zeros(nfold,numEMGs);


%allocate structs
testData = binnedData;
modelData = binnedData;


for i=0:nfold-1
    
    disp(sprintf('processing xval %d of %d',i+1,nfold));

    testDataStart = round(1 + i*foldlength/binsize);      %move the test block from beginning of file up to the end,round because of floating point error
    testDataEnd = round(testDataStart + foldlength/binsize - 1);    
    
    testData.timeframe = binnedData.timeframe(testDataStart:testDataEnd);
    testData.emgdatabin = binnedData.emgdatabin(testDataStart:testDataEnd,:);
    testData.spikeratedata = binnedData.spikeratedata(testDataStart:testDataEnd,:);
    
    if testDataStart == 1
        modelData.timeframe = binnedData.timeframe(testDataEnd+1:dataEnd);
        modelData.emgdatabin = binnedData.emgdatabin(testDataEnd+1:dataEnd,:);
        modelData.spikeratedata = binnedData.spikeratedata(testDataEnd+1:dataEnd,:);
        
    elseif testDataEnd == dataEnd
        modelData.timeframe = binnedData.timeframe(1:testDataStart-1);
        modelData.emgdatabin = binnedData.emgdatabin(1:testDataStart-1,:);
        modelData.spikeratedata = binnedData.spikeratedata(1:testDataStart-1,:);

    else
        modelData.timeframe = [ binnedData.timeframe(1:testDataStart-1); binnedData.timeframe(testDataEnd+1:dataEnd)];
        modelData.emgdatabin = [ binnedData.emgdatabin(1:testDataStart-1,:); binnedData.emgdatabin(testDataEnd+1:dataEnd,:)];
        modelData.spikeratedata = [ binnedData.spikeratedata(1:testDataStart-1,:); binnedData.spikeratedata(testDataEnd+1:dataEnd,:)];
    end
    
    filter = BuildModel(modelData, dataPath, fillen, UseAllInputsOption, PolynomialOrder);
    PredData = predictEMGs(filter, testData);
    
    R2(i+1,:) = CalculateR2(testData.emgdatabin(round(filter.fillen/binsize):end,:),PredData.predemgbin)';
    
end
   
    
    