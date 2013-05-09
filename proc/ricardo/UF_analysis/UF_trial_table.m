function [trial_table tc] = UF_trial_table(bdf)

databurst_version_temp = zeros(size(bdf.databursts,1),1);
databurst_length_temp = zeros(size(bdf.databursts,1),1);
for iDataburst = 1:size(bdf.databursts,1)
    databurst_length_temp(iDataburst) = length(bdf.databursts{iDataburst,2});
    if databurst_length_temp(iDataburst)~=0
        databurst_version_temp(iDataburst) = bdf.databursts{iDataburst,2}(2);
    else
        databurst_version_temp(iDataburst) = -1;
    end
end
databurst_version = mode(databurst_version_temp);
databurst_length = mode(databurst_length_temp);

bdf.databursts(databurst_version_temp~=databurst_version | databurst_length_temp~=databurst_length,:) = [];
if databurst_version == 2
    databurst_length = 50;
end

iCol = 1;
tc.t_trial_start = iCol; iCol=iCol+1;
tc.t_field_buildup = iCol; iCol=iCol+1;
tc.t_ct_hold_on = iCol; iCol=iCol+1;
tc.t_bump_onset = iCol; iCol=iCol+1;
tc.t_trial_end = iCol; iCol=iCol+1;
tc.result = iCol; iCol=iCol+1;
tc.bump_direction = iCol; iCol=iCol+1;
if databurst_version >= 3
    tc.bump_velocity = iCol; iCol=iCol+1;
else
    tc.bump_magnitude = iCol; iCol=iCol+1;
end
if databurst_version >= 1
    tc.bump_duration = iCol; iCol=iCol+1;
end
tc.field_orientation = iCol; iCol=iCol+1;
tc.negative_stiffness = iCol; iCol=iCol+1;
tc.positive_stiffness = iCol; iCol=iCol+1;
tc.bias_force_mag = iCol; iCol=iCol+1;
tc.bias_force_dir = iCol; iCol=iCol+1;
tc.x_offset = iCol; iCol=iCol+1;
tc.y_offset = iCol; iCol=iCol+1;
if databurst_version >= 2
    tc.force_target_diameter = iCol; iCol=iCol+1;
end

start_trial_code = hex2dec('1F');
end_code = hex2dec('20');
reward_code = hex2dec('20');
abort_code = hex2dec('21');
incomplete_code = hex2dec('22');
field_buildingup_code = hex2dec('31');

ct_on_code = hex2dec('30');
ct_hold_code = hex2dec('A0');

bump_code = hex2dec('50');
remove_databurst = [];

if ~isempty(bdf.words(find(diff(bdf.words(:,1))<0,1,'last'),1))
    bdf.databursts = bdf.databursts(find([bdf.databursts{:,1}] < bdf.words(find(diff(bdf.words(:,1))<0,1,'last'),1),1,'last'):end,:);
    bdf.words = bdf.words(find(diff(bdf.words(:,1))<0,1,'last')+1:end,:);
end
% start_time = bdf.words(find(bdf.words(:,2)==start_trial_code ,1,'first'),1);
start_time = bdf.databursts{1,1};
end_time = bdf.words(find(bitand(bdf.words(:,2),...
    repmat(hex2dec('F0'),size(bdf.words(:,2)),1))==end_code,1,'last'),1);
bdf.words = bdf.words(bdf.words(:,1)>=start_time & bdf.words(:,1)<=end_time,:);
% start_end_words = bdf.words(bdf.words(:,2)>=31 & bdf.words(:,2)<=34,:);
% repeated_words = find(diff(start_end_words(:,2))==0);
% for iWord = 1:length(repeated_words)    
%     bdf.words(find(bdf.words(:,1)==start_end_words(repeated_words(iWord),1)),:) = [];
% end

bdf.databursts = bdf.databursts([bdf.databursts{:,1}]>=start_time & [bdf.databursts{:,1}]<end_time,:);

trial_starts = [bdf.databursts{:,1}]';
% trial_ends = bdf.words(bitand(bdf.words(:,2),repmat(hex2dec('F0'),size(bdf.words(:,2)),1))==end_code,1);
% trial_starts = trial_starts(1:length(trial_ends));
num_trials = size(trial_starts,1);

trial_table = nan(num_trials,length(fieldnames(tc)));
trial_table(:,tc.t_trial_start) = trial_starts;
% trial_table(:,tc.t_trial_end) = trial_ends; 

