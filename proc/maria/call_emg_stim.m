% load data file
% choose muscles to stimulate and which animals
% define defaults (pw)
% low pass filter emgs
% define thresholds
% emg to current amp conversion
% stimulate based on current arrays
%TODO make this work for many animals


%% load data file
emg_file = 'EMGdata';
load(emg_file);
%musc_names = {'gluteus max', 'gluteus med', 'gastroc', 'vastus lat', 'biceps fem A',...
%    'biceps fem PR', 'biceps fem PC', 'tib ant', 'rect fem', 'vastus med', 'adduct mag', ...
%    'semimemb', 'gracilis R', 'gracilis C', 'semitend'};
musc_names = {'GS', 'Gmed', 'LG', 'VL', 'BFa',...
        'BFpr', 'BFpc', 'TA', 'RF', 'VM', 'AM', ...
        'SM', 'GRr', 'GRc', 'ST'};
%good and bad channels (1 is good, 0 is bad)
goodChannelsWithBaselines =  [ 1 ,  0 ,  0 , 0 , 1 , 1 ,  1 ,  0 , 1 , 1 , 0 , 0 , 1 , 1 , 1 ;...
    0 ,  1 ,  1 , 1 , 1 , 1 ,  1 ,  1 , 1 , 1 , 0 , 1 , 0 , 1 , 0 ;...
    1 ,  0 ,  1 , 1 , 1 , 0 ,  1 ,  1 , 1 , 1 , 0 , 0 , 1 , 1 , 0 ;...
    1 ,  0 ,  1 , 0 , 1 , 1 ,  1 ,  1 , 0 , 0 , 0 , 0 , 0 , 1 , 1 ;...
    1 ,  1 ,  1 , 0 , 1 , 1 ,  1 ,  1 , 1 , 0 , 0 , 1 , 1 , 1 , 0 ;...
    1 ,  1 ,  0 , 1 , 1 , 1 ,  1 ,  1 , 1 , 0 , 0 , 1 , 0 , 1 , 0 ;...
    1 ,  0 ,  1 , 1 , 1 , 1 ,  1 ,  1 , 1 , 1 , 0 , 1 , 0 , 1 , 1 ;...
    1 ,  0 ,  1 , 1 , 0 , 1 ,  1 ,  1 , 1 , 1 , 0 , 0 , 1 , 1 , 1 ];

animals = [1:8];
muscles = [1 4 5 6 8 3 12 9 15];
n = 4;
Wn = 30/(5000/2); %butter parameters (30 Hz)
channels = [1 2 3 4 5 6 9 8 10];
pw = .2; %ms

mus_mean = {};
%rawCycleData{animal, step}(:, muscle)

%get average of low pass filtered emgs
for i=1:length(muscles)
    %figure; hold on;
    for j=1:length(animals)
        if goodChannelsWithBaselines(animals(j), muscles(i))
            filtered = filter_emgs(rawCycleData, animals(j), muscles(i), n, Wn);
            %plot(filtered);
            mus_mean{i, j} = mean(filtered);
            %plot(mean(filtered));
        end
    end
end
%can now reference a specific filtered average with mus_mean{muscle, animal}
%plot(mus_mean{1,1}); hold on;


%% define thresholds and convert EMG to amplitude
emglow_limit = [.15 .13 .13 .13 .13 .13 .13 .13 .13]; %get rid of low noise
emghigh_limit = [1 1 1 1 1 1 1 1 1]; %get rid of excessively high spikes
amplow_limit = [.3 1.4 .7 1.8 .7 .2 1.2 1.2 .2]; %lowest level of stim to twitch (err on low side)
amphigh_limit = [1.9 3.0 2.2 2.4 1.2 .9 2.6 2.6 .9];  %highest level of stim to use

%check that limits are all defined
%NOTE: this doesn't check number of channels because I might need to make
%up some arrays for certain muscles (particularly IP)
lm = length(muscles);
if lm~=length(emglow_limit) || lm~=length(emghigh_limit) || lm~=length(amplow_limit) || lm~=length(amphigh_limit)
    error('Number of muscles does not match number of values in arrays for EMG and current thresholds; check that there is one value per muscle.')
