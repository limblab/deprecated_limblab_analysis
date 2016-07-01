%
%
% Function that plots the FFT of a given signal.
%
%   function Y = plot_fft(signal, fs)
%
% Where SIGNAL is the signal of which we want to plot the Amplitude
% Spectrum and FS is its sampling frequency. Y is the Fast Foutier
% Transform of the signal.
%
%
%   Juan Gallego 14-03-09
%


function Y = plot_fft(signal, fs)


L = length(signal);             % Length of signal


NFFT = 2^nextpow2(L);           % Next power of 2 from length of signal
Y = fft(signal,NFFT)/L;
f = fs/2*linspace(0,1,NFFT/2);

% Plot single-sided amplitude spectrum.
loglog(f,2*abs(Y(1:NFFT/2)),'k');
title('Single-Sided Amplitude Spectrum')
xlabel('frequency (Hz)')
ylabel('|Y(f)|')
auto_axis = axis;
axis([0 1000 auto_axis(3) auto_axis(4)]);

