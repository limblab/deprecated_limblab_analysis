% %Example of Adapt parameters:
% Adapt.Enable = true;
% Adapt.LR     = 1e-7;
% Adapt.Lag    = 10;
% Adapt.Period = 1; %num trials between adaptation ** 4-8-12: Period higher than 1 don't work! have to check why
% [Adapt.EMGpatterns, Adapt.EMGLabels] = ave_emgs_wf(testData, 0.5, 0,1:12, 1);
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

load('C:\Users\limblab\Desktop\AdaptationData\TestData\fakeNeurRealEMGs_AdaptParams4.mat');

%% Fixed no drop:
Adapt.Enable = false;
[R2FF, filter_out, PredData, vaf, mse, ActSignalsTrunk]= PeriodicR2(filter,testData,foldlength,Adapt);

% Plot predictions:
[numR2,numEMGs] = size(R2FF);
xa = PredData.timeframe/60;
for i = 1:numEMGs
    figure; hold on;
    plot(xa,ActSignalsTrunk(:,i),'k');
    plot(xa,PredData.preddatabin(:,i),'r');
    title(sprintf('%s\nFixed Linear Decoder',nonzeros(testData.emgguide(i,:))));
    xlabel('Time (min)'); ylabel('EMG');
end

% Plot R2:
[numR2,numEMGs] = size(R2FF);
xa = (1:numR2)*foldlength/60;
for i = 1:numEMGs
    figure; plot(xa,R2FF(:,i)); ylim([0 1]);
    title(sprintf('%s\nFixed Linear Decoder',nonzeros(testData.emgguide(i,:))));
    xlabel('Time (min)'); ylabel('R2');
end
figure; plot(xa, mean(R2FF,2));ylim([0 1]);
title(sprintf('Average Accross Muscles\nFixed Linear Decoder'));
xlabel('Time (min)');
ylabel('R2');    


%% Adapt no drop, init optimal filter:
Adapt.Enable = true;
[R2AF, filter_out, PredData, vaf, mse, ActSignalsTrunk]= PeriodicR2(filter,testData,foldlength,Adapt);

% Plot predictions:
[numR2,numEMGs] = size(R2AF);
xa = PredData.timeframe/60;
for i = 1:numEMGs
    figure; hold on;
    plot(xa,ActSignalsTrunk(:,i),'k');
    plot(xa,PredData.preddatabin(:,i),'r');
    title(sprintf('%s\nAdaptive Decoder',nonzeros(testData.emgguide(i,:))));
    xlabel('Time (min)'); ylabel('EMG');
end

% Plot R2:
xa = (1:numR2)*foldlength/60;
for i = 1:numEMGs
    figure; plot(xa,R2AF(:,i)); ylim([0 1]);
    title(sprintf('%s\nAdaptive Decoder',nonzeros(testData.emgguide(i,:))));
    xlabel('Time (min)'); ylabel('R2');
end
figure; plot(xa, mean(R2AF,2));ylim([0 1]);
title(sprintf('Average Accross Muscles\nAdaptive Decoder'));
xlabel('Time (min)');
ylabel('R2');    


%% Adapt no drop, Init random
Adapt.Enable = true;
filt_rand = randomize_weights(filter);

[R2A, filter_out, PredData, vaf, mse, ActSignalsTrunk]= PeriodicR2(filt_rand,testData,foldlength,Adapt);

figure;hold on;
plot(PredData.timeframe,ActSignalsTrunk(:,2),'k');
plot(PredData.timeframe,PredData.preddatabin(:,2),'r');

figure;
plot(PredData.timeframe,PredData.preddatabin(:,1),'r');
hold on;
plot(PredData.timeframe,ActSignalsTrunk(:,1),'k');


%% Fixed and Adapt with enhanced input non-stationarity
Adapt.Enable = true;
pctDrop = 5;
pctPerm = 5;
DP_period = 12000;
initType = 1;
NumIter = 10;
foldlength = 300;
Adapt.NcorrWindow = 6000;
Adapt.NcorrThresh = 0.2;

R2Drop = neuron_dropping_tests_EMGpred3(filter,testData,pctDrop,pctPerm,DP_period,initType,NumIter,foldlength,Adapt);

plot_results(R2Drop);


%% Train GLM
numNeur = size(trainData.spikeratedata,2);
B = zeros(numNeur);
for n = 1:numNeur
    disp(sprintf('training glm on neuron %d',n));
    if n==1
        otherNs = 2:numNeur;
    elseif n==numNeur
        otherNs = 1:numNeur-1;
    else
        otherNs = [1:n-1 n+1:numNeur];
    end
    X = trainData.spikeratedata(:,otherNs)/20;
    Y = trainData.spikeratedata(:,n)/20;
    B(:,n) = glmfit(X,Y,'poisson');
end


