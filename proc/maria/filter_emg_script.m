%inputs
emg_file = 'EMGdata';
load(emg_file); %imports an 8x135 cell called rawCycleData
%each row corresponds to a different animal, each col corresponds to a
%different step (only one animal has 135 steps)
%each cell is ndatapts x 15 array (15 is number of muscles)
%SO to extract an individual muscle over one step, follow this format:
%rawCycleData{1}(:, 1)

raw_emg = rawCycleData{1,1}(:,1); 
rectify_emg = abs(raw_emg); 
[b, a] = butter(4, 90/(5000/2)); %defaults to low; can tell it to do high for a hp filter
low_pass_filt = filtfilt(b,a,rectify_emg); 

%plot
figure; hold on; 
plot(raw_emg, 'color',[.6 .6 .6])
plot(rectify_emg, 'b')
plot(low_pass_filt, 'm', 'linewidth', 2)