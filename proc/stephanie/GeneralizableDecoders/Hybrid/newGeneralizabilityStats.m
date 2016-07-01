% newGeneralizability | Created 08-10-14
function [HonI_vaf IonI_vaf WonI_vaf HonW_vaf WonW_vaf IonW_vaf] = newGeneralizabilityStats(foldername,numlags,emgInd,H, plotFlag, IsoTest, IsoTrain, WmTest, WmTrain,HybridFinal)
% Step 1 | Merge cerebus files and sort
% Step 2 | Unmerge and make bdfs
% Step 3 | Make binned data files (50ms bins)
% foldername = '07242014';
% numlags=10;
% emgInd=11;

% Step 4 | Make hybrid file
% [HybridFinal AlteredIsoFinal AlteredWMFinal] = makeHybridFileFixed(IsoBinned,WmBinned);
% 
% % Step 5 | Make H variable for the EMGs of interest
% [H timerun] = hybridTrain(HybridFinal, numlags, emgInd);
%eval(['H' num2str(emgInd) '=' num2str(a)]);

% Step 6 | Use H variable to make predictions
[HonIpred] = hybridTest(H, IsoTest,numlags,emgInd);
[HonWpred] = hybridTest(H, WmTest,numlags,emgInd);




%--------------------------------------------------------------------------
%BuildNormalModels
options=[]; options.PredEMGs = 1;
IsoModelAll = BuildModel(IsoTrain, options);
WmModelAll = BuildModel(WmTrain, options);
HybridUnMod = BuildModel(HybridFinal, options);



% Make within and across predictions
% Within predictions ------------------------------------------------------
%--------------------------------------------------------------------------
[IonIpred] = predictSignals(IsoModelAll,IsoTest);
IonIpred = IonIpred.preddatabin(:,emgInd);
% [~, IonI_vaf, ~, IonIpred_all] = mfxval(IsoTrain,options);
% IonIpred = IonIpred.preddatabin(:,emgInd);
%--------------------------------------------------------------------------
[WonWpred] = predictSignals(WmModelAll,WmTest);
WonWpred = WonWpred.preddatabin(:,emgInd);
% Across predictions ------------------------------------------------------
%--------------------------------------------------------------------------
[WonIpred] = predictSignals(WmModelAll,IsoTest);
WonIpred = WonIpred.preddatabin(:,emgInd);
%--------------------------------------------------------------------------
[IonWpred] = predictSignals(IsoModelAll,WmTest);
IonWpred = IonWpred.preddatabin(:,emgInd);
%--------------------------------------------------------------------------
[HOonIpred] = predictSignals(HybridUnMod,IsoTest);
HOonIpred = HOonIpred.preddatabin(:,emgInd);
%--------------------------------------------------------------------------
[HOonWpred] = predictSignals(HybridUnMod,WmTest);
HOonWpred = HOonWpred.preddatabin(:,emgInd);



%Calculate VAFs -----------------------------------------------------------
Pred = HonIpred; Act = IsoTest.emgdatabin(numlags:end,emgInd);
HonI_vaf = calculateVAF(Pred,Act);
%--------------------------------------------------------------------------
Pred = HonWpred;
Act = WmTest.emgdatabin(numlags:end,emgInd);
HonW_vaf = calculateVAF(Pred,Act);
%--------------------------------------------------------------------------
Pred = WonWpred;
Act = WmTest.emgdatabin(numlags:end,emgInd);
WonW_vaf = calculateVAF(Pred,Act);
%--------------------------------------------------------------------------
Pred = IonIpred;
Act = IsoTest.emgdatabin(numlags:end,emgInd);
IonI_vaf = calculateVAF(Pred,Act);
%--------------------------------------------------------------------------
Pred = IonWpred;
Act = WmTest.emgdatabin(numlags:end,emgInd);
IonW_vaf = calculateVAF(Pred,Act);
%--------------------------------------------------------------------------
Pred = WonIpred;
Act = IsoTest.emgdatabin(numlags:end,emgInd);
WonI_vaf = calculateVAF(Pred,Act);
%--------------------------------------------------------------------------
Pred = HOonWpred;
Act = WmTest.emgdatabin(numlags:end,emgInd);
HOonW_vaf = calculateVAF(Pred,Act);
%--------------------------------------------------------------------------
Pred = HOonIpred;
Act = IsoTest.emgdatabin(numlags:end,emgInd);
HOonI_vaf = calculateVAF(Pred,Act);


if plotFlag == 1

%Make figures
% Make figure showing hybrid, across, within predictions
linewidth = 1.5;
x = (0:0.05:length(HonIpred)*.05-0.05)';
% Plot predictions of isometric data---------------------------------------
%--------------------------------------------------------------------------
figure;hold on;
plot(x,IsoTest.emgdatabin(numlags:end,emgInd),'k','LineWidth', linewidth)
plot(x,HonIpred,'g','LineWidth', linewidth)
plot(x,IonIpred,'b','LineWidth', linewidth)
plot(x,WonIpred,'r','LineWidth', linewidth)
plot(x,HOonIpred,'c','LineWidth', linewidth)
xlabel('Time (sec)')
title(strcat(foldername, ':', num2str(IsoTest.emgguide(emgInd,:)), ' Predictions | Isometric data'))
legend('Actual',strcat('Hybrid | vaf=',num2str(HonI_vaf)),strcat('Within | vaf=',num2str(IonI_vaf)),strcat('Across | vaf=',num2str(WonI_vaf)),strcat('HybridOrig | vaf=',num2str(HOonI_vaf)))
set(gca,'TickDir','out')
box off
 
