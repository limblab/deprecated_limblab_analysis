% Calculate VAF and R2 for N2F and Cascade Decoder for an specif datafile
% Calculate and Plot Transfer function of each decoder with linearities and
% non linearities.
% Jose Albites

%% Split Data for training and testing

trainTime = 12*60; % 12 min sec
[trainData,testData] = splitBinnedData(binnedData,trainTime);

%% N2F with NonLinearities

%Predicting Force from N2F Decoder
pred_out = [0,1,0,0]; %[PredEMG, PredForce, PredCursPos,PredVeloc]
input_type = 0; % use neurons as inputs
PolynomialOrder = 3; % N2F
[filt_N2F, PredF_NL] = BuildFilter(trainData,pred_out,input_type,PolynomialOrder);
% plot shape non linearities
tt = linspace(-3,3); % aprox range of actual force;
Nx_1 = polyval(filt_N2F.P(:,1),tt);
Ny_1 = polyval(filt_N2F.P(:,2),tt);

Act_Fx = trainData.forcedatabin(10:end,1); % simple lag = 10
Act_Fy = trainData.forcedatabin(10:end,2);
Pred_Fx = PredF_NL.preddatabin(:,1);
Pred_Fy = PredF_NL.preddatabin(:,2);
ActF = [Act_Fx,Act_Fy];
pcPredF = [Pred_Fx,Pred_Fy];
[Mag1,Phase1,Omega1,EstF1] = impulse_txy_decoder(ActF,pcPredF);

% Testing Data
PredF = predictSignals(filt_N2F,testData);
Act_Fx = testData.forcedatabin(10:end,1); % simple lag = 10
Act_Fy = testData.forcedatabin(10:end,2);
Pred_Fx = PredF.preddatabin(:,1);
Pred_Fy = PredF.preddatabin(:,2);
ActF = [Act_Fx,Act_Fy];
PredF = [Pred_Fx,Pred_Fy];
[Mag1b,Phase1b,Omega1b,EstF1b] = impulse_txy_decoder(ActF,PredF);
pcVAF = CalculateVAF(ActF,PredF);
VAF_1 = mean(pcVAF)
R2_1 = mean(CalculateR2(ActF,PredF))
% % [Pxx,F] = PERIODOGRAM(X,WINDOW,NFFT,Fs);
% [Pn2f,Fn2f] = periodogram(Pred_Fx,[],128,20);




%% N2F without NonLinearities

%Predicting Force from N2F Decoder
pred_out = [0,1,0,0]; %[PredEMG, PredForce, PredCursPos,PredVeloc]
input_type = 0; % use neurons as inputs
PolynomialOrder = 0; % NON LINEARITY
[filt_N2F, PredF_NL] = BuildFilter(trainData,pred_out,input_type,PolynomialOrder);

Act_Fx = trainData.forcedatabin(10:end,1); % simple lag = 10
Act_Fy = trainData.forcedatabin(10:end,2);
Pred_Fx = PredF_NL.preddatabin(:,1);
Pred_Fy = PredF_NL.preddatabin(:,2);
ActF = [Act_Fx,Act_Fy];
pcPredF = [Pred_Fx,Pred_Fy];
[Mag2,Phase2,Omega2,EstF2] = impulse_txy_decoder(ActF,pcPredF);

% Testing Data
PredF = predictSignals(filt_N2F,testData);
Act_Fx = testData.forcedatabin(10:end,1); % simple lag = 10
Act_Fy = testData.forcedatabin(10:end,2);
Pred_Fx = PredF.preddatabin(:,1);
Pred_Fy = PredF.preddatabin(:,2);
ActF = [Act_Fx,Act_Fy];
PredF = [Pred_Fx,Pred_Fy];
[Mag2b,Phase2b,Omega2b,EstF2b] = impulse_txy_decoder(ActF,PredF);
pcVAF = CalculateVAF(ActF,PredF);
VAF_2 = mean(pcVAF)
R2_2 = mean(CalculateR2(ActF,PredF))
% [Pxx,F] = PERIODOGRAM(X,WINDOW,NFFT,Fs);
% [Pn2f,Fn2f] = periodogram(Pred_Fx,[],128,20);

