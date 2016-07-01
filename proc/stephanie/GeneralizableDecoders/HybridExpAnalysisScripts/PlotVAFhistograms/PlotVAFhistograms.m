function PlotVAFhistograms(withinVAF,hybridVAF,acrossVAF,histTitle)
% PlotVAFhistograms(IonI_vaf(1:9),HonI_vaf(1:9),WonI_vaf(1:9),'Isometric data | Within')
% PlotVAFhistograms(WonW_vaf(1:9),HonW_vaf(1:9),IonW_vaf(1:9),'Movement data | Within')


figure; 
ax1=subplot(3,1,1);
h1 = histogram(withinVAF);h1.FaceColor = 'b';h1.BinEdges = [-1:.1:1];
title(histTitle)
MillerFigure;
ax2=subplot(3,1,2);
h2 = histogram(hybridVAF);h2.FaceColor = 'y';h2.BinEdges = [-1:.1:1];
title('Hybrid')
ax3=subplot(3,1,3);
MillerFigure;
h3 = histogram(acrossVAF);h3.FaceColor = 'r';h3.BinEdges = [-1:.1:1];
title('Across')
linkaxes([ax1,ax2,ax3],'y')


