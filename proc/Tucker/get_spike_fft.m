%tests the spectral plot of a spike assumes there is a variable i that
%represents the desired spike index

% clear all
% close all
% %script to test out npmk load
% 
% foldername='E:\processing\';
% filename='Kramer_BC_04032013_tucker_no_stim_001-01.nev';
% 
% NEV = openNEV(strcat(foldername,filename),'read','report','nosave','nomat','uV');
% 
% test_fft=fft(double(NEV.Data.Spikes.Waveform)');

test_waveform=NEV.Data.Spikes.Waveform(:,NEV.Data.Spikes.Electrode(:)==42);
test_fft=fft(double(test_waveform));
figure;


for i=1: length(test_waveform(1,:))
i
    subplot(2,1,1); plot(test_waveform(:,i));
    title('spike');
    subplot(2,1,2); semilogy(abs(test_fft(1:floor(length(test_fft(:,i))/2),i).^2));
    title('fft')
    pause
end



