%Figure


figure
mean_WonW_and_HonW = [mean_WonW_G_R2(1,:); mean_HonW_G_R2(1,:); mean_IonW_G_R2(1,:)]';
ste_WonW_and_HonW = [ste_WonW_G_R2(1,:); ste_HonW_G_R2(1,:); ste_IonW_G_R2(1,:)]';

h1 = subplot(2,1,1);
barwitherr(ste_WonW_and_HonW, mean_WonW_and_HonW)
ylim([0 1])

mean_IonI_and_HonI = [mean_IonI_G_R2(1,:);mean_HonI_G_R2(1,:); mean_WonI_G_R2(1,:)]';
ste_IonI_and_HonI = [ste_IonI_G_R2(1,:); ste_HonI_G_R2(1,:); ste_WonI_G_R2(1,:)]';

h2=subplot(2,1,2);
barwitherr(ste_IonI_and_HonI, mean_IonI_and_HonI)
ylim([0 1])

legend(h1,'Within', 'Hybrid', 'Across')
legend('boxoff')
title(h1,'R-squared for EMG predictions | Movement Task | Gyrus Data')
set(h1,'XTickLabel',{'Extensor-Radial' 'Extensor-Median' 'Extensor-Ulnar' 'Flexor-Ulnar' 'Flexor-Median' 'Flexor-Radial'})

title(h2,'R-squared for EMG predictions | Isometric Task | Gyrus Data')
% Labels: 'Isometric Within', 'Hybrid on Isometric', 'Movement on Iso'
%legend(h2,'Within', 'Hybrid', 'Across')
set(h2,'XTickLabel',{'Extensor-Radial' 'Extensor-Median' 'Extensor-Ulnar' 'Flexor-Ulnar' 'Flexor-Median' 'Flexor-Radial'})



