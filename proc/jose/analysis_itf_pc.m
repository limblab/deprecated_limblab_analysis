%% Predicting Force from N2F Decoder
clear all;close all; clc

%% principal components as input
% Converting firing rates to principal components
data=binnedData.spikeratedata;  
[W, pc, eigV] = princomp(data);
c_var = (cumsum(eigV) ./ sum(eigV));
pcData = binnedData;
pcData.spikeratedata = pc;
% if we use only 14 PC  
PC14_Data = binnedData;
PC14_Data.spikeratedata = pc(:,1:14);
PC14_Data.spikeguide = binnedData.spikeguide(1:14,:);
%% Hand Control

% Calculate tf N2F Decoder: 96 neurons to F
ActN = pcData.spikeratedata;
ActFx = binnedData.forcedatabin(:,1);
ActFx = repmat(ActFx,1,96);
[Phc,Fhc] = periodogram(ActFx,[],128,20);
[Mag_hc,Phase_hc,Omega_hc,EstF_hc] = impulse_txy_decoder(ActN,ActFx);
w_N = (eigV./ sum(eigV))'; % contribuition of each neuron
w_N = repmat(w_N,size(Mag_hc,1),1);  
avgMag_hc = Mag_hc.*w_N; % weightening to get the average 
avgMag_hc = sum(avgMag_hc,2);

%% N2F 

%Predicting Force from Cascade Decoder
pred_out = [0,1,0,0]; %[PredEMG, PredForce, PredCursPos,PredVeloc]
input_type = 0; % use neurons as inputs
PolynomialOrder = 3; % N2F
[filt_aux, pc_PredF] = BuildFilter(pcData,pred_out,input_type,PolynomialOrder);

Act_Fx = pcData.forcedatabin(10:end,1); % simple lag = 10
Act_Fy = pcData.forcedatabin(10:end,2);
Pred_Fx = pc_PredF.preddatabin(:,1);
Pred_Fy = pc_PredF.preddatabin(:,2);
ActF = [Act_Fx,Act_Fy];
pcPredF = [Pred_Fx,Pred_Fy];
pcR2 = CalculateR2(ActF,pcPredF);
% [Pxx,F] = PERIODOGRAM(X,WINDOW,NFFT,Fs);
[Pn2f,Fn2f] = periodogram(Pred_Fx,[],128,20);


% Calculate tf N2F Decoder: 96 neurons to F
ActN = pcData.spikeratedata(10:end,:);
PredFx = repmat(Pred_Fx,1,96);
[Mag_pc,Phase_pc,Omega_pc,EstF_pc] = impulse_txy_decoder(ActN,PredFx);
w_N = (eigV./ sum(eigV))'; % contribuition of each neuron
w_N = repmat(w_N,size(Mag_pc,1),1);  
avgMag_pc = Mag_pc.*w_N; % weightening to get the average 
avgMag_pc = sum(avgMag_pc,2);

%% N2F + 14PC

%Predicting Force from Cascade Decoder
pred_out = [0,1,0,0]; %[PredEMG, PredForce, PredCursPos,PredVeloc]
input_type = 0; % use neurons as inputs
PolynomialOrder = 3; % N2F
[filt_aux, pc_PredF14] = BuildFilter(PC14_Data,pred_out,input_type,PolynomialOrder);

Act_Fx = PC14_Data.forcedatabin(10:end,1); % simple lag = 10
Act_Fy = PC14_Data.forcedatabin(10:end,2);
Pred_Fx = pc_PredF14.preddatabin(:,1);
Pred_Fy = pc_PredF14.preddatabin(:,2);
ActF = [Act_Fx,Act_Fy];
pcPredF = [Pred_Fx,Pred_Fy];
pc14R2 = CalculateR2(ActF,pcPredF);
[Pn2f_14,Fn2f_14] = periodogram(Pred_Fx,[],128,20);

% Calculate tf N2F Decoder: 96 neurons to F
ActN = pcData.spikeratedata(10:end,:);
PredFx = repmat(Pred_Fx,1,96);
[Mag_14pc,Phase_14pc,Omega_14pc,EstF_14pc] = impulse_txy_decoder(ActN,PredFx);
w_N = (eigV./ sum(eigV))'; % contribuition of each neuron
w_N = repmat(w_N,size(Mag_pc,1),1);  
avgMag_14pc = Mag_14pc.*w_N; % weightening to get the average 
avgMag_14pc = sum(avgMag_14pc,2);

%% Cascade Decoder
% Calculating PredEMGs
pred_out = [1,0,0,0]; %[PredEMG, PredForce, PredCursPos,PredVeloc]
input_type = 0; % use neurons as inputs
PolynomialOrder = 2; % N2E
[filt_aux, OLPredData_N2E] = BuildFilter(pcData,pred_out,input_type,PolynomialOrder);
OLPredData_N2E.emgdatabin = OLPredData_N2E.preddatabin; % input for the E2F decoder
% Calculating E2F Decoder
pred_out = [0,1,0,0]; %[PredEMG, PredForce, PredCursPos,PredVeloc]
input_type = 1; % use EMGs as inputs
PolynomialOrder = 3; % E2F
[filt_E2F, OLauxData] = BuildFilter(pcData,pred_out,input_type,PolynomialOrder);
PredF_CD = predictSignals(filt_E2F,OLPredData_N2E);
% R2
ActFx = pcData.forcedatabin(19:end,1); % simple lag = 10
ActFy = pcData.forcedatabin(19:end,2);
Pred_Fx2 = PredF_CD.preddatabin(:,1);
Pred_Fy2 = PredF_CD.preddatabin(:,2);
ActF = [ActFx,ActFy];
CD_pcPredF = [Pred_Fx2,Pred_Fy2];
CD_pcR2 = CalculateR2(ActF,CD_pcPredF);
[Pcd,Fcd] = periodogram(Pred_Fx2,[],128,20);

% Calculate tf Cascade Decoder: 96 neurons to F
ActN = binnedData.spikeratedata(19:end,:);
PredFx = repmat(Pred_Fx2,1,96);
[Mag_CDx,Phase_CDx,Omega_CDx,EstF_CDx] = impulse_txy_decoder(ActN,PredFx);
CD_avgMag_pc = Mag_CDx.*w_N; % weightening to get the average 
CD_avgMag_pc = sum(CD_avgMag_pc,2);

%% Plot
figure(1);
plot(EstF_pc(:,1),20*log10(avgMag_pc),'r','LineWidth',2,'MarkerSize',1); hold on;
plot(EstF_CDx(:,1),20*log10(CD_avgMag_pc),'b','LineWidth',2,'MarkerSize',1); 
plot(EstF_14pc(:,1),20*log10(avgMag_14pc),'m','LineWidth',2,'MarkerSize',1); hold on;
plot(EstF_hc(:,1),20*log10(avgMag_hc),'k','LineWidth',2,'MarkerSize',1); hold on;
xlabel('Frequency, Hz')
ylabel('|H|, dB')
title('CD Impulse response transfer function: Fx')
legend('N2F Decoder','CD Decoder','14PC N2F Decoder','Hand Control')


figure(2)
plot(Fn2f,20*log10(Pn2f),'r-','LineWidth',2,'MarkerSize',1); hold on
plot(Fcd,20*log10(Pcd),'b-')
plot(Fn2f_14,20*log10(Pn2f_14),'g-')
plot(Fhc,20*log10(Phc),'k-');
xlabel('Frequency, Hz')
ylabel('PowerFrequency, (dB/dHz)')
title('Periodogram Power Spectral Density: Fx')
legend('N2F Decoder','CD Decoder','14PC N2F Decoder','Hand Control')



