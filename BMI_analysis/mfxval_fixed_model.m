function [R2, nfold] = mfxval_fixed_model(filter,binnedData,foldlength)

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

%allocate test data
testData = binnedData;

for i=0:nfold-1
    
    disp(sprintf('processing xval %d of %d',i+1,nfold));

    testDataStart = round(1 + i*foldlength/binsize);      %move the test block from beginning of file up to the end,round because of floating point error
    testDataEnd = round(testDataStart + foldlength/binsize - 1);    
    
    testData.timeframe = binnedData.timeframe(testDataStart:testDataEnd);
    testData.emgdatabin = binnedData.emgdatabin(testDataStart:testDataEnd,:);
    testData.spikeratedata = binnedData.spikeratedata(testDataStart:testDataEnd,:);
    
    PredData = predictEMGs(filter, testData);
    
    R2(i+1,:) = CalculateR2(testData.emgdatabin(round(filter.fillen/binsize):end,:),PredData.predemgbin)';
    
end
   
    
    