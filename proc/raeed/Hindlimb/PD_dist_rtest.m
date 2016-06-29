%% rayleigh test the PD distribution

% first double the angles because the distribution looks bimodal
PD_distr_double = remove_wrap(2*yupd);

% Rayleigh test
[pval_rtest,z_rtest] = circ_rtest(PD_distr_double)