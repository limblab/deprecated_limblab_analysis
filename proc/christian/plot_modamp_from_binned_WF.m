function [vsum,N] = plot_modamp_from_binned_WF(binnedData)
% wrapper function to plot vector sum of modulation amplitude across
% spike channels for every target

[MTF] = mean_tgt_FR_isobox(binnedData);
[mod_amp, PT] = spike_tunning_from_MFR(MTF(2:end,:));
[vsum,N] = plot_modamp_vsum(mod_amp,PT);

% or we can define the modulation amplitude for each target as the sum of
% the deviation from baseline (ave_fr) of each unit's mean firing rate
mod_amp = MTF(2:end,:)-repmat(MTF(1,:),8,1);
