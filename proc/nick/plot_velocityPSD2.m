% convert to power, combine x and y, and calculate mean and std
% ChPSD_a = squeeze(mean(10*log10([PSDreal{1}(:,1,:);PSDreal{1}(:,2,:)])));
% ChPSD_m = squeeze(mean(10*log10([PSDpred{1}(:,1,1,:);PSDpred{1}(:,1,2,:)])));
% ChPSD_p = squeeze(mean(10*log10([PSDpred{1}(:,2,1,:);PSDpred{1}(:,2,2,:)])));
% ChPSD_s = squeeze(mean(10*log10([PSDpred{1}(:,3,1,:);PSDpred{1}(:,3,2,:)])));
% ChPSDstd_a = squeeze(std(10*log10([PSDreal{1}(:,1,:);PSDreal{1}(:,2,:)])))/sqrt(size(PSDreal{1},1))*1.96;
% ChPSDstd_m = squeeze(std(10*log10([PSDpred{1}(:,1,1,:);PSDpred{1}(:,1,2,:)])))/sqrt(size(PSDpred{1},1))*1.96;
% ChPSDstd_p = squeeze(std(10*log10([PSDpred{1}(:,2,1,:);PSDpred{1}(:,2,2,:)])))/sqrt(size(PSDpred{1},1))*1.96;
% ChPSDstd_s = squeeze(std(10*log10([PSDpred{1}(:,3,1,:);PSDpred{1}(:,3,2,:)])))/sqrt(size(PSDpred{1},1))*1.96;
% 
% MPSD_a = squeeze(mean(10*log10([PSDreal{2}(:,1,:);PSDreal{2}(:,2,:)])));
% MPSD_m = squeeze(mean(10*log10([PSDpred{2}(:,1,1,:);PSDpred{2}(:,1,2,:)])));
% MPSD_p = squeeze(mean(10*log10([PSDpred{2}(:,2,1,:);PSDpred{2}(:,2,2,:)])));
% MPSD_s = squeeze(mean(10*log10([PSDpred{2}(:,3,1,:);PSDpred{2}(:,3,2,:)])));
% MPSDstd_a = squeeze(std(10*log10([PSDreal{2}(:,1,:);PSDreal{2}(:,2,:)])))/sqrt(size(PSDreal{2},1))*1.96;
% MPSDstd_m = squeeze(std(10*log10([PSDpred{2}(:,1,1,:);PSDpred{2}(:,1,2,:)])))/sqrt(size(PSDpred{2},1))*1.96;
% MPSDstd_p = squeeze(std(10*log10([PSDpred{2}(:,2,1,:);PSDpred{2}(:,2,2,:)])))/sqrt(size(PSDpred{2},1))*1.96;
% MPSDstd_s = squeeze(std(10*log10([PSDpred{2}(:,3,1,:);PSDpred{2}(:,3,2,:)])))/sqrt(size(PSDpred{2},1))*1.96;

% linear velocity
ChPSD_a = squeeze(mean(([PSDreal{1}(:,1,:);PSDreal{1}(:,2,:)])));
ChPSD_m = squeeze(mean(([PSDpred{1}(:,1,1,:);PSDpred{1}(:,1,2,:)])));
ChPSD_p = squeeze(mean(([PSDpred{1}(:,2,1,:);PSDpred{1}(:,2,2,:)])));
ChPSD_s = squeeze(mean(([PSDpred{1}(:,3,1,:);PSDpred{1}(:,3,2,:)])));
ChPSDstd_a = squeeze(std(([PSDreal{1}(:,1,:);PSDreal{1}(:,2,:)])))/sqrt(size(PSDreal{1},1))*1.96;
ChPSDstd_m = squeeze(std(([PSDpred{1}(:,1,1,:);PSDpred{1}(:,1,2,:)])))/sqrt(size(PSDpred{1},1))*1.96;
ChPSDstd_p = squeeze(std(([PSDpred{1}(:,2,1,:);PSDpred{1}(:,2,2,:)])))/sqrt(size(PSDpred{1},1))*1.96;
ChPSDstd_s = squeeze(std(([PSDpred{1}(:,3,1,:);PSDpred{1}(:,3,2,:)])))/sqrt(size(PSDpred{1},1))*1.96;

