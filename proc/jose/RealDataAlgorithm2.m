clear all; close all; clc

load RealData_N.mat
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

% Plot R2:
[numR2,numEMGs] = size(R2FF);
xa = (1:numR2)*foldlength/60;
figure; plot(xa, mean(R2FF,2),'k');ylim([0 1]);
title(sprintf('Average Accross Muscles\nFixed Linear Decoder'));
xlabel('Time (min)');
ylabel('R2');   
mean(R2FF(:))


%% Adapt: Init optimal filter:
% EMG templates
Adapt.LR = 1e-8;
Adapt.jtype = 1; % 1 if want to use EMG patterns
Adapt.Enable = true;
[R2AF_e, filter_out, PredData, vaf, mse, ActSignalsTrunk]= PeriodicR2_2(filter,testData,foldlength,Adapt);

% EMG actual recordings
Adapt.jtype = 2; % 1 if want to use real EMG
Adapt.Enable = true;
[R2AF_r, filter_out, PredData, vaf, mse, ActSignalsTrunk]= PeriodicR2_2(filter,testData,foldlength,Adapt);

% Plot R2:
[numR2,numEMGs] = size(R2AF_e);
xa = (1:numR2)*foldlength/60;

for i = 1:numEMGs
    figure; plot(xa,R2AF_e(:,i),'b'); ylim([0 1]);
    hold on;
    plot(xa,R2AF_r(:,i),'r');
    plot(xa,R2FF(:,i),'k');
    legend('Adapt Decoder + EMG templates','Adapt Decoder + Real EMGs','Fixed Decoder','Location','Best')
    title(sprintf('%s\nAdaptive Decoder vs Fixed Decoder',nonzeros(testData.emgguide(i,:))));
    xlabel('Time (min)'); ylabel('R2');
end

figure; plot(xa, mean(R2AF_e,2),'b'); ylim([0 1]);
hold on; plot(xa, mean(R2AF_r,2),'r');
plot(xa, mean(R2FF,2),'k');
legend('Adapt Decoder + EMG templates','Adapt Decoder + Real EMGs','Fixed Decoder','Location','Best')
title(sprintf('Average Accross Muscles\nAdaptive Decoder vs Fixed Decoder'));
xlabel('Time (min)');
ylabel('R2');    
[mean(R2AF_e(:));mean(R2AF_r(:));mean(R2FF(:))]

%% Adapt: Init random
Adapt.Enable = true;
Adapt.LR =1.6e-9;
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
    figure; plot(xa,R2A(:,i)); ylim([0 1]);
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
Adapt.Period = 1;
Adapt.LR =1.6e-8;
filt_zeros.H = zeros(size(filter.H));

% EMG templates
Adapt.jtype = 1; % 1 if want to use EMG patterns
Adapt.Enable = true;
[R2A0_e, filter_out, PredData, vaf, mse, ActSignalsTrunk]= PeriodicR2_2(filt_zeros,testData,foldlength,Adapt);

% EMG actual recordings
Adapt.jtype = 2; % 1 if want to use real EMG
Adapt.Enable = true;
[R2A0_r, filter_out, PredData, vaf, mse, ActSignalsTrunk]= PeriodicR2_2(filt_zeros,testData,foldlength,Adapt);

% Plot R2:
[numR2,numEMGs] = size(R2A0_e);
xa = (1:numR2)*foldlength/60;

for i = 1:numEMGs
    figure; plot(xa,R2A0_e(:,i),'b'); ylim([0 1]);
    hold on;
    plot(xa,R2A0_r(:,i),'r');
    plot(xa,R2FF(:,i),'k');
    legend('Adapt Decoder + EMG templates','Adapt Decoder + Real EMGs','Fixed Decoder','Location','Best')
    title(sprintf('%s\nAdaptive Decoder vs Fixed Decoder',nonzeros(testData.emgguide(i,:))));
    xlabel('Time (min)'); ylabel('R2');
end

figure; plot(xa, mean(R2A0_e,2),'b'); ylim([0 1]);
hold on; plot(xa, mean(R2A0_r,2),'r');
plot(xa, mean(R2FF,2),'k');
legend('Adapt Decoder + EMG templates','Adapt Decoder + Real EMGs','Fixed Decoder','Location','Best')
title(sprintf('Average Accross Muscles\nAdaptive Decoder vs Fixed Decoder'));
xlabel('Time (min)');
ylabel('R2');    
[mean(R2A0_e(:));mean(R2A0_r(:));mean(R2FF(:))]

