close all; clc
%% Calculate tf N2F decoder

Act_Fx = binnedData.forcedatabin(10:end,1); % simple lag = 10
Act_Fy = binnedData.forcedatabin(10:end,2);
Pred_Fx1 = OLPredData_N2F.preddatabin(:,1);
Pred_Fy1 = OLPredData_N2F.preddatabin(:,2);

Act_N2F = [Act_Fx,Act_Fy];
Pred_N2F = [Pred_Fx1,Pred_Fy1];

R2_N2F = CalculateR2(Act_N2F,Pred_N2F);

% Impulse tf
[Mag_N2F,Phase_N2F,Omega_N2F,EstF_N2F] = impulse_txy_decoder(Act_N2F,Pred_N2F);
% MSCohere
[Cxy_N2F,F_N2F] = mscohere(Act_Fx,Pred_Fx1,128,[],[],20);
[Cxy_N2Fy,F_N2Fy] = mscohere(Act_Fy,Pred_Fy1,128,[],[],20);

%% n2F + 2.5 Hz Butter LP Filter

f_order =4; % 2nd order filter
Fc = 5; % Fc=9 Hz
wc = Fc/(20/2); % Fs=20 Hz, wc= Fc/(Fs/2)
[B,A] = butter(f_order,wc);
Pred_Fx1_2 = filter(B,A,Pred_Fx1);
Pred_Fy1_2 = filter(B,A,Pred_Fy1);

Act_N2F = [Act_Fx,Act_Fy];
Pred_N2F_2 = [Pred_Fx1_2,Pred_Fy1_2];

R2_N2F_2 = CalculateR2(Act_N2F,Pred_N2F_2);

% Impulse tf
[Mag_N2F_2,Phase_N2F_2,Omega_N2F_2,EstF_N2F_2] = impulse_txy_decoder(Act_N2F,Pred_N2F_2);
% MSCohere
[Cxy_N2F_2,F_N2F_2] = mscohere(Act_Fx,Pred_Fx1_2,128,[],[],20);
[Cxy_N2Fy_2,F_N2Fy_2] = mscohere(Act_Fy,Pred_Fy1_2,128,[],[],20);

%% n2F + 5 Hz Butter LP Filter

f_order =5; % 2nd order filter
Fc = 5; % Fc=9 Hz
wc = Fc/(20/2); % Fs=20 Hz, wc= Fc/(Fs/2)
[B,A] = butter(f_order,wc);
Pred_Fx1_5 = filter(B,A,Pred_Fx1);
Pred_Fy1_5 = filter(B,A,Pred_Fy1);

Act_N2F = [Act_Fx,Act_Fy];
Pred_N2F_5 = [Pred_Fx1_5,Pred_Fy1_5];

R2_N2F_5 = CalculateR2(Act_N2F,Pred_N2F_5);

[Mag_N2F_5,Phase_N2F_5,Omega_N2F_5,EstF_N2F_5] = impulse_txy_decoder(Act_N2F,Pred_N2F_5);
% MSCohere
[Cxy_N2F_5,F_N2F_5] = mscohere(Act_Fx,Pred_Fx1_5,128,[],[],20);
[Cxy_N2Fy_5,F_N2Fy_5] = mscohere(Act_Fy,Pred_Fy1_5,128,[],[],20);

%% n2F + 9 Hz Butter LP Filter

f_order =5; % 2nd order filter
Fc = 6; % Fc=9 Hz
wc = Fc/(20/2); % Fs=20 Hz, wc= Fc/(Fs/2)
[B,A] = butter(f_order,wc);
Pred_Fx1_9 = filter(B,A,Pred_Fx1);
Pred_Fy1_9 = filter(B,A,Pred_Fy1);

Act_N2F = [Act_Fx,Act_Fy];
Pred_N2F_9 = [Pred_Fx1_9,Pred_Fy1_9];

R2_N2F_9 = CalculateR2(Act_N2F,Pred_N2F_9);

[Mag_N2F_9,Phase_N2F_9,Omega_N2F_9,EstF_N2F_9] = impulse_txy_decoder(Act_N2F,Pred_N2F_9);
% MSCohere
[Cxy_N2F_9,F_N2F_9] = mscohere(Act_Fx,Pred_Fx1_9,128,[],[],20);
[Cxy_N2Fy_9,F_N2Fy_9] = mscohere(Act_Fy,Pred_Fy1_9,128,[],[],20);

%% Calculate tf Cascade Decoder

Act_Fx = binnedData.forcedatabin(19:end,1); % double lag
Act_Fy = binnedData.forcedatabin(19:end,2);
OLPredData_N2E.emgdatabin = OLPredData_N2E.preddatabin;
PredF_CD = predictSignals(E2F_filter,OLPredData_N2E);
Pred_Fx2 = PredF_CD.preddatabin(:,1);
Pred_Fy2 = PredF_CD.preddatabin(:,2);

Act_CD = [Act_Fx,Act_Fy];
Pred_CD = [Pred_Fx2,Pred_Fy2];

R2_CD = CalculateR2(Act_CD,Pred_CD);

