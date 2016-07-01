function PlotVAFhistograms_Spring(withinVAF,hybridVAF,acrossFromIsoVAF,acrossFromMoveVAF,histTitle)
% PlotVAFhistograms_Spring(IonS_vaf(1:9),HonS_vaf(1:9),WonI_vaf(1:9),WonS_vaf(1:9),'Spring data | Within')



figure; 
ax1=subplot(4,1,1);
h1 = histogram(withinVAF);h1.FaceColor = 'b';h1.BinEdges = [-1:.1:1];
title(histTitle)
MillerFigure;
ax2=subplot(4,1,2);
h2 = histogram(hybridVAF);h2.FaceColor = 'y';h2.BinEdges = [-1:.1:1];
title('Hybrid')
ax3=subplot(4,1,3);
MillerFigure;
h3 = histogram(acrossFromIsoVAF);h3.FaceColor = 'r';h3.BinEdges = [-1:.1:1];
title('Across (from Isometric)')
ax4=subplot(4,1,4);
MillerFigure;
h4 = histogram(acrossFromMoveVAF);h4.FaceColor = 'r';h4.BinEdges = [-1:.1:1];
title('Across (from Movement)')
linkaxes([ax1,ax2,ax3,ax4],'y')


