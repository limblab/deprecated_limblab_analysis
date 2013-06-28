% convert to power, combine x and y, and calculate mean and std
% ChTF_m = real(squeeze(mean(20*log10([TF{1}(:,1,1,:);TF{1}(:,1,2,:)]))));
% ChTF_p = real(squeeze(mean(20*log10([TF{1}(:,2,1,:);TF{1}(:,2,2,:)]))));
% ChTFstd_m = real(squeeze(std(20*log10([TF{1}(:,1,1,:);TF{1}(:,1,2,:)]))));
% ChTFstd_p = real(squeeze(std(20*log10([TF{1}(:,2,1,:);TF{1}(:,2,2,:)]))));
% 
% MTF_m = real(squeeze(mean(20*log10([TF{2}(:,1,1,:);TF{2}(:,1,2,:)]))));
% MTF_p = real(squeeze(mean(20*log10([TF{2}(:,2,1,:);TF{2}(:,2,2,:)]))));
% MTFstd_m = real(squeeze(std(20*log10([TF{2}(:,1,1,:);TF{2}(:,1,2,:)]))));
% MTFstd_p = real(squeeze(std(20*log10([TF{2}(:,2,1,:);TF{2}(:,2,2,:)]))));

% linear combined velocity
ChTF_m = real(squeeze(mean(([TF{1}(:,1,1,:);TF{1}(:,1,2,:)]))));
ChTF_p = real(squeeze(mean(([TF{1}(:,2,1,:);TF{1}(:,2,2,:)]))));
ChTF_s = real(squeeze(mean(([TF{1}(:,3,1,:);TF{1}(:,3,2,:)]))));
ChTFstd_m = real(squeeze(std(([TF{1}(:,1,1,:);TF{1}(:,1,2,:)]))))/sqrt(size(TF{1},1))*1.96;
ChTFstd_p = real(squeeze(std(([TF{1}(:,2,1,:);TF{1}(:,2,2,:)]))))/sqrt(size(TF{1},1))*1.96;
ChTFstd_s = real(squeeze(std(([TF{1}(:,3,1,:);TF{1}(:,3,2,:)]))))/sqrt(size(TF{1},1))*1.96;

MTF_m = real(squeeze(mean(([TF{2}(:,1,1,:);TF{2}(:,1,2,:)]))));
MTF_p = real(squeeze(mean(([TF{2}(:,2,1,:);TF{2}(:,2,2,:)]))));
MTF_s = real(squeeze(mean(([TF{2}(:,3,1,:);TF{2}(:,3,2,:)]))));
MTFstd_m = real(squeeze(std(([TF{2}(:,1,1,:);TF{2}(:,1,2,:)]))))/sqrt(size(TF{1},1))*1.96;
MTFstd_p = real(squeeze(std(([TF{2}(:,2,1,:);TF{2}(:,2,2,:)]))))/sqrt(size(TF{1},1))*1.96;
MTFstd_s = real(squeeze(std(([TF{2}(:,3,1,:);TF{2}(:,3,2,:)]))))/sqrt(size(TF{1},1))*1.96;

% speed
% ChTF_m = real(squeeze(mean(20*log10(TF{1}(:,1,3,:)))));
% ChTF_p = real(squeeze(mean(20*log10(TF{1}(:,2,3,:)))));
% ChTFstd_m = real(squeeze(std(20*log10(TF{1}(:,1,3,:)))))/sqrt(size(TF{1},1))*1.96; % 95% conf interval = 1.96*SE
% ChTFstd_p = real(squeeze(std(20*log10(TF{1}(:,2,3,:)))))/sqrt(size(TF{1},1))*1.96;
% 
% MTF_m = real(squeeze(mean(20*log10(TF{2}(:,1,3,:)))));
% MTF_p = real(squeeze(mean(20*log10(TF{2}(:,2,3,:)))));
% MTFstd_m = real(squeeze(std(20*log10(TF{2}(:,1,3,:)))))/sqrt(size(TF{2},1))*1.96;
% MTFstd_p = real(squeeze(std(20*log10(TF{2}(:,2,3,:)))))/sqrt(size(TF{2},1))*1.96;

