function [vsum,N] = plot_modamp_from_binned_WF(binnedData)
% wrapper function to plot vector sum of modulation amplitude across
% spike channels for every target

[MTF] = mean_tgt_FR_isobox(binnedData);
[mod_amp, PT] = spike_tunning_from_MFR(MTF);
[vsum,N] = plot_modamp_vsum(mod_amp,PT);