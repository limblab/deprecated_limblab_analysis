function UF_struct = UF_create_struct(bdf,file_details)

UF_struct = file_details;
UF_struct.trial_range = [-.1 .2];

[UF_struct.trial_table,UF_struct.table_columns] = UF_trial_table(bdf);

if strcmp(file_details.UF_file_prefix,'Kevin_2013-07-30_UF_')
    remove_idx = round(UF_struct.trial_table(:,UF_struct.table_columns.field_orientation)*180/pi);
    remove_idx = remove_idx== 0 | remove_idx==90;
    UF_struct.trial_table = UF_struct.trial_table(~remove_idx,:);        
end

if strcmp(file_details.UF_file_prefix,'Kevin_2013-07-31_UF_')
    remove_idx = round(UF_struct.trial_table(:,UF_struct.table_columns.bias_force_dir)*180/pi);
    remove_idx = remove_idx== 45 | remove_idx==225;
    UF_struct.trial_table = UF_struct.trial_table(~remove_idx,:);        
end

if strcmp(file_details.UF_file_prefix,'Kevin_2013-08-08_UF_')
    remove_idx = round(UF_struct.trial_table(:,UF_struct.table_columns.bias_force_dir)*180/pi);
    remove_idx = remove_idx== 45 | remove_idx==225;
    UF_struct.trial_table = UF_struct.trial_table(~remove_idx,:);        
end

UF_struct.bump_duration = mode(UF_struct.trial_table(:,UF_struct.table_columns.bump_duration));
UF_struct.bias_magnitude = mode(UF_struct.trial_table(:,UF_struct.table_columns.bias_force_mag));

UF_struct.t_lim = min(UF_struct.trial_table(:,UF_struct.table_columns.bump_duration));
UF_struct.fs = round(1/mode(diff(bdf.pos(:,1))));

UF_struct.markerlist = {'^','o','.','*'};
UF_struct.linelist = {'-','-.','--',':'};

rewarded_trials = find(UF_struct.trial_table(:,UF_struct.table_columns.result)==32);
fail_trials = find(UF_struct.trial_table(:,UF_struct.table_columns.result)==34);

if isfield(bdf,'emg')
    UF_struct.num_emg = length(bdf.emg.emgnames);
    UF_struct.emgnames = bdf.emg.emgnames;
else
    UF_struct.num_emg = 0;
    UF_struct.emgnames = {};
end

if isfield(bdf,'analog')
    UF_struct.num_lfp = length(bdf.analog.channel);
else
    UF_struct.num_lfp = 0;
end

% Adjust kinematics
% Remove position offset
bdf.pos(:,2) = bdf.pos(:,2) + UF_struct.trial_table(1,UF_struct.table_columns.x_offset); 
bdf.pos(:,3) = bdf.pos(:,3) + UF_struct.trial_table(1,UF_struct.table_columns.y_offset); 

vel = zeros(size(bdf.pos));
vel(:,1) = bdf.pos(:,1);
vel(:,2) = [0 ; diff(bdf.pos(:,2))*UF_struct.fs];
vel(:,3) = [0 ; diff(bdf.pos(:,3))*UF_struct.fs];

acc = zeros(size(bdf.pos));
acc(:,1) = bdf.pos(:,1);
acc(:,2) = [0 ; diff(vel(:,2))*UF_struct.fs];
acc(:,3) = [0 ; diff(vel(:,3))*UF_struct.fs];

trial_table_temp = UF_struct.trial_table(sort([rewarded_trials;fail_trials]),:);
trial_table_temp = trial_table_temp(1:end-1,:);
UF_struct.trial_table = trial_table_temp;

%% Remove bad trials
temp = min(20,size(UF_struct.trial_table,1));
num_samples = zeros(1,temp);
for iTemp = 1:temp
    num_samples(iTemp) = sum(bdf.pos(:,1)>=UF_struct.trial_table(iTemp,UF_struct.table_columns.t_bump_onset)+UF_struct.trial_range(1) &...
        bdf.pos(:,1)<=UF_struct.trial_table(iTemp,UF_struct.table_columns.t_bump_onset)+UF_struct.trial_range(2));
end
num_samples = mode(num_samples);
t_vector = round(bdf.pos(:,1)*30000)/30000;
UF_struct.t_axis = (1/UF_struct.fs:1/UF_struct.fs:num_samples/UF_struct.fs)+UF_struct.trial_range(1);
[~,UF_struct.t_zero_idx] = min(abs(UF_struct.t_axis));

