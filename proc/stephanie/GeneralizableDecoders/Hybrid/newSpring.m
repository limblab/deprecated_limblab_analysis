

[HonSpred] = hybridTest(H, SprBinned,numlags,emgInd);

%Spring
[IonSpred] = predictSignals(IsoModelAll,SprBinned);
IonSpred = IonSpred.preddatabin(:,emgInd);
[WonSpred] = predictSignals(WmModelAll,SprBinned);
WonSpred = WonSpred.preddatabin(:,emgInd);

% % Spring within
% [~, SonS_vaf, ~, Spr_All_OLPredData] = mfxval(SprBinned, options);
% SonSpred = Spr_All_OLPredData.preddatabin(:,emgInd);

%Calculate VAFs
%-------------------------------------------------------------------------
Pred = HonSpred;
Act = SprBinned.emgdatabin(numlags:end,emgInd);
HonS_vaf = calculateVAF(Pred,Act);
%-------------------------------------------------------------------------
Pred = IonSpred;
Act = SprBinned.emgdatabin(numlags:end,emgInd);
IonS_vaf = calculateVAF(Pred,Act);
%-------------------------------------------------------------------------
Pred = WonSpred;
Act = SprBinned.emgdatabin(numlags:end,emgInd);
WonS_vaf = calculateVAF(Pred,Act);

% Plot spring
Springx = (0:0.05:length(HonSpred)*.05-0.05)';
figure;hold on;
plot(Springx,SprBinned.emgdatabin(numlags:end,emgInd),'k','LineWidth', linewidth)
plot(Springx,HonSpred,'g','LineWidth', linewidth)
plot(Springx,IonSpred,'b','LineWidth', linewidth)
plot(Springx,WonSpred,'r','LineWidth', linewidth)
xlabel('Time (sec)')
set(gca,'TickDir','out')
legend('Actual',strcat('Hybrid | vaf=',num2str(HonS_vaf)),strcat('Iso | vaf=',num2str(IonS_vaf)),strcat('Wm | vaf=',num2str(WonS_vaf)))
title(strcat(foldername, ':', num2str(AlteredWMFinal.emgguide(emgInd,:)), ' Predictions | Spring data'))
 box off
 
 
 %Save figure
saveas(gcf, strcat(foldername, '_PredOnSprData_TwoThirdsScale_',  num2str(AlteredIsoFinal.emgguide(emgInd,:)),'.fig'))
xlim([20 50]);
saveas(gcf, strcat(foldername, '_PredOnSprData_TwoThirdsScale_',  num2str(AlteredIsoFinal.emgguide(emgInd,:)),'.tif'))
 
 
 
 