%% Cascade Decoder with nonlinearities
% Calculating PredEMGs
pred_out = [1,0,0,0]; %[PredEMG, PredForce, PredCursPos,PredVeloc]
input_type = 0; % use neurons as inputs
PolynomialOrder = 2; % N2E
[filt_N2E, OLPredData_N2E] = BuildFilter(trainData,pred_out,input_type,PolynomialOrder);
OLPredData_N2E.emgdatabin = OLPredData_N2E.preddatabin; % input for the E2F decoder
% plot shape non linearities
tt1 = linspace(0,3); % aprox range of actual force;
N_N2Ex_3 = polyval(filt_N2E.P(:,1),tt1);
N_N2Ey_3 = polyval(filt_N2E.P(:,2),tt1);
% Calculating E2F Decoder
pred_out = [0,1,0,0]; %[PredEMG, PredForce, PredCursPos,PredVeloc]
input_type = 1; % use EMGs as inputs
PolynomialOrder = 3; % E2F
[filt_E2F, OLauxData] = BuildFilter(trainData,pred_out,input_type,PolynomialOrder);
PredF_CD = predictSignals(filt_E2F,OLPredData_N2E);
% plot shape non linearities
tt = linspace(-3,3); % aprox range of actual force;
N_E2Fx_3 = polyval(filt_E2F.P(:,1),tt);
N_E2Fy_3 = polyval(filt_E2F.P(:,2),tt);
% R2
ActFx = trainData.forcedatabin(19:end,1); % simple lag = 10
ActFy = trainData.forcedatabin(19:end,2);
Pred_Fx2 = PredF_CD.preddatabin(:,1);
Pred_Fy2 = PredF_CD.preddatabin(:,2);
ActF = [ActFx,ActFy];
PredF = [Pred_Fx2,Pred_Fy2];
[Mag3,Phase3,Omega3,EstF3] = impulse_txy_decoder(ActF,PredF);

% Testing Data
Pred_E = predictSignals(filt_N2E,testData);
Pred_E.emgdatabin = Pred_E.preddatabin; % input for the E2F decoder
Pred_CD = predictSignals(filt_E2F,Pred_E);
Act_Fx = testData.forcedatabin(19:end,1); % double lag
Act_Fy = testData.forcedatabin(19:end,2);
ActF = [Act_Fx,Act_Fy]; % same for PC
Pred_Fx = Pred_CD.preddatabin(:,1);
Pred_Fy = Pred_CD.preddatabin(:,2);
P_CD = [Pred_Fx,Pred_Fy];
[Mag3b,Phase3b,Omega3b,EstF3b] = impulse_txy_decoder(ActF,P_CD);
VAF_CD = CalculateVAF(ActF,P_CD);
VAF_3 = mean(VAF_CD)% 
R2_3 = mean(CalculateR2(ActF,P_CD))
% [Pcd,Fcd] = periodogram(Pred_Fx2,[],128,20);

%% Cascade Decoder without nonlinearities
% Calculating PredEMGs
pred_out = [1,0,0,0]; %[PredEMG, PredForce, PredCursPos,PredVeloc]
input_type = 0; % use neurons as inputs
PolynomialOrder = 0; % NON LINEARITIES
[filt_N2E, OLPredData_N2E] = BuildFilter(trainData,pred_out,input_type,PolynomialOrder);
OLPredData_N2E.emgdatabin = OLPredData_N2E.preddatabin; % input for the E2F decoder

% Calculating E2F Decoder
pred_out = [0,1,0,0]; %[PredEMG, PredForce, PredCursPos,PredVeloc]
input_type = 1; % use EMGs as inputs
PolynomialOrder = 0; % NON LINEARITIES
[filt_E2F, OLauxData] = BuildFilter(trainData,pred_out,input_type,PolynomialOrder);
PredF_CD = predictSignals(filt_E2F,OLPredData_N2E);