[~,first_idx,table_idx] = intersect(t_vector,round((UF_struct.trial_table(:,UF_struct.table_columns.t_bump_onset)+UF_struct.trial_range(1))*1000)/1000);
UF_struct.trial_table = UF_struct.trial_table(table_idx,:);

UF_struct.idx_table = repmat(first_idx,1,num_samples) + repmat(1:num_samples,size(first_idx,1),1);
UF_struct.x_pos = reshape(bdf.pos(UF_struct.idx_table,2),[],num_samples);
UF_struct.y_pos = reshape(bdf.pos(UF_struct.idx_table,3),[],num_samples);UF_struct.x_pos_translated = UF_struct.x_pos-repmat(UF_struct.x_pos(:,UF_struct.t_zero_idx),1,size(UF_struct.y_pos,2));
UF_struct.y_pos_translated = UF_struct.y_pos-repmat(UF_struct.y_pos(:,UF_struct.t_zero_idx),1,size(UF_struct.y_pos,2));
[~,t_end_idx] = min(abs(UF_struct.t_axis-UF_struct.t_lim));
x_temp = UF_struct.x_pos_translated(:,UF_struct.t_zero_idx:t_end_idx);
y_temp = UF_struct.y_pos_translated(:,UF_struct.t_zero_idx:t_end_idx);
max_x_pos = sign(x_temp(:,end)).*max(abs(x_temp),[],2);
max_y_pos = sign(y_temp(:,end)).*max(abs(y_temp),[],2);

if ~UF_struct.trial_table(1,UF_struct.table_columns.force_bump)
    actual_bump_directions = atan2(max_y_pos,max_x_pos);
    actual_bump_directions(actual_bump_directions<0) = actual_bump_directions(actual_bump_directions<0)+2*pi;
    keep_idx = abs(actual_bump_directions - UF_struct.trial_table(:,UF_struct.table_columns.bump_direction))<.5 |...
        abs(-2*pi+actual_bump_directions - UF_struct.trial_table(:,UF_struct.table_columns.bump_direction))<.5;
    UF_struct.trial_table = UF_struct.trial_table(keep_idx,:);
    disp(['Removed ' num2str(sum(~keep_idx)) ' trials'])
else
    field_orientations = unique(UF_struct.trial_table(:,UF_struct.table_columns.field_orientation));
    bump_directions = unique(UF_struct.trial_table(:,UF_struct.table_columns.bump_direction));
    bias_force_directions = unique(UF_struct.trial_table(:,UF_struct.table_columns.bias_force_dir));
    for iField = 1:length(field_orientations)
        field_indexes{iField} = find(UF_struct.trial_table(:,UF_struct.table_columns.field_orientation)==field_orientations(iField));
    end
    for iBump = 1:length(bump_directions)
        bump_indexes{iBump} = find(UF_struct.trial_table(:,UF_struct.table_columns.bump_direction)==bump_directions(iBump));
    end

    for iBias = 1:length(bias_force_directions)
        bias_indexes{iBias} = find(UF_struct.trial_table(:,UF_struct.table_columns.bias_force_dir)==bias_force_directions(iBias));
    end
    remove_idx = [];
    for iBias = 1:length(bias_force_directions)
        for iField = 1:length(field_orientations)
            for iBump = 1:length(bump_directions)
                idx = intersect(bias_indexes{iBias},field_indexes{iField});
                idx = intersect(idx,bump_indexes{iBump});
                remove_idx = [remove_idx; idx(max_x_pos(idx) > mean(max_x_pos(idx)) + 3*std(max_x_pos(idx)))];
                remove_idx = [remove_idx; idx(max_x_pos(idx) < mean(max_x_pos(idx)) - 3*std(max_x_pos(idx)))];
                remove_idx = [remove_idx; idx(max_y_pos(idx) > mean(max_y_pos(idx)) + 3*std(max_y_pos(idx)))];
                remove_idx = [remove_idx; idx(max_y_pos(idx) < mean(max_y_pos(idx)) - 3*std(max_y_pos(idx)))];
            end
        end
    end
    UF_struct.trial_table(remove_idx,:) = [];
    disp(['Removed ' num2str(length(remove_idx)) ' trials'])
end

%%
temp = min(20,size(UF_struct.trial_table,1));
num_samples = zeros(1,temp);
for iTemp = 1:temp
    num_samples(iTemp) = sum(bdf.pos(:,1)>=UF_struct.trial_table(iTemp,UF_struct.table_columns.t_bump_onset)+UF_struct.trial_range(1) &...
        bdf.pos(:,1)<=UF_struct.trial_table(iTemp,UF_struct.table_columns.t_bump_onset)+UF_struct.trial_range(2));
