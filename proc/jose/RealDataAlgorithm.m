clear all; close all; clc

load RealData.mat
% Data set: from August 20th to October 9th (10 datasets = 200 min) 
foldlength = 120; % 120 sec = 2 min

% Build Decoder
[filter OffLPredData, trainDataSet R2] = BuildFilterWiener(1:6,2);
R2_mean = mean(R2);

%% Fixed Decoder

Adapt.Enable = false;
[R2FF, filter_out, PredData, vaf, mse, ActSignalsTrunk]= PeriodicR2_2(filter,testData,foldlength,Adapt);

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
mean(R2FF(:))


%% Adapt: Init optimal filter:
Adapt.Enable = true;
Adapt.jtype = 1;
Adapt.Period = 1;
[R2AF, filter_out, PredData, vaf, mse, ActSignalsTrunk]= PeriodicR2_2(filter,testData,foldlength,Adapt);

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
[numR2,numEMGs] = size(R2AF);
xa = (1:numR2)*foldlength/60;
for i = 1:numEMGs
    figure; plot(xa,R2AF(:,i)); ylim([0 1]);
    title(sprintf('%s\nAdaptive Decoder',nonzeros(testData.emgguide(i,:))));
    xlabel('Time (min)'); ylabel('R2');
end

figure; plot(xa, mean(R2AF,2),'b'); ylim([0 1]);
title(sprintf('Average Accross Muscles\nAdaptive Decoder'));
xlabel('Time (min)');
ylabel('R2');    
mean(R2AF(:))

%% Adapt: Init random
Adapt.Enable = true;
filt_rand = randomize_weights(filter);

[R2A, filter_out, PredData, vaf, mse, ActSignalsTrunk]= PeriodicR2_2(filt_rand,testData,foldlength,Adapt);

figure;hold on;
plot(PredData.timeframe,ActSignalsTrunk(:,2),'k');
plot(PredData.timeframe,PredData.preddatabin(:,2),'r');

figure;
plot(PredData.timeframe,PredData.preddatabin(:,1),'r');
hold on;
plot(PredData.timeframe,ActSignalsTrunk(:,1),'k');

% Plot R2:
[numR2,numEMGs] = size(R2A);
xa = (1:numR2)*foldlength/60;
for i = 1:numEMGs
    figure; plot(xa,R2AF(:,i)); ylim([0 1]);
    title(sprintf('%s\nAdaptive Decoder',nonzeros(testData.emgguide(i,:))));
    xlabel('Time (min)'); ylabel('R2');
end
figure; plot(xa, mean(R2A,2));ylim([0 1]);
title(sprintf('Average Accross Muscles\nAdaptive Decoder'));
xlabel('Time (min)');
ylabel('R2');
mean(R2A(:))
%% Adapt no drop, Weights are zeros

Adapt.Enable = true;
filt_zeros = filter;         
filt_zeros.H = zeros(size(filter.H));

[R2A0, filter_out, PredData, vaf, mse, ActSignalsTrunk]= PeriodicR2_2(filt_zeros,testData,foldlength,Adapt);

% Plot R2:
[numR2,numEMGs] = size(R2A0);
xa = (1:numR2)*foldlength/60;
for i = 1:numEMGs
    figure; plot(xa,R2AF(:,i)); ylim([0 1]);
    title(sprintf('%s\nAdaptive Decoder',nonzeros(testData.emgguide(i,:))));
    xlabel('Time (min)'); ylabel('R2');
end
figure; plot(xa, mean(R2A0,2));ylim([0 1]);
title(sprintf('Average Accross Muscles\nAdaptive Decoder'));
xlabel('Time (min)');
ylabel('R2');
mean(R2A0(:))