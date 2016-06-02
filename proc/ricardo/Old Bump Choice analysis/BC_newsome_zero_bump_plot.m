function BC_newsome_zero_bump_plot(trial_table,bin_length)

bump_directions = unique(trial_table(:,6));

num_bins = floor(size(trial_table(trial_table(:,7)==0,:),1)/bin_length);
stim_succ_bin_dir1 = zeros(1,num_bins);
stim_succ_bin_dir2 = zeros(1,num_bins);
bump_succ_bin_dir1 = zeros(1,num_bins);
bump_succ_bin_dir2 = zeros(1,num_bins);

for i = 1:num_bins
    temp_trial_table = trial_table(trial_table(:,7)==0,:);
    temp_trial_table = temp_trial_table((i-1)*bin_length+1:i*bin_length,:);
    stim_succ_bin_dir1(i) = sum(temp_trial_table(:,6)==bump_directions(1) & temp_trial_table(:,3)==32 & temp_trial_table(:,8)==0)/...
        sum(temp_trial_table(:,6)==bump_directions(1) & temp_trial_table(:,8)==0);
    stim_succ_bin_dir2(i) = sum(temp_trial_table(:,6)==bump_directions(2) & temp_trial_table(:,3)==32 & temp_trial_table(:,8)==0)/...
        sum(temp_trial_table(:,6)==bump_directions(2) & temp_trial_table(:,8)==0);
    bump_succ_bin_dir1(i) = sum(temp_trial_table(:,6)==bump_directions(1) & temp_trial_table(:,3)==32 & temp_trial_table(:,8)==-1)/...
        sum(temp_trial_table(:,6)==bump_directions(1) & temp_trial_table(:,8)==-1);
    bump_succ_bin_dir2(i) = sum(temp_trial_table(:,6)==bump_directions(2) & temp_trial_table(:,3)==32 & temp_trial_table(:,8)==-1)/...
        sum(temp_trial_table(:,6)==bump_directions(2) & temp_trial_table(:,8)==-1);
end

stim_succ_bin = mean([stim_succ_bin_dir1;1-stim_succ_bin_dir2]);
bump_succ_bin = mean([bump_succ_bin_dir1;1-bump_succ_bin_dir2]);

figure; 
plot(bin_length/2:bin_length:num_bins*bin_length,bump_succ_bin,'r')
hold on
plot(bin_length/2:bin_length:num_bins*bin_length,stim_succ_bin,'b')
legend('Bumps','Bump+stim')
xlabel('Trial number')
title(['Probability of moving towards target at ' num2str(180*(bump_directions(1)+pi)/pi,3) 'deg with 0 magnitude bump'])
