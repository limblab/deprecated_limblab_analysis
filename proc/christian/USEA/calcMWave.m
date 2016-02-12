function [ mWave ] = calcMWave2(USEAdata)

%CALCMWAVE
% Calculates the mWave for the provided EMG-data.
% Startindex is set at 2ms (20 samples) after the stim-marker.
% Stim trig is the last analog signal

%% Find stim start position
stimT = find(USEAdata(:,end)>1000);

% Set startindex 2ms after stim
start = max(stimT) + 20;
stop  = start + 500; %50 ms later

%% Check stim marker
if isempty(stimT)
    warning('Could not detect stim pulse');
    mWave = -1;
else
    EMGdata = USEAdata(start:stop,1:end-1);
end

%% Mwave for data of interest
mWave = range(EMGdata);