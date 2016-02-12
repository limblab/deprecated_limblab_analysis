function [emg, stimTime, time] = fakeEMGdata(slope,show_plot)

% Create some fake EMG data to play with

% 2014-09-02

fs = 1000;
slope = slope*fs; % Say the EMG value increases by .1 once per sample

prePeak  = 3; % Add some amount of (sec) baseline before peak
stimTime = prePeak - .050; % Assume MEP occurs 50 ms after stim
emgBaseline = ones(1,prePeak*fs);
emgPeak = 5*[1 1.1 1.15 1.19 1.2 1.25 1.3 1.35 1.4 1.5 1.7 1.9 2.8 3 3.5 4 5];  % First half of fake EMG (contains peak)
emgHalf = [emgBaseline emgPeak];

emg = [emgHalf fliplr(emgHalf)];
time = (0:1/fs:((length(emg)-1)*1/fs)); % Time stamps for full EMG data

lineEQ = emgHalf(end-4) + slope*time; % Steady increase in EMG
emg = emg + lineEQ; 

    % Transpose everything
emg = emg';stimTime = stimTime';time = time';




if show_plot
    % Plot the data
    figure
    plot(time, emg)
    xlim([min(time) max(time)])
    % ylim([-5 max(emg)*1.2])
end

end