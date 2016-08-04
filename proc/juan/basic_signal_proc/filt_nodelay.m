%
%
% Function to remove tremor from the data. The input data must be a row
% vector.
% By default the sampling rate of the signal is considered to be 1kHz. The
% cutoff frequency is provided in Hz.
%
%   y = filt_nodelay(x, sampling_freq, cutoff_freq)
%
%
%       


function y = filt_nodelay(x, sampling_freq, cutoff_freq)


fs = sampling_freq;
order = 5;

fc = cutoff_freq; % The cut off freq of the LP filter
Wn = fc/(fs/2);
[a b] = butter(order,Wn); % a, b are the coefficients of the filter

% To filter with no delay
y_t = filtfilt(a,b,x');
y = y_t'; % to provide a row vector