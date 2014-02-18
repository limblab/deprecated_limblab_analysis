h = figure;
SandG_means = [mean_IonI_S_R2; mean_IonI_G_R2]';
SandG_ste = [ste_IonI_S_R2; ste_IonI_G_R2]';

barwitherr(SandG_ste, SandG_means)
ylim([0 1])

legend('Sulcus','Gyrus')
legend('boxoff')
title('R-squared for EMG predictions | Isometric Task')
set(gca,'XTickLabel',{'Extensor-Radial' 'Extensor-Median' 'Extensor-Ulnar' 'Flexor-Ulnar' 'Flexor-Median' 'Flexor-Radial'})
 
