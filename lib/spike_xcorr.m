function [out, out_t] = spike_xcorr(bdf, chan, unit, bin, num_lags, drawplot)
% SPIKE_XCORR returns the cross correlations for the specified neuron and
% kinematics
%
% OUT = SPIKE_XCORR(BDF, CHAN, UNIT, BIN, NUM_LAGS) returns OUT, the cross 
% correlation between the 4 kinematic parameters (Px, Py, Vx, Vy) and the
% spikes of the specified CHAN and UNIT.  BIN is the bin size.  NUM_LAGS is
% the number of lags to use (on each side of zero)
%
% [OUT, OUT_T] = SPIKE_XCORR( ... ) also returns a vector representing the
% time lags.

% $Id$

% setup spikes and kin signals
spike_times = get_unit(bdf,chan,unit);
t = bdf.pos(1,1):bin:bdf.pos(end,1);
s = train2bins(spike_times, t);
s(1) = 0; s(end) = 0; % blank the overflow buckets in spike bins

[c, kin_points, s_points] = intersect(bdf.pos(:,1), t);
s = s(s_points);
x = bdf.pos(kin_points,[2 3]) - repmat(mean(bdf.pos(:, [2 3])), length(kin_points), 1);
kin_sigs = [x bdf.vel(kin_points,[2 3])];
kin_sigs = kin_sigs ./ repmat(var(kin_sigs), size(kin_sigs,1), 1);

% compute xcorr
out = zeros(2*num_lags+1, 4);
for sig = 1:4
    out(:,sig) = xcorr(kin_sigs(:,sig), s, num_lags, 'unbiased');
end

% return time signal
out_t = -bin*num_lags:bin:bin*num_lags;

if drawplot
    colors = {'r-', 'g-', 'b-', 'm-'};
    figure; hold on;
    for sig = 1:4
        plot(out_t, out(:,sig), colors{sig});
    end
    
    xcnorm = sqrt(sum(out.^2, 2));
    plot(out_t, xcnorm, 'k-');
    
    [p,n] = fileparts(bdf.meta.filename);
    title(sprintf('Cross Correlation\n%s | %d-%d', n, chan, unit));
    legend('X', 'Y', 'Vx', 'Vy', 'norm');
end


