function PlotVAFAcrossDays_kinematics(i,figNo,meanWithinVAF, steWithinVAF, meanHybridVAF, steHybridVAF, save,foldername, filename)

MarkerSize=20;LineWidth = 2;
figure(figNo); hold on;
h1=errorbar(i,meanWithinVAF,steWithinVAF,steWithinVAF,'.b');
set(h1,'MarkerSize',MarkerSize);set(h1,'LineWidth',2)
h2=errorbar(i,meanHybridVAF, steHybridVAF,steHybridVAF,'.g');
set(h2,'MarkerSize',MarkerSize);set(h2,'LineWidth',2)
hold off;
xlim([0 10])
ylim([0 1])
title(filename)

end
