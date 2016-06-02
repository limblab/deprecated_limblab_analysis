function fr = spikes2FrMovAve( s, t, k )
%SPIKES2FRMOVAVE Converts spike train timestamps to continuous firing rates
%   Give a time series of firing rates of spikes s at time interval t
%
%   Returns r: The moving average firing rate 
%

% t = 0:.001:5; % decide the time index on which to evaluate the firing rate
% k = 0.05;     % pick a smoothing parameter (in this case 50 ms)


mask = ones(1,round(k/.001))/k;

s = round(s*1000)/1000;
t = round(t*1000)/1000;
[~,~,idx] = intersect(s,t);

spike_train = zeros(size(t));
spike_train(idx) = 1;

fr = conv(spike_train,mask,'same'); 