end
num_samples = mode(num_samples);
t_vector = round(bdf.pos(:,1)*30000)/30000;
UF_struct.t_axis = (1/UF_struct.fs:1/UF_struct.fs:num_samples/UF_struct.fs)+UF_struct.trial_range(1);
[~,UF_struct.t_zero_idx] = min(abs(UF_struct.t_axis));

[~,first_idx,table_idx] = intersect(t_vector,round((UF_struct.trial_table(:,UF_struct.table_columns.t_bump_onset)+UF_struct.trial_range(1))*1000)/1000);
UF_struct.trial_table = UF_struct.trial_table(table_idx,:);

UF_struct.idx_table = repmat(first_idx,1,num_samples) + repmat(1:num_samples,size(first_idx,1),1);
UF_struct.x_pos = reshape(bdf.pos(UF_struct.idx_table,2),[],num_samples);
UF_struct.y_pos = reshape(bdf.pos(UF_struct.idx_table,3),[],num_samples);
UF_struct.x_vel = reshape(vel(UF_struct.idx_table,2),[],num_samples);
UF_struct.y_vel = reshape(vel(UF_struct.idx_table,3),[],num_samples);
UF_struct.x_acc = reshape(acc(UF_struct.idx_table,2),[],num_samples);
UF_struct.y_acc = reshape(acc(UF_struct.idx_table,3),[],num_samples);
UF_struct.x_force = -(1-2*file_details.rot_handle)*reshape(bdf.force(UF_struct.idx_table,2),[],num_samples);
UF_struct.y_force = -(1-2*file_details.rot_handle)*reshape(bdf.force(UF_struct.idx_table,3),[],num_samples);

if UF_struct.num_emg>0
    UF_struct.emg_all = zeros(UF_struct.num_emg,size(UF_struct.trial_table,1),num_samples);
    % Process EMG
    UF_struct.emg_filtered = zeros(size(bdf.emg.data,1),UF_struct.num_emg);
    [b,a] = butter(4,100/(bdf.emg.emgfreq/2),'high');
    for iEMG = 1:UF_struct.num_emg        
        UF_struct.emg_filtered(:,iEMG)=abs(filtfilt(b,a,double(bdf.emg.data(:,iEMG+1))));   
        UF_struct.emg_all(iEMG,:,:) = reshape(UF_struct.emg_filtered(UF_struct.idx_table,iEMG),[],num_samples);
    end
end

if UF_struct.num_lfp>0
    UF_struct.lfp_all = zeros(UF_struct.num_lfp,size(UF_struct.idx_table,1),size(UF_struct.idx_table,2));
    % Process LFP
    [b,a] = butter(4,100/(round(1/mode(diff(bdf.analog.ts)))/2));
    for iLFP = 1:UF_struct.num_lfp
        filt_lfp = filtfilt(b,a,double(bdf.analog.data{iLFP}));
        UF_struct.lfp_all(iLFP,:,:) = reshape(filt_lfp(UF_struct.idx_table),[],num_samples);
%         UF_struct.lfp_all(iLFP,:,:) = reshape(bdf.analog.data{iLFP}(UF_struct.idx_table),[],num_samples);
    end
end

clear vel acc

UF_struct.field_orientations = unique(UF_struct.trial_table(:,UF_struct.table_columns.field_orientation));
UF_struct.bump_directions = unique(UF_struct.trial_table(:,UF_struct.table_columns.bump_direction));
UF_struct.bias_force_directions = unique(UF_struct.trial_table(:,UF_struct.table_columns.bias_force_dir));
UF_struct.bump_magnitudes = unique(UF_struct.trial_table(:,UF_struct.table_columns.bump_velocity));

UF_struct.colors_bump = lines(length(UF_struct.bump_directions));
UF_struct.colors_field = lines(length(UF_struct.field_orientations));
% UF_struct.colors_field = [0 0 1; 1 0 0; 0 1 0];
UF_struct.colors_bump_mag = lines(length(UF_struct.bump_magnitudes));
UF_struct.colors_field_bump = lines(8);

UF_struct.colors_field_bias = lines(length(UF_struct.field_orientations)*length(UF_struct.bias_force_directions));

UF_struct.field_indexes = cell(1,length(UF_struct.field_orientations));
UF_struct.bump_indexes = cell(1,length(UF_struct.bump_directions));
UF_struct.bias_indexes = cell(1,length(UF_struct.bias_force_directions));
UF_struct.bump_mag_indexes = cell(1,length(UF_struct.bump_magnitudes));