end

%TODO: deal with confusing numbering system for emgs here. should I average
%together different muscles before stimulation? YES

clear('current_arr');
%figure; hold on;
colors = {[204 0 0], [255 125 37], [153 84 255],  [106 212 0], [0 102 51], [0 171 205], [0 0 153], [102 0 159], [64 64 64], [255 51 153], [253 203 0]};
for i=1:length(muscles)
    %cycle through each muscle we'll be stimulating, find the mean of the
    %filtered EMGs, and find the conversion to amplitude of current
    a = mus_mean(i, :);
    a = a(~cellfun('isempty', a));
    ds_mat = norm_mat(dnsamp(a).');
    clear('a');
    ds_means{i} = mean(ds_mat.');
    current_arr{i} = emg2amp(ds_means{i}, emglow_limit(i), emghigh_limit(i), amplow_limit(i), amphigh_limit(i));
%     plot(ds_means{i}, 'linewidth', 2, 'color', colors{i}/255);
    legendinfo{i} = musc_names{muscles(i)};
end

%make IP array
% ip_arr = mean([ds_means{1}; ds_means{6}; ds_means{9}]); 
% ip_emg_low = .13; ip_emg_high = 1; ip_amp_low = 1.5; ip_amp_high = 3.0; 
% current_arr{length(channels)} = emg2amp(ip_arr, ip_emg_low, ip_emg_high, ip_amp_low, ip_amp_high); 
% legendinfo{length(channels)} = 'IP';
%plot(ip_arr, 'k', 'linewidth', 2); 
%add legend
legend(legendinfo);

%% Define parameters to be used to run the stimulation cycle (number of runs, length of runs, etc)
%TODO: figure out best stretch factor
%choose number of time
repeats = 11; %number of times to repeat the cycle
slowdown_factor = 6; %three seems to be pretty much a normal length step. Kind of.
amp_adjust = .65;
if length(amp_adjust)>1 %if using an array of amplitude adjustment
    for i=1:length(current_arr)
        %plot(current_arr{i}); hold on;
        current_arr{i} = current_arr{i}*amp_adjust(i);
        %plot(current_arr{i}); 
    end
else
    current_arr = cellfun(@(x) x*amp_adjust, current_arr, 'UniformOutput', false);
end
stim_update = 20; stim_freq = 40; original_freq = 5000;

%% save original array (ds_means), repeats, slowdown factor, current
%adjustment, current array, muscles, and legend. Autoincrements.
filepath = 'C:\Users\mkj605\Documents\stimulation\';
dayname = datestr(now, 'yyyymmdd');
if ~exist([filepath dayname], 'dir')
    mkdir([filepath dayname]); %make a folder for the day's stimulation
end

i = 1;
while exist([filepath dayname '/' datestr(now, 'yyyymmdd') '_' num2str(i,'%03d') '.mat'], 'file')
    i=i+1;
end
save([filepath dayname '/' datestr(now, 'yyyymmdd') '_' num2str(i,'%03d') '.mat'], ...
    'muscles', 'legendinfo', 'repeats', 'slowdown_factor', 'amp_adjust', 'stim_update', 'stim_freq', 'original_freq', ...
    'ds_means', 'amplow_limit', 'amphigh_limit', 'pw', 'current_arr');


%% Call stimulation based on array
array_stim(current_arr, stim_update, stim_freq, original_freq, slowdown_factor, pw, channels, repeats, legendinfo, 'COM4');

%TODO: array-based stim fxn with freq modulation

%THEN, quickly write array_stim (needs to iterate
%through stimulation with timing while loop and tic toc), also, downsample
%the current array to whatever frequency gets passed. also, this
%stimulation should take the entire matrix of current array and do each
%channel

%TODO: add TTL pulse stim to extra channel (probs channel 16)
