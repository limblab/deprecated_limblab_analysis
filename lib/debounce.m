function y = debounce(x, t)
% DEBOUNCE(X, T) will return a debounced event signal
%   Y = DEBOUNCE(X, T) takes the set of time stamps X and removes all
%   timestamps within T of the most previous timestamp, returning the new
%   list of timestamps with the short time duplicate events removed.
%
%   Example:
%       DEBOUNCE([.4 1.8 2 2.9 4 6.5 7 10], 1) will return:
%           [.4 1.8 4 6.5 10]

% $Id$

d = [+inf; diff(x)];
y = x(d >= t);
