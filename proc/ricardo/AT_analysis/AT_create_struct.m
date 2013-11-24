function AT_struct = AT_create_struct(bdf,file_details)

AT_struct = file_details;

[AT_struct.trial_table,AT_struct.table_columns] = AT_trial_table(bdf);

AT_struct.bump_duration = mode(AT_struct.trial_table(:,AT_struct.table_columns.bump_duration));
AT_struct.bias_magnitude = mode(AT_struct.trial_table(:,AT_struct.table_columns.bias_force_mag));

AT_struct.t_lim = min(AT_struct.trial_table(:,AT_struct.table_columns.bump_duration));
AT_struct.fs = round(1/mode(diff(bdf.pos(:,1))));

AT_struct.markerlist = {'^','o','.','*'};
AT_struct.linelist = {'-','-.','--',':'};

rewarded_trials = find(AT_struct.trial_table(:,AT_struct.table_columns.result)==32);

AT_struct.trial_range = [-.5 .5];
if isfield(bdf,'emg')
    AT_struct.num_emg = length(bdf.emg.emgnames);
    AT_struct.emgnames = bdf.emg.emgnames;
else
    AT_struct.num_emg = 0;
    AT_struct.emgnames = {};
end

if isfield(bdf,'analog')
    AT_struct.num_lfp = length(bdf.analog.channel);
else
    AT_struct.num_lfp = 0;
end

%%
AT_struct.trial_table = AT_struct.trial_table(AT_struct.trial_table(:,AT_struct.table_columns.result)~=33,:);
AT_struct.trial_table = AT_struct.trial_table(AT_struct.trial_table(:,AT_struct.table_columns.result)~=35,:);

% Adjust kinematics
% Remove position offset
bdf.pos(:,2) = bdf.pos(:,2) + AT_struct.trial_table(1,AT_struct.table_columns.x_offset); 
bdf.pos(:,3) = bdf.pos(:,3) + AT_struct.trial_table(1,AT_struct.table_columns.y_offset); 

vel = zeros(size(bdf.pos));
vel(:,1) = bdf.pos(:,1);
vel(:,2) = [0 ; diff(bdf.pos(:,2))*AT_struct.fs];
vel(:,3) = [0 ; diff(bdf.pos(:,3))*AT_struct.fs];

acc = zeros(size(bdf.pos));
acc(:,1) = bdf.pos(:,1);
acc(:,2) = [0 ; diff(vel(:,2))*AT_struct.fs];
acc(:,3) = [0 ; diff(vel(:,3))*AT_struct.fs];

%% Remove bad trials
temp = min(20,size(AT_struct.trial_table,1));
num_samples = zeros(1,temp);
for iTemp = 1:temp
    num_samples(iTemp) = sum(bdf.pos(:,1)>=AT_struct.trial_table(iTemp,AT_struct.table_columns.t_stimuli_onset)+AT_struct.trial_range(1) &...
        bdf.pos(:,1)<=AT_struct.trial_table(iTemp,AT_struct.table_columns.t_stimuli_onset)+AT_struct.trial_range(2));
end
num_samples = mode(num_samples);
t_vector = round(bdf.pos(:,1)*30000)/30000;
AT_struct.t_axis = (1/AT_struct.fs:1/AT_struct.fs:num_samples/AT_struct.fs)+AT_struct.trial_range(1);
[~,AT_struct.t_zero_idx] = min(abs(AT_struct.t_axis));
[~,AT_struct.t_end_bump_idx] = min(abs(AT_struct.t_axis-AT_struct.bump_duration));

[~,first_idx,table_idx] = intersect(t_vector,round((AT_struct.trial_table(:,AT_struct.table_columns.t_stimuli_onset)+AT_struct.trial_range(1))*1000)/1000);
AT_struct.trial_table = AT_struct.trial_table(table_idx,:);

