function [trial_table tc] = AT_trial_table(filename)
load(filename)

databurst_version = zeros(size(bdf.databursts,1),1);
for iDataburst = 1:size(bdf.databursts,1)
    databurst_version(iDataburst) = bdf.databursts{iDataburst,2}(2);
    databurst_length(iDataburst) = length(bdf.databursts{iDataburst,2});
end
databurst_version = mode(databurst_version);
databurst_length = mode(databurst_length);

tc.trial_type = 1;
tc.t_trial_start = 2;
tc.t_ct_on = 3;
tc.t_ct_hold_on = 4;
tc.t_stimuli_onset = 5;
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
tc.x_offset = 25;
tc.y_offset = 26;

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
% trial_table(:,tc.t_trial_end) = trial_ends;

for iTrial = 1:num_trials
    temp_words = bdf.words(find(bdf.words(:,1)>trial_table(iTrial,tc.t_trial_start),1,'first'):...
        find(bdf.words(:,1)==trial_ends(find(trial_ends>trial_table(iTrial,tc.t_trial_start),1,'first'))),:);
    
%     temp_words = bdf.words(bdf.words(:,1)>trial_table(iTrial,tc.t_trial_start) &...
%         bdf.words(:,1)<=trial_table(iTrial,tc.t_trial_end),:);
    for iWord = 1:size(temp_words,1)   
        if bitand(temp_words(iWord,2),hex2dec('F0'))==end_code
            temp_words_end = 1;
        else
            temp_words_end = 0;
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
        end        
        
        if temp_words_end
            column = tc.t_trial_end;
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
    trial_table(iTrial,tc.moving_dots_dot_radius) = bytes2float(bdf.databursts{iTrial,2}(55:58));
    trial_table(iTrial,tc.moving_dots_movement_type) = bytes2float(bdf.databursts{iTrial,2}(59:62));
    trial_table(iTrial,tc.bias_force_mag) = bytes2float(bdf.databursts{iTrial,2}(71:74));
    trial_table(iTrial,tc.bias_force_dir) = bytes2float(bdf.databursts{iTrial,2}(75:78));
    trial_table(iTrial,tc.x_offset) = bytes2float(bdf.databursts{iTrial,2}(7:10));
    trial_table(iTrial,tc.y_offset) = bytes2float(bdf.databursts{iTrial,2}(11:14));
end

remove_index = [];
remove_index = find(isnan(trial_table(:,tc.x_offset)) | isnan(trial_table(:,tc.t_ct_on)));
for iCol = 9:length(fieldnames(tc))    
    temp = find((trial_table(:,iCol) ~= 0 & abs(trial_table(:,iCol))<1e-10) | abs(trial_table(:,iCol))>1e10);
    remove_index = [remove_index temp'];
end
remove_index = unique(remove_index);
trial_table(remove_index,:) = [];

% remove_index = [];
% for iCol=[9 10 11 12 13 14 15 16 17 21 22 23 24 25 26]
% % for iCol = [1 2]
%     [tempa tempb] = hist(log(trial_table(:,iCol)),1000);
%     cumsum_temp = cumsum(tempa/sum(tempa));
%     remove_under = tempb(find(cumsum_temp<0.02,1,'last'));
%     if ~isempty(remove_under)
%         remove_under_idx = find(trial_table(:,iCol)<remove_under);
%         if length(remove_under_idx)/size(trial_table,1)<0.02
%             remove_index = [remove_index find(trial_table(:,iCol)<remove_under)'];
%         end
%     end
%     remove_above = tempb(find(cumsum_temp>0.98,1,'first'));
%     if ~isempty(remove_above)
%         remove_above_idx = find(trial_table(:,iCol)>remove_above);
%         if length(remove_above_idx)/size(trial_table,1)<0.02
%             remove_index = [remove_index find(trial_table(:,iCol)>remove_above)'];
%         end
%     end
%     
%     temp = find(trial_table(:,iCol) ~= 0 & abs(trial_table(:,iCol))<1e-10);
%     remove_index = [remove_index temp];
% end
% remove_index = unique(remove_index);
% trial_table(remove_index,:) = [];

save(filename,'trial_table','tc','-append')