function fr = spikes2fr( s, t, k )
%SPIKES2CONT Converts spike train timestamps to continuous firing rates
%   Give a time series of firing rates of spikes s at time interval t
%
%   Returns r: The number of spikes in each bin
%

% t = 0:.001:5; % decide the time index on which to evaluate the firing rate
% k = 0.05;     % pick a smoothing parameter (in this case 50 ms)

% s = sort(randn(100,1)) + 2.5; % asign some random spike times 
fr = zeros(size(t));
for tau = s'
    fr = fr + (t-tau > 0) .* (t-tau) .* exp((tau-t)/k) / k^2;
end

