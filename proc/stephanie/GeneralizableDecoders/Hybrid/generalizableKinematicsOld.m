%Created 8/19/14

% Make hybrid file
[HybridKinematics AlteredSprFinal AlteredWMFinal] = makeHybridFileFixed(SprBinned, WmBinned);

%Initializations
foldername = '08192014';
curposInd = 1;
numlags = 10;

%Make your models---------------------------------------------------------
options.PredCursPos = 1;
SprModelAll = BuildModel(SprBinned, options);
WmModelAll = BuildModel(WmBinned, options);
HybridKinModel = BuildModel(HybridKinematics, options);

%Use Hybrid to predict wrist movement
[HKonWpred] = predictSignals(HybridKinModel,AlteredWMFinal);
HKonWpred = HKonWpred.preddatabin(:,curposInd);
%Use Hybrid to predict spring
[HKonSpred] = predictSignals(HybridKinModel,AlteredSprFinal);
HKonSpred = HKonSpred.preddatabin(:,curposInd);

% Across predictions ------------------------------------------------------
%--------------------------------------------------------------------------
[WonSpred] = predictSignals(WmModelAll,AlteredSprFinal);
WonSpred = WonSpred.preddatabin(:,curposInd);
%--------------------------------------------------------------------------
[SonWpred] = predictSignals(SprModelAll,AlteredWMFinal);
SonWpred = SonWpred.preddatabin(:,curposInd);


%Calculate VAFs -----------------------------------------------------------
Pred = HKonWpred; Act = AlteredWMFinal.cursorposbin(numlags:end,curposInd);
HKonW_vaf = calculateVAF(Pred,Act)
%--------------------------------------------------------------------------
Pred = HKonSpred; Act = AlteredSprFinal.cursorposbin(numlags:end,curposInd);
HKonS_vaf = calculateVAF(Pred,Act)
%--------------------------------------------------------------------------
Pred = WonSpred; Act = AlteredSprFinal.cursorposbin(numlags:end,curposInd);
WonS_vaf = calculateVAF(Pred,Act)
%--------------------------------------------------------------------------
Pred = SonWpred; Act = AlteredWMFinal.cursorposbin(numlags:end,curposInd);
SonW_vaf = calculateVAF(Pred,Act)
%--------------------------------------------------------------------------
 [~, SonS_vaf, ~, SonSpred_all] = mfxval(SprBinned,options);



%Make figures
% Predictions on Spring data ----------------------------------------------
linewidth = 1.5;
x = (0:0.05:length(HKonSpred)*.05-0.05)';
% Plot predictions of movement data---------------------------------------
%--------------------------------------------------------------------------
figure;hold on;
plot(x,AlteredSprFinal.cursorposbin(numlags:end,curposInd),'k','LineWidth', linewidth)
plot(x,HKonSpred,'g','LineWidth', linewidth)
plot(x,WonSpred,'b','LineWidth', linewidth)

xlabel('Time (sec)')
title(strcat([foldername, ':',' ', num2str(AlteredSprFinal.cursorposlabels(curposInd,1)), ' Predictions | Spring data']))
legend('Actual',strcat('Hybrid | vaf=',num2str(HKonS_vaf)),strcat('Across | vaf=',num2str(WonS_vaf)))
set(gca,'TickDir','out')
box off



% Predictions on Movement data ---------------------------------------------
linewidth = 1.5;
x = (0:0.05:length(HKonWpred)*.05-0.05)';
% Plot predictions of movement data---------------------------------------
%--------------------------------------------------------------------------
figure;hold on;
plot(x,AlteredWMFinal.cursorposbin(numlags:end,curposInd),'k','LineWidth', linewidth)
plot(x,HKonWpred,'g','LineWidth', linewidth)
plot(x,SonWpred,'b','LineWidth', linewidth)

xlabel('Time (sec)')
title(strcat([foldername, ':',' ', num2str(AlteredWMFinal.cursorposlabels(curposInd,1)), ' Predictions | Movement data']))
legend('Actual',strcat('Hybrid | vaf=',num2str(HKonW_vaf)),strcat('Across | vaf=',num2str(SonW_vaf)))
set(gca,'TickDir','out')
box off
