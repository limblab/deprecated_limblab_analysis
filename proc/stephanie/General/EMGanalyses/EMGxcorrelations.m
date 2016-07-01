function EMGxcorrelations(out_struct)

figure
n = length(out_struct.emg.data(1,2:end));
counter = 1;
h_subplot = [];
for i = 2:length(out_struct.emg.data(1,:))
    maxVal = 0;
    for j = 2:length(out_struct.emg.data(1,:))        
        h_subplot(end+1) = subplot(n,n,counter);
        [EMGcor lags] = xcorr(out_struct.emg.data(:,i),out_struct.emg.data(:,j));
        maxVal = max(max(abs(EMGcor)),maxVal);
        if j<i
%             plot(lags, EMGcor,'k')
        else
            plot(lags, EMGcor,'b')
        end
        
        if i == 2
            title(out_struct.emg.emgnames(1,j-1))
        end
        if j == 2
            ylabel(out_struct.emg.emgnames(1,i-1))
        end        
        counter = counter+1;        
    end
end
title('Cross-Correlation')
set(h_subplot,'YLim',[-maxVal,maxVal])
set(h_subplot,'XLim',[-20 20])



figure
n = length(out_struct.emg.data(1,2:end));
counter = 1;
h_subplot = [];
for i = 2:length(out_struct.emg.data(1,:))
    maxVal = 0;
    for j = 2:length(out_struct.emg.data(1,:))        
        h_subplot(end+1) = subplot(n,n,counter);
        [EMGcoh freq] = mscohere(out_struct.emg.data(:,i),out_struct.emg.data(:,j),2000,0,4000,2000);
        if j<i
        else
            plot(freq, EMGcoh,'b')
        end
        
        if i == 2
            title(out_struct.emg.emgnames(1,j-1))
        end
        if j == 2
            ylabel(out_struct.emg.emgnames(1,i-1))
        end        
        counter = counter+1;        
    end
end
title('Coherence')
set(h_subplot,'YLim',[0,1])
set(h_subplot,'XLim',[0,50])








end
