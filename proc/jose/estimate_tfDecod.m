%% Calculate tf N2F decoder

Act_Fx = binnedData.forcedatabin(10:end,1); % simple lag = 10
Act_Fy = binnedData.forcedatabin(10:end,2);
Pred_Fx1 = OLPredData_N2F.preddatabin(:,1);
Pred_Fy1 = OLPredData_N2F.preddatabin(:,2);

Act_N2F = [Act_Fx,Act_Fy];
Pred_N2F = [Pred_Fx1,Pred_Fy1];

[Mag_N2F,Phase_N2F,Omega_N2F,EstF_N2F] = impulse_txy_decoder(Act_N2F,Pred_N2F);

%% n2F + 2.5 Hz FIR LP Filter

f_order =1; % 2nd order filter
Fc = 1.5; % Fc=5 Hz
wc = Fc/(20/2); % Fs=20 Hz, wc= Fc/(Fs/2)
f_coeff = fir1(f_order,wc);
Pred_Fx1_2 = filter(f_coeff,1,Pred_Fx1);
Pred_Fy1_2 = filter(f_coeff,1,Pred_Fy1);

Act_N2F = [Act_Fx,Act_Fy];
Pred_N2F_2 = [Pred_Fx1_2,Pred_Fy1_2];

[Mag_N2F_2,Phase_N2F_2,Omega_N2F_2,EstF_N2F_2] = impulse_txy_decoder(Act_N2F,Pred_N2F_2);

%% n2F + 5 Hz FIR LP Filter

f_order =1; % 2nd order filter
Fc = 2.5; % Fc=5 Hz
wc = Fc/(20/2); % Fs=20 Hz, wc= Fc/(Fs/2)
f_coeff = fir1(f_order,wc);
Pred_Fx1_5 = filter(f_coeff,1,Pred_Fx1);
Pred_Fy1_5 = filter(f_coeff,1,Pred_Fy1);

Act_N2F = [Act_Fx,Act_Fy];
Pred_N2F_5 = [Pred_Fx1_5,Pred_Fy1_5];

[Mag_N2F_5,Phase_N2F_5,Omega_N2F_5,EstF_N2F_5] = impulse_txy_decoder(Act_N2F,Pred_N2F_5);

%% n2F + 9 Hz FIR LP Filter

f_order =1; % 2nd order filter
Fc = 1; % Fc=9 Hz
wc = Fc/(20/2); % Fs=20 Hz, wc= Fc/(Fs/2)
f_coeff = fir1(f_order,wc);
Pred_Fx1_9 = filter(f_coeff,1,Pred_Fx1);
Pred_Fy1_9 = filter(f_coeff,1,Pred_Fy1);

Act_N2F = [Act_Fx,Act_Fy];
Pred_N2F_9 = [Pred_Fx1_9,Pred_Fy1_9];

[Mag_N2F_9,Phase_N2F_9,Omega_N2F_9,EstF_N2F_9] = impulse_txy_decoder(Act_N2F,Pred_N2F_9);


%% Calculate tf Cascade Decoder

Act_Fx = binnedData.forcedatabin(19:end,1); % double lag
Act_Fy = binnedData.forcedatabin(19:end,2);
OLPredData_N2E.emgdatabin = OLPredData_N2E.preddatabin;
PredF_CD = predictSignals(E2F_filter,OLPredData_N2E);
Pred_Fx2 = PredF_CD.preddatabin(:,1);
Pred_Fy2 = PredF_CD.preddatabin(:,2);

Act_CD = [Act_Fx,Act_Fy];
Pred_CD = [Pred_Fx2,Pred_Fy2];

[Mag_CD,Phase_CD,Omega_CD,EstF_CD] = impulse_txy_decoder(Act_CD,Pred_CD);

%% Make plot

%  Fx
figure(1); clf
plot(EstF_N2F(:,1), 20*log10(Mag_N2F(:,1)), 'b-'); hold on
plot(EstF_N2F_2(:,1), 20*log10(Mag_N2F_2(:,1)), 'k-');
plot(EstF_N2F_5(:,1), 20*log10(Mag_N2F_5(:,1)), 'g-');
plot(EstF_N2F_9(:,1), 20*log10(Mag_N2F_9(:,1)), 'r-');
plot(EstF_CD(:,1), 20*log10(Mag_CD(:,1)), 'm-');
xlabel('Frequency, Hz')
ylabel('|H|, dB')
title('Impulse response transfer function: Fx')
legend('N2F','N2F + 2.5Hz','N2F + 5Hz','N2F + 9Hz','CD','Location','Best')

% Fy
figure(2); clf
plot(EstF_N2F(:,2), 20*log10(Mag_N2F(:,2)), 'b-'); hold on
plot(EstF_N2F_2(:,2), 20*log10(Mag_N2F_2(:,2)), 'k-');
plot(EstF_N2F_5(:,2), 20*log10(Mag_N2F_5(:,2)), 'g-');
plot(EstF_N2F_9(:,2), 20*log10(Mag_N2F_9(:,2)), 'r-');
plot(EstF_CD(:,2), 20*log10(Mag_CD(:,2)), 'm-');
xlabel('Frequency, Hz')
ylabel('\angle H, rad')
title('Impulse response transfer function: Fy')
legend('N2F','N2F + 2.5Hz','N2F + 5Hz','N2F + 9Hz','CD','Location','Best')


% %  Phase plot on bottom
% subplot(2,1,2)
% plot(EstFy1, EstPhase_y1, 'b-'); hold on
% plot(EstFy2, EstPhase_y2, 'r-')
% xlabel('Frequency, Hz')
% ylabel('\angle H, rad')