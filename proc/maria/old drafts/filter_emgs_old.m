function lp_matrix = filter_emgs(emg_array, animal, muscle, n, Wn)

%format: rawCycleData{animalnum, stepnum}(:, musclenum)

data_pts = zeros(1,size(emg_array, 2)); %define an empty array to remember length of data collection for each step

rect_matrix = {}; %cell(size(stepn)) %maybe?
i=1;

%check total length of this particular sample

while i<=size(emg_array, 2) & size(emg_array{animal, i})~=[0 0]
    %first do abs value or everything will be close to zero
    rectify_emg = abs(emg_array{animal, i}(:, muscle));
    data_pts(i) = length(rectify_emg);
    rect_matrix{i} = rectify_emg;
    %plot(rectify_emg);
    i = i+1;
end
stepn = 1:i-1;
data_pts = data_pts(stepn);
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

[b, a] = butter(n, Wn); %defaults to low; can tell it to do high for a hp filter
lp_matrix = zeros(length(stepn), target_len); %matrix of lp filters
figure; 
for i=stepn
    low_pass_filt = filtfilt(b,a,ds_matrix(i, :));
    lp_matrix(i, :) = low_pass_filt;
    plot(low_pass_filt);
end

end

