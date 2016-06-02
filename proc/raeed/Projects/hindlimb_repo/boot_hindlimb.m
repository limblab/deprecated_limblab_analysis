%% boostrap hindlimb
num_sec = .25;
if isempty(gcp)
    parpool;
end

num_times = 30;

prct_tuned = zeros(num_times,1);
prct_changed = prct_tuned;
median_dPD = prct_tuned;

parfor i = 1:num_times
    [prct_tuned(i),prct_changed(i),median_dPD(i)] = run_hindlimb(num_sec);
end

%% plot boot
mean_prct_tuned = mean(prct_tuned)
mean_prct_changed = mean(prct_changed)
mean_median_dPD = mean(median_dPD)