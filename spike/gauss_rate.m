function rate = gauss_rate(b, window)
% GAUSS_RATE - Returns the firing rate of pulse train
%   GAUSS_RATE(B, WINDOW) - B is the pulse train
%                         - WINDOW is the width over which to smooth

% $Id$

x = -3*window:3*window;
g = normpdf(x, 0, window);

rate = conv(g, b);
rate = circshift(rate', -3*window);
rate = rate(1:length(b));
