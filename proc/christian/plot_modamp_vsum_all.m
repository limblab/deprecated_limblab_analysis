function [vsum,N] = plot_modamp_vsum_all(mod_amp)
% mod_amp,is modulation amplitude
% obtained from calling [mod_amp, PT] = spike_tunning_from_MFR(spikerates)
% this plots sum of modulation amplitude, using all units for all tgts

vsum    = zeros(8,1);
n_units = size(mod_amp,2);
figure; hold on;

x_factor = cosd(0:45:360);
y_factor = sind(0:45:360);

vsum = sum(abs(mod_amp),2);

for tgt = 1:8
    vsum(tgt) = sum(abs(mod_amp(tgt,:)));
    vx = x_factor(tgt)*vsum(tgt);
    vy = y_factor(tgt)*vsum(tgt);
    plot([0 vx], [0 vy],'b-o');
    text(vx,vy,[' N = ' num2str(N(tgt))]);
end
axis equal;
pretty_fig(gca);
title(sprintf('sum of modulation amplitude for all spike channels\n with corresponding preferred target'));