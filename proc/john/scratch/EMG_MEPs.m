function [] = EMG_MEPs(emg, t_emg, stimTimes)
% EMG_MEPs - For each stim. time stamp isolate a window around (in front
% of?) stim. and find the time and value of peak in EMG.
%
% INPUT:
%       'stimTimes': [n_stims x 1] - Time stamps of intracortical stimulations
%             'EMG': EMG signal
% OUTPUT:
%
% Created by John W. Miller
% 2014-09-02
%
%%

    % EMG sampling rate
fs = 1000; % 1k?

    % Window around peak in EMG (Hopefully a MEP)
timePostStim = 0.1; % sec?
window = 0.050; % Time region before and after to average for baseline

n_stims = length(stimTimes);
for iStim = 1:n_stims
    t_stim   = stimTimes(iStim,1); % Time stamp of current stim
    if 1
        plot(t_emg,emg)
        line('XData',[t_stim t_stim], 'YData',[min(emg) max(emg)])
    end
        % EMG idx closest to time of stim
    idx_stim = find(t_stim <= t_emg,1,'first');
        % Assume MEP will have occured earlier than 1 sec after stim
    idx_postPeak = find((t_stim+1) <= t_emg,1,'first');
    
    emgPreStim  = mean(emg(preStimWindow,1));
    emgPostPeak = mean(emg(postPeakWindow,1));
    % I should calculate a slope
    
    baseline    = (emgPreStim-emgPostPeak)/2;
    
    
    preStimWindow  = (idx_stim - window*fs):idx_stim;
        % Assume the MEP will have occured earlier than 2*'window' (sec) after peak
    postPeakWindow = (idx_stim:(idx_stim + window*fs))+2*window*fs;
    emgPreStim  = (emg(preStimWindow,1));
    emgPostPeak = (emg(postPeakWindow,1));
    spread = find(median(emgPreStim)==emg):find(median(emgPostPeak)==emg);
    t_values = t_emg(spread);
    run = range(t_values); % rise/run :)
    emgSlope = (mean(emgPostPeak)-mean(emgPreStim))/run;
    lineEQ = emgSlope*t_values;
    
%     [peakVal, idx_peak] = max(emg(idx_stim:(idx_stim+
    
    
    
        % Calc basline EMG during MEP
    emgIdxPre  = emgIdx - pre*fs;
    emgIdxPost = emgIdx + post*fs;
        
        
    if emgIdxPre > 0 && emgIdxPost < length(emg)
        emgPeakPre  = emg(emgIdx - pre*fs,1);
        emgPeakPost = emg(emgIdx + post*fs,1);
        peakValue = max(emg(emgIdxPre:emgIdxPost,1));
        baseline  = (emgPeakPre + emgPeakPost)/2 % Average value at time of peak
        MEP = peakValue - baseline;
    end
    
    
    
    
    
    
end