function filt = filter_lfp(dat,t,noise_samp)

Fs = round(1/mode(diff(t)));

% dat = mean(lfp_temp(idx,:),1);
noise_dat = dat(:,noise_samp);

[~, nsamples] = size(dat);
[~, nsamples_noise] = size(noise_dat);
Fl = 60;

meandat = mean(noise_dat,2);
% demean the data
noise_dat = noise_dat - repmat(meandat,1,nsamples_noise);

time_noise = (0:nsamples_noise-1)/Fs;
time = (0:nsamples-1)/Fs;
tmp  = exp(1i*2*pi*Fl*time_noise);                   % complex sin and cos
% ampl = 2*dat*tmp'/Nsamples;                  % estimated amplitude of complex sin and cos
ampl = 2*noise_dat/tmp;                % estimated amplitude of complex sin and cos on integer number of cycles
tmp = exp(1i*2*pi*Fl*time);
est  = ampl*tmp;                               % estimated signal at this frequency
filt = dat - est;                              % subtract estimated signal
filt = real(filt);
% filt = filt + meandat;
% figure; plot(time,filt,time,dat)