MPSD_a = squeeze(mean(([PSDreal{2}(:,1,:);PSDreal{2}(:,2,:)])));
MPSD_m = squeeze(mean(([PSDpred{2}(:,1,1,:);PSDpred{2}(:,1,2,:)])));
MPSD_p = squeeze(mean(([PSDpred{2}(:,2,1,:);PSDpred{2}(:,2,2,:)])));
MPSD_s = squeeze(mean(([PSDpred{2}(:,3,1,:);PSDpred{2}(:,3,2,:)])));
MPSDstd_a = squeeze(std(([PSDreal{2}(:,1,:);PSDreal{2}(:,2,:)])))/sqrt(size(PSDreal{2},1))*1.96;
MPSDstd_m = squeeze(std(([PSDpred{2}(:,1,1,:);PSDpred{2}(:,1,2,:)])))/sqrt(size(PSDpred{2},1))*1.96;
MPSDstd_p = squeeze(std(([PSDpred{2}(:,2,1,:);PSDpred{2}(:,2,2,:)])))/sqrt(size(PSDpred{2},1))*1.96;
MPSDstd_s = squeeze(std(([PSDpred{2}(:,3,1,:);PSDpred{2}(:,3,2,:)])))/sqrt(size(PSDpred{2},1))*1.96;

% speed
% ChPSD_a = real(squeeze(mean(10*log10(PSDreal{1}(:,3,:)))));
% ChPSD_m = real(squeeze(mean(10*log10(PSDpred{1}(:,1,3,:)))));
% ChPSD_p = real(squeeze(mean(10*log10(PSDpred{1}(:,2,3,:)))));
% ChPSD_s = real(squeeze(mean(10*log10(PSDpred{1}(:,3,3,:)))));
% ChPSDstd_a = real(squeeze(std(10*log10(PSDreal{1}(:,3,:)))))/sqrt(size(PSDreal{1},1))*1.96; % 95% conf interval = 1.96*SE
% ChPSDstd_m = real(squeeze(std(10*log10(PSDpred{1}(:,1,3,:)))))/sqrt(size(PSDpred{1},1))*1.96;
% ChPSDstd_p = real(squeeze(std(10*log10(PSDpred{1}(:,2,3,:)))))/sqrt(size(PSDpred{1},1))*1.96;
% ChPSDstd_s = real(squeeze(std(10*log10(PSDpred{1}(:,3,3,:)))))/sqrt(size(PSDpred{1},1))*1.96;
% 
% MPSD_a = real(squeeze(mean(10*log10(PSDreal{2}(:,3,:)))));
% MPSD_m = real(squeeze(mean(10*log10(PSDpred{2}(:,1,3,:)))));
% MPSD_p = real(squeeze(mean(10*log10(PSDpred{2}(:,2,3,:)))));
% MPSD_s = real(squeeze(mean(10*log10(PSDpred{2}(:,3,3,:)))));
% MPSDstd_a = real(squeeze(std(10*log10(PSDreal{2}(:,3,:)))))/sqrt(size(PSDreal{2},1))*1.96;
% MPSDstd_m = real(squeeze(std(10*log10(PSDpred{2}(:,1,3,:)))))/sqrt(size(PSDpred{2},1))*1.96;
% MPSDstd_p = real(squeeze(std(10*log10(PSDpred{2}(:,2,3,:)))))/sqrt(size(PSDpred{2},1))*1.96;
% MPSDstd_s = real(squeeze(std(10*log10(PSDpred{2}(:,3,3,:)))))/sqrt(size(PSDpred{2},1))*1.96;

% linear speed
% ChPSD_a = real(squeeze(mean(PSDreal{1}(:,3,:))));
% ChPSD_m = real(squeeze(mean(PSDpred{1}(:,1,3,:))));
% ChPSD_p = real(squeeze(mean(PSDpred{1}(:,2,3,:))));
% ChPSD_s = real(squeeze(mean(PSDpred{1}(:,3,3,:))));
% ChPSDstd_a = real(squeeze(std(PSDreal{1}(:,3,:))))/sqrt(size(PSDreal{1},1))*1.96; % 95% conf interval = 1.96*SE
% ChPSDstd_m = real(squeeze(std(PSDpred{1}(:,1,3,:))))/sqrt(size(PSDpred{1},1))*1.96;
% ChPSDstd_p = real(squeeze(std(PSDpred{1}(:,2,3,:))))/sqrt(size(PSDpred{1},1))*1.96;
% ChPSDstd_s = real(squeeze(std(PSDpred{1}(:,3,3,:))))/sqrt(size(PSDpred{1},1))*1.96;
% 
% MPSD_a = real(squeeze(mean(PSDreal{2}(:,3,:))));
% MPSD_m = real(squeeze(mean(PSDpred{2}(:,1,3,:))));
% MPSD_p = real(squeeze(mean(PSDpred{2}(:,2,3,:))));
% MPSD_s = real(squeeze(mean(PSDpred{2}(:,3,3,:))));
% MPSDstd_a = real(squeeze(std(PSDreal{2}(:,3,:))))/sqrt(size(PSDreal{2},1))*1.96;
% MPSDstd_m = real(squeeze(std(PSDpred{2}(:,1,3,:))))/sqrt(size(PSDpred{2},1))*1.96;
% MPSDstd_p = real(squeeze(std(PSDpred{2}(:,2,3,:))))/sqrt(size(PSDpred{2},1))*1.96;
% MPSDstd_s = real(squeeze(std(PSDpred{2}(:,3,3,:))))/sqrt(size(PSDpred{2},1))*1.96;

