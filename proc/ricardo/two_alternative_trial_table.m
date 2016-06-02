% Build trial_table
% trial_table = 
%[ cursor_on_ct start end result bump_direction bump_magnitude stim_id Xstart Ystart Xend Yend; ... ] for each trial
% trial type = 1 (bump), 2 (stim)

function [trial_table , table_columns] = two_alternative_trial_table(filename)
load(filename, 'bdf')
databurst_version = bdf.databursts{1,2}(2);
start_trial_code = hex2dec('1D');
reward_code = hex2dec('20');
abort_code = hex2dec('21');
fail_code = hex2dec('22');
incomplete_code = hex2dec('23');
bump_code = hex2dec('50');
stim_code = hex2dec('60');
ct_on_code = hex2dec('30');
go_cue_code = hex2dec('31');

col_num = 1;
%timing
table_columns.ct_on = col_num; col_num = col_num+1;
table_columns.interval_1_start = col_num; col_num = col_num+1;
table_columns.interval_1_stim_start = col_num; col_num = col_num+1;
table_columns.interval_1_stim_end = col_num; col_num = col_num+1;
table_columns.interval_2_start = col_num; col_num = col_num+1;
table_columns.interval_2_stim_start = col_num; col_num = col_num+1;
table_columns.interval_2_stim_end = col_num; col_num = col_num+1;
table_columns.movement_start = col_num; col_num = col_num+1;
table_columns.trial_end = col_num; col_num = col_num+1;

% trial details
table_columns.result = col_num; col_num = col_num+1;
table_columns.training = col_num; col_num = col_num+1;
table_columns.first_target = col_num; col_num = col_num+1;

%stim details
table_columns.interval_1_bump_magnitude = col_num; col_num = col_num+1;
table_columns.interval_1_bump_direction = col_num; col_num = col_num+1;
table_columns.interval_1_stim_code = col_num; col_num = col_num+1;
table_columns.interval_2_bump_magnitude = col_num; col_num = col_num+1;
table_columns.interval_2_bump_direction = col_num; col_num = col_num+1;
table_columns.interval_2_stim_code = col_num;

%databurst indices
db_training = 7;
db_first_target = 16;
db_target_size = 17:20;
db_stim_delay = 21:24;
db_bump_duration_1 = 25:28;
db_bump_duration_2 = 29:32;
db_stim_code_1 = 33:36;
db_stim_code_2 = 37:40;
db_bump_mag_1 = 41:44;
db_bump_mag_2 = 45:48;
db_bump_dir_1 = 49:52;
db_bump_dir_2 = 53:56;

bdf.words = bdf.words(find(bdf.words(:,1)>bdf.databursts{1} & bitand(bdf.words(:,2),hex2dec('f0'))==hex2dec('10'),1,'first'):...
    find(bitand(bdf.words(:,2),hex2dec('f0'))==hex2dec('20'),1,'last'),:);

% hack to remove stim codes from bdf.words, we can get them from databurst
bdf.words = bdf.words(bitand(bdf.words(:,2),hex2dec('60'))~=hex2dec('60'),:);

results = bdf.words(bitand(bdf.words(:,2),hex2dec('F0'))==hex2dec('20'),:);
trial_table = nan(length(results),col_num);
trial_table(:,[table_columns.trial_end table_columns.result]) = results;
trial_starts = bdf.words(bitand(bdf.words(:,2),hex2dec('f0'))==hex2dec('10'),1);

valid_dbs = ([bdf.databursts{:,1}]-trial_starts(1,1) > -.5 & [bdf.databursts{:,1}]-trial_starts(end,1) < 0.002);
bdf.databursts = bdf.databursts(valid_dbs,:);

ct_on = bdf.words(bdf.words(:,2) == ct_on_code,1);
interval_starts = nan(length(ct_on),3);
stim_time = nan(length(ct_on),2);
bump_end = nan(length(ct_on),2);

for i=1:length(ct_on)    
    stim_delay = bytes2float(bdf.databursts{i,2}(db_stim_delay));
    bump_length(1) = bytes2float(bdf.databursts{i,2}(db_bump_duration_1));
    bump_length(2) = bytes2float(bdf.databursts{i,2}(db_bump_duration_2));
    trial_table(i,[table_columns.interval_1_bump_direction, table_columns.interval_1_bump_magnitude,...
        table_columns.interval_2_bump_direction, table_columns.interval_2_bump_magnitude]) =...
            bytes2float(bdf.databursts{i,2}([db_bump_dir_1 db_bump_mag_1,...
            db_bump_dir_2 db_bump_mag_2]));
    trial_table(i,[table_columns.interval_1_stim_code table_columns.interval_2_stim_code]) =...
        bytes2float(bdf.databursts{i,2}([db_stim_code_1 db_stim_code_2]));
    trial_table(i,table_columns.training) = bdf.databursts{i,2}(db_training);
    trial_table(i,table_columns.first_target) = bdf.databursts{i,2}(db_first_target);
    bump_length = bump_length/1000;
    word_idx = find(bdf.words(:,1)==ct_on(i));
    for j=1:3        
        if (length(bdf.words)>=word_idx+j)
            if bdf.words(word_idx+j,2)==go_cue_code
                interval_starts(i,j) = bdf.words(word_idx+j,1);
                if j<3
                    stim_time(i,j) = bdf.words(word_idx+j,1)+stim_delay;
                    bump_end(i,j) = stim_time(i,j)+bump_length(j);
                end
            end
        end
    end
end

trial_table(:,table_columns.ct_on) = ct_on;
trial_table(:,table_columns.interval_1_start) = interval_starts(:,1);
trial_table(:,table_columns.interval_1_stim_start) = stim_time(:,1);
trial_table(:,table_columns.interval_1_stim_end) = bump_end(:,1);

trial_table(:,table_columns.interval_2_start) = interval_starts(:,2);
trial_table(:,table_columns.interval_2_stim_start) = stim_time(:,2);
trial_table(:,table_columns.interval_2_stim_end) = bump_end(:,2);

trial_table(:,table_columns.movement_start) = interval_starts(:,3);

return
% for i=1:length(trial_starts)-1
%     if trial_starts(i+1,1)<bump_times(i,1) || trial_starts(i,2)==abort_code
%         bump_times = [bump_times(1:i-1,:) ; [0 0] ; bump_times(i:end,:)];
%     end
% end
