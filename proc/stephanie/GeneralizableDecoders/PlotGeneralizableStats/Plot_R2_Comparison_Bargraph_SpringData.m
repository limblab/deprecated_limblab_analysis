%Figure


figure
mean_WonS_and_HonS = [mean_WonS_All_R2(1,:); mean_HonS_All_R2(1,:); mean_IonS_All_R2(1,:); mean_SonS_All_R2(1,:)]';
ste_WonS_and_HonS = [ste_WonS_All_R2(1,:); ste_HonS_All_R2(1,:); ste_IonS_All_R2(1,:); ste_SonS_All_R2(1,:)]';

h1 = subplot(1,1,1);
barwitherr(ste_WonS_and_HonS, mean_WonS_and_HonS)
ylim([0 1])

legend(h1,'Wm', 'Hybird', 'Iso', 'Spr')
legend('boxoff')
title(h1,'R-squared for EMG predictions | Decoders Applied to Spring Data')
set(h1,'XTickLabel',{'Extensor-Radial' 'Extensor-Median' 'Extensor-Ulnar' 'Flexor-Ulnar' 'Flexor-Median' 'Flexor-Radial'})
set(gca,'TickDir','out') 

figure
mean_WonS_and_HonS_vaf = [mean_WonS_All_vaf(1,:); mean_HonS_All_vaf(1,:); mean_IonS_All_vaf(1,:); mean_SonS_All_vaf(1,:)]';
ste_WonS_and_HonS_vaf = [ste_WonS_All_vaf(1,:); ste_HonS_All_vaf(1,:); ste_IonS_All_vaf(1,:); ste_SonS_All_vaf(1,:)]';

h1 = subplot(1,1,1);
barwitherr(ste_WonS_and_HonS_vaf, mean_WonS_and_HonS_vaf)
ylim([-10 1])

legend(h1,'Wm', 'Hybird', 'Iso', 'Spr')
legend('boxoff')
title(h1,'VAF for EMG predictions | Decoders Applied to Spring Data')
set(h1,'XTickLabel',{'Extensor-Radial' 'Extensor-Median' 'Extensor-Ulnar' 'Flexor-Ulnar' 'Flexor-Median' 'Flexor-Radial'})
set(gca,'TickDir','out')
