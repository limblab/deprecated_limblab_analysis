function HybridMeasureOfLinearity(MegaVAFstruct)


% Compute ratios of Hybrid Over within and across | for each separate day
HonWversusWonWratio_all = ([MegaVAFstruct.HonW_vaf_mean])./([MegaVAFstruct.WonW_vaf_mean]);
figure; plot(HonWversusWonWratio_all,'*')

figure; plot(1:length(HonWversusWonWratio_all),HonWversusWonWratio_all,'.k','MarkerSize',10);
legend({'HonW versus WonW';'HonW versus IonW'})

% Compute ratios of Hybrid Over within and across | for each separate day -
% for Iso
HonIversusIonIratio_all = ([MegaVAFstruct.HonI_vaf_mean])./([MegaVAFstruct.IonI_vaf_mean]);


figure; bar([HonIversusIonIratio_all; HonIversusWonIratio_all]');ylim([-1 1]);
legend({'HonI versus IonI';'HonI versus WonI'})



end

