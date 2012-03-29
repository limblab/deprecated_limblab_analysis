
%Fixed no drop:
Adapt.Enable = false;
[R2FF, filter_out, PredData, vaf, mse, ActSignalsTrunk]= PeriodicR2(filter,concatData2E,foldlength,Adapt);

figure;
plot(PredData.timeframe,PredData.preddatabin(:,2),'r');
hold on;
plot(PredData.timeframe,ActSignalsTrunk(:,2),'k');

%Adapt no drop, Init random
Adapt.Enable = true;
filt_rand = randomize_weights(filter);

[R2AF, filter_out, PredData, vaf, mse, ActSignalsTrunk]= PeriodicR2(filt_rand,concatData2E,foldlength,Adapt);

figure;
plot(PredData.timeframe,PredData.preddatabin(:,2),'r');
hold on;
plot(PredData.timeframe,ActSignalsTrunk(:,2),'k');

figure;
plot(PredData.timeframe,PredData.preddatabin(:,1),'r');
hold on;
plot(PredData.timeframe,ActSignalsTrunk(:,1),'k');


%Fixed, with drop
Adapt.Enable = true;
pctDrop = 2;
pctPerm = 2;
DP_period = 12000;
initType = 2;
NumIter = 10;

R2Drop = neuron_dropping_tests_EMGpred3(filter,concatData,pctDrop,pctPerm,DP_period,initType,NumIter,foldlength,Adapt);