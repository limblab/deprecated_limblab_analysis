function analyze_joint(bdf, chan, unit, start, stop)
% ANALYZE_JOINT - Performs joint level analysis based on goniometer signals
%   ANALYZE_JOINT(BDF, CHAN, UNIT, START, STOP) performs joint level
%   analysis on the specified channel and unit between START and STOP

% $Id$

addpath ../spike
addpath ../bdf

% for now we are going to use GoniometerX
g_chan = find(strcmp('GoniometerY', bdf.raw.analog.channels));
g_time = (1:length(bdf.raw.analog.data{g_chan})) / bdf.raw.analog.adfreq + ...
    bdf.raw.analog.ts{g_chan};

start_idx = find(g_time > start, 1, 'first');
stop_idx  = find(g_time > stop, 1, 'first');

[b,a] = butter(8, 10/bdf.raw.analog.adfreq);
g = filtfilt(b, a, bdf.raw.analog.data{g_chan});
dg = diff(g);
g = g(start_idx:stop_idx);
dg = dg(start_idx:stop_idx);
t = g_time(start_idx:stop_idx);

% get units
s = get_unit(bdf, chan, unit);
b = train2bins(s, t);
b(1) = 0; % cover a bug in train2bins
g_spike = g(b == 1);

gmax = max(g);
gmin = min(g);
gstep = (gmax - gmin) / 8;
gbins = gmin-gstep:gstep:gmax+gstep;

n = hist(g, gbins);
ns = hist(g_spike, gbins);

rate = 1000 * ns ./ n;
rate_err = 1000 * sqrt(ns) ./ n;

figure; errorbar(gbins(2:end-1), rate(2:end-1), rate_err(2:end-1), 'bo-');
title(sprintf('Unit: %d-%d', chan, unit));

% cleanup
rmpath ../spike
rmpath ../bdf