% x only
% ChPSD_a = squeeze(mean(10*log10(PSDreal{1}(:,1,:))));
% ChPSD_m = squeeze(mean(10*log10(PSDpred{1}(:,1,1,:))));
% ChPSD_p = squeeze(mean(10*log10(PSDpred{1}(:,2,1,:))));
% ChPSDstd_a = squeeze(std(10*log10(PSDreal{1}(:,1,:))));
% ChPSDstd_m = squeeze(std(10*log10(PSDpred{1}(:,1,1,:))));
% ChPSDstd_p = squeeze(std(10*log10(PSDpred{1}(:,2,1,:))));
% 
% MPSD_a = squeeze(mean(10*log10(PSDreal{2}(:,1,:))));
% MPSD_m = squeeze(mean(10*log10(PSDpred{2}(:,1,1,:))));
% MPSD_p = squeeze(mean(10*log10(PSDpred{2}(:,2,1,:))));
% MPSDstd_a = squeeze(std(10*log10(PSDreal{2}(:,1,:))));
% MPSDstd_m = squeeze(std(10*log10(PSDpred{2}(:,1,1,:))));
% MPSDstd_p = squeeze(std(10*log10(PSDpred{2}(:,2,1,:))));

% y only
% ChPSD_a = squeeze(mean(10*log10(PSDreal{1}(:,2,:))));
% ChPSD_m = squeeze(mean(10*log10(PSDpred{1}(:,1,2,:))));
% ChPSD_p = squeeze(mean(10*log10(PSDpred{1}(:,2,2,:))));
% ChPSDstd_a = squeeze(std(10*log10(PSDreal{1}(:,2,:))));
% ChPSDstd_m = squeeze(std(10*log10(PSDpred{1}(:,1,2,:))));
% ChPSDstd_p = squeeze(std(10*log10(PSDpred{1}(:,2,2,:))));
% 
% MPSD_a = squeeze(mean(10*log10(PSDreal{2}(:,2,:))));
% MPSD_m = squeeze(mean(10*log10(PSDpred{2}(:,1,2,:))));
% MPSD_p = squeeze(mean(10*log10(PSDpred{2}(:,2,2,:))));
% MPSDstd_a = squeeze(std(10*log10(PSDreal{2}(:,2,:))));
% MPSDstd_m = squeeze(std(10*log10(PSDpred{2}(:,1,2,:))));
% MPSDstd_p = squeeze(std(10*log10(PSDpred{2}(:,2,2,:))));

% Chewie x and y movement
% ChPSD_x = squeeze(mean(10*log10(PSDpred{1}(:,1,1,:))));
% ChPSD_y = squeeze(mean(10*log10(PSDpred{1}(:,1,2,:))));
% ChPSDstd_x = squeeze(std(10*log10(PSDpred{1}(:,1,1,:))));
% ChPSDstd_y = squeeze(std(10*log10(PSDpred{1}(:,1,2,:))));
% Chewie x and y posture
% ChPSD_x = squeeze(mean(10*log10(PSDpred{1}(:,2,1,:))));
% ChPSD_y = squeeze(mean(10*log10(PSDpred{1}(:,2,2,:))));
% ChPSDstd_x = squeeze(std(10*log10(PSDpred{1}(:,2,1,:))));
% ChPSDstd_y = squeeze(std(10*log10(PSDpred{1}(:,2,2,:))));
% Chewie x and y actual
% ChPSD_x = squeeze(mean(10*log10(PSDreal{1}(:,1,:))));
% ChPSD_y = squeeze(mean(10*log10(PSDreal{1}(:,2,:))));
% ChPSDstd_x = squeeze(std(10*log10(PSDreal{1}(:,1,:))));
% ChPSDstd_y = squeeze(std(10*log10(PSDreal{1}(:,2,:))));


