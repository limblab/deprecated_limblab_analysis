function [c, t, lag] = stxcorr(x, y, window_size, varargin);
% STXCORR short-time cross corelation
%   C = STXCORR(X, Y, WINDOW_SIZE) divides signals X and Y into active
%   windows and calculates C a vector containing the peak of the cross-
%   corelation for each window.
%
%   C = STXCORR(X, Y, WINDOW_SIZE, OVERLAP), where OVERLAP is the number of
%   samples from each window that overlap with the next.  Defaults to zero
%
%   C = STXCORR(X, Y, WINDOW_SIZE, OVERLAP, MAX_OFFSET) instead of looking
%   at the overall peak of the cross corelation from each window it only
%   looks at the region from -MAX_OFFSET to +MAX_OFFSET.
%
%   [C, T] = STXCORR(...) also returns T the list of window centers
%   coresponding to each value of C.
%
%   [C, T, LAG] = STXCORR(...) also returns LAG the timing of the peak of
%   the cross corelation for each value of C.

% $Id$

% get input arguments
overlap = 0;
max_offset = window_size - 1;
if nargin > 3
    overlap = varargin{1};
end

if nargin > 4
    max_offset = varargin{2};
end

% ensure x and y are same length and other variables are scalar
if (length(x) ~= length(y))
    error('X and Y must be the same length');
end
if (~isscalar(window_size))
    error('WINDOW_SIZE must be scalar');
end
if (~isscalar(overlap))
    error('OVERLAP must be scalar');
end
if (~isscalar(max_offset))
    error('MAX_OFFSET must be scalar');
end

% get window start and stop times
num_windows = floor(length(x) / (window_size-overlap)) - 1;
starts = (0:num_windows-1) .* (window_size - overlap) + 1;
stops = starts + window_size;
centers = (starts + stops) ./ 2;

% get xcorr for each window
c = zeros(num_windows, 1);
lag = zeros(num_windows, 1);
for i = 1:num_windows
    x_win = x(starts(i):stops(i));
    y_win = y(starts(i):stops(i));
    c_win = xcorr(x_win, y_win, 'coeff');
    c_win_roi = c_win(window_size-max_offset:window_size+max_offset);
        
    peak = find(c_win_roi == max(c_win_roi), 1, 'first');
    if isscalar(peak)
        c(i) = c_win_roi(peak);      
        lag(i) = peak - max_offset;
    else
        c(i) = 0;
        lag(i) = NaN;
    end
end

% asign remaining output
t = centers;



