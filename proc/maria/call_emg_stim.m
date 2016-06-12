% load data file
% choose muscles to stimulate and which animals
% define defaults (pw)
% low pass filter emgs
% define thresholds
% emg to current amp conversion
% stimulate based on current arrays
%TODO make this work for many animals


%load data file
emg_file = 'EMGdata';
load(emg_file);
musc_names = {'gluteus max', 'gluteus med', 'gastroc', 'vastus lat', 'biceps fem A',...
    'biceps fem PR', 'biceps fem PC', 'tib ant', 'rect fem', 'vastus med', 'adduct mag', ...
    'semimemb', 'gracilis R', 'gracilis C', 'semitend'};
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
muscles = [1 4 5 6 3 8 9 12 15];
n = 4;
Wn = 30/(5000/2); %butter parameters (30 Hz)
channels = [1 3 5 2 4 7 6 8 9];
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


%define thresholds
emglow_limit = [.15 .13 .13 .13 .13 .13 .13 .13 .13]; %get rid of low noise
emghigh_limit = [1 1 1 1 1 1 1 1 1]; %get rid of excessively high spikes
amplow_limit = [.4 2 1.1 1.3 .3 .8 2.4 .9 1.6]; %lowest level of stim to twitch (err on low side)
amphigh_limit = [2.3 3.5 1.25 1.9 1.3 1.8 3.5 1.7 2.4];  %highest level of stim to use

%check that limits are all defined
lm = length(channels);
if lm~=length(emglow_limit) || lm~=length(emghigh_limit) || lm~=length(amplow_limit) || lm~=length(amphigh_limit) || lm~=length(muscles)
    error('Number of muscles does not match number of channels or incorrect number of values in arrays for EMG and current thresholds; check that there is one value per muscle.')
end

%TODO: deal with confusing numbering system for emgs here. should I average
%together different muscles before stimulation? YES

clear('current_arr');
%figure; hold on;
for i=1:length(muscles)
    %cycle through each muscle we'll be stimulating, find the mean of the
    %filtered EMGs, and find the conversion to amplitude of current
    a = mus_mean(i, :);
    a = a(~cellfun('isempty', a));
    ds_mat = norm_mat(dnsamp(a).');
    clear('a');
    %figure(channels(i)); hold on; plot(ds_mat);
    ds_mean = mean(ds_mat.');
    %plot(ds_mean, 'color', [.5 .5 .5], 'linewidth', 2); %use these plots to help choose thresholds
    current_arr{i} = emg2amp(ds_mean, emglow_limit(i), emghigh_limit(i), amplow_limit(i), amphigh_limit(i));
    %plot(ds_mean, 'linewidth', 2);
    legendinfo{i} = musc_names{muscles(i)};
end

%legend(legendinfo);

%TODO: figure out best stretch factor
repeats = 1; %number of times to repeat the cycle
slowdown_factor = 16;
amp_adjust = .5;
current_arr = cellfun(@(x) x*amp_adjust, current_arr, 'UniformOutput', false);


array_stim(current_arr, 20, 40, 5000, slowdown_factor, pw, channels, repeats, legendinfo, 'COM4');

%TODO: array-based stim fxn with freq modulation

%THEN, quickly write array_stim (needs to iterate
%through stimulation with timing while loop and tic toc), also, downsample
%the current array to whatever frequency gets passed. also, this
%stimulation should take the entire matrix of current array and do each
%channel

%TODO: add TTL pulse stim to extra channel (probs channel 16)
