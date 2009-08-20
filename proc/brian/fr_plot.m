function fr_plot(bdf, chan, unit)
% fr_plot.m

% Plots the firing rate of a neuron both from the model and the observed
% fring rate in a limbstate (speed/direction) space

th = 0:pi/4:2*pi;
sp = 0:5:25;

[TH, SP] = meshgrid(th, sp);
