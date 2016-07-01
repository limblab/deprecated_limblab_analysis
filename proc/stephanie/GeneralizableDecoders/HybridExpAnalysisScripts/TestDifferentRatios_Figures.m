foldername = '07232014';


MarkerSize = 20;
x = 1:1:12;
HonW_vaf_std = Hstats{1,1}.HonW_vaf;
HonW_vaf_var = Hstats{1,2}.HonW_vaf;
HonW_vaf_sqrtstd = Hstats{1,3}.HonW_vaf;
subplot(2,1,1);  hold on;
plot(x,HonW_vaf_std ,'bs','MarkerSize', MarkerSize)
plot(x,HonW_vaf_var,'go','MarkerSize', MarkerSize)
plot(x,HonW_vaf_sqrtstd,'rv','MarkerSize', MarkerSize)
legend('std', 'var', 'sqrtstd','Location','NorthEastOutside');
title(strcat([foldername, ' | Hybrid on Movement ']));
set(gca,'XTick',[1:length(HybridFinal.emgguide(:,1))]);
EMGnames = {HybridFinal.emgguide};
set(gca,'XTickLabel',EMGnames)
MillerFigure
axis([1 12 -.1 1])
box off

HonI_vaf_std = Hstats{1,1}.HonI_vaf;
HonI_vaf_var = Hstats{1,2}.HonI_vaf;
HonI_vaf_sqrtstd = Hstats{1,3}.HonI_vaf;
subplot(2,1,2); hold on;
plot(x,HonI_vaf_std ,'bs','MarkerSize', MarkerSize)
plot(x,HonI_vaf_var,'go','MarkerSize', MarkerSize)
plot(x,HonI_vaf_sqrtstd,'rv','MarkerSize', MarkerSize)
title('Hybrid on Isometric')
set(gca,'XTick',[1:length(HybridFinal.emgguide(:,1))]);
legend('std', 'var', 'sqrtstd','Location','NorthEastOutside');
set(gca,'XTickLabel',EMGnames)
MillerFigure
axis([1 12 -.1 1])
box off
 
   saveas(gcf, strcat(foldername, '_RatioEval', '.fig'))
    saveas(gcf, strcat(foldername, '_RatioEval', '.pdf'))
   
   