AT_struct.idx_table = repmat(first_idx,1,num_samples) + repmat(1:num_samples,size(first_idx,1),1);
AT_struct.x_pos = reshape(bdf.pos(AT_struct.idx_table,2),[],num_samples);
AT_struct.y_pos = reshape(bdf.pos(AT_struct.idx_table,3),[],num_samples);
AT_struct.x_pos_translated = AT_struct.x_pos-repmat(AT_struct.x_pos(:,AT_struct.t_zero_idx),1,size(AT_struct.y_pos,2));
AT_struct.y_pos_translated = AT_struct.y_pos-repmat(AT_struct.y_pos(:,AT_struct.t_zero_idx),1,size(AT_struct.y_pos,2));
[~,t_end_idx] = min(abs(AT_struct.t_axis-AT_struct.t_lim));
x_temp = AT_struct.x_pos_translated(:,AT_struct.t_zero_idx:t_end_idx);
y_temp = AT_struct.y_pos_translated(:,AT_struct.t_zero_idx:t_end_idx);
max_x_pos = sign(x_temp(:,end)).*max(abs(x_temp),[],2);
max_y_pos = sign(y_temp(:,end)).*max(abs(y_temp),[],2);
actual_bump_directions = atan2(max_y_pos,max_x_pos);
actual_bump_directions(actual_bump_directions<0) = actual_bump_directions(actual_bump_directions<0)+2*pi;
keep_idx = abs(actual_bump_directions - AT_struct.trial_table(:,AT_struct.table_columns.bump_direction))<.5 |...
    abs(-2*pi+actual_bump_directions - AT_struct.trial_table(:,AT_struct.table_columns.bump_direction))<.5;
AT_struct.trial_table = AT_struct.trial_table(keep_idx,:);

%%
temp = min(20,size(AT_struct.trial_table,1));
num_samples = zeros(1,temp);
for iTemp = 1:temp
    num_samples(iTemp) = sum(bdf.pos(:,1)>=AT_struct.trial_table(iTemp,AT_struct.table_columns.t_stimuli_onset)+AT_struct.trial_range(1) &...
        bdf.pos(:,1)<=AT_struct.trial_table(iTemp,AT_struct.table_columns.t_stimuli_onset)+AT_struct.trial_range(2));
end
num_samples = mode(num_samples);
t_vector = round(bdf.pos(:,1)*30000)/30000;
AT_struct.t_axis = (1/AT_struct.fs:1/AT_struct.fs:num_samples/AT_struct.fs)+AT_struct.trial_range(1);
[~,AT_struct.t_zero_idx] = min(abs(AT_struct.t_axis));

[~,first_idx,table_idx] = intersect(t_vector,round((AT_struct.trial_table(:,AT_struct.table_columns.t_stimuli_onset)+AT_struct.trial_range(1))*1000)/1000);
AT_struct.trial_table = AT_struct.trial_table(table_idx,:);

AT_struct.idx_table = repmat(first_idx,1,num_samples) + repmat(1:num_samples,size(first_idx,1),1);
AT_struct.x_pos = reshape(bdf.pos(AT_struct.idx_table,2),[],num_samples);
AT_struct.y_pos = reshape(bdf.pos(AT_struct.idx_table,3),[],num_samples);
AT_struct.x_pos_translated = AT_struct.x_pos-repmat(AT_struct.x_pos(:,AT_struct.t_zero_idx),1,size(AT_struct.y_pos,2));
AT_struct.y_pos_translated = AT_struct.y_pos-repmat(AT_struct.y_pos(:,AT_struct.t_zero_idx),1,size(AT_struct.y_pos,2));
AT_struct.x_vel = reshape(vel(AT_struct.idx_table,2),[],num_samples);
AT_struct.y_vel = reshape(vel(AT_struct.idx_table,3),[],num_samples);
AT_struct.x_acc = reshape(acc(AT_struct.idx_table,2),[],num_samples);
AT_struct.y_acc = reshape(acc(AT_struct.idx_table,3),[],num_samples);
AT_struct.x_force = -(1-2*file_details.rot_handle)*reshape(bdf.force(AT_struct.idx_table,2),[],num_samples);
AT_struct.y_force = -(1-2*file_details.rot_handle)*reshape(bdf.force(AT_struct.idx_table,3),[],num_samples);

if AT_struct.num_emg>0
    AT_struct.emg_all = zeros(AT_struct.num_emg,size(AT_struct.trial_table,1),num_samples);
    % Process EMG
    AT_struct.emg_filtered = zeros(size(bdf.emg.data,1),AT_struct.num_emg);
    [b,a] = butter(4,100/(bdf.emg.emgfreq/2),'high');
    for iEMG = 1:AT_struct.num_emg        
        AT_struct.emg_filtered(:,iEMG)=abs(filtfilt(b,a,double(bdf.emg.data(:,iEMG+1))));   
        AT_struct.emg_all(iEMG,:,:) = reshape(AT_struct.emg_filtered(AT_struct.idx_table,iEMG),[],num_samples);
    end
