% filterDimReduction2
% This script is different from filterDimReduction because it uses a
% different method to calculate the new filters

% Make hybrid file
[HybridFinal AlteredIsoFinal AlteredWMFinal IsoTrain IsoTest WmTrain WmTest] = makeHybridFileFixed(IsoBinned,WmBinned);
[H] = quickHybridDecoder(HybridFinal);

% input is H;
[U,S,V] = svd(H'); % Use the transpose of H, your filter

% Get your lambdas from the S matrix
for i=1:length(S(:,1))
    lambdas(i) = S(i,i);
    LambdaSubset(i) = sum(lambdas(1:i));
end

% Plot VAFs as a function of number of lambda
x = 1:1:length(lambdas); % xaxis representing the number of lambdas
LambdaSum = sum(lambdas);
LambdaVAFs = LambdaSubset/LambdaSum;
figure; hold on; title('VAFs as a function of #s of lambda');
plot(x,LambdaVAFs,'k*','MarkerSize',10)
plot(2,LambdaVAFs(2),'m*','MarkerSize',10)
str1 = strcat(['\leftarrow ' sprintf('%.2f',LambdaVAFs(2))]);
text(2.2,LambdaVAFs(2),str1);
MillerFigure

% Plot Lambdas
figure; plot(x,lambdas,'k*','MarkerSize',10);
title('Lambda values'); MillerFigure

% Calculate measured modes
ActualMuscles_Hyb = HybridFinal.emgdatabin;
UnitVector1 = U(:,1); UnitVector2 = U(:,2);
MeasuredMode1_Hyb = ActualMuscles_Hyb*UnitVector1;
MeasuredMode2_Hyb = ActualMuscles_Hyb*UnitVector2;

% Make a reduced H for the Hybrid data
HybridModes = HybridFinal;
HybridModes.emgdatabin = cat(2,MeasuredMode1_Hyb,MeasuredMode2_Hyb);
HybridModes_H=filMIMO4(HybridModes.spikeratedata,HybridModes.emgdatabin,10,1,1);  %not sure this makes sense

% Reduce the isometric data
% IsoTestH=filMIMO4(IsoTest.spikeratedata,IsoTest.emgdatabin,10,1,1);
% [U_iso,S_iso,V_iso] = svd(IsoTestH');
 ActualMuscles_Iso = IsoTest.emgdatabin;
MeasuredMode1_Iso = ActualMuscles_Iso*UnitVector1;
MeasuredMode2_Iso = ActualMuscles_Iso*UnitVector2;
IsoModes = cat(2,MeasuredMode1_Iso,MeasuredMode2_Iso);
[HybHonIsopred_svd,~,IsoModesAct]=predMIMO4(IsoTest.spikeratedata,HybridModes_H,1,1,IsoModes);

%Plot iso preds
HonIMode1_vaf = calculateVAF(HybHonIsopred_svd(:,1),IsoModesAct(:,1));
HonIMode2_vaf = calculateVAF(HybHonIsopred_svd(:,2),IsoModesAct(:,2));
figure; hold on;
x = (0:0.05:length(IsoModesAct)*0.05-0.05)';
plot(x,HybHonIsopred_svd(:,1),'r')
plot(x,IsoModesAct(:,1),'k')
xlim([10 30])
xlabel('Time (sec)')
title(strcat('Hybrid on Isometric Mode 1 | vaf=', num2str(HonIMode1_vaf)))
MillerFigure

figure; hold on;
plot(x,HybHonIsopred_svd(:,2),'r')
plot(x,IsoModesAct(:,2),'k')
xlim([10 30])
xlabel('Time (sec)')
title(strcat('Hybrid on Isometric Mode 2 | vaf=', num2str(HonIMode2_vaf)))
MillerFigure

% Reduce the movement data
ActualMuscles_Wm = WmTest.emgdatabin;
MeasuredMode1_Wm = ActualMuscles_Wm*UnitVector1;
MeasuredMode2_Wm = ActualMuscles_Wm*UnitVector2;
WmModes = cat(2,MeasuredMode1_Wm,MeasuredMode2_Wm);
[HybHonWmpred_svd,~,WmModesAct]=predMIMO4(WmTest.spikeratedata,HybridModes_H,1,1,WmModes);

%Plot Wm preds
HonWmMode1_vaf = calculateVAF(HybHonWmpred_svd(:,1),WmModesAct(:,1))
HonWmMode2_vaf = calculateVAF(HybHonWmpred_svd(:,2),WmModesAct(:,2))
figure; hold on;
x = (0:0.05:length(WmModesAct)*0.05-0.05)';
plot(x,HybHonWmpred_svd(:,1),'g')
plot(x,WmModesAct(:,1),'k')
xlim([10 30])
xlabel('Time (sec)')
title(strcat('Hybrid on Movement Mode 1 | vaf=', num2str(HonWmMode1_vaf)))
figure; hold on;
plot(x,HybHonWmpred_svd(:,2),'g')
plot(x,WmModesAct(:,2),'k')
xlim([10 30])
xlabel('Time (sec)')
title(strcat('Hybrid on Movement Mode 2 | vaf=', num2str(HonWmMode2_vaf)))

[IsoTrainRedH u1i u2i] = reduceHdim(IsoTrain,0);
[ReducedIonIPreds ActualIsoModes] = testReducedH(IsoTest, IsoTrainRedH, u1i, u2i);


figure; hold on
plot(ActualIsoModes(:,1),'k')
plot(ReducedIonIPreds(:,1),'b')
plot(HybHonIsopred_svd(:,1),'g')
title('Isometric Mode 1 Predctions')
legend('Actual','Within','Hybrid')
MillerFigure

[WmTrainRedH u1w u2w] = reduceHdim(WmTrain,0);
[ReducedWonWPreds ActualWmModes] = testReducedH(WmTest, WmTrainRedH, u1w, u2w);

figure; hold on

plot(WmModesAct(:,1),'k')
plot(ReducedWonWPreds(:,1),'b')
plot(HybHonWmpred_svd(:,1),'g')
title('Movement Mode 1 Predctions')
legend('Actual','Within','Hybrid')
MillerFigure

% [HybridRedH u1h u2h] = reduceHdim(HybridFinal,1);
% [ReducedHonWPreds ActualHybridModes] = testReducedH(WmTest, HybridRedH, u1h, u2h);






