% newGeneralizability | Created 08-10-14
function [H HonI_vaf IonI_vaf WonI_vaf HonW_vaf WonW_vaf IonW_vaf] = newGeneralizabilityStats_Jan2015(IsoTest, IsoTrain, WmTest, WmTrain,HybridFinal)

% % Step 5 | Make H variable for the EMGs of interest
[H] = quickHybridDecoder(HybridFinal);
%BuildNormalModels
options=[]; options.PredEMGs = 1;
IsoModelAll = BuildModel(IsoTrain, options);
WmModelAll = BuildModel(WmTrain, options);
HybridUnMod = BuildModel(HybridFinal, options);

% Step 6 | Use H variable to make predictions
[HonIpred,~,HonIact]=predMIMO4(IsoTest.spikeratedata,H,1,1,IsoTest.emgdatabin);
[HonWpred,~,HonWact]=predMIMO4(WmTest.spikeratedata,H,1,1,WmTest.emgdatabin);

[IonIpred,~,IonIact]=predMIMO4(IsoTest.spikeratedata,IsoModelAll.H,1,1,IsoTest.emgdatabin);
[IonWpred,~,IonWact]=predMIMO4(WmTest.spikeratedata,IsoModelAll.H,1,1,WmTest.emgdatabin);

[WonWpred,~,WonWact]=predMIMO4(WmTest.spikeratedata,WmModelAll.H,1,1,WmTest.emgdatabin);
[WonIpred,~,WonIact]=predMIMO4(IsoTest.spikeratedata,WmModelAll.H,1,1,IsoTest.emgdatabin);


%Step 7 | Calculate VAFs -----------------------------------------------------------
HonI_vaf = calculateVAF(HonIpred,HonIact);
HonW_vaf = calculateVAF(HonWpred,HonWact);
IonI_vaf = calculateVAF(IonIpred,IonIact);
WonW_vaf = calculateVAF(WonWpred,WonWact);
IonW_vaf = calculateVAF(IonWpred,IonWact);
WonI_vaf = calculateVAF(WonIpred,WonIact);

end