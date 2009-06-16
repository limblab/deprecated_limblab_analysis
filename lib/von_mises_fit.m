function [mu, kappa] = von_mises_fit(alpha)
% VON_MISES_FIT - fits a von Mises distribution to the samle
%   [MU, KAPPA] = VON_MISES_FIT(ALPHA) returns MU and KAPPA from the von
%   Mises distribution that best fits the set of circular observations
%   contained in ALPHA.

x = cos(alpha);
y = sin(alpha);

mu = atan2( sum(y), sum(x) );

R = sum(cos(mu-alpha));
V = R/length(alpha);

Ak = @(k) (besseli(1,k)/besseli(0,k) - V).^2;

kappa = fminsearch(Ak, 1);
