function y = von_mises(alpha, mu, kappa)
% VON_MISES - the circular normal distribution
%   Y = VON_MISES(ALPHA, MU, KAPPA) gives the value at angle ALPHA of the 
%   von Mises function having mean MU and dispersion KAPPA

if ~isscalar(mu)
    error('MU must be scalar');
end

if ~isscalar(kappa)
    error('KAPPA must be scalar');
end

y = exp(kappa * cos(alpha - mu)) / (2 * pi * besseli(0, kappa));
