%% data
numlags = 10;
start = 1;
stop  = 2*numlags;

% binnedData.spikeratedata = 20*ones(size(binnedData.spikeratedata));
binnedData.spikeratedata = 20*zeros(size(binnedData.spikeratedata));
testData = data_segment(binnedData,start,stop,'bin');
tempData = data_segment(binnedData,start+numlags-1,stop,'bin');

%% Preds
[FfromN] = predictSignals(N2F,testData);
[FfromNR]= predictSignals(N2FR,testData);
[EfromN] = predictSignals(N2E,testData);
tempData.emgdatabin = EfromN.preddatabin;
[FfromE] = predictSignals(E2F,tempData);


%% delta spike
testData.spikeratedata = testData.spikeratedata + 20;
[dFfromN] = predictSignals(N2F,testData);
[dFfromNR]= predictSignals(N2FR,testData);
[dEfromN] = predictSignals(N2E,testData);
tempData.emgdatabin = dEfromN.preddatabin;
[dFfromE] = predictSignals(E2F,tempData);

%% stability measure
dE       = dEfromN.preddatabin(1,:) - EfromN.preddatabin(1,:)
dFdirect = dFfromN.preddatabin(1,:) - FfromN.preddatabin(1,:)
dFcascade= dFfromE.preddatabin(1,:) - FfromE.preddatabin(1,:)
dFregul  = dFfromNR.preddatabin(1,:)- FfromNR.preddatabin(1,:)
% dE       = dEfromN.preddatabin(1,:)
% dFdirect = dFfromN.preddatabin(1,:)
% dFcascade= dFfromE.preddatabin(1,:)
% dFregul  = dFfromNR.preddatabin(1,:)
