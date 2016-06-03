function idx = thrcross(curve, thr)
% THRCROSS - Threshold crossing
%   IDX = THRCROSS(CURVE, THR) returns the index for which CURVE 
%       crosses the threashold THR.  In the event that it crosses more than
%       once, it will return the crossing on the largest swing.

% $Id$

% Find peaks and troughs
dd = diff(curve);
peaks = find(dd(1:end-1) > 0 & dd(2:end) < 0) + 1;
troughs = find(dd(1:end-1) < 0 & dd(2:end) > 0) + 1;

% Keep only from first trough to last peak
peaks = peaks(peaks > troughs(1));
troughs = troughs(troughs < peaks(end));

swings = curve(peaks) - curve(troughs);
ms = find(swings == max(swings));
bigswing = troughs(ms):peaks(ms);

idx = find(curve(bigswing) > thr, 1, 'first') + bigswing(1) - 1;
%idx = peaks(ms);

%figure; hold on;
%plot(curve, 'k-')
%plot(peaks, curve(peaks), 'ko');
%plot(troughs, curve(troughs), 'ks');
%plot(bigswing, curve(bigswing), 'r-');
%plot(idx, curve(idx), 'r*');
