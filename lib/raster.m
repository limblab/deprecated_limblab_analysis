function [table, all] = raster(spikes, events, start, stop, h)
% RASTER displays a raster plot of the spike data synchronized to an event
%   RASTER(SPIKES, EVENTS, START, STOP) displays the raster plot of the
%   specified spike train SPIKES centered about the time of EVENTS.  Given
%   multiple EVENTS it will display one raster trace aligned to each
%   value in EVENTS.  Both SPIKES and EVENTS are time stamp data.
%
%   START and STOP both specify the extents of the window. For example: 
%       RASTER(SPIKES, EVENTS, -.25 1.25) will draw a raster plot from .25
%       seconds before the event to 1.25 seconds after.
%
%   RASTER(..., H) will not open a new figure window but will instead 
%
%   TABLE = RASTER( ... ) will return the set of time stamps of the spikes
%   aligned to each event.
%
%   [TABLE, ALL] = RASTER( ... ) will also return timestamp data ALL being
%   the time stamps of all spikes aligned to the events.  This is usefull
%   to feed into a bining routine so the firing rate can be plotted.

% $Id$

num_trials = length(events);

% Build trial table
table = cell(num_trials, 1);

for i = 1:num_trials
    table{i} = spikes(spikes > events(i)+start & spikes < events(i)+stop);
    table{i} = table{i} - events(i);
end

figure;
hold on;
for i = 1:num_trials
    plot(table{i}, i*ones(length(table{i})), 'k.')
end

if nargout > 1
    all = [];
    for i = 1:num_trials
        all = [all; table{i}];
    end
    all = sort(all);
end

