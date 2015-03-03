function [vsum,N] = plot_modamp_vsum(mod_amp,PT)
% mod_am, PT are modulation amplitude and preferred target
% obtained from calling [mod_amp, PT] = spike_tunning_from_MFR(spikerates)


vsum = zeros(8,1);
N    = zeros(8,1);
figure; hold on;

x_factor = cosd(0:45:360);
y_factor = sind(0:45:360);

for tgt = 1:8
    N(tgt)    = sum(PT==tgt);
    vsum(tgt) = sum(mod_amp(PT==tgt));
    vx = x_factor(tgt)*vsum(tgt);
    vy = y_factor(tgt)*vsum(tgt);
    plot([0 vx], [0 vy],'b-o');
    text(vx,vy,[' N = ' num2str(N(tgt))]);
end
axis equal;
pretty_fig(gca);
title(sprintf('sum of modulation amplitude for all spike channels\n with corresponding preferred target'));