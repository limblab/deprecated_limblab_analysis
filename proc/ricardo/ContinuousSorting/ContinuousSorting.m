filepath = 'D:\Data\Kramer_10I1';
filename = '\Kramer_02_23_2012_RW_001';
fileExt = '.nev';
% filepath = 'D:\Data\TestData\Raw\';

temp = dir([filepath filename '.mat']);
if isempty(temp)
    bdf = get_cerebus_data([filepath filename fileExt],3);
    save([filepath filename ''],'bdf','-v7.3');
else
    load([filepath filename '.mat'])
end

highpass = 750;
lowpass = 14000;
fs = 30000;
[b,a] = butter(4,[highpass lowpass]/(fs/2));
t = 0:1/fs:(length(bdf.raw.analog.data{1})-1)/30000;
t = bdf.analog.ts;
NFFT = 2^nextpow2(length(t));
f = fs/2*linspace(0,1,NFFT/2+1);
plot_idx = 110001:210000;
f_idx = 1:find(f>10000,1,'first');
f_idx = 1:length(f);

for iNeuron = 1:size(bdf.analog.channel,2)
    neuron = bdf.analog.data{iNeuron};    
    neuron_filt = filtfilt(b,a,double(neuron));
%     neuron_filt = neuron;
    fft_neuron = fft(neuron_filt,NFFT)/length(t);
    
    figure(3)
    subplot(211)
    plot(t(plot_idx),neuron_filt(plot_idx))
    subplot(212)
    plot(f(f_idx),2*abs(fft_neuron(f_idx)))
    title(num2str(iNeuron))
    drawnow
    pause
end

fft_neuron = fft(neuron_filt);