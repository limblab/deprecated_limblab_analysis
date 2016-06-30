function emg = filterEMG(emg)

EMG_hp = 50; % default high pass at 50 Hz
EMG_lp = 10; % default low pass at 10 Hz

emgsamplerate = datastruct.emg.emgfreq;
numEMGs = length(datastruct.emg.emgnames);


[bh,ah] = butter(4, EMG_hp*2/emgsamplerate, 'high'); %highpass filter params
[bl,al] = butter(4, EMG_lp*2/emgsamplerate, 'low');  %lowpass filter params

for E=1:numEMGs
    % Filter EMG data
    tempEMG = double(datastruct.emg.data(emgtimebins,E+1));
    tempEMG = filtfilt(bh,ah,tempEMG); %highpass filter
    tempEMG = abs(tempEMG); %rectify
    tempEMG = filtfilt(bl,al,tempEMG); %lowpass filter
    
    %downsample EMG data to desired bin size
    %             emgdatabin(:,E) = resample(tempEMG, 1/binsize, emgsamplerate);
    emgdatabin(:,E) = interp1(datastruct.emg.data(emgtimebins,1), tempEMG, timeframe,'linear',0);
end

%Normalize EMGs
if NormData
    for i=1:numEMGs
        %             emgdatabin(:,i) = emgdatabin(:,i)/max(emgdatabin(:,i));
        %dont use the max because of artefact, use 99% percentile
        EMGNormRatio = prctile(emgdatabin(:,i),99);
        emgdatabin(:,i) = emgdatabin(:,i)/EMGNormRatio;
    end
end