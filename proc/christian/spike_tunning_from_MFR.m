function [mod_amp, PT] = spike_tunning_from_MFR(spikerates)
% this function uses as inputs
% spikerates : a [ num_target x num_spike_chan ] arrays of firing rates
%    (use >>> spikerates = mean_tgt_FR_isobox(binnedData,varargin)
% directions : the directions corresponding to each rows of spikerates
%
% this function calculates, for each spike channel,
% mod_amp : the modulation amplitude difference between max and min FR
% PT      : the target index with max FR, or "preferred target"

n_chan  = size(spikerates,2);

mod_amp = nan(1,n_chan);
PT      = nan(1,n_chan);

for n = 1:n_chan
    mod_amp(n) = max(spikerates(:,n))-min(spikerates(:,n));
    
    t_PD = find(spikerates(:,n)==max(spikerates(:,n)));
    if length(t_PD)>1
        warning('spike chan %d has undetermined PD',n);
        t_PD = t_PD(1);
    end
    PT(n) = t_PD;
end