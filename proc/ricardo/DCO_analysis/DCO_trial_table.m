function [trial_table,tc,bdf] = DCO_trial_table(bdf)

databurst_version_temp = zeros(size(bdf.databursts,1),1);
databurst_length_temp = zeros(size(bdf.databursts,1),1);
for iDataburst = 1:size(bdf.databursts,1)
    databurst_length_temp(iDataburst) = length(bdf.databursts{iDataburst,2});
    if databurst_length_temp(iDataburst) > 1
        databurst_version_temp(iDataburst) = bdf.databursts{iDataburst,2}(2);
    else
        databurst_version_temp(iDataburst) = -1;
    end
end
databurst_version = mode(databurst_version_temp);
databurst_length = mode(databurst_length_temp);

bdf.databursts(databurst_version_temp~=databurst_version | databurst_length_temp~=databurst_length,:) = [];

iCol = 1;
tc.t_trial_start = iCol; iCol=iCol+1;
tc.t_ct_on = iCol; iCol=iCol+1;
tc.t_ct_hold_on = iCol; iCol=iCol+1;
tc.t_go_cue = iCol; iCol=iCol+1;
tc.t_movement_start = iCol; iCol=iCol+1;
tc.t_ot_first_hold = iCol; iCol=iCol+1;
tc.t_ot_last_hold = iCol; iCol=iCol+1;
tc.t_trial_end = iCol; iCol=iCol+1;
tc.result = iCol; iCol=iCol+1;
tc.x_offset = iCol; iCol=iCol+1;
tc.y_offset = iCol; iCol=iCol+1;
tc.outer_target_direction = iCol; iCol=iCol+1;
tc.outer_target_radius = iCol; iCol=iCol+1;
tc.outer_target_span = iCol; iCol=iCol+1;
tc.outer_target_thickness = iCol; iCol=iCol+1;
tc.outer_target_stiffness = iCol; iCol=iCol+1;
tc.target_force = iCol; iCol=iCol+1;
tc.target_force_range = iCol; iCol=iCol+1;
tc.cursor_radius = iCol; iCol=iCol+1;
tc.brain_control = iCol; iCol=iCol+1;

start_trial_code = hex2dec('1F');
end_code = hex2dec('20');
reward_code = hex2dec('20');
abort_code = hex2dec('21');
fail_code = hex2dec('22');
incomplete_code = hex2dec('23');

ct_on_code = hex2dec('30');
ct_hold_code = hex2dec('A0');
movement_code = hex2dec('80');
ot_hold_code = hex2dec('A1');

remove_databurst = [];
bdf.words = bdf.words(1:find(bdf.words(:,1)<bdf.force(end,1),1,'last'),:);  % Remove last partial second
bdf.databursts = bdf.databursts(1:find([bdf.databursts{:,1}]<bdf.force(end,1),1,'last'),:);
bdf.words = bdf.words(bdf.words(:,1)>1,:);
bdf.databursts = bdf.databursts([bdf.databursts{:,1}]>1,:);
if ~isempty(bdf.words(find(diff(bdf.words(:,1))<0,1,'last'),1))
    bdf.databursts = bdf.databursts(find([bdf.databursts{:,1}] < bdf.words(find(diff(bdf.words(:,1))<0,1,'last'),1),1,'last'):end,:);
    bdf.words = bdf.words(find(diff(bdf.words(:,1))<0,1,'last')+1:end,:);
end
start_time = bdf.databursts{1,1};
end_time = bdf.words(find(bitand(bdf.words(:,2),...
    repmat(hex2dec('F0'),size(bdf.words(:,2)),1))==end_code,1,'last'),1);
bdf.words = bdf.words(bdf.words(:,1)>=start_time & bdf.words(:,1)<=end_time,:);

bdf.databursts = bdf.databursts([bdf.databursts{:,1}]>=start_time & [bdf.databursts{:,1}]<end_time,:);

trial_starts = [bdf.databursts{:,1}]';
num_trials = size(trial_starts,1);

trial_table = nan(num_trials,length(fieldnames(tc)));
trial_table(:,tc.t_trial_start) = trial_starts;

