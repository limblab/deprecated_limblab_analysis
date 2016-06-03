ChPSD_a = squeeze(mean([PSDreal{1}(:,1,:);PSDreal{1}(:,2,:)]));
ChPSD_m = squeeze(mean([PSDpred{1}(:,1,1,:);PSDpred{1}(:,1,2,:)]));
ChPSD_p = squeeze(mean([PSDpred{1}(:,2,1,:);PSDpred{1}(:,2,2,:)]));
ChPSDstd_a = squeeze(std([PSDreal{1}(:,1,:);PSDreal{1}(:,2,:)]));
ChPSDstd_m = squeeze(std([PSDpred{1}(:,1,1,:);PSDpred{1}(:,1,2,:)]));
ChPSDstd_p = squeeze(std([PSDpred{1}(:,2,1,:);PSDpred{1}(:,2,2,:)]));

MPSD_a = squeeze(mean([PSDreal{2}(:,1,:);PSDreal{2}(:,2,:)]));
MPSD_m = squeeze(mean([PSDpred{2}(:,1,1,:);PSDpred{2}(:,1,2,:)]));
MPSD_p = squeeze(mean([PSDpred{2}(:,2,1,:);PSDpred{2}(:,2,2,:)]));
MPSDstd_a = squeeze(std([PSDreal{2}(:,1,:);PSDreal{2}(:,2,:)]));
MPSDstd_m = squeeze(std([PSDpred{2}(:,1,1,:);PSDpred{2}(:,1,2,:)]));
MPSDstd_p = squeeze(std([PSDpred{2}(:,2,1,:);PSDpred{2}(:,2,2,:)]));

freq = 0:10/128:10;

figure
subplot(1,2,1)
hold on; plot(freq,10*log10(ChPSD_a),'k',freq,10*log10(ChPSD_m),'r',freq,10*log10(ChPSD_p),'b');
hold on; shadedplot(freq,10*log10(ChPSD_a-ChPSDstd_a)',10*log10(ChPSD_a+ChPSDstd_a)',[0.7 0.7 0.7],[0.7 0.7 0.7])
hold on; shadedplot(freq,10*log10(ChPSD_m-ChPSDstd_m)',10*log10(ChPSD_m+ChPSDstd_m)',[1.0 0.7 0.7],[1.0 0.7 0.7])
hold on; shadedplot(freq,10*log10(ChPSD_p-ChPSDstd_p)',10*log10(ChPSD_p+ChPSDstd_p)',[0.7 0.7 1.0],[0.7 0.7 1.0])
hold on; plot(freq,10*log10(ChPSD_a),'k',freq,10*log10(ChPSD_m),'r',freq,10*log10(ChPSD_p),'b');
legend('actual','movement','posture')
title('Chewie PSD')
ylabel('power/frequency (dB/Hz)')
xlabel('frequency (Hz)')
grid off

subplot(1,2,2)
hold on; plot(freq,10*log10(MPSD_a),'k',freq,10*log10(MPSD_m),'r',freq,10*log10(MPSD_p),'b');
hold on; shadedplot(freq,10*log10(MPSD_a-MPSDstd_a)',10*log10(MPSD_a+MPSDstd_a)',[0.7 0.7 0.7],[0.7 0.7 0.7])
hold on; shadedplot(freq,10*log10(MPSD_m-MPSDstd_m)',10*log10(MPSD_m+MPSDstd_m)',[1.0 0.7 0.7],[1.0 0.7 0.7])
hold on; shadedplot(freq,10*log10(MPSD_p-MPSDstd_p)',10*log10(MPSD_p+MPSDstd_p)',[0.7 0.7 1.0],[0.7 0.7 1.0])
hold on; plot(freq,10*log10(MPSD_a),'k',freq,10*log10(MPSD_m),'r',freq,10*log10(MPSD_p),'b');
legend('actual','movement','posture')
title('Mini PSD')
ylabel('power/frequency (dB/Hz)')
xlabel('frequency (Hz)')
grid off