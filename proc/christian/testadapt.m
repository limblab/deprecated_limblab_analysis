% %Example of Adapt parameters:
% Adapt.Enable = true;
% Adapt.LR     = 1e-7;
% Adapt.Lag    = 10;
% Adapt.Period = 1; %num trials between adaptation ** 4-8-12: Period higher than 1 don't work! have to check why
% [Adapt.EMGpatterns, Adapt.EMGLabels] = ave_emgs_wf(testData, 0.5, 0,1:12, 0);
% %i.e. -> [EMGpatterns, EMGLabels] = ave_emgs_wf(binnedData, timeBefore, timeAfter,EMGvector, plotflag)
% % tests with Spike_WFHC_3-5_to_3-9_N:
% % EMGs_v = [10 9 4 13 6 1 3 7 8 11 12 14];
% % EMGs = [ECRb ECRl AbPL FDI FCR2 FDS1 FDP1 FCU1 FCU2 ECU1 ECU2 EDCr];

% %Example of tests parameters:
% DP_period  = 12000; %number of bins between drops and permutations?
% NumIter    = 10;
% foldlength = 120;   %time between calculation of R2,vaf, in seconds
% initType   = 2;     % 1=randomized weigths, 2=linear filter, other = null filter
% pctDrop    = 5;
% pctPerm    = 5;
% testData = ThreshData;

load('C:\Documents and Settings\Christian\My Documents\Dropbox\Adaptation\EMGAdapt_Spike2\testadapt_Data+Params.mat');

%Fixed no drop:
Adapt.Enable = false;
[R2FF, filter_out, PredData, vaf, mse, ActSignalsTrunk]= PeriodicR2(filter,testData,foldlength,Adapt);

figure;
plot(PredData.timeframe,PredData.preddatabin(:,2),'r');
hold on;
plot(PredData.timeframe,ActSignalsTrunk(:,2),'k');

%Adapt no drop, Init random
Adapt.Enable = true;
filt_rand = randomize_weights(filter);

[R2AF, filter_out, PredData, vaf, mse, ActSignalsTrunk]= PeriodicR2(filt_rand,testData,foldlength,Adapt);

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
pctDrop = 0;
pctPerm = 0;
DP_period = 12000;
initType = 2;
NumIter = 1;
foldlength = 300;

R2Drop = neuron_dropping_tests_EMGpred3(filter,testData,pctDrop,pctPerm,DP_period,initType,NumIter,foldlength,Adapt);

plot_results(R2Drop);