% figure
% hold on; plot(freq,ChPSD_x,'r',freq,ChPSD_y,'b');
% hold on; shadedplot(freq,(ChPSD_x-ChPSDstd_x)',(ChPSD_x+ChPSDstd_x)',[1.0 0.7 0.7],[1.0 0.7 0.7]);
% hold on; shadedplot(freq,(ChPSD_y-ChPSDstd_y)',(ChPSD_y+ChPSDstd_y)',[0.7 0.7 1.0],[0.7 0.7 1.0]);
% hold on; plot(freq,ChPSD_x,'r',freq,ChPSD_y,'b');
% legend('movement x','movement y')
% % legend('posture x','posture y')
% % legend('actual x','actual y')
% title('Chewie PSD')
% ylabel('power/frequency (dB/Hz)')
% xlabel('frequency (Hz)')
% grid off


figure
subplot(1,2,1)
set(gca,'TickDir','out')
hold on; plot(TFfreq{1,1}(1,:)',ChPSD_a,'k',TFfreq{1,1}(1,:)',ChPSD_m,'r',TFfreq{1,1}(1,:)',ChPSD_p,'b',TFfreq{1,1}(1,:)',ChPSD_s,'g');
hold on; shadedplot(TFfreq{1,1}(1,:)',(ChPSD_a-ChPSDstd_a)',(ChPSD_a+ChPSDstd_a)',[0.7 0.7 0.7],[0.7 0.7 0.7]);
hold on; shadedplot(TFfreq{1,1}(1,:)',(ChPSD_m-ChPSDstd_m)',(ChPSD_m+ChPSDstd_m)',[1.0 0.7 0.7],[1.0 0.7 0.7]);
hold on; shadedplot(TFfreq{1,1}(1,:)',(ChPSD_p-ChPSDstd_p)',(ChPSD_p+ChPSDstd_p)',[0.7 0.7 1.0],[0.7 0.7 1.0]);
hold on; shadedplot(TFfreq{1,1}(1,:)',(ChPSD_s-ChPSDstd_s)',(ChPSD_s+ChPSDstd_s)',[0.7 1.0 0.7],[0.7 1.0 0.7]);
hold on; plot(TFfreq{1,1}(1,:)',ChPSD_a,'k',TFfreq{1,1}(1,:)',ChPSD_m,'r',TFfreq{1,1}(1,:)',ChPSD_p,'b',TFfreq{1,1}(1,:)',ChPSD_s,'g');
legend('actual','movement','posture','standard')
title('Monkey C PSD')
ylabel('power/frequency')
xlabel('frequency (Hz)')
% axis([0 3 0 140])
grid off

subplot(1,2,2)
set(gca,'TickDir','out')
hold on; plot(TFfreq{1,1}(1,:)',MPSD_a,'k',TFfreq{1,1}(1,:)',MPSD_m,'r',TFfreq{1,1}(1,:)',MPSD_p,'b',TFfreq{1,1}(1,:)',MPSD_s,'g');
hold on; shadedplot(TFfreq{1,1}(1,:)',(MPSD_a-MPSDstd_a)',(MPSD_a+MPSDstd_a)',[0.7 0.7 0.7],[0.7 0.7 0.7]);
hold on; shadedplot(TFfreq{1,1}(1,:)',(MPSD_m-MPSDstd_m)',(MPSD_m+MPSDstd_m)',[1.0 0.7 0.7],[1.0 0.7 0.7]);
hold on; shadedplot(TFfreq{1,1}(1,:)',(MPSD_p-MPSDstd_p)',(MPSD_p+MPSDstd_p)',[0.7 0.7 1.0],[0.7 0.7 1.0]);
hold on; shadedplot(TFfreq{1,1}(1,:)',(MPSD_s-MPSDstd_s)',(MPSD_s+MPSDstd_s)',[0.7 1.0 0.7],[0.7 1.0 0.7]);
hold on; plot(TFfreq{1,1}(1,:)',MPSD_a,'k',TFfreq{1,1}(1,:)',MPSD_m,'r',TFfreq{1,1}(1,:)',MPSD_p,'b',TFfreq{1,1}(1,:)',MPSD_s,'g');
legend('actual','movement','posture','standard')
title('Monkey M PSD')
ylabel('power/frequency')
xlabel('frequency (Hz)')
% axis([0 3 0 140])
grid off

% Normalized
figure
subplot(1,2,1)
set(gca,'TickDir','out')
hold on; plot(TFfreq{1,1}(1,:)',ChPSD_a/max(ChPSD_a),'k',TFfreq{1,1}(1,:)',ChPSD_m/max(ChPSD_m),'r',TFfreq{1,1}(1,:)',ChPSD_p/max(ChPSD_p),'b',TFfreq{1,1}(1,:)',ChPSD_s/max(ChPSD_s),'g');
hold on; shadedplot(TFfreq{1,1}(1,:)',((ChPSD_a-ChPSDstd_a)/max(ChPSD_a))',((ChPSD_a+ChPSDstd_a)/max(ChPSD_a))',[0.7 0.7 0.7],[0.7 0.7 0.7]);
hold on; shadedplot(TFfreq{1,1}(1,:)',((ChPSD_m-ChPSDstd_m)/max(ChPSD_m))',((ChPSD_m+ChPSDstd_m)/max(ChPSD_m))',[1.0 0.7 0.7],[1.0 0.7 0.7]);
hold on; shadedplot(TFfreq{1,1}(1,:)',((ChPSD_p-ChPSDstd_p)/max(ChPSD_p))',((ChPSD_p+ChPSDstd_p)/max(ChPSD_p))',[0.7 0.7 1.0],[0.7 0.7 1.0]);
hold on; shadedplot(TFfreq{1,1}(1,:)',((ChPSD_s-ChPSDstd_s)/max(ChPSD_s))',((ChPSD_s+ChPSDstd_s)/max(ChPSD_s))',[0.7 1.0 0.7],[0.7 1.0 0.7]);
hold on; plot(TFfreq{1,1}(1,:)',ChPSD_a/max(ChPSD_a),'k',TFfreq{1,1}(1,:)',ChPSD_m/max(ChPSD_m),'r',TFfreq{1,1}(1,:)',ChPSD_p/max(ChPSD_p),'b',TFfreq{1,1}(1,:)',ChPSD_s/max(ChPSD_s),'g');
legend('actual','movement','posture','standard')
title('Monkey C Normalized PSD')
ylabel('magnitude')
xlabel('frequency (Hz)')
% axis([0 3 0 1.2])
grid off

subplot(1,2,2)
set(gca,'TickDir','out')
hold on; plot(TFfreq{1,1}(1,:)',MPSD_a/max(MPSD_a),'k',TFfreq{1,1}(1,:)',MPSD_m/max(MPSD_m),'r',TFfreq{1,1}(1,:)',MPSD_p/max(MPSD_p),'b',TFfreq{1,1}(1,:)',MPSD_s/max(MPSD_s),'g');
hold on; shadedplot(TFfreq{1,1}(1,:)',((MPSD_a-MPSDstd_a)/max(MPSD_a))',((MPSD_a+MPSDstd_a)/max(MPSD_a))',[0.7 0.7 0.7],[0.7 0.7 0.7]);
hold on; shadedplot(TFfreq{1,1}(1,:)',((MPSD_m-MPSDstd_m)/max(MPSD_m))',((MPSD_m+MPSDstd_m)/max(MPSD_m))',[1.0 0.7 0.7],[1.0 0.7 0.7]);
hold on; shadedplot(TFfreq{1,1}(1,:)',((MPSD_p-MPSDstd_p)/max(MPSD_p))',((MPSD_p+MPSDstd_p)/max(MPSD_p))',[0.7 0.7 1.0],[0.7 0.7 1.0]);
hold on; shadedplot(TFfreq{1,1}(1,:)',((MPSD_s-MPSDstd_s)/max(MPSD_s))',((MPSD_s+MPSDstd_s)/max(MPSD_s))',[0.7 1.0 0.7],[0.7 1.0 0.7]);
hold on; plot(TFfreq{1,1}(1,:)',MPSD_a/max(MPSD_a),'k',TFfreq{1,1}(1,:)',MPSD_m/max(MPSD_m),'r',TFfreq{1,1}(1,:)',MPSD_p/max(MPSD_p),'b',TFfreq{1,1}(1,:)',MPSD_s/max(MPSD_s),'g');
legend('actual','movement','posture','standard')
title('Monkey M Normalized PSD')
ylabel('magnitude')
xlabel('frequency (Hz)')
% axis([0 3 0 1.2])
grid off