for iTrial = 1:num_trials
    temp_words = bdf.words(bdf.words(:,1)>trial_table(iTrial,tc.t_trial_start),:);
    iWord = 1;
    current_word = temp_words(iWord,2);
    while(current_word~=start_trial_code)
        switch temp_words(iWord,2)  
            case field_buildingup_code
                column = tc.t_field_buildup;
            case ct_hold_code
                column = tc.t_ct_hold_on;
            case bump_code
                column = tc.t_bump_onset;
            case reward_code
                column = tc.t_trial_end; 
                trial_table(iTrial,tc.result) = temp_words(iWord,2);
            case abort_code
                column = tc.t_trial_end; 
                trial_table(iTrial,tc.result) = temp_words(iWord,2);
            case incomplete_code
                column = tc.t_trial_end; 
                trial_table(iTrial,tc.result) = temp_words(iWord,2);
            otherwise 
                column = [];
        end
        trial_table(iTrial,column) = temp_words(iWord,1);
        if iTrial == num_trials
            break
        end
        iWord = iWord + 1;
        current_word = temp_words(iWord,2);
    end
%     trial_table(iTrial,tc.result) = temp_words(end,2);
end

% for iTrial = 1:num_trials
%     temp_words = bdf.words(bdf.words(:,1)>trial_table(iTrial,tc.t_trial_start) &...
%         bdf.words(:,1)<=trial_table(iTrial,tc.t_trial_end),:);
%     for iWord = 1:size(temp_words,1)        
%         switch temp_words(iWord,2)  
%             case field_buildingup_code
%                 column = tc.t_field_buildup;
%             case ct_hold_code
%                 column = tc.t_ct_hold_on;
%             case bump_code
%                 column = tc.t_bump_onset;
%             otherwise 
%                 column = [];
%         end
%         trial_table(iTrial,column) = temp_words(iWord,1);
%     end
%     trial_table(iTrial,tc.result) = temp_words(end,2);
% end

for iTrial = 1:num_trials
    if length(bdf.databursts{iTrial,2})==databurst_length
        temp_idx = 7:10;
        trial_table(iTrial,tc.x_offset) = bytes2float(bdf.databursts{iTrial,2}(temp_idx)); temp_idx = temp_idx+4;
        trial_table(iTrial,tc.y_offset) = bytes2float(bdf.databursts{iTrial,2}(temp_idx)); temp_idx = temp_idx+4;
        if databurst_version <= 2
            trial_table(iTrial,tc.bump_magnitude) = bytes2float(bdf.databursts{iTrial,2}(temp_idx)); temp_idx = temp_idx+4;
        else
            trial_table(iTrial,tc.bump_velocity) = bytes2float(bdf.databursts{iTrial,2}(temp_idx)); temp_idx = temp_idx+4;
        end
        trial_table(iTrial,tc.bump_direction) = bytes2float(bdf.databursts{iTrial,2}(temp_idx)); temp_idx = temp_idx+4;
        if databurst_version > 0
            trial_table(iTrial,tc.bump_duration) = bytes2float(bdf.databursts{iTrial,2}(temp_idx)); temp_idx = temp_idx+4;
        end    
        trial_table(iTrial,tc.negative_stiffness) = bytes2float(bdf.databursts{iTrial,2}(temp_idx)); temp_idx = temp_idx+4;
        trial_table(iTrial,tc.positive_stiffness) = bytes2float(bdf.databursts{iTrial,2}(temp_idx)); temp_idx = temp_idx+4;
        trial_table(iTrial,tc.field_orientation) = bytes2float(bdf.databursts{iTrial,2}(temp_idx)); temp_idx = temp_idx+4;
        trial_table(iTrial,tc.bias_force_mag) = bytes2float(bdf.databursts{iTrial,2}(temp_idx)); temp_idx = temp_idx+4;
        trial_table(iTrial,tc.bias_force_dir) = bytes2float(bdf.databursts{iTrial,2}(temp_idx)); temp_idx = temp_idx+4;
        trial_table(iTrial,tc.force_target_diameter) = bytes2float(bdf.databursts{iTrial,2}(temp_idx)); temp_idx = temp_idx+4;
    end        
end

remove_index = [];
remove_index = find(isnan(trial_table(:,tc.x_offset)));
for iCol = 7:length(fieldnames(tc))    
    temp = find((trial_table(:,iCol) ~= 0 & abs(trial_table(:,iCol))<1e-10) | abs(trial_table(:,iCol))>1e10);
    remove_index = [remove_index temp'];
end
remove_index = unique(remove_index);
trial_table(remove_index,:) = [];