UF_struct.x_pos_translated = UF_struct.x_pos-repmat(UF_struct.x_pos(:,UF_struct.t_zero_idx),1,size(UF_struct.y_pos,2));
UF_struct.y_pos_translated = UF_struct.y_pos-repmat(UF_struct.y_pos(:,UF_struct.t_zero_idx),1,size(UF_struct.y_pos,2));
UF_struct.x_pos_rot_bump = repmat(cos(-UF_struct.trial_table(:,UF_struct.table_columns.bump_direction)),1,size(UF_struct.x_pos_translated,2)).*UF_struct.x_pos_translated -...
    repmat(sin(-UF_struct.trial_table(:,UF_struct.table_columns.bump_direction)),1,size(UF_struct.x_pos_translated,2)).*UF_struct.y_pos_translated;
UF_struct.y_pos_rot_bump = repmat(sin(-UF_struct.trial_table(:,UF_struct.table_columns.bump_direction)),1,size(UF_struct.x_pos_translated,2)).*UF_struct.x_pos_translated +...
    repmat(cos(-UF_struct.trial_table(:,UF_struct.table_columns.bump_direction)),1,size(UF_struct.x_pos_translated,2)).*UF_struct.y_pos_translated;

UF_struct.x_vel_rot_bump = repmat(cos(-UF_struct.trial_table(:,UF_struct.table_columns.bump_direction)),1,size(UF_struct.x_pos_translated,2)).*UF_struct.x_vel -...
    repmat(sin(-UF_struct.trial_table(:,UF_struct.table_columns.bump_direction)),1,size(UF_struct.x_pos_translated,2)).*UF_struct.y_vel;
UF_struct.y_vel_rot_bump = repmat(sin(-UF_struct.trial_table(:,UF_struct.table_columns.bump_direction)),1,size(UF_struct.x_pos_translated,2)).*UF_struct.x_vel +...
    repmat(cos(-UF_struct.trial_table(:,UF_struct.table_columns.bump_direction)),1,size(UF_struct.x_pos_translated,2)).*UF_struct.y_vel;

UF_struct.x_acc_rot_bump = repmat(cos(-UF_struct.trial_table(:,UF_struct.table_columns.bump_direction)),1,size(UF_struct.x_pos_translated,2)).*UF_struct.x_acc -...
    repmat(sin(-UF_struct.trial_table(:,UF_struct.table_columns.bump_direction)),1,size(UF_struct.x_pos_translated,2)).*UF_struct.y_acc;
UF_struct.y_acc_rot_bump = repmat(sin(-UF_struct.trial_table(:,UF_struct.table_columns.bump_direction)),1,size(UF_struct.x_pos_translated,2)).*UF_struct.x_acc +...
    repmat(cos(-UF_struct.trial_table(:,UF_struct.table_columns.bump_direction)),1,size(UF_struct.x_pos_translated,2)).*UF_struct.y_acc;

% x_force_translated = UF_struct.x_force-repmat(UF_struct.x_force(:,1),1,size(UF_struct.x_force,2));
% y_force_translated = UF_struct.y_force-repmat(UF_struct.y_force(:,1),1,size(UF_struct.y_force,2));

x_force_translated = UF_struct.x_force-repmat(mean(UF_struct.x_force(:,UF_struct.t_axis<0),2),1,size(UF_struct.x_force,2));
y_force_translated = UF_struct.y_force-repmat(mean(UF_struct.y_force(:,UF_struct.t_axis<0),2),1,size(UF_struct.y_force,2));

UF_struct.x_force_rot_bump = repmat(cos(-UF_struct.trial_table(:,UF_struct.table_columns.bump_direction)),1,size(x_force_translated,2)).*x_force_translated -...
    repmat(sin(-UF_struct.trial_table(:,UF_struct.table_columns.bump_direction)),1,size(x_force_translated,2)).*y_force_translated;
UF_struct.y_force_rot_bump = repmat(sin(-UF_struct.trial_table(:,UF_struct.table_columns.bump_direction)),1,size(x_force_translated,2)).*x_force_translated +...
    repmat(cos(-UF_struct.trial_table(:,UF_struct.table_columns.bump_direction)),1,size(x_force_translated,2)).*y_force_translated;

%%
for iField = 1:length(UF_struct.field_orientations)
    UF_struct.field_indexes{iField} = find(UF_struct.trial_table(:,UF_struct.table_columns.field_orientation)==UF_struct.field_orientations(iField));