% linear speed
% ChTF_m = real(squeeze(mean(TF{1}(:,1,3,:))));
% ChTF_p = real(squeeze(mean(TF{1}(:,2,3,:))));
% ChTFstd_m = real(squeeze(std(TF{1}(:,1,3,:))))/sqrt(size(TF{1},1))*1.96; % 95% conf interval = 1.96*SE
% ChTFstd_p = real(squeeze(std(TF{1}(:,2,3,:))))/sqrt(size(TF{1},1))*1.96;
% 
% MTF_m = real(squeeze(mean(TF{2}(:,1,3,:))));
% MTF_p = real(squeeze(mean(TF{2}(:,2,3,:))));
% MTFstd_m = real(squeeze(std(TF{2}(:,1,3,:))))/sqrt(size(TF{2},1))*1.96;
% MTFstd_p = real(squeeze(std(TF{2}(:,2,3,:))))/sqrt(size(TF{2},1))*1.96;

% normalized plots
figure
subplot(1,2,1)
set(gca,'TickDir','out')
hold on; plot(TFfreq{1,1}(1,:),ChTF_m/max(ChTF_m),'r',TFfreq{1,1}(1,:),ChTF_p/max(ChTF_p),'b',TFfreq{1,1}(1,:),ChTF_s/max(ChTF_s),'g');
hold on; shadedplot(TFfreq{1,1}(1,:),((ChTF_m-ChTFstd_m)/max(ChTF_m))',((ChTF_m+ChTFstd_m)/max(ChTF_m))',[1 0.7 0.7],[1 0.7 0.7]);
hold on; shadedplot(TFfreq{1,1}(1,:),((ChTF_p-ChTFstd_p)/max(ChTF_p))',((ChTF_p+ChTFstd_p)/max(ChTF_p))',[0.7 0.7 1],[0.7 0.7 1]);
hold on; shadedplot(TFfreq{1,1}(1,:),((ChTF_s-ChTFstd_s)/max(ChTF_s))',((ChTF_s+ChTFstd_s)/max(ChTF_s))',[0.7 1 0.7],[0.7 1 0.7]);
hold on; plot(TFfreq{1,1}(1,:),ChTF_m/max(ChTF_m),'r',TFfreq{1,1}(1,:),ChTF_p/max(ChTF_p),'b',TFfreq{1,1}(1,:),ChTF_s/max(ChTF_s),'g');
% plot(TFfreq{1,1}(1,:),ChTF_m-max(ChTF_m),'r',TFfreq{1,1}(1,:),ChTF_p-max(ChTF_p),'b');
% hold on; shadedplot(TFfreq{1,1}(1,:),((ChTF_m-ChTFstd_m)-max(ChTF_m))',((ChTF_m+ChTFstd_m)-max(ChTF_m))',[1 0.7 0.7],[1 0.7 0.7]);
% hold on; shadedplot(TFfreq{1,1}(1,:),((ChTF_p-ChTFstd_p)-max(ChTF_p))',((ChTF_p+ChTFstd_p)-max(ChTF_p))',[0.7 0.7 1],[0.7 0.7 1]);
% hold on; plot(TFfreq{1,1}(1,:),ChTF_m-max(ChTF_m),'r',TFfreq{1,1}(1,:),ChTF_p-max(ChTF_p),'b');
legend('movement','posture','standard')
title('Monkey C Normalized Transfer Function')
xlabel('frequency (Hz)')
ylabel('normalized magnitude')
axis([0 5 0 1.2])
grid off

