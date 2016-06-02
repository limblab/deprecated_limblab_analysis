%inputs
emg_file = 'EMGdata';
load(emg_file); %imports an 8x135 cell called rawCycleData
%each row corresponds to a different animal, each col corresponds to a
%different step (only one animal has 135 steps)
%each cell is ndatapts x 15 array (15 is number of muscles)
%SO to extract an individual muscle over one step, follow this format:
%rawCycleData{1}(:, 1)

n = 4; 
Wn = 30/(5000/2); %butter parameters (30 Hz)

musc_names = {'gluteus max', 'gluteus med', 'gastroc', 'vastus lat', 'biceps fem A',...
    'biceps fem PR', 'biceps fem PC', 'tib ant', 'rect fem', 'vastus med', 'adduct mag', ...
    'semimemb', 'gracilis R', 'gracilis C', 'semitend'};
%and good channels (1 is good, 0 is bad)
goodChannelsWithBaselines =  [ 1 ,  0 ,  0 , 0 , 1 , 1 ,  1 ,  0 , 1 , 1 , 0 , 0 , 1 , 1 , 1 ;...

    0 ,  1 ,  1 , 1 , 1 , 1 ,  1 ,  1 , 1 , 1 , 0 , 1 , 0 , 1 , 0 ;...

    1 ,  0 ,  1 , 1 , 1 , 0 ,  1 ,  1 , 1 , 1 , 0 , 0 , 1 , 1 , 0 ;...

    1 ,  0 ,  1 , 0 , 1 , 1 ,  1 ,  1 , 0 , 0 , 0 , 0 , 0 , 1 , 1 ;...

    1 ,  1 ,  1 , 0 , 1 , 1 ,  1 ,  1 , 1 , 0 , 0 , 1 , 1 , 1 , 0 ;...

    1 ,  1 ,  0 , 1 , 1 , 1 ,  1 ,  1 , 1 , 0 , 0 , 1 , 0 , 1 , 0 ;...

    1 ,  0 ,  1 , 1 , 1 , 1 ,  1 ,  1 , 1 , 1 , 0 , 1 , 0 , 1 , 1 ;...

    1 ,  0 ,  1 , 1 , 0 , 1 ,  1 ,  1 , 1 , 1 , 0 , 0 , 1 , 1 , 1 ];


for an_i = 1:8
    for mus_j = 1:15; 
%format: rawCycleData{animalnum, stepnum}(:, musclenum)
animal = an_i; 
data_pts = stepn; 
muscle = mus_j; 
rect_matrix = {}; %cell(size(stepn)) %maybe?
i=1; 

%check total length of this particular sample

%average emgs


while i<=135 & size(rawCycleData{animal, i})~=[0 0]
    %first do abs value or everything will be close to zero
    rectify_emg = abs(rawCycleData{animal, i}(:, muscle)); 
    data_pts(i) = length(rectify_emg); 
    rect_matrix{i} = rectify_emg; 
    %plot(rectify_emg); 
    i = i+1
end
stepn = 1:i-1;
target_len = min(data_pts);

%interpolate first to downsample, then avg, then lp filt
%figure('Name', 'interpolate 1st');
%hold on; 
ds_matrix = zeros(length(stepn), target_len); %matrix of downsampled data
for i=stepn
    conv_fact = target_len/data_pts(i); 
    x = 1/5000:1/5000:data_pts(i)/5000; %time variable (sampling at 5000hz)
    xq = 1/5000/conv_fact:1/5000/conv_fact:data_pts(i)/5000; %new time variables - now an array of len 
    downsamp = interp1(x, rect_matrix{i}, xq);
    ds_matrix(i, :) = downsamp; 
    %plot(downsamp); 
end

figure('Name', ['Animal ' num2str(animal) ', Muscle ' num2str(muscle)]);
hold on; 


[b, a] = butter(n, Wn); %defaults to low; can tell it to do high for a hp filter
lp_matrix = zeros(length(stepn), target_len); %matrix of lp filters
for i=stepn
    low_pass_filt = filtfilt(b,a,ds_matrix(i, :));
    lp_matrix(i, :) = low_pass_filt; 
    %plot(low_pass_filt); 
end
avgall = mean(lp_matrix);

e = std(lp_matrix); 
errorbar(avgall, e); 
plot(avgall, 'k', 'linewidth', 3); 
saveas(gcf, ['Animal' num2str(animal) 'Muscle' num2str(muscle) '.png']); 
end
end