for iTrial = 1:num_trials
    temp_words = bdf.words(bdf.words(:,1)>trial_table(iTrial,tc.t_trial_start),:);
    iWord = 1;
    current_word = temp_words(iWord,2);
    flag_mov = 0;
    flag_ot = 0;
    skip_this = 0;
    while(current_word~=start_trial_code)
        switch temp_words(iWord,2)             
            case ct_on_code
                column = tc.t_ct_on;
            case ct_hold_code
                column = tc.t_ct_hold_on;
            case movement_code
                if ~flag_mov
                    column = tc.t_go_cue; 
                else
                    skip_this = 1;
                end
                flag_mov = 1;                
            case ot_hold_code
                if ~flag_ot
                    column = [tc.t_ot_first_hold tc.t_ot_last_hold];
                else
                    column = tc.t_ot_last_hold;
                end
                flag_ot = 1;
            case reward_code
                column = tc.t_trial_end; 
                trial_table(iTrial,tc.result) = temp_words(iWord,2);
            case abort_code
                column = tc.t_trial_end; 
                trial_table(iTrial,tc.result) = temp_words(iWord,2);
            case incomplete_code
                column = tc.t_trial_end; 
                trial_table(iTrial,tc.result) = temp_words(iWord,2);
            case fail_code
                column = tc.t_trial_end; 
                trial_table(iTrial,tc.result) = temp_words(iWord,2);
            otherwise 
                column = [];
        end
        if ~skip_this
            trial_table(iTrial,column) = temp_words(iWord,1);        
        end
        skip_this = 0;
        iWord = iWord + 1;
        if (iTrial == num_trials && iWord > size(temp_words,1))
            break
        end
        current_word = temp_words(iWord,2);
    end
end

for iTrial = 1:num_trials
    if length(bdf.databursts{iTrial,2})==databurst_length
        temp_idx = 7:10;
        trial_table(iTrial,tc.x_offset) = bytes2float(bdf.databursts{iTrial,2}(temp_idx)); temp_idx = temp_idx+4;
        trial_table(iTrial,tc.y_offset) = bytes2float(bdf.databursts{iTrial,2}(temp_idx)); temp_idx = temp_idx+4;
        trial_table(iTrial,tc.outer_target_direction) = bytes2float(bdf.databursts{iTrial,2}(temp_idx)); temp_idx = temp_idx+4;
        trial_table(iTrial,tc.outer_target_radius) = bytes2float(bdf.databursts{iTrial,2}(temp_idx)); temp_idx = temp_idx+4;
        trial_table(iTrial,tc.outer_target_span) = bytes2float(bdf.databursts{iTrial,2}(temp_idx)); temp_idx = temp_idx+4;
        trial_table(iTrial,tc.outer_target_thickness) = bytes2float(bdf.databursts{iTrial,2}(temp_idx)); temp_idx = temp_idx+4;
        trial_table(iTrial,tc.outer_target_stiffness) = bytes2float(bdf.databursts{iTrial,2}(temp_idx)); temp_idx = temp_idx+4;
        trial_table(iTrial,tc.target_force) = bytes2float(bdf.databursts{iTrial,2}(temp_idx)); temp_idx = temp_idx+4;
        trial_table(iTrial,tc.target_force_range) = bytes2float(bdf.databursts{iTrial,2}(temp_idx)); temp_idx = temp_idx+4;
        trial_table(iTrial,tc.cursor_radius) = bytes2float(bdf.databursts{iTrial,2}(temp_idx)); temp_idx = temp_idx+4;
        trial_table(iTrial,tc.brain_control) = bdf.databursts{iTrial,2}(temp_idx(1)); temp_idx = temp_idx+1;
    end        
end

trial_table(:,tc.outer_target_direction) = round(180/pi*trial_table(:,tc.outer_target_direction))*pi/180;

remove_idx = find(isnan(trial_table(:,tc.t_trial_start)) |...
    isnan(trial_table(:,tc.t_ct_on)) |...
    isnan(trial_table(:,tc.t_ct_hold_on)) |...
    isnan(trial_table(:,tc.t_trial_end)) |...
    isnan(trial_table(:,tc.t_go_cue)));

remove_index = [remove_idx(:) find(isnan(trial_table(:,tc.x_offset)))];
for iCol = 7:length(fieldnames(tc))    
    temp = find((trial_table(:,iCol) ~= 0 & abs(trial_table(:,iCol))<1e-10) | abs(trial_table(:,iCol))>1e10);
    remove_index = [remove_index(:); temp(:)];
end
remove_index = unique(remove_index);

trial_table(remove_index,:) = [];
disp(['Removed ' num2str(length(remove_index)) ' trial(s) out of ' num2str(size(trial_table,1)+length(remove_index)) ' because one or more words were corrupted.'])

