function PlotVAFAcrossDays(i,figNo,meanWithinVAF, steWithinVAF, meanHybridVAF, steHybridVAF, meanAcrossWmVAF, steAcrossIsoVAF,meanAcrossIsoVAF, steAcrossWmVAF, save,foldername, filename)

if ~isempty(meanWithinVAF)
    MarkerSize=20;LineWidth = 2;
    figure(figNo); hold on;
    h1=errorbar(i,meanWithinVAF,steWithinVAF,steWithinVAF,'.b');
    set(h1,'MarkerSize',MarkerSize);set(h1,'LineWidth',2)
    h2=errorbar(i,meanHybridVAF, steHybridVAF,steHybridVAF,'.g');
    set(h2,'MarkerSize',MarkerSize);set(h2,'LineWidth',2)
    h3=errorbar(i,meanAcrossWmVAF, steAcrossWmVAF,steAcrossWmVAF,'.r');
    set(h3,'MarkerSize',MarkerSize); set(h3,'LineWidth',2)
    h4=errorbar(i,meanAcrossIsoVAF, steAcrossIsoVAF,steAcrossIsoVAF,'.m');
    set(h4,'MarkerSize',MarkerSize); set(h4,'LineWidth',2)
    hold off;
    xlim([0 15])
    ylim([0 1])
    title(filename)
    legend('Within','Hybrid','Move','Iso')
end

end
