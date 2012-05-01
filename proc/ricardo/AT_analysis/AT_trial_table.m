function [trial_table tc] = AT_trial_table(filename)
load(filename)

tc.trial_type = 1;
tc.t_trial_start = 2;
tc.t_ct_on = 3;
tc.t_visual_1_onset = 4;
tc.t_bump_1_onset = 5;
tc.t_visual_2_onset = 6;
tc.t_bump_2_onset = 7;
tc.t_ot_on = 8;
tc.t_trial_end = 9;
tc.result = 10;
tc.bump_direction = 11;
tc.bump_1_magnitude = 12;
tc.bump_2_magnitude = 13;
tc.visual_1_diameter = 14;
tc.visual_2_diameter = 15;
tc.training = 16;
tc.catch = 17;
tc.staircase_id = 18;
tc.bias_force_mag = 19;
tc.bias_force_dir = 20;
tc.bump_duration = 21;

databurst_version = bdf.databursts{1,2}(2);

start_trial_code = hex2dec('1E');
end_code = hex2dec('20');
reward_code = hex2dec('20');
abort_code = hex2dec('21');
fail_code = hex2dec('22');
incomplete_code = hex2dec('23');

ct_on_code = hex2dec('30');
ct_hold_code = hex2dec('A0');
ot_on_code = hex2dec('40');

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
            case ot_on_code+1
                column = tc.t_visual_1_onset;
            case bump_code+1
                column = tc.t_bump_1_onset;
            case ot_on_code+2
                column = tc.t_visual_2_onset;
            case bump_code+2
                column = tc.t_bump_2_onset;
            case ot_on_code+3
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
    trial_table(iTrial,tc.bump_1_magnitude) = bytes2float(bdf.databursts{iTrial,2}(19:22));
    trial_table(iTrial,tc.bump_2_magnitude) = bytes2float(bdf.databursts{iTrial,2}(23:26));
    trial_table(iTrial,tc.bump_direction) = bytes2float(bdf.databursts{iTrial,2}(27:30));
    trial_table(iTrial,tc.bump_duration) = bytes2float(bdf.databursts{iTrial,2}(31:34));
    trial_table(iTrial,tc.visual_1_diameter) = 2*bytes2float(bdf.databursts{iTrial,2}(35:38));
    trial_table(iTrial,tc.visual_2_diameter) = 2*bytes2float(bdf.databursts{iTrial,2}(39:42));
    trial_table(iTrial,tc.bias_force_mag) = bytes2float(bdf.databursts{iTrial,2}(55:58));
    trial_table(iTrial,tc.bias_force_dir) = bytes2float(bdf.databursts{iTrial,2}(59:62));

end

save(filename,'trial_table','tc','-append')