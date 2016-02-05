function [Pxx,F] = plot_psd(A,Fs)

nfft = 2^nextpow2(size(A,1));
% Pxx = abs(fft(x,nfft)).^2/length(x)/Fs;

% Create a single-sided spectrum
[Pxx,F] = periodogram(A,[],nfft,Fs);

plot(F,Pxx);
pretty_fig(gca);