[Mag_CD,Phase_CD,Omega_CD,EstF_CD] = impulse_txy_decoder(Act_CD,Pred_CD);
% MSCohere
[Cxy_CD,F_CD] = mscohere(Act_Fx,Pred_Fx2,128,[],[],20);
[Cxy_CDy,F_CDy] = mscohere(Act_Fy,Pred_Fy2,128,[],[],20);

%% Calculate tf N2F + PCA

Act_Fx = binnedData.forcedatabin(10:end,1); % simple lag = 10
Act_Fy = binnedData.forcedatabin(10:end,2);
Pred_Fx3 = OLPredData_N2F_PCA.preddatabin(:,1);
Pred_Fy3 = OLPredData_N2F_PCA.preddatabin(:,2);

Act_N2F = [Act_Fx,Act_Fy];
Pred_N2F_PCA = [Pred_Fx3,Pred_Fy3];

R2_N2F_PCA = CalculateR2(Act_N2F,Pred_N2F_PCA);

[Mag_N2F_PCA,Phase_N2F_PCA,Omega_N2F_PCA,EstF_N2F_PCA] = impulse_txy_decoder(Act_N2F,Pred_N2F_PCA);
[Cxy_N2F_PCA,F_N2F_PCA] = mscohere(Act_Fx,Pred_Fx3,128,[],[],20);
[Cxy_N2F_PCAy,F_N2F_PCAy] = mscohere(Act_Fy,Pred_Fy3,128,[],[],20);

%% Make plot

%  Fx
figure(); clf
plot(EstF_N2F(:,1), 20*log10(Mag_N2F(:,1)), 'b-'); hold on
plot(EstF_N2F_2(:,1), 20*log10(Mag_N2F_2(:,1)), 'k-');
plot(EstF_N2F_5(:,1), 20*log10(Mag_N2F_5(:,1)), 'g-');
plot(EstF_N2F_9(:,1), 20*log10(Mag_N2F_9(:,1)), 'r-');
plot(EstF_CD(:,1), 20*log10(Mag_CD(:,1)), 'm-');
plot(EstF_N2F_PCA(:,1), 20*log10(Mag_N2F_PCA(:,1)), 'c-'); hold on
xlabel('Frequency, Hz')
ylabel('|H|, dB')
title('Impulse response transfer function: Fx')
legend('N2F','N2F + 2.5Hz','N2F + 5Hz','N2F + 9Hz','CD','N2F+PCA',...
    'Location','Best');

% Fy
figure(); clf
plot(EstF_N2F(:,2), 20*log10(Mag_N2F(:,2)), 'b-'); hold on
plot(EstF_N2F_2(:,2), 20*log10(Mag_N2F_2(:,2)), 'k-');
plot(EstF_N2F_5(:,2), 20*log10(Mag_N2F_5(:,2)), 'g-');
plot(EstF_N2F_9(:,2), 20*log10(Mag_N2F_9(:,2)), 'r-');
plot(EstF_CD(:,2), 20*log10(Mag_CD(:,2)), 'm-');
plot(EstF_N2F_PCA(:,2), 20*log10(Mag_N2F_PCA(:,2)), 'c-'); hold on
xlabel('Frequency, Hz')
ylabel('\angle H, rad')
title('Impulse response transfer function: Fy')
legend('N2F','N2F + 2.5Hz','N2F + 5Hz','N2F + 9Hz','CD','N2F+PCA',...
    'Location','Best');


% %  Phase plot on bottom
% subplot(2,1,2)
% plot(EstFy1, EstPhase_y1, 'b-'); hold on
% plot(EstFy2, EstPhase_y2, 'r-')
% xlabel('Frequency, Hz')
% ylabel('\angle H, rad')

%% ms cohere
%[Cxy,F] = MSCOHERE(X,Y,WINDOW,NOVERLAP,NFFT,Fs)
figure(); clf
plot(F_N2F, Cxy_N2F, 'b-'); hold on
plot(F_N2F_2, Cxy_N2F_2, 'k-');
plot(F_N2F_5, Cxy_N2F_5, 'g-');
plot(F_N2F_9, Cxy_N2F_9, 'r-');
plot(F_CD, Cxy_CD, 'm-');
title('magnitude squared coherence estimate vs HC - Fx')
legend('N2F','N2F + 2.5Hz','N2F + 5Hz','N2F + 9Hz','CD','Location','Best')
xlabel('Frequency, Hz')
ylabel('Coherence, %')

figure(); clf
plot(F_N2Fy, Cxy_N2Fy, 'b-'); hold on
plot(F_N2Fy_2, Cxy_N2Fy_2, 'k-');
plot(F_N2Fy_5, Cxy_N2Fy_5, 'g-');
plot(F_N2Fy_9, Cxy_N2Fy_9, 'r-');
plot(F_CDy, Cxy_CDy, 'm-');
title('magnitude squared coherence estimate vs HC - Fy')
legend('N2F','N2F + 2.5Hz','N2F + 5Hz','N2F + 9Hz','CD','Location','Best')
xlabel('Frequency, Hz')
ylabel('Coherence, %')

