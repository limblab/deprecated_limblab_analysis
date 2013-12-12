function plot_PD_distr(pds,num_bins)
% plots distribution of PDs
pd_bin = linspace(-pi, pi*(1-2/num_bins), num_bins);
freq = hist(pds,pd_bin);

% plot polar pd distribution
h_pol = polar([pd_bin pd_bin(1)],[freq freq(1)],'b-');
set(h_pol,'LineWidth',3)