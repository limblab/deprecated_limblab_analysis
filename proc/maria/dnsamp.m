function ds_matrix = dnsamp(cell_array)
%function to downsample/'squish' a set of arrays so that all of them are 
%the length of the shortest array
%INPUT: a 1 by n-length cell matrix
%OUTPUTS: matrix of downsampled, equal-length arrays

data_pts = zeros(1, length(cell_array)); %define an empty array to remember length of data collection for each step

for i=1:length(cell_array)
    data_pts(i) = length(cell_array{i}); %gives the number of data points in each row of the matrix
end

target_len = min(data_pts); %the target length for the final array is the shortest one in the set

ds_matrix = zeros(length(cell_array), target_len); %matrix of downsampled data

for i=1:length(cell_array)
    conv_fact = target_len/data_pts(i);
    x = 1/5000:1/5000:data_pts(i)/5000; %time variable (sampling at 5000hz)
    xq = 1/5000/conv_fact:1/5000/conv_fact:data_pts(i)/5000; %new time variables - now an array of len
    downsamp = interp1(x, cell_array{i}, xq);
    ds_matrix(i, :) = downsamp;
    %plot(downsamp);
end