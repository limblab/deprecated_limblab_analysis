lags = -1:0.05:1;

% normalized plots
figure; plot(lags,mean(FIRy_m)/max(mean(FIRy_m)),'r',lags,mean(FIRy_p)/max(mean(FIRy_p)),'b');
hold on; shadedplot(lags,(mean(FIRy_m)-std(FIRy_m))/max(mean(FIRy_m)),(mean(FIRy_m)+std(FIRy_m))/max(mean(FIRy_m)),[1 0.7 0.7],[1 0.7 0.7]);
hold on; shadedplot(lags,(mean(FIRy_p)-std(FIRy_p))/max(mean(FIRy_p)),(mean(FIRy_p)+std(FIRy_p))/max(mean(FIRy_p)),[0.7 0.7 1],[0.7 0.7 1]);
hold on; plot(lags,mean(FIRy_m)/max(mean(FIRy_m)),'r',lags,mean(FIRy_p)/max(mean(FIRy_p)),'b');
legend('movement','posture')
title('Chewie Normalized FIRy')
xlabel('lag (s)')
ylabel('normalized gain')
grid off
figure; plot(lags,mean(FIRx_m)/max(mean(FIRx_m)),'r',lags,mean(FIRx_p)/max(mean(FIRx_p)),'b');
hold on; shadedplot(lags,(mean(FIRx_m)-std(FIRx_m))/max(mean(FIRx_m)),(mean(FIRx_m)+std(FIRx_m))/max(mean(FIRx_m)),[1 0.7 0.7],[1 0.7 0.7]);
hold on; shadedplot(lags,(mean(FIRx_p)-std(FIRx_p))/max(mean(FIRx_p)),(mean(FIRx_p)+std(FIRx_p))/max(mean(FIRx_p)),[0.7 0.7 1],[0.7 0.7 1]);
hold on; plot(lags,mean(FIRx_m)/max(mean(FIRx_m)),'r',lags,mean(FIRx_p)/max(mean(FIRx_p)),'b');
axis([-1 1 -0.4 1.4])
legend('movement','posture')
title('Chewie Normalized FIRx')
xlabel('lag (s)')
ylabel('normalized gain')
grid off

% non-normalized plots
figure; plot(lags,mean(FIRx_m),'r',lags,mean(FIRx_p),'b');
hold on; shadedplot(lags,mean(FIRx_m)-std(FIRx_m),mean(FIRx_m)+std(FIRx_m),[1 0.7 0.7],[1 0.7 0.7]);
hold on; shadedplot(lags,mean(FIRx_p)-std(FIRx_p),mean(FIRx_p)+std(FIRx_p),[0.7 0.7 1],[0.7 0.7 1]);
hold on; plot(lags,mean(FIRx_m),'r',lags,mean(FIRx_p),'b');
legend('movement','posture')
title('Chewie FIRx')
xlabel('lag (s)')
ylabel('gain')
grid off
figure; plot(lags,mean(FIRy_m),'r',lags,mean(FIRy_p),'b');
hold on; shadedplot(lags,mean(FIRy_m)-std(FIRy_m),mean(FIRy_m)+std(FIRy_m),[1 0.7 0.7],[1 0.7 0.7]);
hold on; shadedplot(lags,mean(FIRy_p)-std(FIRy_p),mean(FIRy_p)+std(FIRy_p),[0.7 0.7 1],[0.7 0.7 1]);
hold on; plot(lags,mean(FIRy_m),'r',lags,mean(FIRy_p),'b');
legend('movement','posture')
title('Chewie FIRy')
xlabel('lag (s)')
ylabel('gain')
grid off