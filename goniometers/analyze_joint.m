function [f, p] = analyze_joint(bdf, chan, unit, start, stop, quiet)
% ANALYZE_JOINT - Performs joint level analysis based on goniometer signals
%   ANALYZE_JOINT(BDF, CHAN, UNIT, START, STOP) performs joint level
%   analysis on the specified channel and unit between START and STOP

% $Id$

addpath ../spike
addpath ../bdf
addpath ../lib

disp(nargchk(5, 6, nargin));
if nargin < 6
    quiet = 0;
end

% for now we are going to use GoniometerX
g_chan = find(strcmp('GoniometerY', bdf.raw.analog.channels));
g_time = (1:length(bdf.raw.analog.data{g_chan})) / bdf.raw.analog.adfreq + ...
    bdf.raw.analog.ts{g_chan};

start_idx = find(g_time > start, 1, 'first');
stop_idx  = find(g_time > stop, 1, 'first');

[b,a] = butter(8, 10/bdf.raw.analog.adfreq);
g = filtfilt(b, a, bdf.raw.analog.data{g_chan});
%dg = diff(g);
g = g(start_idx:stop_idx);
%dg = dg(start_idx:stop_idx);
t = g_time(start_idx:stop_idx);

% get units
s = get_unit(bdf, chan, unit);
b = train2bins(s, t);
b(1) = 0; % cover a bug in train2bins

[means, bins, errors, ns, ts] = plot_posterior(g, b, quiet);
%subplot(2,2,1), plot_posterior(g, b);
%subplot(2,2,2), plot_posterior(dg, b);
%subplot(2,2,3), plot(t,g,'r-',t,b,'k-');
%subplot(2,2,4), plot(t,dg,'r-',t,b,'k-');

if ~quiet
    suptitle(sprintf('Unit: %d-%d', chan, unit));
end

% get modified f-statistic on tuning curve
f = var(means) / mean(errors);

% get probability of this much varience under null hypothesis
ps = binocdf( ns, ts, sum(ns) / sum(ts) );
ps(ps > .5) = 1 - ps(ps > .5);
ps = 2*ps;
p = min(ps) < .05 / length(ps);

% cleanup
rmpath ../spike
rmpath ../bdf
rmpath ../lib

