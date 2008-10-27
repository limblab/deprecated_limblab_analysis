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

% normalize values
ag = (g - mean(g)) / sqrt(var(g));
adg = (dg - mean(dg)) / sqrt(var(dg));

%plot(ag, adg)

% get units
s = get_unit(bdf, chan, unit);
b = train2bins(s, t);
b(1) = 0; % cover a bug in train2bins

%d = tmi(b, [ag adg], -1000:10:1000);
%plot(-1000:10:1000, d);

[c1, lags] = xcorr(g, b);
c2 = xcorr(dg, b);

plot(lags, c1,'b-', lags, c2, 'r-');
%plot(b)

% cleanup
rmpath ../spike
rmpath ../bdf
