target_folder = 'D:\Jaco_8I1\Jaco_2016-02-16_antenna\'
params.file_prefix = 'Jaco_2016-02-16_antenna_001'
NEVNSx = cerebus2NEVNSx(target_folder,params.file_prefix);

t = 1/30000:1/30000:length(NEVNSx.NS5.Data)/30000;

figure; plot(t,NEVNSx.NS5.Data(1,:)); hold on; plot(t,NEVNSx.NS5.Data(45,:))
title('Raw data from two channels'); xlabel('t (s)'); ylabel('Amplitude (au)')

Fs = 30000;
L = length(NEVNSx.NS5.Data); 
Y = fft(double(NEVNSx.NS5.Data(1,:)),NFFT)/L; 
NFFT = 2^nextpow2(L); 
f = Fs/2*linspace(0,1,NFFT/2+1);
figure; 
plot(f,2*abs(Y(1:NFFT/2+1)))
title('Amplitude of FFT of neural data')
xlabel('Frequency (Hz)')
ylabel('|Y(f)|')

all_electrodes = double(NEVNSx.NS5.Data);
all_electrodes_mean = mean(all_electrodes);
figure; 
plot(all_electrodes(1,:)-all_electrodes_mean); 
hold on; 
plot(all_electrodes(1,:))

Y_filt = fft(all_electrodes(1,:)-all_electrodes_mean);  
figure; 
plot(f,2*abs(Y(1:NFFT/2+1)))
hold on
plot(f+20,2*abs(Y_filt(1:NFFT/2+1)))

title('Amplitude of FFT of neural data')
xlabel('Frequency (Hz)')
ylabel('|Y(f)|')

sim_noise = 3*sin(t*2*pi*60)+1*rand(size(t))-.5;
% sim_noise = sin(t*2*pi*60);
rect_sim_noise = abs(sim_noise);
Y_sim_noise = fft(rect_sim_noise,NFFT)/L;  
figure; 
plot(f,2*abs(Y_sim_noise(1:NFFT/2+1)))
xlim([0 250])

title('Amplitude of FFT of simulated noise')
xlabel('Frequency (Hz)')
ylabel('|Y(f)|')