end

if AT_struct.num_lfp>0
    AT_struct.lfp_all = zeros(AT_struct.num_lfp,size(AT_struct.idx_table,1),size(AT_struct.idx_table,2));
    % Process LFP
    [b,a] = butter(4,100/(round(1/mode(diff(bdf.analog.ts)))/2));
    for iLFP = 1:AT_struct.num_lfp
        filt_lfp = filtfilt(b,a,double(bdf.analog.data{iLFP}));
        AT_struct.lfp_all(iLFP,:,:) = reshape(filt_lfp(AT_struct.idx_table),[],num_samples);
    end
end

AT_struct.visual_trials = find(AT_struct.trial_table(:,AT_struct.table_columns.trial_type)==0);
AT_struct.proprio_trials = find(AT_struct.trial_table(:,AT_struct.table_columns.trial_type)==1);
AT_struct.control_trials = find(AT_struct.trial_table(:,AT_struct.table_columns.trial_type)==2);
AT_struct.trial_type_indexes = {AT_struct.visual_trials,AT_struct.proprio_trials,AT_struct.control_trials};
AT_struct.trial_types = {'Visual','Proprio','Control'};

AT_struct.reward_trials = find(AT_struct.trial_table(:,AT_struct.table_columns.result)==32);
AT_struct.fail_trials = find(AT_struct.trial_table(:,AT_struct.table_columns.result)==34);

AT_struct.bump_directions = AT_struct.trial_table(:,AT_struct.table_columns.bump_direction);
AT_struct.dot_directions = AT_struct.trial_table(:,AT_struct.table_columns.moving_dots_direction);

AT_struct.bump_duration = AT_struct.trial_table(1,AT_struct.table_columns.bump_duration);

AT_struct.unique_bump_directions = unique(AT_struct.bump_directions(AT_struct.proprio_trials));
AT_struct.visual_idx = cell(length(AT_struct.unique_bump_directions),1);
AT_struct.proprio_idx = cell(length(AT_struct.unique_bump_directions),1);
AT_struct.bump_indexes = cell(length(AT_struct.unique_bump_directions),1);
for iBumpDir = 1:length(AT_struct.unique_bump_directions)
    AT_struct.proprio_idx{iBumpDir} = [AT_struct.proprio_idx{iBumpDir} intersect(AT_struct.proprio_trials,find(AT_struct.bump_directions==AT_struct.unique_bump_directions(iBumpDir)))];
    AT_struct.visual_idx{iBumpDir} = [AT_struct.visual_idx{iBumpDir} intersect(AT_struct.visual_trials,find(AT_struct.bump_directions==AT_struct.unique_bump_directions(iBumpDir)))];
    AT_struct.bump_indexes{iBumpDir} = find(AT_struct.bump_directions==AT_struct.unique_bump_directions(iBumpDir));
end

temp = 180/pi*abs(AT_struct.trial_table(intersect(AT_struct.visual_trials,...
    find(AT_struct.trial_table(:,AT_struct.table_columns.result)==32)),AT_struct.table_columns.moving_dots_direction)-...
    AT_struct.trial_table(intersect(AT_struct.visual_trials,...
    find(AT_struct.trial_table(:,AT_struct.table_columns.result)==32)),AT_struct.table_columns.bump_direction));
temp = find(temp > 170 & temp < 190);
for iBump = 1:length(AT_struct.bump_indexes)
    AT_struct.visual_difficult_correct_trials{iBump} = intersect(AT_struct.bump_indexes{iBump},temp);
end

temp = 180/pi*abs(AT_struct.trial_table(intersect(AT_struct.visual_trials,...
    find(AT_struct.trial_table(:,AT_struct.table_columns.result)==34)),AT_struct.table_columns.moving_dots_direction)-...
    AT_struct.trial_table(intersect(AT_struct.visual_trials,...
    find(AT_struct.trial_table(:,AT_struct.table_columns.result)==34)),AT_struct.table_columns.bump_direction));
temp = find(temp > 170 & temp < 190);
for iBump = 1:length(AT_struct.bump_indexes)
    AT_struct.visual_difficult_fail_trials{iBump} = intersect(AT_struct.bump_indexes{iBump},temp);
end

AT_struct.colors_trial_type = [0 0 1; 1 0 0; 0 1 0];
AT_struct.colors_response = [.5 0 .5; .5 .5 0];
AT_struct.response_str = {'Visual correct','Visual fail'};

