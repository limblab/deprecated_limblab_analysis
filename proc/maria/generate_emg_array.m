% load data file
% choose muscles to stimulate and which animals
% define defaults (pw)
% low pass filter emgs
% define thresholds
% emg to current amp conversion
% stimulate based on current arrays

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
muscles = [1 4 5 6 7 8 3 9 12 15];
n = 4;
Wn = 30/(5000/2); %butter parameters (30 Hz)
colors = {[204 0 0], [255 125 37], [153 84 255],  [106 212 0], [0 102 51], [0 171 205], [0 0 153], [102 0 159], [64 64 64], [255 51 153], [253 203 0]};
mus_mean = {};
%rawCycleData{animal, step}(:, muscle)
clear('emg_array'); 
clear('legendinfo');
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

for i=1:length(muscles) %make all the same length, then average. 
    a = mus_mean(i, :);
    a = a(~cellfun('isempty', a));
    ds_mat = norm_mat(dnsamp(a).');
    clear('a');
    emg_array{i} = mean(ds_mat.');
    arr_lens(i) = length(emg_array{i}); 
    legendinfo{i} = musc_names{muscles(i)};
end

%NOTE: MUST RESIZE ALL ARRAYS TO BE THE SAME TODO
if ~all(arr_lens == arr_lens(1))
    %get min val
    min_val = min(arr_lens); 
    emg_array = cellfun(@(x) x(1:min_val), emg_array, 'UniformOutput', false); 
    %chop off the end of every array so they're all the same length (since
    %it's like one value) -- BUT this is still cheating
end


%% make IP array
emg_array{end+1} = mean([emg_array{1}; emg_array{6}; emg_array{10}]); 
legendinfo{end+1} = 'IP';
%plot(ip_arr, 'k', 'linewidth', 2); 
%add legend

%% choose only a certain segment of the array for a given muscle

%for example, RF: 
%emg_array{8}(600:end) = 0; 


%% Translate a muscle's curve (wrap around the end of the array)
%emg_array{1} = circshift(emg_array{1}.', 100).'; 


%% Add in a gaussian curve to one of the muscles
%hmm. average? kind of a weighted average? (IN ALL REGIONS where the
%y-value of the gaussian is greater than the y-value of the emg array)

%calculate the curve itself
c = 1.2; %1/c = height of peak
mu = 1400; %mu is the x-location of the peak
peakwidth = 150; %width from peak to intercept with emglow_limit (noise threshold)
emglow_limit = .13; %to set omega so that the graph intercepts at the emg threshold
omega = sqrt(-peakwidth^2/log(emglow_limit/c)); 
x = linspace(0, length(emg_array{2}), length(emg_array{2})).'; %values of x

y = (1/c * exp(-((x-mu).^2)/omega^2)).';

%plot(y);

%then I can either average the two plots together 
%emg_array{2} = mean([emg_array{2}; y]); 

%or I can only insert the gaussian where it's greater than the original
indices = find(emg_array{10}<y); 
emg_array{10}(indices) = y(indices); 

%% Plot

figure; hold on;
for i=1:size(emg_array, 2)
    plot(emg_array{i}, 'linewidth', 2, 'color', colors{i}/255);
end
legend(legendinfo);

%can now reference a specific filtered average with mus_mean{muscle, animal}
%plot(mus_mean{1,1}); hold on;

%% Save array in format that is easily useable by call_emg_stim
save('emg_array_stgauss', 'legendinfo', 'emg_array'); 


