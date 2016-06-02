function mod_amp = spike_mod_amp_from_MFR(MFR,ave_fr)
% this function uses as inputs
% spikerates : a [ num_target x num_spike_chan ] arrays of firing rates
%    (use >>> spikerates = mean_tgt_FR_isobox(binnedData,varargin)
% directions : the directions corresponding to each rows of spikerates
%
% this function calculates, for each target,
% mod_amp : the absolute difference between the meat firing rate in each
%           target (MFR) and each unit's baseline (ave_fr)

[n_tgt,n_chan]  = size(MFR);

mod_amp = nan(n_tgt, n_chan);




for n = 1:n_tgt
    mod_amp(i,:) = max(MFR(:,n))-min(MFR(:,n));
    
    t_PD = find(MFR(:,n)==max(MFR(:,n)));
    if length(t_PD)>1
        warning('spike chan %d has undetermined PD',n);
        t_PD = t_PD(1);
    end
    PT(n) = t_PD;
end