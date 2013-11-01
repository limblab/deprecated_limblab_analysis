function [ d, t ] = train2bins( s, b )
%TRAIN2BINS Converts spike train timestamps to bins of spike counts
%   Give a time series of bins giving spike counts per bin for a given bin
%   width w and spike train timesamps s.
%
%   Returns d: The number of spikes in each bin
%           t: The coresponding timestamps for the start of each bin
%
%Example:
%   [d, t] = train2bins( [0.2 0.4 1.1 1.7], .5 );
%
%   Gives:
%       d = [   2   0   1   1 ]
%       t = [ 0.0 0.5 1.0 1.5 ]

% $Id$

if isscalar(b)
    lastbin = b * floor(s(end)/b); % get last timestamp
    t = 0:b:lastbin;
else
    t = b;
    b = b(2)-b(1);
end

if ~issorted(s)
    s = sort(s);
end

d = zeros(size(t));

if ~isempty(s)

        %spike index on first ts > t(1)
    s_i = find(s>=t(1),1,'first');

    for i = 1:length(d)-1
        while s_i<=length(s) && s(s_i)<t(i+1)
            d(i) = d(i)+1;
            s_i  = s_i +1;
        end
    end

    while s_i<=length(s) && s(s_i)<t(end)+b
        d(end) = d(end)+1;
        s_i  = s_i +1;
    end
end

