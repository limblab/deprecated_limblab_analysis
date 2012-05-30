function [trial_table tc] = AT_trial_table(filename)
load(filename)

tc.trial_type = 1;
tc.t_trial_start = 2;
tc.t_ct_on = 3;
tc.t_stimuli_onset = 4;
tc.t_ct_hold_on = 5;
tc.t_ot_on = 6;
tc.t_trial_end = 7;
tc.result = 8;
tc.bump_direction = 9;
tc.bump_magnitude = 10;
tc.moving_dots_target_size = 11;
tc.moving_dots_coherence = 12;
tc.moving_dots_direction = 13;
tc.moving_dots_speed = 14;
tc.moving_dots_num_dots = 15;
tc.moving_dots_dot_radius = 16;
tc.moving_dots_movement_type = 17;
tc.training = 18;
tc.catch = 19;
tc.staircase_id = 20;
tc.bias_force_mag = 21;
tc.bias_force_dir = 22;
tc.bump_duration = 23;
tc.main_direction = 24;

databurst_version = bdf.databursts{1,2}(2);

start_trial_code = hex2dec('1E');
end_code = hex2dec('20');
reward_code = hex2dec('20');
abort_code = hex2dec('21');
fail_code = hex2dec('22');
incomplete_code = hex2dec('23');

ct_on_code = hex2dec('30');
ct_hold_code = hex2dec('A0');
ot_on_code = hex2dec('80');

bump_code = hex2dec('50');

start_time = bdf.databursts{1,1};
end_time = bdf.words(find(bitand(bdf.words(:,2),...
    repmat(hex2dec('F0'),size(bdf.words(:,2)),1))==end_code,1,'last'),1);
bdf.words = bdf.words(bdf.words(:,1)>start_time & bdf.words(:,1)<=end_time,:);
bdf.databursts = bdf.databursts([bdf.databursts{:,1}]<end_time,:);

trial_starts = [bdf.databursts{:,1}]';
trial_ends = bdf.words(bitand(bdf.words(:,2),repmat(hex2dec('F0'),size(bdf.words(:,2)),1))==end_code,1);
num_trials = size(trial_starts,1);

trial_table = nan(num_trials,length(fieldnames(tc)));
trial_table(:,tc.t_trial_start) = trial_starts;
trial_table(:,tc.t_trial_end) = trial_ends;

for iTrial = 1:num_trials
    temp_words = bdf.words(bdf.words(:,1)>trial_table(iTrial,tc.t_trial_start) &...
        bdf.words(:,1)<=trial_table(iTrial,tc.t_trial_end),:);
    for iWord = 1:size(temp_words,1)        
        switch temp_words(iWord,2)
            case ct_on_code
                column = tc.t_ct_on;                
            case ct_hold_code
                column = tc.t_ct_hold_on;
            case bump_code
                column = tc.t_stimuli_onset;
            case ot_on_code
                column = tc.t_ot_on;
            otherwise 
                column = [];
        end
        trial_table(iTrial,column) = temp_words(iWord,1);
    end
    trial_table(iTrial,tc.result) = temp_words(end,2);
end

for iTrial = 1:num_trials
    trial_table(iTrial,tc.trial_type) = bdf.databursts{iTrial,2}(15);
    trial_table(iTrial,tc.staircase_id) = bdf.databursts{iTrial,2}(16);
    trial_table(iTrial,tc.training) = bdf.databursts{iTrial,2}(17);        
    trial_table(iTrial,tc.catch) = bdf.databursts{iTrial,2}(18);
    trial_table(iTrial,tc.main_direction) = bytes2float(bdf.databursts{iTrial,2}(19:22));
    trial_table(iTrial,tc.bump_magnitude) = bytes2float(bdf.databursts{iTrial,2}(23:26));
    trial_table(iTrial,tc.bump_direction) = bytes2float(bdf.databursts{iTrial,2}(27:30));
    trial_table(iTrial,tc.bump_duration) = bytes2float(bdf.databursts{iTrial,2}(31:34));
    trial_table(iTrial,tc.moving_dots_target_size) = bytes2float(bdf.databursts{iTrial,2}(35:38));
    trial_table(iTrial,tc.moving_dots_coherence) = bytes2float(bdf.databursts{iTrial,2}(39:42));
    trial_table(iTrial,tc.moving_dots_direction) = bytes2float(bdf.databursts{iTrial,2}(43:46));
    trial_table(iTrial,tc.moving_dots_speed) = bytes2float(bdf.databursts{iTrial,2}(47:50));
    trial_table(iTrial,tc.moving_dots_num_dots) = bytes2float(bdf.databursts{iTrial,2}(51:54));
    trial_table(iTrial,tc.moving_dots_movement_type) = bytes2float(bdf.databursts{iTrial,2}(59:62));
    trial_table(iTrial,tc.bias_force_mag) = bytes2float(bdf.databursts{iTrial,2}(71:74));
    trial_table(iTrial,tc.bias_force_dir) = bytes2float(bdf.databursts{iTrial,2}(75:78));

end

save(filename,'trial_table','tc','-append')