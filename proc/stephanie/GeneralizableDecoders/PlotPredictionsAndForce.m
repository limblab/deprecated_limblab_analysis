i = 12;
figure
hold on
plot(WmBinned.emgdatabin(10:end,i),'k')
plot(Iso_All_OLPredData.preddatabin(:,i),'r')

figure
hold on
plot(IsoBinned.emgdatabin(10:end,i),'k')
plot(Wm_All_OLPredData.preddatabin(:,i),'r')