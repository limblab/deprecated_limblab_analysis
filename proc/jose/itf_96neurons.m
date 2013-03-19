%% Predicting Force from Cascade Decoder
% Calculating PredEMGs
pred_out = [1,0,0,0]; %[PredEMG, PredForce, PredCursPos,PredVeloc]
input_type = 0; % use neurons as inputs
PolynomialOrder = 2; % N2E
[filt_aux, OLPredData_N2E] = BuildFilter(binnedData,pred_out,input_type,PolynomialOrder);
OLPredData_N2E.emgdatabin = OLPredData_N2E.preddatabin; % input for the E2F decoder
% Calculating E2F Decoder
pred_out = [0,1,0,0]; %[PredEMG, PredForce, PredCursPos,PredVeloc]
input_type = 1; % use EMGs as inputs
PolynomialOrder = 3; % E2F
[filt_E2F, OLauxData] = BuildFilter(binnedData,pred_out,input_type,PolynomialOrder);
PredF_CD = predictSignals(filt_E2F,OLPredData_N2E);
Pred_Fx2 = PredF_CD.preddatabin(:,1);
Pred_Fy2 = PredF_CD.preddatabin(:,2);

%% Calculate tf Cascade Decoder: 96 neurons to F
ActN = binnedData.spikeratedata(19:end,:);
PredFx = repmat(Pred_Fx2,1,96);
[Mag_CDx,Phase_CDx,Omega_CDx,EstF_CDx] = impulse_txy_decoder(ActN,PredFx);

%% Predicting Force from N2F Decoder
% Calculating PredEMGs
pred_out = [0,1,0,0]; %[PredEMG, PredForce, PredCursPos,PredVeloc]
input_type = 0; % use neurons as inputs
PolynomialOrder = 3; % N2E
[filt_aux, PredF_N2F] = BuildFilter(binnedData,pred_out,input_type,PolynomialOrder); 
Pred_Fx1 = PredF_N2F.preddatabin(:,1);
Pred_Fy1 = PredF_N2F.preddatabin(:,2);   

%% Calculate tf N2F Decoder: 96 neurons to F
ActN = binnedData.spikeratedata(10:end,:);
PredFx = repmat(Pred_Fx1,1,96);
[Mag_N2Fx,Phase_N2Fx,Omega_N2Fx,EstF_N2Fx] = impulse_txy_decoder(ActN,PredFx);
    
%% PLot 
% Figure 1
% N2F
mMagx1 = mean(Mag_N2Fx,2);
stdMagx1 = std(Mag_N2Fx,1,2);
nMagx1 = mMagx1 - stdMagx1;
pMagx1 = mMagx1 + stdMagx1;
% CD
mMagx2 = mean(Mag_CDx,2);
stdMagx2 = std(Mag_CDx,1,2);
nMagx2 = mMagx2 - stdMagx2;
pMagx2 = mMagx2 + stdMagx2;
% Plot 96N - Fx
figure(1); 
area([EstF_N2Fx(:,1);flipdim(EstF_N2Fx(:,1),1)],[20*log10(nMagx1);flipdim(20*log10(pMagx1),1)],...
    'FaceColor',[1 0.85 0.85],'EdgeColor',[0.9 0.9 1]);  hold on
area([EstF_CDx(:,1);flipdim(EstF_CDx(:,1),1)],[20*log10(nMagx2);flipdim(20*log10(pMagx2),1)],...
    'FaceColor',[0.85 0.85 1],'EdgeColor',[0.9 0.9 1]); 
plot(EstF_N2Fx(:,1),20*log10(mMagx1),'r','LineWidth',2,'MarkerSize',1); 
plot(EstF_CDx(:,1),20*log10(mMagx2),'b','LineWidth',2,'MarkerSize',1);
xlabel('Frequency, Hz')
ylabel('|H|, dB')
title('CD Impulse response transfer function: Fx')
legend('std N2F Decoder','std Cascade Decoder','N2F Decoder','Cascade Decoder')

    
    