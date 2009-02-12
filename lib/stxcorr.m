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

% $Id: $

% get input arguments
overlap = 0;
max_offset = window_size - 1;
if nargin > 3
    overlap = varargin{1};
end

if nargin > 4
    window_size = varargin{2};
end

% get window start and stop times









