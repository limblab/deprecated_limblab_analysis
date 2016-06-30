% load data file
% choose muscles to stimulate and which animals
% define defaults (pw)
% low pass filter emgs
% define thresholds
% emg to current amp conversion
% stimulate based on current arrays
%TODO make this work for many animals

%To stimulate based on a pre-saved current array, set this to 1. To make
%one based on emgs, set it to 0.
array_pref = 0;

if array_pref==0
    %load data file
    emg_file = 'EMGdata';
    load(emg_file);
    musc_names = {'gluteus max', 'gluteus med', 'gastroc', 'vastus lat', 'biceps fem A',...
        'biceps fem PR', 'biceps fem PC', 'tib ant', 'rect fem', 'vastus med', 'adduct mag', ...
        'semimemb', 'gracilis R', 'gracilis C', 'semitend'};
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
    muscles = [1 4 5 6 7 3 8 9 12 14 15];
    n = 4;
    Wn = 30/(5000/2); %butter parameters (30 Hz)
    channels = [1 2 3 4 5 6 7 8 9 10 11];
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
    emglow_limit = [.13 .13 .13 .13 .13 .13 .13 .13 .13 .13 .13]; %get rid of low noise
    emghigh_limit = [1 1 1 1 1 1 1 1 1 1 1]; %get rid of excessively high spikes
    amplow_limit = [.2 .8 .5 .4 1.1 .5 .6 1.2 .9 .7 .9]; %lowest level of stim to twitch (err on low side)
    amphigh_limit = [1.9 3.0 1.7 2.5 2.8 2.9 2.7 2.4 3.2 3.4 2.8];  %highest level of stim to use
    
    %check that limits are all defined
    lm = length(channels);
    if lm~=length(emglow_limit) || lm~=length(emghigh_limit) || lm~=length(amplow_limit) || lm~=length(amphigh_limit) || lm~=length(muscles)
        error('Number of muscles does not match number of channels or incorrect number of values in arrays for EMG and current thresholds; check that there is one value per muscle.')
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
        %figure(channels(i)); hold on; plot(ds_mat);
        ds_mean = mean(ds_mat.');
        %hold on; plot(ds_mean, 'color', colors{i}/255, 'linewidth', 2.5); %use these plots to help choose thresholds
        current_arr{i} = emg2amp(ds_mean, emglow_limit(i), emghigh_limit(i), amplow_limit(i), amphigh_limit(i));
        %hold on; plot(current_arr{i}, 'color', colors{i}/255, 'linewidth', 2.5);
        legendinfo{i} = musc_names{muscles(i)};
    end
    
%     aleg = legend(legendinfo); 
%     set(aleg,'FontSize',18);
    %to stimulate based on a saved array:
else
    %load the file
    %TODO load file, set the new currents based on emg and amplitude low
    %and high limits, somehow correlate with muscle names/channels? balls.
    %this is slightly harder than I hoped
    
    %finally, update the amplitudes
    for i=1:length(muscles)
        current_arr{i} = change_amp_limits(current_arr{i}, amplow_limit(i), amphigh_limit(i), 2);
    end
end

%legend(legendinfo);

%TODO: figure out best stretch factor
repeats = 1; %number of times to repeat the cycle
slowdown_factor = 4;
amp_adjust = 1;
current_arr = cellfun(@(x) x*amp_adjust, current_arr, 'UniformOutput', false);

%If saving current array for later stimulus possibilities
saving = 0; %0 is off, 1 is on
if saving
    %remove the amplitude adjustment so I can update current array later
    %with the correct amplitudes
    for i=1:length(muscles)
        saved_current{i} = change_amp_limits(current_arr{i}, amplow_limit(i), amphigh_limit(i), 1);
    end
    %save current and muscles TODO double check that legend info is in the
    %correct order
    comments = 'Any useful commentary on this array for stimulation'; 
    save(['current' datestr(now, 'yyyymmdd_HHMM'), '.mat'], 'saved_current', 'legendinfo', 'comments')
end

array_stim(current_arr, 20, 40, 5000, slowdown_factor, pw, channels, repeats, legendinfo, 'COM4');

%TODO: array-based stim fxn with freq modulation

%THEN, quickly write array_stim (needs to iterate
%through stimulation with timing while loop and tic toc), also, downsample
%the current array to whatever frequency gets passed. also, this
%stimulation should take the entire matrix of current array and do each
%channel

%TODO: add TTL pulse stim to extra channel (probs channel 16)
