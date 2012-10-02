% clear all
datapath = 'D:\Data\Kevin_12A2';
filenames = dir([datapath '\Kevin_2012-10-02*.nev']);
% filenames(end+1) = dir([datapath '\Kevin_2012-09-18*.nev']);

trial_table = [];
for iFile = 1:length(filenames)   
    filename_no_ext = filenames(iFile).name(1:end-4);
    if ~exist([datapath '\' filename_no_ext '.mat'])
        bdf = get_cerebus_data([datapath '\' filenames(iFile).name],3);    
        save([datapath '\' filename_no_ext],'bdf');        
    else
        load([datapath '\' filename_no_ext],'bdf');        
    end
    bdf_temp = bdf;    
    if strcmp(filename_no_ext,'Kevin_2012-09-28_UF_002')
        bdf_temp.words(732,:) = [];
    end
%     if strcmp(filename_no_ext,'Kevin_2012-10-02_UF_001')
%         bdf_temp.words(find(bdf.words(:,1)>120.95,1,'first'),:) = [];
%     end
    if iFile == 1
        bdf_all = bdf;
        [trial_table_temp table_columns] = UF_trial_table(bdf_temp);
        trial_table_temp = trial_table_temp(1:end-1,:);
    else        
        old_end_time = trial_table(end,table_columns.t_trial_end);
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
        else
            error('Poop')
        end
    end    
   	trial_table = [trial_table; trial_table_temp];
end
bdf = bdf_all;
trial_table(:,table_columns.bump_direction) = round(trial_table(:,table_columns.bump_direction)*180/pi)*pi/180;
bump_duration = trial_table(1,table_columns.bump_duration);

t_lim = min(trial_table(:,table_columns.bump_duration));
fs = 1/diff(bdf.pos(1:2,1));
field_orientations = unique(trial_table(:,table_columns.field_orientation));
bump_directions = unique(trial_table(:,table_columns.bump_direction));
colors_bump = lines(length(bump_directions));
colors_field = lines(length(field_orientations));
colors_field = [0 0 1; 1 0 0; 0 1 0];
markerlist = {'^','o','.','*'};
linelist = {'-','-.','--',':'};

rewarded_trials = find(trial_table(:,table_columns.result)==32);
aborted_trials = find(trial_table(:,table_columns.result)==33);
field_indexes = cell(1,length(field_orientations));
bump_indexes = cell(1,length(bump_directions));
trial_range = [-.2 .5];

%% Adjust kinematics

% encoder = bdf.raw.enc;

% Remove position offset
bdf.pos(:,2) = bdf.pos(:,2) + trial_table(1,table_columns.x_offset); 
bdf.pos(:,3) = bdf.pos(:,3) + trial_table(1,table_columns.y_offset); 

vel = zeros(size(bdf.pos));
vel(:,1) = bdf.pos(:,1);
vel(:,2) = [0 ; diff(bdf.pos(:,2))*fs];
vel(:,3) = [0 ; diff(bdf.pos(:,3))*fs];

% [b,a] = butter(8, 200/fs);
% vel(:,2) = filtfilt(b, a, vel(:,2));
% vel(:,3) = filtfilt(b, a, vel(:,3));

acc = zeros(size(bdf.pos));
acc(:,1) = bdf.pos(:,1);
acc(:,2) = [0 ; diff(vel(:,2))*fs];
acc(:,3) = [0 ; diff(vel(:,3))*fs];

% [b,a] = butter(8, 400/fs);
% acc(:,2) = filtfilt(b, a, acc(:,2));
% acc(:,3) = filtfilt(b, a, acc(:,3));

% Remove force offset
xy_movement = sqrt(diff(bdf.pos(:,2)).^2+diff(bdf.pos(:,3)).^2);
handle_not_moving_idx = intersect(find(xy_movement<1e-16),find(abs(bdf.pos(:,2))<20 & abs(bdf.pos(:,3)<10)));
% handle_not_moving_idx = find(xy_movement<50*min(xy_movement));
x_force_offset = mean(bdf.force(handle_not_moving_idx,2));
y_force_offset = mean(bdf.force(handle_not_moving_idx,3));
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
bdf.force(:,2) = bdf.force(:,2) - x_force_offset;
bdf.force(:,3) = bdf.force(:,3) - y_force_offset;

trial_table_temp = trial_table(rewarded_trials,:);

x_pos = zeros(size(trial_table_temp,1),length(find(bdf.pos(:,1)>trial_table_temp(1,table_columns.t_bump_onset)+trial_range(1) &...
        bdf.pos(:,1)<trial_table_temp(1,table_columns.t_bump_onset)+trial_range(2))));
y_pos = x_pos;
x_vel = x_pos;
y_vel = x_pos;
x_acc = x_pos;
y_acc = x_pos;
x_force = x_pos;
y_force = x_pos;
% s_enc = x_pos;
% e_enc = x_pos;

for iTrial = 1:size(trial_table_temp,1)
    idx = find(bdf.pos(:,1)>=trial_table_temp(iTrial,table_columns.t_bump_onset)+trial_range(1),1,'first'):...
        find(bdf.pos(:,1)>=trial_table_temp(iTrial,table_columns.t_bump_onset)+trial_range(1),1,'first')+size(x_pos,2)-1;
    x_pos(iTrial,:) = bdf.pos(idx,2);
    y_pos(iTrial,:) = bdf.pos(idx,3);
    x_vel(iTrial,:) = vel(idx,2);
    y_vel(iTrial,:) = vel(idx,3);
    x_acc(iTrial,:) = acc(idx,2);
    y_acc(iTrial,:) = acc(idx,3);
    x_force(iTrial,:) = bdf.force(idx,2);
    y_force(iTrial,:) = bdf.force(idx,3);        
end
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

    x_pos = x_pos(~outliers,:);
    y_pos = y_pos(~outliers,:);
    x_vel = x_vel(~outliers,:);
    y_vel = y_vel(~outliers,:);
    x_acc = x_acc(~outliers,:);
    y_acc = y_acc(~outliers,:);
    x_force = x_force(~outliers,:);
    y_force = y_force(~outliers,:);
    trial_table_temp = trial_table_temp(~outliers,:);    
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

%%
% Raw positions
t_axis = (1/fs:1/fs:size(x_pos,2)/fs)+trial_range(1);
for iField = 1:length(field_indexes)
    for iBump = 1:length(bump_indexes)
        idx = intersect(field_indexes{iField},bump_indexes{iBump});
        [tmp t_idx] = min(abs(t_axis));
        figure(1)
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
        xlabel('X force (?)')
        ylabel('Y force (?)')
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
        subplot(2,2,iBump)
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
        subplot(2,2,iBump)
        plot(x_force(idx,t_idx:end)'-repmat(x_force(idx,t_idx)',size(x_force(idx,t_idx:end),2),1),...
            y_force(idx,t_idx:end)'-repmat(y_force(idx,t_idx)',size(y_force(idx,t_idx:end),2),1),'Color',colors_field(iField,:))
        hold on
        axis square
        xlim([-5 5])
        ylim([-5 5])
        title(['Bump: ' num2str(round(bump_directions(iBump)*180/pi)) 'deg'])
        xlabel('X force (?)')
        ylabel('Y force (?)')
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
    subplot(2,2,iBump)
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
    subplot(2,2,iBump)
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
    subplot(2,2,iBump)
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
    subplot(2,2,iBump)
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
        subplot(2,2,iBump)
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
    end
    
end

%% TODO

% poop