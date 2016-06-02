%% data
numlags = 10;
start = 1;
stop  = 2*numlags;

binnedData.spikeratedata = 20*ones(size(binnedData.spikeratedata));
testData = data_segment(binnedData,start,stop,'bin');
tempData = data_segment(binnedData,start+numlags-1,stop,'bin');

%% Preds

% [FfromNR,~,~]=predMIMO3(testData.spikeratedata,N2FR.H,1,1,testData.cursorposbin);
[FfromN,~,~]=predMIMO3(testData.spikeratedata,N2F.H,1,1,testData.cursorposbin);
[EfromN,~,~]=predMIMO3(testData.spikeratedata,N2E.H,1,1,testData.emgdatabin);
[FfromE,~,~]=predMIMO3(EfromN,E2F.H,1,1,testData.cursorposbin(9:end,:));

dE       = EfromN(1,:)
dFdirect = FfromN(1,:)
dFcascade= FfromE(1,:)
% dFregul  = FfromNR(1,:)
