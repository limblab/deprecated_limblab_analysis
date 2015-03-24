% Plot predictions
figure
i = 2;

x= IsoBinned.timeframe(610:910);
plot(x,IsoBinned.emgdatabin(610:910,i), 'k','LineWidth',2)
hold on
plot(x,HonI_PredData.preddatabin(1:301,i),'g','LineWidth',2) %8931
%plot(AlteredIso.emgdatabin(1:600,i), 'k','LineWidth',2)
title('Hybrid')
xlim([35 45])
box off

figure
plot(x,IsoBinned.emgdatabin(610:910,i), 'k','LineWidth',2)
hold on
plot(x,WonI_PredData.preddatabin(600:900,i),'r','LineWidth',2)
title('Across')
xlim([35 45])
box off

figure
plot(x,IsoBinned.emgdatabin(610:910,i), 'k','LineWidth',2)
hold on
plot(x,Iso_All_OLPredData.preddatabin(600:900,i),'b','LineWidth',2)
title('Within')
xlim([35 45])
box off

%Movement------------------------------------------------------------------


x= WmBinned.timeframe(10:310);
plot(x,WmBinned.emgdatabin(10:310,i), 'k','LineWidth',2)
hold on
plot(x,HonW_PredDdata.preddatabin(301:601,i),'g','LineWidth',2) %8931
%plot(AlteredIso.emgdatabin(1:600,i), 'k','LineWidth',2)
title('Hybrid')
xlim([35 45])
box off


figure
plot(x,WmBinned.emgdatabin(10:310,i), 'k','LineWidth',2)
hold on
plot(x,IonW_PredData.preddatabin(1:300,i),'r','LineWidth',2)
title('Across')
xlim([35 45])
box off

figure
plot(x,WmBinned.emgdatabin(610:910,i), 'k','LineWidth',2)
hold on
plot(x,Wm_All_OLPredData.preddatabin(1:300,i),'b','LineWidth',2)
title('Within')
xlim([35 45])
box off


