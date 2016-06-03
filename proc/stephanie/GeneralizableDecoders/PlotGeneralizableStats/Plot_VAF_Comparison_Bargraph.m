%Figure


figure
mean_WonW_and_HonW_vaf = [mean_WonW_All_vaf(1,:); mean_HonW_All_vaf(1,:); mean_IonW_All_vaf(1,:)]';
ste_WonW_and_HonW_vaf = [ste_WonW_All_vaf(1,:); ste_HonW_All_vaf(1,:); ste_IonW_All_vaf(1,:)]';

h1 = subplot(2,1,1);
barwitherr(ste_WonW_and_HonW_vaf, mean_WonW_and_HonW_vaf)
ylim([-10 1])

mean_IonI_and_HonI_vaf = [mean_IonI_All_vaf(1,:);mean_HonI_All_vaf(1,:); mean_WonI_All_vaf(1,:)]';
ste_IonI_and_HonI_vaf = [ste_IonI_All_vaf(1,:); ste_HonI_All_vaf(1,:); ste_WonI_All_vaf(1,:)]';

h2=subplot(2,1,2);
barwitherr(ste_IonI_and_HonI_vaf, mean_IonI_and_HonI_vaf)
ylim([-10 1])

legend(h1,'Within', 'Hybrid', 'Across')
legend('boxoff')
title(h1,'VAF for EMG predictions | Movement Task')
set(h1,'XTickLabel',{'Extensor-Radial' 'Extensor-Median' 'Extensor-Ulnar' 'Flexor-Ulnar' 'Flexor-Median' 'Flexor-Radial'})
set(gca,'TickDir','out')

title(h2,'VAF for EMG predictions | Isometric Task')
% Labels: 'Isometric Within', 'Hybrid on Isometric', 'Movement on Iso'
%legend(h2,'Within', 'Hybrid', 'Across')
set(h2,'XTickLabel',{'Extensor-Radial' 'Extensor-Median' 'Extensor-Ulnar' 'Flexor-Ulnar' 'Flexor-Median' 'Flexor-Radial'})
set(gca,'TickDir','out')


