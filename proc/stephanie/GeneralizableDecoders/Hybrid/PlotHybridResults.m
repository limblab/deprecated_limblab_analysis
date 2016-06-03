

numlags = 10;
EMG = 11;
[FinalPredHybridFinal] = hybridTest(H, HybridFinal, numlags, EMG);
figure
hold on;
plot(HybridFinal.emgdatabin(10:end,EMG),'k')
plot(FinalPredHybridFinal,'b')

[FinalPredAltIso] = hybridTest(H, AlteredIsoFinal, numlags, EMG);
figure
hold on;
plot(AlteredIsoFinal.emgdatabin(10:end,EMG),'k')
plot(FinalPredAltIso,'b')
title('Hybrid Decoder on Iso data only')

FinalPredAltWM] = hybridTest(H, AlteredWMFinal, numlags, EMG);
figure
hold on;
plot(AlteredWMFinal.emgdatabin(10:end,EMG),'k')
plot(FinalPredAltWM,'b')
title('Hybrid Decoder on Movement data only')

figure
hold on;
plot(HybridFinal.emgdatabin(:,EMG));

figure
hold on;
plot(IsoBinned.emgdatabin(:,EMG),'b')
plot(WmBinned.emgdatabin(:,EMG),'g')
