function lp_matrix = filter_emgs(emg_array, animal, muscle, n, Wn)
%outputs a matrix of the low-pass-filtered emgs, where the columns of the
%matrix are the data points (over time) and the rows of the matrix are the
%number of steps taken by the animal

%format: rawCycleData{animalnum, stepnum}(:, musclenum)

data_pts = zeros(1,size(emg_array, 2)); %define an empty array to remember length of data collection for each step

rect_matrix = {}; %cell(size(stepn)) %maybe?
i=1;

while i<=size(emg_array, 2) & size(emg_array{animal, i})~=[0 0]
    %first do abs value or everything will be close to zero
    rectify_emg = abs(emg_array{animal, i}(:, muscle));
    rect_matrix{i} = rectify_emg;
    %plot(rectify_emg);
    i = i+1;
end
stepn = 1:i-1;

ds_matrix = dnsamp(rect_matrix); 
target_len = size(ds_matrix, 2); 

[b, a] = butter(n, Wn); %defaults to low; can tell it to do high for a hp filter
lp_matrix = zeros(length(stepn), target_len); %matrix of lp filters
for i=stepn
    low_pass_filt = filtfilt(b,a,ds_matrix(i, :));
    lp_matrix(i, :) = low_pass_filt;
end
end

