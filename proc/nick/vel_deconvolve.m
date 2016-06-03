% load binnedData and decoder file

posture_decoder.P = posture_decoder.P';
movement_decoder.P = movement_decoder.P';

% %% deconvolution to try to find impulse response
% 
% win_len = 10;
% 
% binnedData.spikeratedata = [zeros(win_len-1,size(binnedData.spikeratedata,2)); binnedData.spikeratedata(win_len:size(binnedData.spikeratedata,1)-(win_len-1),:); zeros(win_len-1,size(binnedData.spikeratedata,2))];
% 
move_pred = predictSignals(movement_decoder,binnedData);
post_pred = predictSignals(posture_decoder,binnedData);
% xvel = binnedData.velocbin(win_len:end-(win_len-1),1);
% yvel = binnedData.velocbin(win_len:end-(win_len-1),2);
% 
% px = post_pred.preddatabin(:,1);
% py = post_pred.preddatabin(:,2);
% mx = move_pred.preddatabin(:,1);
% my = move_pred.preddatabin(:,2);
% 
% [pxq,pxr] = deconv(px,xvel);
% [pyq,pyr] = deconv(py,xvel);
% [mxq,mxr] = deconv(mx,yvel);
% [myq,myr] = deconv(my,yvel);
% 
% figure;
% subplot(1,2,1)
% plot(1:length(pxq),pxq,'r',1:length(mxq),mxq,'b')
% title('x');
% legend('posture', 'movement');
% 
% subplot(1,2,2)
% plot(1:length(pyq),pyq,'r',1:length(myq),myq,'b')
% title('y');
% legend('posture', 'movement');

%% cross correlation

xcfpx = crosscorr(post_pred.preddatabin(:,1),binnedData.velocbin(10:end,1));
xcfmx = crosscorr(move_pred.preddatabin(:,1),binnedData.velocbin(10:end,1));
xcfpy = crosscorr(post_pred.preddatabin(:,2),binnedData.velocbin(10:end,2));
xcfmy = crosscorr(move_pred.preddatabin(:,2),binnedData.velocbin(10:end,2));

figure;
subplot(1,2,1)
plot(-20:20,xcfmx,'b',-20:20,xcfpx,'r')
title('x');
ylabel('cross correlation');
legend('movement','posture');
axis([-20 20 -0.2 1.2])

subplot(1,2,2)
plot(-20:20,xcfmy,'b',-20:20,xcfpy,'r')
title('y');
ylabel('cross correlation');
legend('movement','posture');
axis([-20 20 -0.2 1.2])

%% transfer function

[mTFx,FmTFx] = tfestimate(binnedData.velocbin(10:end,1),move_pred.preddatabin(:,1),128,[],[],20);
[pTFx,FpTFx] = tfestimate(binnedData.velocbin(10:end,1),post_pred.preddatabin(:,1),128,[],[],20);
[mTFy,FmTFy] = tfestimate(binnedData.velocbin(10:end,2),move_pred.preddatabin(:,2),128,[],[],20);
[pTFy,FpTFy] = tfestimate(binnedData.velocbin(10:end,2),post_pred.preddatabin(:,2),128,[],[],20);

figure;
subplot(1,2,1)
plot(FmTFx,20*log10(abs(mTFx)),'b',FpTFx,20*log10(abs(pTFx)),'r')
grid on
title('tranfer function for x')
xlabel('Frequency (Hz)')
ylabel('Magnitude (dB)')
legend('movement','posture')

subplot(1,2,2)
plot(FmTFy,20*log10(abs(mTFy)),'b',FpTFy,20*log10(abs(pTFy)),'r')
grid on
title('tranfer function for y')
xlabel('Frequency (Hz)')
ylabel('Magnitude (dB)')
legend('movement','posture')

% title('transfer function for movement x')
% subplot(1,2,2)
% tfestimate(binnedData.velocbin(10:end,1),post_pred.preddatabin(:,1),128,[],[],20);
% title('transfer function for posture x')
% 
% figure;
% subplot(1,2,1)
% tfestimate(binnedData.velocbin(10:end,2),move_pred.preddatabin(:,2),128,[],[],20);
% title('transfer function for movement y')
% subplot(1,2,2)
% tfestimate(binnedData.velocbin(10:end,2),post_pred.preddatabin(:,2),128,[],[],20);
% title('transfer function for posture y')


%% frequency response

pfftx = fft(post_pred.preddatabin(:,1));
mfftx = fft(move_pred.preddatabin(:,1));
pffty = fft(post_pred.preddatabin(:,2));
mffty = fft(move_pred.preddatabin(:,2));

freq = (1:length(pfftx))*20/length(pfftx);

figure;
subplot(1,2,1)
plot(freq,abs(mfftx),'b',freq,abs(pfftx),'r')
title('x');
ylabel('fft');
legend('movement','posture');

subplot(1,2,2)
plot(freq,abs(mffty),'b',freq,abs(pffty),'r')
title('y');
ylabel('fft');
legend('movement','posture');

%% power spectral density

segments = 50;
h = spectrum.welch('Hamming', floor(length(post_pred.preddatabin(:,1))/segments));
ppsdx = psd(h,post_pred.preddatabin(:,1),'Fs',20);
mpsdx = psd(h,move_pred.preddatabin(:,1),'Fs',20);
ppsdy = psd(h,post_pred.preddatabin(:,2),'Fs',20);
mpsdy = psd(h,move_pred.preddatabin(:,2),'Fs',20);

figure
subplot(1,2,1)
plot(mpsdx.Frequencies,10*log10(mpsdx.Data),'b',ppsdx.Frequencies,10*log10(ppsdx.Data),'r')
grid on
title('PSD for x')
xlabel('Frequency (Hz)')
ylabel('Power/frequency (dB/Hz)')
legend('movement','posture')

subplot(1,2,2)
plot(mpsdy.Frequencies,10*log10(mpsdy.Data),'b',ppsdy.Frequencies,10*log10(ppsdy.Data),'r')
grid on
title('PSD for y')
xlabel('Frequency (Hz)')
ylabel('Power/frequency (dB/Hz)')
legend('movement','posture')

%% impulse response
pdatax = iddata(post_pred.preddatabin(:,1),double(binnedData.velocbin(10:end,1)),0.05);
mdatax = iddata(move_pred.preddatabin(:,1),double(binnedData.velocbin(10:end,1)),0.05);
pdatay = iddata(post_pred.preddatabin(:,2),double(binnedData.velocbin(10:end,2)),0.05);
mdatay = iddata(move_pred.preddatabin(:,2),double(binnedData.velocbin(10:end,2)),0.05);

figure;
% subplot(1,2,1)
impulse(mdatax,'b',pdatax,'r',1)
title('x');
ylabel('impulse response');
legend('movement','posture');

figure;
% subplot(1,2,2)
impulse(mdatay,'b',pdatay,'r',1)
title('y');
ylabel('impulse response');
legend('movement','posture');
