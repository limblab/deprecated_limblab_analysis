%% Analyze results
% This script does the analysis of the results of the M1-M2
% simulations.
%
%
% Author:  Jasper Schuurmans
% Contact: jasper@schuurmans.cc
%% Cleanup and retrieve results
clear, clc
disp('Analyzing data...')
% Somewhat cumbersome construction to prevent m-lint warnings:
dat         = load('simResult');
out         = dat.out;
pool        = dat.pool;
velocities  = dat.velocities;
amplitudes  = dat.amplitudes;
ramp        = dat.ramp;
inputs      = dat.inputs;
clear dat

%% Calculate average neuron firing freq (before stretch onset)
time = out{1,1}.time;
idx = (time<0) & (time>-0.5);
avgFreq = sum(out{1,1}.nrn.S(idx)) / pool.N / 0.5;

%% Filter neural output ('emg')
% Create 3rd order low-pass Butterworth filter at 80 Hz.
[B,A] = butter(3, 80 / (1000/2));

% Use filtfilt to prevent phase lag from filtering.
emg  = cell(length(velocities), length(amplitudes));
for ii = 1:length(velocities)
    for jj = 1:length(amplitudes)
        emg{ii,jj} = filtfilt(B,A,out{ii,jj}.nrn.S);
    end
end   

%% Calculate M1 magnitude
M1 = zeros(length(velocities), length(amplitudes));
for ii = 1:length(velocities)
    for jj = 1:length(amplitudes)
        M1(ii,jj) = M1area(out{ii,jj}.time, emg{ii,jj});
    end
end

%% Calculate M2 magnitude
M2 = zeros(length(velocities), length(amplitudes));
for ii = 1:length(velocities)
    for jj = 1:length(amplitudes)
        M2(ii,jj) = M2area(out{ii,jj}.time, emg{ii,jj});
    end
end

%% Save results
time = out{1,1}.time;
save('analyzedResults',...
    'time',...
    'M1',...
    'M2',...
    'emg',...
    'out',...
    'avgFreq',...
    'velocities',...
    'amplitudes',...
    'ramp',...
    'pool',...
    'inputs');
%% Done!
disp('Analysis done.')