GeneralizableAnalysis_BarPlotSummaryOfMultivariateVAFs(MegaVAFstruct)

% Compute ratios of Hybrid Over within and across | across all days
HonWversusWonWratio = mean([MegaVAFstruct.HonW_vaf_mean])/mean([MegaVAFstruct.WonW_vaf_mean]);
HonWversusIonWratio = mean([MegaVAFstruct.HonW_vaf_mean])/mean([MegaVAFstruct.IonW_vaf_mean]);

HonWversusWonWratio = mean([MegaVAFstruct.HonW_vaf_mean])/mean([MegaVAFstruct.WonW_vaf_mean]);
HonWversusIonWratio = mean([MegaVAFstruct.HonW_vaf_mean])/mean([MegaVAFstruct.IonW_vaf_mean]);


% Compute ratios of Hybrid Over within and across | for each separate day
HonWversusWonWratio_all = ([MegaVAFstruct.HonW_vaf_mean])./([MegaVAFstruct.WonW_vaf_mean]);
HonWversusIonWratio_all = ([MegaVAFstruct.HonW_vaf_mean])./([MegaVAFstruct.IonW_vaf_mean]);


figure; plot(HonWversusWonWratio_all,'.k','MarkerSize',15); title('Movement | Hybrid versus Movement Decoder')
figure; plot(HonWversusIonWratio_all,'.k','MarkerSize',15); title('Movement | Hybrid versus Isometric Decoder')

figure; bar([HonWversusWonWratio_all; HonWversusIonWratio_all]');ylim([-1 1]);
legend({'HonW versus WonW';'HonW versus IonW'})

% Compute ratios of Hybrid Over within and across | for each separate day -
% for Iso
HonIversusIonIratio_all = ([MegaVAFstruct.HonI_vaf_mean])./([MegaVAFstruct.IonI_vaf_mean]);
HonIversusWonIratio_all = ([MegaVAFstruct.HonI_vaf_mean])./([MegaVAFstruct.WonI_vaf_mean]);

figure; plot(HonIversusIonIratio_all,'.k','MarkerSize',15); title('Isometric | Hybrid versus Isometric Decoder')
figure; plot(HonIversusWonIratio_all,'.k','MarkerSize',15); title('Isometric | Hybrid versus Movement Decoder')

figure; bar([HonIversusIonIratio_all; HonIversusWonIratio_all]');ylim([-1 1]);
legend({'HonI versus IonI';'HonI versus WonI'})





