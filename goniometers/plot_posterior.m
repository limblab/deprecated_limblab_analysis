function [means, bins, errors, ni, Ti] = plot_posterior(signal, spiketrain)
% PLOT_POSTERIOR - Plots a posterior distribution of firing rate as a
%                  function  fo the specified signal
%
%   PLOT_POSTERIOR(SIGNAL, SPIKETRAIN) - Creates a histogram of firing rate 
%       as a function of SIGNAL divided into 8 bins.  SPIKETRAIN is the 
%       same length as signal and contains the number of spikes within each 
%       sample.

% $Id$

b = spiketrain;

sig_spike = signal(b == 1);

smax = max(signal);
smin = min(signal);
sstep = (smax - smin) / 8;
sbins = smin-sstep:sstep:smax+sstep;

n = hist(signal, sbins);
ns = hist(sig_spike, sbins);

rate = 1000 * ns ./ n;
rate_err = 1000 * sqrt(ns) ./ n;

errorbar(sbins(2:end-1), rate(2:end-1), rate_err(2:end-1), 'bo-');

means = rate(2:end-1);
bins = sbins(2:end-1);
errors = rate_err(2:end-1);
ni = ns(2:end-1);
Ti = n(2:end-1);


