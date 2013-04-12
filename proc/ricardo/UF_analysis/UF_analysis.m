% clear all
use_experimental = 1;
file_prefix = 'Kevin_2013-04-12_UF';

    if ~use_experimental
        datapath = 'D:\Data\Kevin_12A2\Data\';
        filenames = dir([datapath '\' file_prefix '_*.nev']);

        trial_table = [];
        for iFile = 1:length(filenames)   
            filename_no_ext = filenames(iFile).name(1:end-4);
            if ~exist([datapath filename_no_ext '.mat'])
                bdf = get_cerebus_data([datapath '\' filenames(iFile).name],3);    
                save([datapath filename_no_ext],'bdf');        
            else
                load([datapath filename_no_ext],'bdf');        
            end
            bdf_temp = bdf;    
            if strcmp(filename_no_ext,'Kevin_2012-09-28_UF_002')
                bdf_temp.words(732,:) = [];
            end   
            if iFile == 1
                bdf_all = bdf;
                [trial_table_temp table_columns] = UF_trial_table(bdf_temp);
                trial_table_temp = trial_table_temp(1:end-1,:);
            else        
        %         old_end_time = trial_table(end,table_columns.t_trial_end);
                old_end_time = bdf_all.pos(end,1)+1;
                [trial_table_temp table_columns_temp] = UF_trial_table(bdf_temp);
                trial_table_temp = trial_table_temp(1:end-1,:);
                if isequal(table_columns,table_columns_temp)
                    trial_table_temp(:,table_columns_temp.t_trial_start) = trial_table_temp(:,table_columns_temp.t_trial_start) +...
                        old_end_time;
                    trial_table_temp(:,table_columns_temp.t_field_buildup) = trial_table_temp(:,table_columns_temp.t_field_buildup) +...
                        old_end_time;
                    trial_table_temp(:,table_columns_temp.t_ct_hold_on) = trial_table_temp(:,table_columns_temp.t_ct_hold_on) +...
                        old_end_time;
                    trial_table_temp(:,table_columns_temp.t_bump_onset) = trial_table_temp(:,table_columns_temp.t_bump_onset) +...
                        old_end_time;
                    trial_table_temp(:,table_columns_temp.t_trial_end) = trial_table_temp(:,table_columns_temp.t_trial_end) +...
                        old_end_time;
                    bdf_temp.words(:,1) = bdf_temp.words(:,1) + old_end_time;
                    bdf_all.words = [bdf_all.words ; bdf_temp.words];
                    bdf_temp.pos(:,1) = bdf_temp.pos(:,1) + old_end_time;
                    bdf_all.pos = [bdf_all.pos ; bdf_temp.pos];
                    bdf_temp.vel(:,1) = bdf_temp.vel(:,1) + old_end_time;
                    bdf_all.vel = [bdf_all.vel ; bdf_temp.vel];
                    bdf_temp.acc(:,1) = bdf_temp.acc(:,1) + old_end_time;
                    bdf_all.acc = [bdf_all.acc ; bdf_temp.acc];
                    bdf_temp.force(:,1) = bdf_temp.force(:,1) + old_end_time;
                    bdf_all.force = [bdf_all.force ; bdf_temp.force];
                    for iTrial = 1:size(bdf_temp.databursts,1)
                        bdf_temp.databursts{iTrial,1} = bdf_temp.databursts{iTrial,1} + old_end_time;
                    end
                    bdf_all.databursts = [bdf_all.databursts; bdf_temp.databursts];
                    for iUnit = 1:size(bdf_all.units,2)
                        unit_id = bdf_all.units(iUnit).id;
                        temp_units = reshape([bdf_temp.units.id],2,[])';
                        [~,~,unit_idx] = intersect(unit_id,temp_units,'rows');
                        if ~isempty(unit_idx)
                            bdf_all.units(iUnit).ts = [bdf_all.units(iUnit).ts ; bdf_temp.units(unit_idx).ts + old_end_time];
                        else
                            warning('Neuron dropped from recording') %#ok<WNTAG>
                        end
                    end

        %             for iUnit = 1:size(bdf_temp.units,2)
        %                 bdf_all.units(iUnit).ts = [bdf_all.units(iUnit).ts ; bdf_temp.units(iUnit).ts + old_end_time];
        %             end
                else
                    error('Poop')
                end
            end    
            trial_table = [trial_table; trial_table_temp];
        end
        bdf = bdf_all;
        trial_table(:,table_columns.bump_direction) = round(trial_table(:,table_columns.bump_direction)*180/pi)*pi/180;
    else
        % Experimental!        (but then again, what isn't?)
        datapath = 'D:\Data\Kevin_12A2\Data\';
        if exist([datapath file_prefix '-concat.mat'],'file')
            disp('Files already concatenated. Loading existing files.')
            load([datapath,file_prefix,'-concat.mat'])
            if (NEVNSx.MetaTags.NumFilesConcat ~= length(dir([datapath file_prefix '*.nev'])))
                NEVNSx = concatenate_NEVs(datapath,file_prefix);
                NEVNSx.NEV = artifact_removal(NEVNSx.NEV,3,0.001);
                save([datapath,file_prefix,'-concat.mat'],'NEVNSx')
            end
        else            
            NEVNSx = concatenate_NEVs(datapath,file_prefix);
            NEVNSx.NEV = artifact_removal(NEVNSx.NEV,3,0.001);
            save([datapath,file_prefix,'-concat.mat'],'NEVNSx')
        end        
        bdf = get_nev_mat_data(NEVNSx,3);         
    end
        
[trial_table table_columns] = UF_trial_table(bdf);
        
bump_duration = trial_table(1,table_columns.bump_duration);

t_lim = min(trial_table(:,table_columns.bump_duration));
fs = 1/diff(bdf.pos(1:2,1));

field_orientations = unique(trial_table(:,table_columns.field_orientation));
bump_directions = unique(trial_table(:,table_columns.bump_direction));
bias_force_directions = unique(trial_table(:,table_columns.bias_force_dir));

colors_bump = lines(length(bump_directions));
colors_field = lines(length(field_orientations));
colors_field = [0 0 1; 1 0 0; 0 1 0];

colors_field_bias = lines(length(field_orientations)*length(bias_force_directions));

markerlist = {'^','o','.','*'};
linelist = {'-','-.','--',':'};

rewarded_trials = find(trial_table(:,table_columns.result)==32);
aborted_trials = find(trial_table(:,table_columns.result)==33);

field_indexes = cell(1,length(field_orientations));
bump_indexes = cell(1,length(bump_directions));
bias_indexes = cell(1,length(bias_force_directions));

trial_range = [-.5 .5];
if isfield(bdf,'emg')
    num_emg = size(bdf.emg.emgnames,2);
else
    num_emg = 0;
end

num_emg = 0;

%% Adjust kinematics

% encoder = bdf.raw.enc;

% Remove position offset
bdf.pos(:,2) = bdf.pos(:,2) + trial_table(1,table_columns.x_offset); 
bdf.pos(:,3) = bdf.pos(:,3) + trial_table(1,table_columns.y_offset); 

vel = zeros(size(bdf.pos));
vel(:,1) = bdf.pos(:,1);
vel(:,2) = [0 ; diff(bdf.pos(:,2))*fs];
vel(:,3) = [0 ; diff(bdf.pos(:,3))*fs];

acc = zeros(size(bdf.pos));
acc(:,1) = bdf.pos(:,1);
acc(:,2) = [0 ; diff(vel(:,2))*fs];
acc(:,3) = [0 ; diff(vel(:,3))*fs];

% % Remove force offset
% xy_movement = sqrt(diff(bdf.pos(:,2)).^2+diff(bdf.pos(:,3)).^2);
% [b,a] = butter(4,50/(fs/2),'low');
% xy_movement = filtfilt(b,a,xy_movement);
% handle_not_moving_idx = intersect(find(xy_movement<1e-30),find(abs(bdf.pos(:,2))<20 & abs(bdf.pos(:,3)<10)));
% % handle_not_moving_idx = find(xy_movement<50*min(xy_movement));
% x_force_offset = mean(bdf.force(handle_not_moving_idx,2));
% y_force_offset = mean(bdf.force(handle_not_moving_idx,3));
% 
% trial_table_temp = trial_table(~isnan(trial_table(:,table_columns.t_field_buildup)),:);
% x_forces_offset = zeros(size(trial_table_temp,1),100);
% y_forces_offset = zeros(size(trial_table_temp,1),100);
% for iTrial = 1:size(trial_table_temp,1)
%     t_field_onset = trial_table_temp(iTrial,table_columns.t_field_buildup);
%     x_forces_offset(iTrial,:) = bdf.force(find(bdf.force(:,1)<t_field_onset,100,'last'),2);
%     y_forces_offset(iTrial,:) = bdf.force(find(bdf.force(:,1)<t_field_onset,100,'last'),3);
% end
% x_force_offset = mean(mean(x_forces_offset));
% y_force_offset = mean(mean(y_forces_offset));
% 
% bdf.force(:,2) = bdf.force(:,2) - x_force_offset;
% bdf.force(:,3) = bdf.force(:,3) - y_force_offset;

% % Copy EMG
% if num_emg>0
%     emg = bdf.emg.data;
% else
%     emg = [];
% end

trial_table_temp = trial_table(rewarded_trials,:);
trial_table_temp = trial_table_temp(1:end-1,:);

if num_emg>0
    emg_all = zeros(num_emg,size(trial_table_temp,1),length(find(bdf.emg.data(:,1)>trial_table_temp(1,table_columns.t_bump_onset)+trial_range(1) &...
            bdf.emg.data(:,1)<trial_table_temp(1,table_columns.t_bump_onset)+trial_range(2))));

    % Process EMG
    emg_filtered = zeros(size(bdf.emg.data,1),num_emg);
    for iEMG = 1:num_emg
        [b,a] = butter(4,50/(bdf.emg.emgfreq/2),'high');
        emg_filtered(:,iEMG)=abs(filter(b,a,bdf.emg.data(:,iEMG+1)));   
%         [b,a] = butter(4,50/(bdf.emg.emgfreq/2),'low');
%         emg_filtered(:,iEMG)=filter(b,a,emg_filtered(:,iEMG));
    end
end
% emg_filtered = abs(emg_filtered);
% [b,a] = butter(4,150/(bdf.emg.emgfreq/2),'low');

num_samples = sum(bdf.pos(:,1)>=trial_table_temp(1,table_columns.t_bump_onset)+trial_range(1) &...
    bdf.pos(:,1)<=trial_table_temp(1,table_columns.t_bump_onset)+trial_range(2));
all_idx = 1:size(bdf.pos,1);
t_vector = round(bdf.pos(:,1)*30000)/30000;

[~,first_idx,~] = intersect(t_vector,round((trial_table_temp(:,table_columns.t_bump_onset)+trial_range(1))*1000)/1000);
idx_table = repmat(first_idx,1,num_samples) + repmat(1:num_samples,size(first_idx,1),1);
x_pos = reshape(bdf.pos(idx_table,2),[],num_samples);
y_pos = reshape(bdf.pos(idx_table,3),[],num_samples);
x_vel = reshape(vel(idx_table,2),[],num_samples);
y_vel = reshape(vel(idx_table,3),[],num_samples);
x_acc = reshape(acc(idx_table,2),[],num_samples);
y_acc = reshape(acc(idx_table,3),[],num_samples);
x_force = reshape(bdf.force(idx_table,2),[],num_samples);
y_force = reshape(bdf.force(idx_table,3),[],num_samples);

emg_fs = double(1/mean(diff(bdf.emg.data(:,1))));
t_vector = round(double(bdf.emg.data(:,1))*round(emg_fs))/emg_fs;
num_samples_emg = sum(bdf.emg.data(:,1)>=trial_table_temp(1,table_columns.t_bump_onset)+trial_range(1) &...
    bdf.emg.data(:,1)<=trial_table_temp(1,table_columns.t_bump_onset)+trial_range(2));
[~,first_idx,~] = intersect(t_vector,round((trial_table_temp(:,table_columns.t_bump_onset)+trial_range(1))*emg_fs)/emg_fs);
emg_idx_table = repmat(first_idx,1,num_samples_emg) + repmat(1:num_samples_emg,size(first_idx,1),1);

if length(first_idx)~=size(trial_table_temp,1)
    num_emg = 0;
    warning('EMG length does not match NEV length')
end
for iEMG = 1:num_emg        
    emg_all(iEMG,:,:) = reshape(emg_filtered(emg_idx_table,iEMG),[],num_samples_emg);
end

% toc

% % Process EMG
% for iEMG = 1:size(emg_all,1)
%     emg_all(iEMG,:,:) = abs(emg_all(iEMG,:,:)-mean(mean(emg_all(iEMG,:,:))));
% end
    
t_axis = (1/fs:1/fs:size(x_pos,2)/fs)+trial_range(1);
[t_zero t_zero_idx] = min(abs(t_axis));
% rotate position traces with field orientation and remove outliers
for i = 1:2
    x_pos_rot_field = repmat(cos(-trial_table_temp(:,table_columns.field_orientation)),1,size(x_pos,2)).*x_pos -...
        repmat(sin(-trial_table_temp(:,table_columns.field_orientation)),1,size(x_pos,2)).*y_pos;
    y_pos_rot_field = repmat(sin(-trial_table_temp(:,table_columns.field_orientation)),1,size(x_pos,2)).*x_pos +...
        repmat(cos(-trial_table_temp(:,table_columns.field_orientation)),1,size(x_pos,2)).*y_pos;

    x_pos_translated = x_pos-repmat(x_pos(:,t_zero_idx),1,size(y_pos,2));
    y_pos_translated = y_pos-repmat(y_pos(:,t_zero_idx),1,size(y_pos,2));
    x_pos_rot_bump = repmat(cos(-trial_table_temp(:,table_columns.bump_direction)),1,size(x_pos_translated,2)).*x_pos_translated -...
        repmat(sin(-trial_table_temp(:,table_columns.bump_direction)),1,size(x_pos_translated,2)).*y_pos_translated;
    y_pos_rot_bump = repmat(sin(-trial_table_temp(:,table_columns.bump_direction)),1,size(x_pos_translated,2)).*x_pos_translated +...
        repmat(cos(-trial_table_temp(:,table_columns.bump_direction)),1,size(x_pos_translated,2)).*y_pos_translated;

    x_vel_rot_bump = diff(x_pos_rot_bump,[],2)*fs;
    y_vel_rot_bump = diff(y_pos_rot_bump,[],2)*fs;

    x_acc_rot_bump = diff(x_vel_rot_bump,[],2)*fs;
    y_acc_rot_bump = diff(y_vel_rot_bump,[],2)*fs;
    
    mean_y = mean(y_pos_rot_field(:,t_zero_idx));
    std_y = std(y_pos_rot_field(:,t_zero_idx));
    outliers = ~(y_pos_rot_field(:,t_zero_idx)<mean_y+2*std_y & y_pos_rot_field(:,t_zero_idx)>mean_y-2*std_y);

    initial_acc = x_acc_rot_bump(:,t_zero_idx);
    mean_acc = mean(initial_acc);
    std_acc = std(initial_acc);
    temp = ~(initial_acc > mean_acc-2*std_acc & initial_acc < mean_acc+2*std_acc);
    outliers = or(outliers,temp);
    
%     initial_x_force = x_force(:,t_zero_idx);
%     mean_x_force = mean(initial_x_force);
%     std_x_force = std(initial_x_force);
%     temp = ~(initial_x_force > mean_x_force-2*std_x_force & initial_x_force < mean_x_force+2*std_x_force);
%     outliers = or(outliers,temp);
%     
%     initial_y_force = y_force(:,t_zero_idx);
%     mean_y_force = mean(initial_y_force);
%     std_y_force = std(initial_y_force);
%     temp = ~(initial_y_force > mean_y_force-2*std_y_force & initial_y_force < mean_y_force+2*std_y_force);
%     outliers = or(outliers,temp);
%     outliers = [];
    x_pos = x_pos(~outliers,:);
    y_pos = y_pos(~outliers,:);
    x_vel = x_vel(~outliers,:);
    y_vel = y_vel(~outliers,:);
    x_acc = x_acc(~outliers,:);
    y_acc = y_acc(~outliers,:);
    x_force = x_force(~outliers,:);
    y_force = y_force(~outliers,:);
    trial_table_temp = trial_table_temp(~outliers,:);    
    idx_table = idx_table(~outliers,:);
    if num_emg>0
        emg_all = emg_all(:,~outliers,:);
    end
    disp(['Removed ' num2str(sum(outliers)) ' trials'])
end

x_pos_translated = x_pos-repmat(x_pos(:,t_zero_idx),1,size(y_pos,2));
y_pos_translated = y_pos-repmat(y_pos(:,t_zero_idx),1,size(y_pos,2));
x_pos_rot_bump = repmat(cos(-trial_table_temp(:,table_columns.bump_direction)),1,size(x_pos_translated,2)).*x_pos_translated -...
    repmat(sin(-trial_table_temp(:,table_columns.bump_direction)),1,size(x_pos_translated,2)).*y_pos_translated;
y_pos_rot_bump = repmat(sin(-trial_table_temp(:,table_columns.bump_direction)),1,size(x_pos_translated,2)).*x_pos_translated +...
    repmat(cos(-trial_table_temp(:,table_columns.bump_direction)),1,size(x_pos_translated,2)).*y_pos_translated;

x_vel_rot_bump = repmat(cos(-trial_table_temp(:,table_columns.bump_direction)),1,size(x_pos_translated,2)).*x_vel -...
    repmat(sin(-trial_table_temp(:,table_columns.bump_direction)),1,size(x_pos_translated,2)).*y_vel;
y_vel_rot_bump = repmat(sin(-trial_table_temp(:,table_columns.bump_direction)),1,size(x_pos_translated,2)).*x_vel +...
    repmat(cos(-trial_table_temp(:,table_columns.bump_direction)),1,size(x_pos_translated,2)).*y_vel;

x_acc_rot_bump = repmat(cos(-trial_table_temp(:,table_columns.bump_direction)),1,size(x_pos_translated,2)).*x_acc -...
    repmat(sin(-trial_table_temp(:,table_columns.bump_direction)),1,size(x_pos_translated,2)).*y_acc;
y_acc_rot_bump = repmat(sin(-trial_table_temp(:,table_columns.bump_direction)),1,size(x_pos_translated,2)).*x_acc +...
    repmat(cos(-trial_table_temp(:,table_columns.bump_direction)),1,size(x_pos_translated,2)).*y_acc;

% x_vel_rot_bump = diff(x_pos_rot_bump,[],2)*fs;
% y_vel_rot_bump = diff(y_pos_rot_bump,[],2)*fs;

% x_acc_rot_bump = diff(x_vel_rot_bump,[],2)*fs;
% y_acc_rot_bump = diff(y_vel_rot_bump,[],2)*fs;

x_jerk_rot_bump = diff(x_acc_rot_bump,[],2)*fs;
y_jerk_rot_bump = diff(y_acc_rot_bump,[],2)*fs;

x_pos_rot_field = repmat(cos(-trial_table_temp(:,table_columns.field_orientation)),1,size(x_pos,2)).*x_pos -...
    repmat(sin(-trial_table_temp(:,table_columns.field_orientation)),1,size(x_pos,2)).*y_pos;
y_pos_rot_field = repmat(sin(-trial_table_temp(:,table_columns.field_orientation)),1,size(x_pos,2)).*x_pos +...
    repmat(cos(-trial_table_temp(:,table_columns.field_orientation)),1,size(x_pos,2)).*y_pos;

x_force_translated = x_force-repmat(x_force(:,1),1,size(x_force,2));
y_force_translated = y_force-repmat(y_force(:,1),1,size(y_force,2));

x_force_rot_bump = repmat(cos(-trial_table_temp(:,table_columns.bump_direction)),1,size(x_force_translated,2)).*x_force_translated -...
    repmat(sin(-trial_table_temp(:,table_columns.bump_direction)),1,size(x_force_translated,2)).*y_force_translated;
y_force_rot_bump = repmat(sin(-trial_table_temp(:,table_columns.bump_direction)),1,size(x_force_translated,2)).*x_force_translated +...
    repmat(cos(-trial_table_temp(:,table_columns.bump_direction)),1,size(x_force_translated,2)).*y_force_translated;
    

%%
for iField = 1:length(field_orientations)
    field_indexes{iField} = find(trial_table_temp(:,table_columns.field_orientation)==field_orientations(iField));
end

for iBump = 1:length(bump_directions)
    bump_indexes{iBump} = find(trial_table_temp(:,table_columns.bump_direction)==bump_directions(iBump));
end

for iBias = 1:length(bias_force_directions)
    bias_indexes{iBias} = find(trial_table_temp(:,table_columns.bias_force_dir)==bias_force_directions(iBias));
end

%%
% Raw positions
figure(1)
clf
t_axis = (1/fs:1/fs:size(x_pos,2)/fs)+trial_range(1);
for iField = 1:length(field_indexes)
    for iBump = 1:length(bump_indexes)
        idx = intersect(field_indexes{iField},bump_indexes{iBump});
        [tmp t_idx] = min(abs(t_axis));        
        subplot(length(field_indexes),length(bump_indexes),(iField-1)*(length(bump_indexes))+iBump)
        plot(x_pos(idx,t_idx),y_pos(idx,t_idx),'k.','MarkerSize',10)
        hold on
        plot(x_pos(idx,t_idx:end)',y_pos(idx,t_idx:end)')
        xlim([-10 10])
        ylim([-10 10])
        axis square
        title(['F: ' num2str(round(field_orientations(iField)*180/pi))...
            'deg  B: ' num2str(round(bump_directions(iBump)*180/pi)) 'deg'])
        xlabel('X pos (cm)')
        ylabel('Y pos (cm)')        
    end
end
%%
% Raw forces
figure(2) 
clf
t_axis = (1/fs:1/fs:size(x_pos,2)/fs)+trial_range(1);
for iField = 1:length(field_indexes)
    for iBump = 1:length(bump_indexes)
        idx = intersect(field_indexes{iField},bump_indexes{iBump});
        [tmp t_idx] = min(abs(t_axis));        
        subplot(length(field_indexes),length(bump_indexes),(iField-1)*(length(bump_indexes))+iBump)
        plot(x_force(idx,t_idx),y_force(idx,t_idx),'k.','MarkerSize',10)
        hold on        
        plot(x_force(idx,t_idx:end)',y_force(idx,t_idx:end)')
        axis square
        xlim([-5 5])
        ylim([-5 5])
        title(['F: ' num2str(round(field_orientations(iField)*180/pi))...
            'deg  B: ' num2str(round(bump_directions(iBump)*180/pi)) 'deg'])
        xlabel('X force (N)')
        ylabel('Y force (N)')
    end
end
        
%% Aligned positions
figure(3)
clf
t_axis = (1/fs:1/fs:size(x_pos,2)/fs)+trial_range(1);
[tmp t_idx] = min(abs(t_axis)); 
for iField = 1:length(field_indexes)
    for iBump = 1:length(bump_indexes)
        idx = intersect(field_indexes{iField},bump_indexes{iBump});       
        figure(3)
        subplot(2,length(bump_indexes),(iField-1)*length(bump_indexes)+iBump)
        plot(x_pos_translated(idx,t_idx:end)',...
            y_pos_translated(idx,t_idx:end)','Color',colors_field(iField,:))
        hold on
        xlim([-10 10])
        ylim([-10 10])
        title(['Bump: ' num2str(round(bump_directions(iBump)*180/pi)) 'deg'])
        xlabel('X pos (cm)')
        ylabel('Y pos (cm)')
        axis square
    end
end 

%% Aligned forces
figure(4)
clf
t_axis = (1/fs:1/fs:size(x_force,2)/fs)+trial_range(1);
[~, t_idx] = min(abs(t_axis)); 
for iField = 1:length(field_indexes)
    for iBump = 1:length(bump_indexes)
        idx = intersect(field_indexes{iField},bump_indexes{iBump});        
        subplot(2,length(bump_indexes),(iField-1)*length(bump_indexes)+iBump)
        plot(x_force(idx,t_idx:end)'-repmat(x_force(idx,t_idx)',size(x_force(idx,t_idx:end),2),1),...
            y_force(idx,t_idx:end)'-repmat(y_force(idx,t_idx)',size(y_force(idx,t_idx:end),2),1),'Color',colors_field(iField,:))
        hold on
        axis square
        xlim([-5 5])
        ylim([-5 5])
        title(['Bump: ' num2str(round(bump_directions(iBump)*180/pi)) 'deg'])
        xlabel('X force (N)')
        ylabel('Y force (N)')
    end
end        
        
%% Force/position map
figure(5)
clf
t_axis = (1/fs:1/fs:size(x_pos,2)/fs)+trial_range(1);
x_pos_pre_bump = x_pos(:,t_axis<0);
y_pos_pre_bump = y_pos(:,t_axis<0);
x_force_pre_bump = x_force(:,t_axis<0);
y_force_pre_bump = y_force(:,t_axis<0);

dec_ratio = 10;
for iField = 1:length(field_indexes)    
    idx = field_indexes{iField};        
    figure(5)
    hold on
    quiver(x_pos_pre_bump(idx,1:dec_ratio:end)',y_pos_pre_bump(idx,1:dec_ratio:end)',...
        x_force_pre_bump(idx,1:dec_ratio:end)',y_force_pre_bump(idx,1:dec_ratio:end)','Color',colors_field(iField,:))
    xlim([-2 2])
    ylim([-2 2])
    axis square
end      
           
%%  Rotated with respect to bump: Position, velocity and acceleration
hf = figure;
clf
plot_range = [-.05 t_lim];
plot_vars = {'x_pos_rot_bump','y_pos_rot_bump',...
    'x_vel_rot_bump','y_vel_rot_bump',...
    'x_acc_rot_bump','y_acc_rot_bump'};
title_list = {'Position parallel to bump','Position perpendicular to bump',...
    'Velocity parallel to bump','Velocity perpendicular to bump',...
    'Acceleration parallel to bump','Acceleration perpendicular to bump'};
ylabel_list = {'Pos (cm)','Pos (cm)','Vel (cm/s)','Vel (cm/s)','Acc (cm/s)','Acc (cm/s)'};
    
for iPlot = 1:6
    subplot(3,2,iPlot)
    value_matrix = eval(plot_vars{iPlot});
    t_axis = (1/fs:1/fs:size(value_matrix,2)/fs)+trial_range(1);
    t_idx = (t_axis>plot_range(1) & t_axis<plot_range(2));
    hold on
    for iBump = 1:length(bump_directions)
        for iField = 1:length(field_orientations)           
            idx = intersect(field_indexes{iField},bump_indexes{iBump});
            temp_mean = mean(value_matrix(idx,t_idx),1);
            temp_std = std(value_matrix(idx,t_idx),[],1);
            temp_std = [temp_mean+temp_std,...            
                temp_mean(end:-1:1)-temp_std(end:-1:1)];
            temp_t = t_axis(t_idx);
            temp_t = [temp_t temp_t(end:-1:1)];
            area(temp_t,temp_std,'FaceColor',min(colors_bump(iBump,:)*1,[1 1 1]),'LineStyle','none')   
        end
    end
    for iBump = 1:length(bump_directions)
        for iField = 1:length(field_orientations)           
            idx = intersect(field_indexes{iField},bump_indexes{iBump});
            plot(t_axis(t_idx),mean(value_matrix(idx,t_idx)),'Color',colors_bump(iBump,:),'LineStyle',linelist{iField});
        end
    end
    alpha(0.1)
    ylabel(ylabel_list{iPlot})
    xlabel('t (s)')
    title(title_list{iPlot})
    xlim(plot_range)
    ylim([min(min(value_matrix(:,t_idx))) max(max(value_matrix(:,t_idx)))])
end

%% Maximum displacement after "t_lim" time
plot_range = [0 t_lim];
t_axis = (1/fs:1/fs:size(value_matrix,2)/fs)+trial_range(1);
[tmp t_idx] = min(abs(t_axis));
[~,t_end_idx] = min(abs(t_axis-t_lim));
max_x_pos = max(x_pos_rot_bump(:,t_idx:t_end_idx),[],2);
max_x_vel = max(x_vel_rot_bump(:,t_idx:t_end_idx),[],2);
max_x_acc = max(x_acc_rot_bump(:,t_idx:t_end_idx),[],2);

max_y_pos = sign(y_pos_rot_bump(:,t_end_idx)).*max(abs(y_pos_rot_bump(:,t_idx:t_end_idx)),[],2);
max_y_vel = max(abs(y_vel_rot_bump(:,t_idx:t_end_idx)),[],2);
max_y_acc = max(abs(y_acc_rot_bump(:,t_idx:t_end_idx)),[],2);

figure
hold on
xlabel('Maximum displacement parallel to bump (cm)')
ylabel('Maximum displacement perpendicular to bump (cm)')
for iField = 1:length(field_orientations)
    for iBump = 1:length(bump_directions)
        idx = intersect(field_indexes{iField},bump_indexes{iBump});
        mean_x = mean(max_x_pos(idx));
        std_x = std(max_x_pos(idx));
        mean_y = mean(max_y_pos(idx));
        std_y = std(max_y_pos(idx));
        plot(mean_x + [-std_x std_x],[mean_y mean_y],'LineWidth',2,'Color',colors_bump(iBump,:),'LineStyle',linelist{iField})
        plot([mean_x mean_x],mean_y +[-std_y std_y],'LineWidth',2,'Color',colors_bump(iBump,:),'LineStyle',linelist{iField})
    end
end
for iField = 1:length(field_orientations)
    for iBump = 1:length(bump_directions)
        idx = intersect(field_indexes{iField},bump_indexes{iBump});
        plot(max_x_pos(idx),max_y_pos(idx),'Color',colors_bump(iBump,:),...
            'Marker',markerlist{iField},'LineStyle','none','MarkerSize',10)
%         hold on
    end
end

max_max_x = 1.1*max(max_x_pos);
max_max_y = 1.1*max(max_y_pos);
text(.1*max_max_x,1*max_max_y,'Field orientations','HorizontalAlignment','center')
for iField = 1:length(field_orientations)
    plot(.1*max_max_x+.03*max_max_x*[-cos(field_orientations(iField)) cos(field_orientations(iField))],...
       .85*max_max_y+.03*max_max_x*[-sin(field_orientations(iField)) sin(field_orientations(iField))],... 
       'LineStyle',linelist{iField},'LineWidth',2,'Color','k',...
       'Marker',markerlist{iField},'MarkerSize',10)
end

text(.1*max_max_x,.65*max_max_y,'Bump directions','HorizontalAlignment','center')
for iBump = 1:length(bump_directions)
    plot(.1*max_max_x+.03*max_max_x*[0 cos(bump_directions(iBump))],...
       .5*max_max_y+.03*max_max_x*[0 sin(bump_directions(iBump))],... 
       'LineStyle','-','LineWidth',2,'Color',colors_bump(iBump,:))
end

xlim([0 max_max_x])
ylim([0 1.1*max_max_y])
axis equal

%% Maximum displacement after "t_lim" time
t_axis = (1/fs:1/fs:size(value_matrix,2)/fs)+trial_range(1);
[~, t_idx] = min(abs(t_axis));
[~, t_end_idx] = min(abs(t_axis-t_lim));

x_temp = x_pos_translated(:,t_idx:t_end_idx);
y_temp = y_pos_translated(:,t_idx:t_end_idx);
max_x_pos = sign(x_temp(:,end)).*max(abs(x_temp),[],2);
max_y_pos = sign(y_temp(:,end)).*max(abs(y_temp),[],2);

figure
hold on
xlabel('X position (cm)')
ylabel('Y position (cm)')
for iField = 1:length(field_orientations)
    for iBump = 1:length(bump_directions)
        idx = intersect(field_indexes{iField},bump_indexes{iBump});
        mean_x = mean(max_x_pos(idx));
        std_x = std(max_x_pos(idx));
        mean_y = mean(max_y_pos(idx));
        std_y = std(max_y_pos(idx));
        plot(mean_x + [-std_x std_x],[mean_y mean_y],'LineWidth',2,'Color',colors_bump(iBump,:),'LineStyle',linelist{iField})
        plot([mean_x mean_x],mean_y +[-std_y std_y],'LineWidth',2,'Color',colors_bump(iBump,:),'LineStyle',linelist{iField})
    end
end
for iField = 1:length(field_orientations)
    for iBump = 1:length(bump_directions)
        idx = intersect(field_indexes{iField},bump_indexes{iBump});
        plot(max_x_pos(idx),max_y_pos(idx),'Color',colors_bump(iBump,:),...
            'Marker',markerlist{iField},'LineStyle','none','MarkerSize',10)
        plot(x_temp(idx,:)',y_temp(idx,:)','Color',colors_bump(iBump,:),'LineStyle',linelist{iField})
    end
end

max_max_x = 1.1*max(max_x_pos);
max_max_y = 1.1*max(max_y_pos);
text(-.7*max_max_x,.8*max_max_y,'Field orientations','HorizontalAlignment','center')
max_max_x = 1.1*max(max_x_pos);
max_max_y = 1.1*max(max_y_pos);
for iField = 1:length(field_orientations)
    plot(-.7*max_max_x+.06*max_max_x*[-cos(field_orientations(iField)) cos(field_orientations(iField))],...
       .65*max_max_y+.06*max_max_x*[-sin(field_orientations(iField)) sin(field_orientations(iField))],... 
       'LineStyle',linelist{iField},'LineWidth',2,'Color','k',...
       'Marker',markerlist{iField},'MarkerSize',10)
end

text(-.7*max_max_x,.4*max_max_y,'Bump directions','HorizontalAlignment','center')
for iBump = 1:length(bump_directions)
    plot(-.7*max_max_x+.06*max_max_x*[0 cos(bump_directions(iBump))],...
       .25*max_max_y+.06*max_max_x*[0 sin(bump_directions(iBump))],... 
       'LineStyle','-','LineWidth',2,'Color',colors_bump(iBump,:))
end

xlim([-max_max_x max_max_x])
ylim([-max_max_y max_max_y])
axis equal

%% Starting position
t_axis = (1/fs:1/fs:size(value_matrix,2)/fs)+trial_range(1);
[~, t_idx] = min(abs(t_axis));
x_pos_start = x_pos(:,t_idx);
y_pos_start = y_pos(:,t_idx);

figure
hold on
xlabel('Starting X position (cm)')
ylabel('Starting Y position (cm)')
legend_text = {};
for iField = 1:length(field_orientations)    
    idx = field_indexes{iField};
    mean_x = mean(x_pos_start(idx));
    std_x = std(x_pos_start(idx));
    mean_y = mean(y_pos_start(idx));
    std_y = std(y_pos_start(idx));
    plot(mean_x + [-std_x std_x],[mean_y mean_y],'LineWidth',2,'Color',colors_field(iField,:))
    legend_text{iField} = ['Field at ' num2str(180*field_orientations(iField)/pi) '^o'];
end
for iField = 1:length(field_orientations)    
    idx = field_indexes{iField};
    mean_x = mean(x_pos_start(idx));
    std_x = std(x_pos_start(idx));
    mean_y = mean(y_pos_start(idx));
    std_y = std(y_pos_start(idx));   
    plot([mean_x mean_x],mean_y +[-std_y std_y],'LineWidth',2,'Color',colors_field(iField,:))
end
for iField = 1:length(field_orientations)
    idx = field_indexes{iField};
    plot(x_pos_start(idx),y_pos_start(idx),'Color',colors_field(iField,:),...
        'Marker',markerlist{iField},'LineStyle','none','MarkerSize',10)
end
legend(legend_text)
axis equal

%% Individual bump accelerations
figure;
plot_range = [-.05 t_lim];
t_axis = (1/fs:1/fs:size(value_matrix,2)/fs)+trial_range(1);
[~, t_idx] = min(abs(t_axis));

% t_axis = 1/fs:1/fs:size(x_acc_rot_bump,2)/fs;
y_limit = [min(min(x_acc_rot_bump(:,t_axis<t_lim))) max(max(x_acc_rot_bump(:,t_axis<t_lim)))];
x_limit = plot_range;
for iBump = 1:length(bump_directions)
    subplot(2,length(bump_directions)/2,iBump)
    hold on
    for iField = 1:length(field_orientations)           
        idx = intersect(field_indexes{iField},bump_indexes{iBump});
        temp_std = [mean(x_acc_rot_bump(idx,:),1)+std(x_acc_rot_bump(idx,:),[],1),...            
            mean(x_acc_rot_bump(idx,end:-1:1),1)-std(x_acc_rot_bump(idx,end:-1:1),[],1)];
        temp_t = [t_axis t_axis(end:-1:1)];
        area(temp_t,temp_std,'FaceColor',min(colors_field(iField,:)*1,[1 1 1]),'LineStyle','none')   
    end    
    alpha(0.1)
end
for iBump = 1:length(bump_directions)
    subplot(2,length(bump_directions)/2,iBump)
    hold on
    for iField = 1:length(field_orientations)           
        idx = intersect(field_indexes{iField},bump_indexes{iBump});
        plot(t_axis,mean(x_acc_rot_bump(idx,:)),'Color',colors_field(iField,:),'LineStyle','-');
    end
    ylabel('Acc (cm/s^2)')
    xlabel('t (s)')
    title(['Acceleration parallel to bump at ' num2str(180*bump_directions(iBump)/pi) '^o'])
    xlim(x_limit)
    ylim(y_limit)
    axis square
end

text(x_limit(1)+.2*(x_limit(2)-x_limit(1)),y_limit(1)+.4*(y_limit(2)-y_limit(1)),'Field orientations','HorizontalAlignment','center')
for iField = 1:length(field_orientations)
    plot(x_limit(1)+.2*(x_limit(2)-x_limit(1))+.1*(x_limit(2)-x_limit(1))*[-cos(field_orientations(iField)) cos(field_orientations(iField))],...
       y_limit(1)+.2*(y_limit(2)-y_limit(1))+.1*(y_limit(2)-y_limit(1))*[-sin(field_orientations(iField)) sin(field_orientations(iField))],... 
       'LineStyle','-','LineWidth',2,'Color',colors_field(iField,:))
end

%% Individual bump jerks
figure;
values_matrix = x_jerk_rot_bump;
% t_axis = 1/fs:1/fs:size(values_matrix,2)/fs;
t_axis = (1/fs:1/fs:size(values_matrix,2)/fs)+trial_range(1);
[~, t_idx] = min(abs(t_axis));

y_limit = [min(min(values_matrix(:,t_axis<t_lim))) max(max(values_matrix(:,t_axis<t_lim)))];
x_limit = [-0.05 t_lim];

for iBump = 1:length(bump_directions)
    subplot(2,length(bump_directions)/2,iBump)
    hold on
    for iField = 1:length(field_orientations)           
        idx = intersect(field_indexes{iField},bump_indexes{iBump});
        temp_std = [mean(values_matrix(idx,:),1)+std(values_matrix(idx,:),[],1),...            
            mean(values_matrix(idx,end:-1:1),1)-std(values_matrix(idx,end:-1:1),[],1)];
        temp_t = [t_axis t_axis(end:-1:1)];
        area(temp_t,temp_std,'FaceColor',min(colors_field(iField,:)*1,[1 1 1]),'LineStyle','none')   
    end    
    alpha(0.1)
end
for iBump = 1:length(bump_directions)
    subplot(2,length(bump_directions)/2,iBump)
    hold on
    for iField = 1:length(field_orientations)           
        idx = intersect(field_indexes{iField},bump_indexes{iBump});
        plot(t_axis,mean(values_matrix(idx,:)),'Color',colors_field(iField,:),'LineStyle','-');
    end
    ylabel('Jerk (cm/s^3)')
    xlabel('t (s)')
    title(['Jerk parallel to bump at ' num2str(180*bump_directions(iBump)/pi) '^o'])
    xlim(x_limit)
    ylim(y_limit)
    axis square
end

text(x_limit(1)+.2*(x_limit(2)-x_limit(1)),y_limit(1)+.4*(y_limit(2)-y_limit(1)),'Field orientations','HorizontalAlignment','center')
for iField = 1:length(field_orientations)
    plot(x_limit(1)+.2*(x_limit(2)-x_limit(1))+.1*(x_limit(2)-x_limit(1))*[-cos(field_orientations(iField)) cos(field_orientations(iField))],...
       y_limit(1)+.2*(y_limit(2)-y_limit(1))+.1*(y_limit(2)-y_limit(1))*[-sin(field_orientations(iField)) sin(field_orientations(iField))],... 
       'LineStyle','-','LineWidth',2,'Color',colors_field(iField,:))
end

%% End position as a function of time
figure
t_axis = (1/fs:1/fs:size(value_matrix,2)/fs)+trial_range(1);
field_transitions = find(diff(trial_table_temp(:,table_columns.field_orientation))~=0);
t_field_transitions = trial_table_temp(field_transitions,table_columns.t_trial_start);
for iField = 1:length(field_indexes)
    for iBump = 1:length(bump_indexes)
        idx = intersect(field_indexes{iField},bump_indexes{iBump});      
        [a t_idx] = min(abs(t_axis-t_lim));
        subplot(1,length(bump_indexes),iBump)
        plot(trial_table_temp(idx,table_columns.t_trial_start),x_pos_rot_bump(idx,t_idx),'.','Color',colors_field(iField,:))
        hold on
        plot([t_field_transitions t_field_transitions]',[zeros(size(field_transitions)),10*ones(size(field_transitions))]','k-');
        xlim([0 trial_table_temp(end,table_columns.t_trial_start)])
        ylim([min(x_pos_rot_bump(:,t_idx))-1 1+max(x_pos_rot_bump(:,t_idx))])
        xlabel('t (s)')
        ylabel('Final position parallel to bump (cm)')
        title(['Bump at ' num2str(180/pi*bump_directions(iBump)) '^o'])
    end
end        


%% Forces
figure
values_matrix = x_force_rot_bump;
% t_axis = 1/fs:1/fs:size(values_matrix,2)/fs;
t_axis = (1/fs:1/fs:size(value_matrix,2)/fs)+trial_range(1);
[~,t_idx] = min(abs(t_axis));
[~,t_end_idx] = min(abs(t_axis-t_lim));
y_limit = [min(min(values_matrix(:,t_idx:t_end_idx))) max(max(values_matrix(:,t_idx:t_end_idx)))];
x_limit = plot_range;
for iField = 1:length(field_orientations)
    for iBump = 1:length(bump_directions)
        idx = intersect(bump_indexes{iBump},field_indexes{iField});
        subplot(2,length(bump_directions)/2,iBump)
        hold on
        temp_std = [mean(values_matrix(idx,:),1)+std(values_matrix(idx,:),[],1),...            
            mean(values_matrix(idx,end:-1:1),1)-std(values_matrix(idx,end:-1:1),[],1)];
        temp_t = [t_axis t_axis(end:-1:1)];
        area(temp_t,temp_std,'FaceColor',min(colors_field(iField,:)*1,[1 1 1]),'LineStyle','none') 
        plot(t_axis,mean(values_matrix(idx,:)),'Color',colors_field(iField,:))
%         plot(t_axis,values_matrix(idx,:));
        xlim(x_limit)
        ylim(y_limit)
        alpha(.1)
        ylabel('Force (N)')
        xlabel('t (s)')
        title(['Force parallel to bump at ' num2str(180*bump_directions(iBump)/pi) '^o'])
    end
    
end

%% EMG

for iEMG = 1:num_emg
    figure
    temp_emg = squeeze(emg_all(iEMG,:,:));
    t_axis = (1/fs:1/fs:size(value_matrix,2)/fs)+trial_range(1);
    for iField = 1:length(field_indexes)
        for iBump = 1:length(bump_indexes)
            idx = intersect(field_indexes{iField},bump_indexes{iBump});      
            [a t_idx] = min(abs(t_axis-t_lim));
            subplot(1,length(bump_indexes),iBump)            
            hold on
            plot(t_axis,smooth(mean(temp_emg(idx,:)),1),'Color',colors_field(iField,:))
            title([bdf.emg.emgnames{iEMG} ' B:' num2str(bump_directions(iBump)*180/pi) ' deg'],'interpreter','none')
            xlabel('t (s)')
            ylabel('EMG (V)')
%             xlim([-.05 .15])
        end
        legend_str{iField} = ['F: ' num2str(field_orientations(iField)*180/pi) ' deg'];
    end      
    legend(legend_str,'interpreter','none')
end

%% Units
tic
if isfield(bdf,'units')
    t_axis = trial_range(1); 
    all_chans = reshape([bdf.units.id],2,[])';
    units = unit_list(bdf);
    dt = round(mean(diff(bdf.pos(:,1)))*10000)/10000;
    bin_size = dt;
    bin_width = 0.02;    
%     trial_range = [-3 0.5];

    neuron_t_axis = (1:(trial_range(2)-trial_range(1))/bin_size)*bin_size+trial_range(1);
    varnames = {'Bin','Bump X','Bump Y','Field orientation','Trial number','Bump on'};       
    
    hist_centers = neuron_t_axis(1):bin_width:neuron_t_axis(end);
    anova_bins = hist_centers > -0.1 & hist_centers < 0.15;      

    for iUnit = 1:size(units,1)    
        unit_idx = find(all_chans(:,1)==units(iUnit,1) & all_chans(:,2)==units(iUnit,2));    
        ts = bdf.units(unit_idx).ts; %#ok<FNDSB>
        ts_cell = {};    
        max_y = 0;
            
%         % anova independent variables
%         bump_dir_mat = zeros(size(trial_table_temp,1)-1,length(hist_centers));
        bump_x_mat = zeros(size(trial_table_temp,1)-1,length(hist_centers));
        bump_y_mat = zeros(size(trial_table_temp,1)-1,length(hist_centers));
        field_orientation_mat = zeros(size(trial_table_temp,1)-1,length(hist_centers));    
        trial_number_mat = zeros(size(trial_table_temp,1)-1,length(hist_centers));         
        bin_mat = zeros(size(trial_table_temp,1)-1,length(hist_centers)); 
        bump_on_mat = zeros(size(trial_table_temp,1)-1,length(hist_centers));         
        bump_on_mat(:,hist_centers>=0 & hist_centers <= bump_duration) = 1; 
%         %anova dependent variable
        hist_mat = zeros(size(trial_table_temp,1)-1,length(hist_centers));
%         fr_mat = zeros(size(trial_table_temp,1),length(neuron_t_axis));
        
        figure
        hold on
        unit_idx = find(all_chans(:,1)==units(iUnit,1) & all_chans(:,2)==units(iUnit,2));    
        fr = spikes2fr(bdf.units(unit_idx).ts,bdf.pos(:,1),.01);
        unit_all_trials = zeros(size(trial_table_temp,1),length(neuron_t_axis));
        spikes_vector = [];
        for iTrial = 1:size(trial_table_temp,1)-1
            idx = idx_table(iTrial,:);
            unit_all_trials(iTrial,:) = fr(idx);
                    
            spikes_temp = bdf.units(unit_idx).ts(bdf.units(unit_idx).ts>trial_table_temp(iTrial,table_columns.t_bump_onset)+trial_range(1) &...
                bdf.units(unit_idx).ts < trial_table_temp(iTrial,table_columns.t_bump_onset)+trial_range(2));
            spikes_temp = reshape(spikes_temp - trial_table_temp(iTrial,table_columns.t_bump_onset),[],1);
            spikes_vector = [spikes_vector [spikes_temp';repmat(iTrial,1,length(spikes_temp))]];
%             bump_dir_mat(iTrial,:) = trial_table_temp(iTrial,table_columns.bump_direction);
            bump_x_mat(iTrial,:) = round(1000*cos(trial_table_temp(iTrial,table_columns.bump_direction)))/1000;
            bump_y_mat(iTrial,:) = round(1000*sin(trial_table_temp(iTrial,table_columns.bump_direction)))/1000;
            field_orientation_mat(iTrial,:) = trial_table_temp(iTrial,table_columns.field_orientation);
            trial_number_mat(iTrial,:) = iTrial;
            fr_mat(iTrial,:) = fr(idx);
            
            ts_temp = ts(ts>trial_table(iTrial,table_columns.t_bump_onset)+neuron_t_axis(1) &...
                ts<trial_table(iTrial,table_columns.t_bump_onset)+neuron_t_axis(end));
            ts_temp = ts_temp' - trial_table(iTrial,table_columns.t_bump_onset);
            ts_cell{iTrial} = ts_temp;
            hist_mat(iTrial,:) = hist(ts_cell{iTrial},hist_centers);
            bin_mat(iTrial,:) = 1:size(bin_mat,2);
        end
        max_y = .5*iTrial;        
       
        for iBias = 1:length(bias_indexes)
            for iField = 1:length(field_indexes)
                for iBump = 1:length(bump_indexes)
                    idx = intersect(field_indexes{iField},bump_indexes{iBump});
                    idx = intersect(idx,bias_indexes{iBias});
                    subplot(1,length(bump_indexes),iBump)               
                    spikes_idx = [];
                    for iTrial = 1:length(idx)
                        spikes_idx = [spikes_idx find(spikes_vector(2,:)==idx(iTrial))];
                    end
                    plot(spikes_vector(1,spikes_idx),.5*spikes_vector(2,spikes_idx),'.','Color',...
                        min([1,1,1],colors_field_bias((iBias-1)*length(field_indexes)+iField,:)+.7),'MarkerSize',5)
                    hold on
                end
            end
                 end
        
        for iBias = 1:length(bias_indexes)
            for iField = 1:length(field_indexes)
                for iBump = 1:length(bump_indexes)
                    idx = intersect(field_indexes{iField},bump_indexes{iBump});
                    idx = intersect(idx,bias_indexes{iBias});
                    subplot(1,length(bump_indexes),iBump)               
                    plot(neuron_t_axis,mean(unit_all_trials(idx,:),1),'Color',...
                        colors_field_bias((iBias-1)*length(field_indexes)+iField,:),'LineWidth',2)
                    title(['B:' num2str(bump_directions(iBump)*180/pi) ' deg'],'interpreter','none')
                    ylim([0 size(trial_table_temp,1)/2])
                    ylabel('Firing rate (1/s)')
                    xlabel('t (s)')
                    max_y = max(max_y,max(mean(unit_all_trials(idx,:),1)));
                end
%                 legend_str{iField} = ['Field: ' num2str(field_orientations(iField)*180/pi) ' deg'];
                legend_str{(iBias-1)*length(field_indexes)+iField} = ['F: ' num2str(field_orientations(iField)*180/pi) ' deg' ' BF: ' num2str(round(bias_force_directions(iBias)*180/pi)) ' deg'];
            end
        end
        legend(legend_str,'interpreter','none')
        set(gcf,'name',['Channel: ' num2str(units(iUnit,1))],'numbertitle','off')
        drawnow 
        
        for iBump = 1:length(bump_indexes)
            subplot(1,length(bump_indexes),iBump)
            ylim([0 1.2*max_y])
            xlim([-0.1 .15])
        end
%         [p,table,stats] = anovan(fr_mat(:),{t_mat(:),bump_dir_mat(:),field_orientation_mat(:),...
%             trial_number_mat(:),bump_on_mat(:)},...
%             'model','interaction','continuous',[1 4],'varnames',varnames,'display','on');
        hist_mat = hist_mat(:,anova_bins);
%         bump_dir_mat = bump_dir_mat(:,anova_bins);
        bump_x_mat = bump_x_mat(:,anova_bins);
        bump_y_mat = bump_y_mat(:,anova_bins);
        field_orientation_mat = field_orientation_mat(:,anova_bins);
        bin_mat = bin_mat(:,anova_bins);
        trial_number_mat = trial_number_mat(:,anova_bins);
        bump_on_mat = bump_on_mat(:,anova_bins);
        
        [p,table,stats] = anovan(hist_mat(:),{bin_mat(:),bump_x_mat(:),bump_y_mat(:),field_orientation_mat(:),...
            trial_number_mat(:),bump_on_mat(:)},...
            'model','interaction','continuous',[1 2 3 5],'varnames',varnames,'display','on');
        table(find(p<0.05)+1,1)
        
        pause
    end
end
toc

%% TODO

% poop