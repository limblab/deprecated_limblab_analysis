function fr = spikes2fr( s, t, k )
%SPIKES2CONT Converts spike train timestamps to continuous firing rates
%   Give a time series of firing rates of spikes s at time interval t
%
%   Returns r: The number of spikes in each bin
%

% t = 0:.001:5; % decide the time index on which to evaluate the firing rate
% k = 0.05;     % pick a smoothing parameter (in this case 50 ms)

% s = sort(randn(100,1)) + 2.5; % asign some random spike times 

% fr = zeros(size(t));
% for tau = s'
%     fr = fr + (t-tau > 0) .* (t-tau) .* exp((tau-t)/k) / k^2;
% end

t_kernel = 0:mean(diff(t)):20*k;
kernel = (t_kernel > 0) .* (t_kernel).*exp((-t_kernel)/k)/k^2;

s = round(s*1000)/1000;
[~,~,idx] = intersect(s,t);

spike_train = zeros(size(t));
spike_train(idx) = 1;

fr = conv(spike_train,kernel,'full'); 
fr = fr(1:length(t));
