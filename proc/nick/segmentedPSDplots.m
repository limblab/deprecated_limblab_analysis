% set paths to include necessary functions
if (exist('BMI_analysis','dir') ~= 7)
    load_paths;
end

monkey{1} = 'Chewie'; monkey{2} = 'Mini';
datasets(1) = 9; datasets(2) = 10; % 9 files for Chewie and 10 for Mini
window = 128; % number of samples for spectral analysis

PSDmove = cell(1,length(monkey));
PSDpost = cell(1,length(monkey));

for m = 1:length(monkey)
    
    for dataset = 1:datasets(m)
        
        % load binnedData and decoder files
        load(['C:\Users\Nicholas Sachs\Desktop\SD_Datasets\' monkey{m} '_binned_' num2str(dataset) '.mat']);
        load(['C:\Users\Nicholas Sachs\Desktop\SD_Datasets\' monkey{m} '_decoder_' num2str(dataset) '.mat']);
        
        % calculate sampling frequency
        Fs = round(1/(binnedData.timeframe(2)-binnedData.timeframe(1)));

        count = 1;
        movebins = zeros(size(binnedData.timeframe));
        movetimes = binnedData.words(binnedData.words(:,2) == 49,1);
        posttimes = binnedData.words([0; binnedData.words(1:end-1,2)] == 49,1);
        
        for x = 1:length(binnedData.timeframe)
            if count < length(movetimes)
                if binnedData.timeframe(x) > movetimes(count) % + 0.1
                    movebins(x) = 1;
                end
                if binnedData.timeframe(x) > posttimes(count) + 0.25
                    count = count + 1;
                end
            end
        end
        
        hmove = spectrum.welch('Hamming',floor(length(movebins == 1)/window));
        hpost = spectrum.welch('Hamming',floor(length(movebins == 0)/window));
        for dim = 1:2

            PSDtemp = psd(hmove,binnedData.velocbin(movebins == 1,dim),'Fs',Fs);
            PSDmove{m}(dataset,dim,:) = PSDtemp.data; 
            PSDtemp = psd(hmove,binnedData.velocbin(movebins == 0,dim),'Fs',Fs);
            PSDpost{m}(dataset,dim,:) = PSDtemp.data;
            
        end
    end
end

Freq = PSDtemp.frequencies;

ChPSD_m = squeeze(mean(([PSDmove{1}(:,1,:);PSDmove{1}(:,2,:)])));
ChPSD_p = squeeze(mean(([PSDpost{1}(:,1,:);PSDpost{1}(:,2,:)])));

MPSD_m = squeeze(mean(([PSDmove{2}(:,1,:);PSDmove{2}(:,2,:)])));
MPSD_p = squeeze(mean(([PSDpost{2}(:,1,:);PSDpost{2}(:,2,:)])));

figure
subplot(1,2,1)
set(gca,'TickDir','out')
hold on; plot(Freq,ChPSD_m,'r',Freq,ChPSD_p,'b');
legend('movement','posture')
title('Monkey C PSD of Actual Velocities')
ylabel('power/frequency')
xlabel('frequency (Hz)')
axis([0 3 0 180])
grid off

subplot(1,2,2)
set(gca,'TickDir','out')
hold on; plot(Freq,MPSD_m,'r',Freq,MPSD_p,'b');
legend('movement','posture')
title('Monkey M PSD of Actual Velocities')
ylabel('power/frequency')
xlabel('frequency (Hz)')
axis([0 3 0 180])
grid off

%Normalized
figure
subplot(1,2,1)
set(gca,'TickDir','out')
hold on; plot(Freq,ChPSD_m/max(ChPSD_m),'r',Freq,ChPSD_p/max(ChPSD_p),'b');
legend('movement','posture')
title('Monkey C PSD of Actual Velocities')
ylabel('normalized power')
xlabel('frequency (Hz)')
axis([0 3 0 1.1])
grid off

subplot(1,2,2)
set(gca,'TickDir','out')
hold on; plot(Freq,MPSD_m/max(MPSD_m),'r',Freq,MPSD_p/max(MPSD_p),'b');
legend('movement','posture')
title('Monkey M PSD of Actual Velocities')
ylabel('normalized power')
xlabel('frequency (Hz)')
axis([0 3 0 1.1])
grid off
