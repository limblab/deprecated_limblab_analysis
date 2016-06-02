% combine x and y
ChC_m = squeeze(mean([C{1}(:,1,1,:);C{1}(:,1,2,:)]));
ChC_p = squeeze(mean([C{1}(:,2,1,:);C{1}(:,2,2,:)]));
ChC_s = squeeze(mean([C{1}(:,3,1,:);C{1}(:,3,2,:)]));
ChCstd_m = squeeze(std([C{1}(:,1,1,:);C{1}(:,1,2,:)]))/sqrt(size(C{1},1))*1.96;
ChCstd_p = squeeze(std([C{1}(:,2,1,:);C{1}(:,2,2,:)]))/sqrt(size(C{1},1))*1.96;
ChCstd_s = squeeze(std([C{1}(:,3,1,:);C{1}(:,3,2,:)]))/sqrt(size(C{1},1))*1.96;

MC_m = squeeze(mean([C{2}(:,1,1,:);C{2}(:,1,2,:)]));
MC_p = squeeze(mean([C{2}(:,2,1,:);C{2}(:,2,2,:)]));
MC_s = squeeze(mean([C{2}(:,3,1,:);C{2}(:,3,2,:)]));
MCstd_m = squeeze(std([C{2}(:,1,1,:);C{2}(:,1,2,:)]))/sqrt(size(C{2},1))*1.96;
MCstd_p = squeeze(std([C{2}(:,2,1,:);C{2}(:,2,2,:)]))/sqrt(size(C{2},1))*1.96;
MCstd_s = squeeze(std([C{2}(:,3,1,:);C{2}(:,3,2,:)]))/sqrt(size(C{2},1))*1.96;

% speed
% ChC_m = squeeze(mean(C{1}(:,1,3,:)));
% ChC_p = squeeze(mean(C{1}(:,2,3,:)));
% ChCstd_m = squeeze(std(C{1}(:,1,3,:)))/sqrt(size(C{1},1))*1.96;
% ChCstd_p = squeeze(std(C{1}(:,2,3,:)))/sqrt(size(C{1},1))*1.96;
% 
% MC_m = squeeze(mean(C{2}(:,1,3,:)));
% MC_p = squeeze(mean(C{2}(:,2,3,:)));
% MCstd_m = squeeze(std(C{2}(:,1,3,:)))/sqrt(size(C{2},1))*1.96;
% MCstd_p = squeeze(std(C{2}(:,2,3,:)))/sqrt(size(C{2},1))*1.96;

% x only
% ChC_m = squeeze(mean(C{1}(:,1,1,:)));
% ChC_p = squeeze(mean(C{1}(:,2,1,:)));
% ChCstd_m = squeeze(std(C{1}(:,1,1,:)));
% ChCstd_p = squeeze(std(C{1}(:,2,1,:)));
% 
% MC_m = squeeze(mean(C{2}(:,1,1,:)));
% MC_p = squeeze(mean(C{2}(:,2,1,:)));
% MCstd_m = squeeze(std(C{2}(:,1,1,:)));
% MCstd_p = squeeze(std(C{2}(:,2,1,:)));

% y only
% ChC_m = squeeze(mean(C{1}(:,1,2,:)));
% ChC_p = squeeze(mean(C{1}(:,2,2,:)));
% ChCstd_m = squeeze(std(C{1}(:,1,2,:)));
% ChCstd_p = squeeze(std(C{1}(:,2,2,:)));
% 
% MC_m = squeeze(mean(C{2}(:,1,2,:)));
% MC_p = squeeze(mean(C{2}(:,2,2,:)));
% MCstd_m = squeeze(std(C{2}(:,1,2,:)));
% MCstd_p = squeeze(std(C{2}(:,2,2,:)));

figure

subplot(1,2,1)
set(gca,'TickDir','out')
hold on; plot(TFfreq{1,1}(1,:)',ChC_m,'r',TFfreq{1,1}(1,:)',ChC_p,'b',TFfreq{1,1}(1,:)',ChC_s,'g');
hold on; shadedplot(TFfreq{1,1}(1,:)',(ChC_m-ChCstd_m)',(ChC_m+ChCstd_m)',[1.0 0.7 0.7],[1.0 0.7 0.7]);
hold on; shadedplot(TFfreq{1,1}(1,:)',(ChC_p-ChCstd_p)',(ChC_p+ChCstd_p)',[0.7 0.7 1.0],[0.7 0.7 1.0]);
hold on; shadedplot(TFfreq{1,1}(1,:)',(ChC_s-ChCstd_s)',(ChC_s+ChCstd_s)',[0.7 1.0 0.7],[0.7 1.0 0.7]);
hold on; plot(TFfreq{1,1}(1,:)',ChC_m,'r',TFfreq{1,1}(1,:)',ChC_p,'b',TFfreq{1,1}(1,:)',ChC_s,'g');
legend('movement','posture','standard')
title('Monkey C Coherence')
ylabel('magnitude')
xlabel('frequency (Hz)')
axis([0 5 0 1])
grid off

subplot(1,2,2)
set(gca,'TickDir','out')
hold on; plot(TFfreq{1,1}(1,:)',MC_m,'r',TFfreq{1,1}(1,:)',MC_p,'b',TFfreq{1,1}(1,:)',MC_s,'g');
hold on; shadedplot(TFfreq{1,1}(1,:)',(MC_m-MCstd_m)',(MC_m+MCstd_m)',[1.0 0.7 0.7],[1.0 0.7 0.7]);
hold on; shadedplot(TFfreq{1,1}(1,:)',(MC_p-MCstd_p)',(MC_p+MCstd_p)',[0.7 0.7 1.0],[0.7 0.7 1.0]);
hold on; shadedplot(TFfreq{1,1}(1,:)',(MC_s-MCstd_s)',(MC_s+MCstd_s)',[0.7 1.0 0.7],[0.7 1.0 0.7]);
hold on; plot(TFfreq{1,1}(1,:)',MC_m,'r',TFfreq{1,1}(1,:)',MC_p,'b',TFfreq{1,1}(1,:)',MC_s,'g');
legend('movement','posture','standard')
title('Monkey M Coherence')
ylabel('magnitude')
xlabel('frequency (Hz)')
axis([0 5 0 1])
grid off