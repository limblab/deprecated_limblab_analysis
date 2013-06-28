logTFx_m = 20*log10(abs(TFx_m));
logTFy_m = 20*log10(abs(TFy_m));
logTFx_p = 20*log10(abs(TFx_p));
logTFy_p = 20*log10(abs(TFy_p));

% normalized plots
figure; plot(TFfreq,mean(TFy_m)/max(mean(TFy_m)),'r',TFfreq,mean(TFy_p)/max(mean(TFy_p)),'b');
hold on; shadedplot(TFfreq,(mean(TFy_m)-std(TFy_m))/max(mean(TFy_m)),(mean(TFy_m)+std(TFy_m))/max(mean(TFy_m)),[1 0.7 0.7],[1 0.7 0.7]);
hold on; shadedplot(TFfreq,(mean(TFy_p)-std(TFy_p))/max(mean(TFy_p)),(mean(TFy_p)+std(TFy_p))/max(mean(TFy_p)),[0.7 0.7 1],[0.7 0.7 1]);
hold on; plot(TFfreq,mean(TFy_m)/max(mean(TFy_m)),'r',TFfreq,mean(TFy_p)/max(mean(TFy_p)),'b');
legend('movement','posture')
title('Chewie Normalized TFy')
xlabel('frequency (Hz)')
ylabel('normalized magnitude')
grid off
figure; plot(TFfreq,mean(TFx_m)/max(mean(TFx_m)),'r',TFfreq,mean(TFx_p)/max(mean(TFx_p)),'b');
hold on; shadedplot(TFfreq,(mean(TFx_m)-std(TFx_m))/max(mean(TFx_m)),(mean(TFx_m)+std(TFx_m))/max(mean(TFx_m)),[1 0.7 0.7],[1 0.7 0.7]);
hold on; shadedplot(TFfreq,(mean(TFx_p)-std(TFx_p))/max(mean(TFx_p)),(mean(TFx_p)+std(TFx_p))/max(mean(TFx_p)),[0.7 0.7 1],[0.7 0.7 1]);
hold on; plot(TFfreq,mean(TFx_m)/max(mean(TFx_m)),'r',TFfreq,mean(TFx_p)/max(mean(TFx_p)),'b');
% axis([-1 1 -0.4 1.4])
legend('movement','posture')
title('Chewie Normalized TFx')
xlabel('frequency (Hz)')
ylabel('normalized magnitude')
grid off

% non-normalized plots
figure; plot(TFfreq,mean(TFx_m),'r',TFfreq,mean(TFx_p),'b');
hold on; shadedplot(TFfreq,mean(TFx_m)-std(TFx_m),mean(TFx_m)+std(TFx_m),[1 0.7 0.7],[1 0.7 0.7]);
hold on; shadedplot(TFfreq,mean(TFx_p)-std(TFx_p),mean(TFx_p)+std(TFx_p),[0.7 0.7 1],[0.7 0.7 1]);
hold on; plot(TFfreq,mean(TFx_m),'r',TFfreq,mean(TFx_p),'b');
legend('movement','posture')
title('Chewie TFx')
xlabel('frequency (Hz)')
ylabel('magnitude (dB)')
grid off
figure; plot(TFfreq,mean(TFy_m),'r',TFfreq,mean(TFy_p),'b');
hold on; shadedplot(TFfreq,mean(TFy_m)-std(TFy_m),mean(TFy_m)+std(TFy_m),[1 0.7 0.7],[1 0.7 0.7]);
hold on; shadedplot(TFfreq,mean(TFy_p)-std(TFy_p),mean(TFy_p)+std(TFy_p),[0.7 0.7 1],[0.7 0.7 1]);
hold on; plot(TFfreq,mean(TFy_m),'r',TFfreq,mean(TFy_p),'b');
legend('movement','posture')
title('Chewie TFy')
xlabel('frequency (Hz)')
ylabel('magnitude (dB)')
grid off