function c = get_spikes_corr(spikes,target_signals,varargin)
% Returns a (num_lags*2+1 x num_neurons x num_signals) array
% of the squared normalized covariance between
% each neuron in 'spikes' and each signal in 'target_signal'.
% 
%
%   spikes          : column-wise array of firing rates or spike count (MxNum_neur)
%   target_signals  : MxP array, with P signals to which we want to correlate with the spikes
%   varargins
%      [num_lags]   : number of lags over which to evaluate covariance
%
% 06/2014 Chris
%%

num_lags = 10;
if nargin >2
    num_lags = varargin{1};
end

num_neur_tot = size(spikes,2);
num_sig      = size(target_signals,2);

c = zeros(num_lags*2+1,num_neur_tot,num_sig); %covariance matrix

for n = 1:num_neur_tot
    for s = 1:num_sig
%         c(:,n,s) = xcov(spikes(:,n),target_signals(:,s),num_lags,'coef');
        c(:,n,s) = xcov(spikes(:,n),target_signals(:,s),num_lags,'biased').^2;
    end
end