% R2
ActFx = trainData.forcedatabin(19:end,1); % simple lag = 10
ActFy = trainData.forcedatabin(19:end,2);
Pred_Fx2 = PredF_CD.preddatabin(:,1);
Pred_Fy2 = PredF_CD.preddatabin(:,2);
ActF = [ActFx,ActFy];
PredF = [Pred_Fx2,Pred_Fy2];
[Mag4,Phase4,Omega4,EstF4] = impulse_txy_decoder(ActF,PredF);

% Testing Data
Pred_E = predictSignals(filt_N2E,testData);
Pred_E.emgdatabin = Pred_E.preddatabin; % input for the E2F decoder
Pred_CD = predictSignals(filt_E2F,Pred_E);
Act_Fx = testData.forcedatabin(19:end,1); % double lag
Act_Fy = testData.forcedatabin(19:end,2);
ActF = [Act_Fx,Act_Fy]; % same for PC
Pred_Fx = Pred_CD.preddatabin(:,1);
Pred_Fy = Pred_CD.preddatabin(:,2);
P_CD = [Pred_Fx,Pred_Fy];
[Mag4b,Phase4b,Omega4b,EstF4b] = impulse_txy_decoder(ActF,P_CD);
VAF_CD = CalculateVAF(ActF,P_CD);
VAF_4 = mean(VAF_CD)% 
R2_4 = mean(CalculateR2(ActF,P_CD))
% [Pcd,Fcd] = periodogram(Pred_Fx2,[],128,20);

%% Cascade Decoder without nonlinearities Type 5
% Calculating PredEMGs
pred_out = [1,0,0,0]; %[PredEMG, PredForce, PredCursPos,PredVeloc]
input_type = 0; % use neurons as inputs
PolynomialOrder = 0; % NON LINEARITIES
[filt_N2E, OLPredData_N2E] = BuildFilter(trainData,pred_out,input_type,PolynomialOrder);
OLPredData_N2E.emgdatabin = OLPredData_N2E.preddatabin; % input for the E2F decoder
% Calculating E2F Decoder
pred_out = [0,1,0,0]; %[PredEMG, PredForce, PredCursPos,PredVeloc]
input_type = 1; % use EMGs as inputs
PolynomialOrder = 3; % Force
[filt_E2F, OLauxData] = BuildFilter(trainData,pred_out,input_type,PolynomialOrder);
PredF_CD = predictSignals(filt_E2F,OLPredData_N2E);
% R2
ActFx = trainData.forcedatabin(19:end,1); % simple lag = 10
ActFy = trainData.forcedatabin(19:end,2);
Pred_Fx2 = PredF_CD.preddatabin(:,1);
Pred_Fy2 = PredF_CD.preddatabin(:,2);
ActF = [ActFx,ActFy];
PredF = [Pred_Fx2,Pred_Fy2];
[Mag5,Phase5,Omega5,EstF5] = impulse_txy_decoder(ActF,PredF);

% Testing Data
Pred_E = predictSignals(filt_N2E,testData);
Pred_E.emgdatabin = Pred_E.preddatabin; % input for the E2F decoder
Pred_CD = predictSignals(filt_E2F,Pred_E);
Act_Fx = testData.forcedatabin(19:end,1); % double lag
Act_Fy = testData.forcedatabin(19:end,2);
ActF = [Act_Fx,Act_Fy]; % same for PC
Pred_Fx = Pred_CD.preddatabin(:,1);
Pred_Fy = Pred_CD.preddatabin(:,2);
P_CD = [Pred_Fx,Pred_Fy];
[Mag5b,Phase5b,Omega5b,EstF5b] = impulse_txy_decoder(ActF,P_CD);
VAF_CD = CalculateVAF(ActF,P_CD);
VAF_5 = mean(VAF_CD)% 
R2_5 = mean(CalculateR2(ActF,P_CD))
% [Pcd,Fcd] = periodogram(Pred_Fx2,[],128,20);

