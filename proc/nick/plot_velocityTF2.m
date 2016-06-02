logTFx_m = 20*log10(abs(TFx_m));
logTFy_m = 20*log10(abs(TFy_m));
logTFx_p = 20*log10(abs(TFx_p));
logTFy_p = 20*log10(abs(TFy_p));

% normalized plots
figure; plot(TFfreq,mean(logTFy_m)-max(mean(logTFy_m)),'r',TFfreq,mean(logTFy_p)-max(mean(logTFy_p)),'b');
hold on; shadedplot(TFfreq,(mean(logTFy_m)-std(logTFy_m))-max(mean(logTFy_m)),(mean(logTFy_m)+std(logTFy_m))-max(mean(logTFy_m)),[1 0.7 0.7],[1 0.7 0.7]);
hold on; shadedplot(TFfreq,(mean(logTFy_p)-std(logTFy_p))-max(mean(logTFy_p)),(mean(logTFy_p)+std(logTFy_p))-max(mean(logTFy_p)),[0.7 0.7 1],[0.7 0.7 1]);
hold on; plot(TFfreq,mean(logTFy_m)-max(mean(logTFy_m)),'r',TFfreq,mean(logTFy_p)-max(mean(logTFy_p)),'b');
legend('movement','posture')
title('Mini Normalized logTFy')
xlabel('frequency (Hz)')
ylabel('normalized magnitude')
grid off
figure; plot(TFfreq,mean(logTFx_m)-max(mean(logTFx_m)),'r',TFfreq,mean(logTFx_p)-max(mean(logTFx_p)),'b');
hold on; shadedplot(TFfreq,(mean(logTFx_m)-std(logTFx_m))-max(mean(logTFx_m)),(mean(logTFx_m)+std(logTFx_m))-max(mean(logTFx_m)),[1 0.7 0.7],[1 0.7 0.7]);
hold on; shadedplot(TFfreq,(mean(logTFx_p)-std(logTFx_p))-max(mean(logTFx_p)),(mean(logTFx_p)+std(logTFx_p))-max(mean(logTFx_p)),[0.7 0.7 1],[0.7 0.7 1]);
hold on; plot(TFfreq,mean(logTFx_m)-max(mean(logTFx_m)),'r',TFfreq,mean(logTFx_p)-max(mean(logTFx_p)),'b');
% axis([-1 1 -0.4 1.4])
legend('movement','posture')
title('Mini Normalized logTFx')
xlabel('frequency (Hz)')
ylabel('normalized magnitude')
grid off

% non-normalized plots
figure; plot(TFfreq,mean(logTFx_m),'r',TFfreq,mean(logTFx_p),'b');
hold on; shadedplot(TFfreq,mean(logTFx_m)-std(logTFx_m),mean(logTFx_m)+std(logTFx_m),[1 0.7 0.7],[1 0.7 0.7]);
hold on; shadedplot(TFfreq,mean(logTFx_p)-std(logTFx_p),mean(logTFx_p)+std(logTFx_p),[0.7 0.7 1],[0.7 0.7 1]);
hold on; plot(TFfreq,mean(logTFx_m),'r',TFfreq,mean(logTFx_p),'b');
legend('movement','posture')
title('Mini TFx')
xlabel('frequency (Hz)')
ylabel('magnitude (dB)')
grid off
figure; plot(TFfreq,mean(logTFy_m),'r',TFfreq,mean(logTFy_p),'b');
hold on; shadedplot(TFfreq,mean(logTFy_m)-std(logTFy_m),mean(logTFy_m)+std(logTFy_m),[1 0.7 0.7],[1 0.7 0.7]);
hold on; shadedplot(TFfreq,mean(logTFy_p)-std(logTFy_p),mean(logTFy_p)+std(logTFy_p),[0.7 0.7 1],[0.7 0.7 1]);
hold on; plot(TFfreq,mean(logTFy_m),'r',TFfreq,mean(logTFy_p),'b');
legend('movement','posture')
title('Mini TFy')
xlabel('frequency (Hz)')
ylabel('magnitude (dB)')
grid off