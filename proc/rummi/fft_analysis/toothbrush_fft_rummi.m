%fft review
close all
%load force_t and force_mag
time_start = 40001; %1;
time_end = 40601; %length(force_mag);
data_length = length(force_mag(time_start:time_end)); %complex double to double

%3 = 12901:13501, 5 = 17201:17801, 8 = 23201:24801, 12(push) = 36201:37201,
%13(push) = 40001:40601


%%
figure %of recording
plot(force_t(time_start:time_end),force_mag(time_start:time_end))
title('Toothbrush Vibration Force Measurement')
xlabel('time')
ylabel('force')

%%
Y = fft(force_mag(time_start:time_end)');

P2 = abs(Y/data_length);
P1 = P2(1:data_length/2+1);
P1(2:end-1) = 2*P1(2:end-1);

f = 1000*(0:(data_length/2))/data_length;

figure(2)
plot(f(15:end),P1(15:end))
title('Single-Sided Amplitude Spectrum of Force - Section 13')
xlabel('frequency (Hz)')
ylabel('|P1(f)|')