end

for iBump = 1:length(UF_struct.bump_directions)
    UF_struct.bump_indexes{iBump} = find(UF_struct.trial_table(:,UF_struct.table_columns.bump_direction)==UF_struct.bump_directions(iBump));
end

for iBias = 1:length(UF_struct.bias_force_directions)
    UF_struct.bias_indexes{iBias} = find(UF_struct.trial_table(:,UF_struct.table_columns.bias_force_dir)==UF_struct.bias_force_directions(iBias));
end

for iBumpMag = 1:length(UF_struct.bump_magnitudes)
    UF_struct.bump_mag_indexes{iBumpMag} = find(UF_struct.trial_table(:,UF_struct.table_columns.bump_velocity)==UF_struct.bump_magnitudes(iBumpMag));
end

[~,t_end_idx] = min(abs(UF_struct.t_axis-UF_struct.t_lim));
UF_struct.bump_dir_actual = zeros(length(UF_struct.bump_indexes),length(UF_struct.field_indexes));
x_temp = UF_struct.x_pos_translated(:,UF_struct.t_zero_idx:t_end_idx);
y_temp = UF_struct.y_pos_translated(:,UF_struct.t_zero_idx:t_end_idx);
max_x_pos = sign(x_temp(:,end)).*max(abs(x_temp),[],2);
max_y_pos = sign(y_temp(:,end)).*max(abs(y_temp),[],2);
for iField = 1:length(UF_struct.field_orientations)
    for iBump = 1:length(UF_struct.bump_directions)
        idx = intersect(UF_struct.field_indexes{iField},UF_struct.bump_indexes{iBump});
        mean_x = mean(max_x_pos(idx));
        std_x = std(max_x_pos(idx));
        mean_y = mean(max_y_pos(idx));
        std_y = std(max_y_pos(idx));
        if isnan(mean_x)
            UF_struct.bump_dir_actual(iBump,iField) = UF_struct.bump_directions(iBump);
        else
            UF_struct.bump_dir_actual(iBump,iField) = atan2(mean_y,mean_x);
        end
    end    
end
temp = abs(UF_struct.bump_dir_actual-[UF_struct.bump_directions UF_struct.bump_directions]) > abs(UF_struct.bump_dir_actual-[UF_struct.bump_directions UF_struct.bump_directions]+2*pi);
UF_struct.bump_dir_actual(temp) = UF_struct.bump_dir_actual(temp)+2*pi;
UF_struct.bump_dir_actual = mean(UF_struct.bump_dir_actual,2);
% UF_struct.bump_dir_actual(UF_struct.bump_dir_actual<0)=2*pi+UF_struct.bump_dir_actual(UF_struct.bump_dir_actual<0);
bump_dir_mat = [abs(UF_struct.bump_dir_actual-UF_struct.bump_directions) abs((UF_struct.bump_dir_actual-2*pi)-UF_struct.bump_directions)];
[~,idx] = min(bump_dir_mat,[],2);
idx = idx-1;
UF_struct.bump_dir_actual = UF_struct.bump_dir_actual - 2*pi*idx;

UF_struct.bump_force_dir_actual = atan2(mean(UF_struct.y_force(:,UF_struct.t_axis>0.03 & UF_struct.t_axis<UF_struct.bump_duration),2)-...
    mean(UF_struct.y_force(:,UF_struct.t_axis>-.05 & UF_struct.t_axis<0),2),...
    mean(UF_struct.x_force(:,UF_struct.t_axis>0.03 & UF_struct.t_axis<UF_struct.bump_duration),2)-...
    mean(UF_struct.x_force(:,UF_struct.t_axis>-.05 & UF_struct.t_axis<0),2));
UF_struct.bump_force_dir_actual(UF_struct.bump_force_dir_actual<0) = UF_struct.bump_force_dir_actual(UF_struct.bump_force_dir_actual<0)+2*pi;

units = unit_list(bdf);
UF_struct.firingrates = zeros([size(UF_struct.idx_table) length(units)]);
all_chans = reshape([bdf.units.id],2,[])';
fr_tc = 0.02;

for iUnit = 1:size(units,1)    
    unit_idx = find(all_chans(:,1)==units(iUnit,1) & all_chans(:,2)==units(iUnit,2));
    fr = spikes2fr(bdf.units(unit_idx).ts,bdf.pos(:,1),fr_tc); 
    UF_struct.firingrates(:,:,iUnit) = fr(UF_struct.idx_table);
end

