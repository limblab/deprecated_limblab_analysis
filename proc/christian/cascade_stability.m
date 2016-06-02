%% data
start = 2405;
stop  = 2430;

testData = binnedData;
testData.timeframe     = testData.timeframe(start:stop);
testData.spikeratedata = testData.spikeratedata(start:stop,:);
testData.emgdatabin    = testData.emgdatabin(start:stop,:);
testData.cursorposbin  = testData.cursorposbin(start:stop,:);

% spikesUL = binnedData.spikeratedata(start:stop, :);
% 
% EMGsUL = binnedData.emgdatabin(start:stop, :);
% PosUL1 = binnedData.cursorposbin(start:stop, :);
% PosUL2 = binnedData.cursorposbin(start+9:stop, :);
 
%% calc preds
[N2EPreds,spikeNew,EMGsULnew]=predMIMO3(spikesUL,N2E.H,1,1,EMGsUL);
    PredictedData = N2EPreds;
    decoder = N2E;
    Ynonlinear=zeros(size(PredictedData));
    for z=1:size(PredictedData,2);
        Ynonlinear(:,z) = polyval(decoder.P(:,z),PredictedData(:,z));
    end
    N2EPreds = Ynonlinear;
    
[N2FPreds,spikeNew1,PosULnew1]=predMIMO3(spikesUL,N2F.H,1,1,PosUL1);
    PredictedData = N2FPreds;
    decoder = N2F;
    Ynonlinear=zeros(size(PredictedData));
    for z=1:size(PredictedData,2);
        Ynonlinear(:,z) = polyval(decoder.P(:,z),PredictedData(:,z));
    end
    N2FPreds = Ynonlinear;
    
[E2FPreds,spikeNew2,PosULnew2]=predMIMO3(N2EPreds,E2F.H,1,1,PosUL2);
    PredictedData = E2FPreds;
    decoder = E2F;
    Ynonlinear=zeros(size(PredictedData));
    for z=1:size(PredictedData,2);
        Ynonlinear(:,z) = polyval(decoder.P(:,z),PredictedData(:,z));
    end
    E2FPreds = Ynonlinear;

%% preds with delta spike    
dspikesUL = spikesUL - 20;

[dN2EPreds,dspikeNew,dEMGsULnew]=predMIMO3(dspikesUL,N2E.H,1,1,EMGsUL);
    PredictedData = dN2EPreds;
    decoder = N2E;
    Ynonlinear=zeros(size(PredictedData));
    for z=1:size(PredictedData,2);
        Ynonlinear(:,z) = polyval(decoder.P(:,z),PredictedData(:,z));
    end
    dN2EPreds = Ynonlinear;
    
[dN2FPreds,dspikeNew1,PosULnew1]=predMIMO3(dspikesUL,N2F.H,1,1,PosUL1);
    PredictedData = dN2FPreds;
    decoder = N2F;
    Ynonlinear=zeros(size(PredictedData));
    for z=1:size(PredictedData,2);
        Ynonlinear(:,z) = polyval(decoder.P(:,z),PredictedData(:,z));
    end
    dN2FPreds = Ynonlinear;

[dE2FPreds,dspikeNew2,PosULnew2]=predMIMO3(dN2EPreds,E2F.H,1,1,PosUL2);
    PredictedData = dE2FPreds;
    decoder = E2F;
    Ynonlinear=zeros(size(PredictedData));
    for z=1:size(PredictedData,2);
        Ynonlinear(:,z) = polyval(decoder.P(:,z),PredictedData(:,z));
    end
    dE2FPreds = Ynonlinear;

%% compare

dN = 20;
dE = dN2EPreds-N2EPreds;
dFdirect = dN2FPreds - N2FPreds
dFcascade= dE2FPreds - E2FPreds