%Save figure
% saveas(gcf, strcat(foldername, '_PredOnIsoData_',  num2str(IsoTest.emgguide(emgInd,:)),'.fig'))
% xlim([30 50]);
% saveas(gcf, strcat(foldername, '_PredOnIsoData_',  num2str(IsoTest.emgguide(emgInd,:)),'.tif'))
 
 
 
% Plot predictions of movement data----------------------------------------
%--------------------------------------------------------------------------
figure;hold on;
plot(x,WmTest.emgdatabin(numlags:end,emgInd),'k','LineWidth', linewidth)
plot(x,HonWpred,'g','LineWidth', linewidth)
plot(x,WonWpred,'b','LineWidth', linewidth)
plot(x,IonWpred,'r','LineWidth', linewidth)
plot(x,HOonWpred,'c','LineWidth', linewidth)
title(strcat(foldername, ':', num2str(WmTest.emgguide(emgInd,:)), ' Predictions | Movement data'))
legend('Actual',strcat('Hybrid | vaf=',num2str(HonW_vaf)),strcat('Within | vaf=',num2str(WonW_vaf)),strcat('Across | vaf=',num2str(IonW_vaf)),strcat('HybridOrig | vaf=',num2str(HOonW_vaf)));
set(gca,'TickDir','out')
 box off
 
   %Save figure
%  saveas(gcf, strcat(foldername, '_PredOnWmData_',  num2str(WmTest.emgguide(emgInd,:)),'.fig'))
% xlim([30 50]);
%  saveas(gcf, strcat(foldername, '_PredOnWmData_',  num2str(WmTest.emgguide(emgInd,:)),'.tif'))
% 

 %--------------------------------------------------------------------------------
 %Polynomial plotting
 PolyOrder = 2;PlotFlag=0;
 
 
Act = IsoTest.emgdatabin(numlags:end,emgInd);
[P] = WienerNonlinearity(HonIpred,Act,PolyOrder,PlotFlag);
HonIcascade = polyval(P,HonIpred);
HcascadeonI_vaf = calculateVAF(HonIcascade,Act);


linewidth = 1.5;
x = (0:0.05:length(HonIpred)*.05-0.05)';
% Plot predictions of isometric data---------------------------------------
%--------------------------------------------------------------------------
figure;hold on;
plot(x,IsoTest.emgdatabin(numlags:end,emgInd),'k','LineWidth', linewidth)
plot(x,HonIpred,'g','LineWidth', linewidth)
plot(x,HonIcascade,'b','LineWidth', linewidth)
xlabel('Time (sec)');
title(strcat(foldername, ':', num2str(IsoTest.emgguide(emgInd,:)), ' Predictions | Isometric data'))
set(gca,'TickDir','out'); box off;
legend('Actual', strcat('Hybrid Linear | vaf=', num2str(HonI_vaf)), strcat('Hybrid 2nd Order | vaf=',num2str(HcascadeonI_vaf)));



%Save figure
% saveas(gcf, strcat(foldername, '_PredOnIsoDataWCascade_',  num2str(IsoTest.emgguide(emgInd,:)),'.fig'))
% xlim([30 50]);
% saveas(gcf, strcat(foldername, '_PredOnIsoDataWCascade_',  num2str(IsoTest.emgguide(emgInd,:)),'.tif'))


%------------------------------------------------------------------------------
%--------------------------------------------------------------------------
Act = WmTest.emgdatabin(numlags:end,emgInd);
[P] = WienerNonlinearity(HonWpred,Act,PolyOrder,PlotFlag);
HonWcascade = polyval(P,HonWpred);
HcascadeonW_vaf = calculateVAF(HonWcascade,Act);

% Plot predictions of movement data----------------------------------------
%--------------------------------------------------------------------------
figure;hold on;
plot(x,WmTest.emgdatabin(numlags:end,emgInd),'k','LineWidth', linewidth)
plot(x,HonWpred,'g','LineWidth', linewidth)
plot(x,HonWcascade,'b','LineWidth', linewidth)
title(strcat(foldername, ':', num2str(WmTest.emgguide(emgInd,:)), ' Predictions | Movement data'))
legend('Actual', strcat('Hybrid Linear | vaf=', num2str(HonW_vaf)), strcat('Hybrid 2nd Order | vaf=',num2str(HcascadeonW_vaf)));
set(gca,'TickDir','out')
 box off
  
 
% saveas(gcf, strcat(foldername, '_PredOnWmDataWCascade_',  num2str(IsoTest.emgguide(emgInd,:)),'.fig'))
% xlim([30 50]);
% saveas(gcf, strcat(foldername, '_PredOnWmDataWCascade_',  num2str(IsoTest.emgguide(emgInd,:)),'.tif'))

end
  
  
