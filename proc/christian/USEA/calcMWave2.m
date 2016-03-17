function [ mWave ] = calcMWave2(USEAdata)

%CALCMWAVE
% Calculates the mWave for the provided EMG-data.
% Startindex is set at 2ms (20 samples) after the stim-marker.
% Stim trig is the last analog signal

%% Find endo of stim pulse
stimT = max(find(USEAdata(:,end)>1000));

%% Check stim marker
if isempty(stimT)
    mWave = [];
    return;
else
    % Measure Vpp from 2ms to 32ms after stim
    start = max(stimT) + 20;
    stop  = start + 300; %30 ms later
    EMGdata = USEAdata(start:stop,1:end-1);
end

%% Mwave for data of interest
mWave = range(EMGdata);