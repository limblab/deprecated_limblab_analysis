function rate = spikes2rate(ts)
% SPIKES2RATE - Converts spike time stamps to a firing rate
%   using interspike intervals

% $Id$

rate = 1 ./ diff(ts);
timebase = .5 * (ts(2:end) + ts(1:end-1));

rate = [timebase rate];
