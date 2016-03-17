function emg_pattern = time_varying_emg_pattern_default

tmp = load('/Users/christianethier/Dropbox/Adaptation/opt_emgs_default_E2F+traj.mat');
emg_pattern = tmp.opt_emgs;