%% Plot
figure
plot(EstF1(:,1),20*log10(Mag1(:,1)),'r','LineWidth',2,'MarkerSize',1); hold on;
plot(EstF2(:,1),20*log10(Mag2(:,1)),'b','LineWidth',2,'MarkerSize',1); hold on;
plot(EstF3(:,1),20*log10(Mag3(:,1)),'m','LineWidth',2,'MarkerSize',1); hold on;
plot(EstF4(:,1),20*log10(Mag4(:,1)),'g','LineWidth',2,'MarkerSize',1); hold on;
plot(EstF5(:,1),20*log10(Mag5(:,1)),'k','LineWidth',2,'MarkerSize',1); hold on;
xlabel('Frequency, Hz')
ylabel('|H|, dB')
title('CD Impulse response transfer function: Fx')
legend('Type 1','Type 2','Type 3','Type 4','Type 5')

figure
plot(EstF1(:,2),20*log10(Mag1(:,2)),'r','LineWidth',2,'MarkerSize',1); hold on;
plot(EstF2(:,2),20*log10(Mag2(:,2)),'b','LineWidth',2,'MarkerSize',1); hold on;
plot(EstF3(:,2),20*log10(Mag3(:,2)),'m','LineWidth',2,'MarkerSize',1); hold on;
plot(EstF4(:,2),20*log10(Mag4(:,2)),'g','LineWidth',2,'MarkerSize',1); hold on;
plot(EstF5(:,2),20*log10(Mag5(:,2)),'k','LineWidth',2,'MarkerSize',1); hold on;
xlabel('Frequency, Hz')
ylabel('|H|, dB')
title('CD Impulse response transfer function: Fy')
legend('Type 1','Type 2','Type 3','Type 4','Type 5')

figure
plot(EstF1b(:,1),20*log10(Mag1b(:,1)),'r','LineWidth',2,'MarkerSize',1); hold on;
plot(EstF2b(:,1),20*log10(Mag2b(:,1)),'b','LineWidth',2,'MarkerSize',1); hold on;
plot(EstF3b(:,1),20*log10(Mag3b(:,1)),'m','LineWidth',2,'MarkerSize',1); hold on;
plot(EstF4b(:,1),20*log10(Mag4b(:,1)),'g','LineWidth',2,'MarkerSize',1); hold on;
plot(EstF5b(:,1),20*log10(Mag5b(:,1)),'k','LineWidth',2,'MarkerSize',1); hold on;
xlabel('Frequency, Hz')
ylabel('|H|, dB')
title('Transfer function: Fx')
legend('Type 1','Type 2','Type 3','Type 4','Type 5')

figure
plot(EstF1b(:,2),20*log10(Mag1b(:,2)),'r','LineWidth',2,'MarkerSize',1); hold on;
plot(EstF2b(:,2),20*log10(Mag2b(:,2)),'b','LineWidth',2,'MarkerSize',1); hold on;
plot(EstF3b(:,2),20*log10(Mag3b(:,2)),'m','LineWidth',2,'MarkerSize',1); hold on;
plot(EstF4b(:,2),20*log10(Mag4b(:,2)),'g','LineWidth',2,'MarkerSize',1); hold on;
plot(EstF5b(:,2),20*log10(Mag5b(:,2)),'k','LineWidth',2,'MarkerSize',1); hold on;
xlabel('Frequency, Hz')
ylabel('|H|, dB')
title('Transfer function: Fy')
legend('Type 1','Type 2','Type 3','Type 4','Type 5')

figure
plot(tt,Nx_1,'r','LineWidth',2,'MarkerSize',1); hold on;
plot(tt1,N_N2Ex_3,'b','LineWidth',2,'MarkerSize',1); hold on;
plot(tt,N_E2Fx_3,'m','LineWidth',2,'MarkerSize',1); hold on;
title('Non linearity in X')
legend('N2F','N2E','E2F','Location','Best')

figure
plot(tt,Ny_1,'r','LineWidth',2,'MarkerSize',1); hold on;
plot(tt1,N_N2Ey_3,'b','LineWidth',2,'MarkerSize',1); hold on;
plot(tt,N_E2Fy_3,'m','LineWidth',2,'MarkerSize',1); hold on;
title('Non linearity in Y')
legend('N2F','N2E','E2F','Location','Best')