subplot(1,2,2)
set(gca,'TickDir','out')
hold on; plot(TFfreq{1,1}(1,:),MTF_m/max(MTF_m),'r',TFfreq{1,1}(1,:),MTF_p/max(MTF_p),'b',TFfreq{1,1}(1,:),MTF_s/max(MTF_s),'g');
hold on; shadedplot(TFfreq{1,1}(1,:),((MTF_m-MTFstd_m)/max(MTF_m))',((MTF_m+MTFstd_m)/max(MTF_m))',[1 0.7 0.7],[1 0.7 0.7]);
hold on; shadedplot(TFfreq{1,1}(1,:),((MTF_p-MTFstd_p)/max(MTF_p))',((MTF_p+MTFstd_p)/max(MTF_p))',[0.7 0.7 1],[0.7 0.7 1]);
hold on; shadedplot(TFfreq{1,1}(1,:),((MTF_s-MTFstd_s)/max(MTF_s))',((MTF_s+MTFstd_s)/max(MTF_s))',[0.7 1 0.7],[0.7 1 0.7]);
hold on; plot(TFfreq{1,1}(1,:),MTF_m/max(MTF_m),'r',TFfreq{1,1}(1,:),MTF_p/max(MTF_p),'b',TFfreq{1,1}(1,:),MTF_s/max(MTF_s),'g');
% plot(TFfreq{1,1}(1,:),MTF_m-max(MTF_m),'r',TFfreq{1,1}(1,:),MTF_p-max(MTF_p),'b');
% hold on; shadedplot(TFfreq{1,1}(1,:)',((MTF_m-MTFstd_m)-max(MTF_m))',((MTF_m+MTFstd_m)-max(MTF_m))',[1 0.7 0.7],[1 0.7 0.7]);
% hold on; shadedplot(TFfreq{1,1}(1,:)',((MTF_p-MTFstd_p)-max(MTF_p))',((MTF_p+MTFstd_p)-max(MTF_p))',[0.7 0.7 1],[0.7 0.7 1]);
% hold on; plot(TFfreq{1,1}(1,:),MTF_m-max(MTF_m),'r',TFfreq{1,1}(1,:),MTF_p-max(MTF_p),'b');
% axis([-1 1 -0.4 1.4])
legend('movement','posture','standard')
title('Monkey M Normalized Transfer Function')
xlabel('frequency (Hz)')
ylabel('normalized magnitude')
axis([0 5 0 1.2])
grid off

% non-normalized plots
figure
subplot(1,2,1)
set(gca,'TickDir','out')
hold on; plot(TFfreq{1,1}(1,:),ChTF_m,'r',TFfreq{1,1}(1,:),ChTF_p,'b',TFfreq{1,1}(1,:),ChTF_s,'g');
hold on; shadedplot(TFfreq{1,1}(1,:)',(ChTF_m-ChTFstd_m)',(ChTF_m+ChTFstd_m)',[1 0.7 0.7],[1 0.7 0.7]);
hold on; shadedplot(TFfreq{1,1}(1,:)',(ChTF_p-ChTFstd_p)',(ChTF_p+ChTFstd_p)',[0.7 0.7 1],[0.7 0.7 1]);
hold on; shadedplot(TFfreq{1,1}(1,:)',(ChTF_s-ChTFstd_s)',(ChTF_s+ChTFstd_s)',[0.7 1 0.7],[0.7 1 0.7]);
hold on; plot(TFfreq{1,1}(1,:),ChTF_m,'r',TFfreq{1,1}(1,:),ChTF_p,'b',TFfreq{1,1}(1,:),ChTF_s,'g');
legend('movement','posture','standard')
title('Monkey C Transfer Function')
xlabel('frequency (Hz)')
ylabel('magnitude')
axis([0 5 0 1.2])
grid off

subplot(1,2,2)
set(gca,'TickDir','out')
hold on; plot(TFfreq{1,1}(1,:),MTF_m,'r',TFfreq{1,1}(1,:),MTF_p,'b',TFfreq{1,1}(1,:),MTF_s,'g');
hold on; shadedplot(TFfreq{1,1}(1,:)',(MTF_m-MTFstd_m)',(MTF_m+MTFstd_m)',[1 0.7 0.7],[1 0.7 0.7]);
hold on; shadedplot(TFfreq{1,1}(1,:)',(MTF_p-MTFstd_p)',(MTF_p+MTFstd_p)',[0.7 0.7 1],[0.7 0.7 1]);
hold on; shadedplot(TFfreq{1,1}(1,:)',(MTF_s-MTFstd_s)',(MTF_s+MTFstd_s)',[0.7 1 0.7],[0.7 1 0.7]);
hold on; plot(TFfreq{1,1}(1,:),MTF_m,'r',TFfreq{1,1}(1,:),MTF_p,'b',TFfreq{1,1}(1,:),MTF_s,'g');
legend('movement','posture','standard')
title('Monkey M Transfer Function')
xlabel('frequency (Hz)')
ylabel('magnitude')
axis([0 5 0 1.2])
grid off
