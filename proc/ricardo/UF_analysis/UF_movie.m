% UF movie
dataset = 2;
% dataset 1 = 90 degree bumps, 2 field orientations
% dataset 2 = 90/270 degree bumps, 1 field orientation, bias force  90
% dataset 3 = 90/270 degree bumps, 1 field orientation, bias force  270
% dataset 4 = 90 degree bumps, 1 field orientation, 2 bias force directions

start_time = -.05;
end_time = .15;
dt = mode(diff(bdf.pos(:,1)));
frame_rate = 10;
play_vel = .1;
frame_step = frame_rate*play_vel;

num_samples = sum(bdf.pos(:,1)>=trial_table_temp(1,table_columns.t_bump_onset)+start_time &...
    bdf.pos(:,1)<=trial_table_temp(1,table_columns.t_bump_onset)+end_time);
all_idx = 1:size(bdf.pos,1);
t_vector = round(bdf.pos(:,1)/dt)*dt;
t_axis = start_time:dt:end_time;
[~,first_idx,~] = intersect(t_vector,round((trial_table_temp(:,table_columns.t_bump_onset)+start_time)/dt)*dt);
idx_table = repmat(first_idx,1,num_samples) + repmat(1:num_samples,size(first_idx,1),1);
x_pos_video = reshape(bdf.pos(idx_table,2),[],num_samples);
y_pos_video = reshape(bdf.pos(idx_table,3),[],num_samples);

x_force_video = -reshape(bdf.force(idx_table,2),[],num_samples);
x_force_offset = mean(mean(x_force_video(:,end-100:end)));
x_force_video = x_force_video -x_force_offset;

y_force_video = -reshape(bdf.force(idx_table,3),[],num_samples);
y_force_offset = mean(mean(y_force_video(:,end-100:end)));
y_force_video = y_force_video - y_force_offset;

emg_all_video = zeros(num_emg,size(trial_table_temp,1),num_samples);

emg_fs = double(1/mean(diff(bdf.emg.data(:,1))));
t_vector = round(double(bdf.emg.data(:,1))*round(emg_fs))/emg_fs;
num_samples_emg = sum(bdf.emg.data(:,1)>=trial_table_temp(1,table_columns.t_bump_onset)+start_time &...
bdf.emg.data(:,1)<=trial_table_temp(1,table_columns.t_bump_onset)+end_time);
[~,first_idx,~] = intersect(t_vector,round((trial_table_temp(:,table_columns.t_bump_onset)+start_time)*emg_fs)/emg_fs);
emg_idx_table = repmat(first_idx,1,num_samples_emg) + repmat(1:num_samples_emg,size(first_idx,1),1);
    
for iEMG = 1:num_emg        
    emg_all_video(iEMG,:,:) = reshape(emg_filtered(emg_idx_table,iEMG),[],num_samples_emg);
end

%%
switch dataset
    case 1
    % 90 degree bumps, 2 field orientations
    clear trial_idx
    trial_idx{1} = intersect(find(trial_table_temp(:,table_columns.bias_force_dir)==bias_force_directions(1)),...
        find(trial_table_temp(:,table_columns.field_orientation)==field_orientations(1)));
    trial_idx{1} = intersect(trial_idx{1},find(trial_table_temp(:,table_columns.bump_direction)==bump_directions(2)));
    trial_idx{2} = intersect(find(trial_table_temp(:,table_columns.bias_force_dir)==bias_force_directions(1)),...
        find(trial_table_temp(:,table_columns.field_orientation)==field_orientations(2)));
    trial_idx{2} = intersect(trial_idx{2},find(trial_table_temp(:,table_columns.bump_direction)==bump_directions(2)));

    case 2
    % 90/270 degree bumps, 1 field orientation, bias force  90
    clear trial_idx
    trial_idx{1} = intersect(find(trial_table_temp(:,table_columns.bias_force_dir)==bias_force_directions(1)),...
        find(trial_table_temp(:,table_columns.field_orientation)==field_orientations(1)));
    trial_idx{1} = intersect(trial_idx{1},find(trial_table_temp(:,table_columns.bump_direction)==bump_directions(2)));
    trial_idx{2} = intersect(find(trial_table_temp(:,table_columns.bias_force_dir)==bias_force_directions(1)),...
        find(trial_table_temp(:,table_columns.field_orientation)==field_orientations(1)));
    trial_idx{2} = intersect(trial_idx{2},find(trial_table_temp(:,table_columns.bump_direction)==bump_directions(4)));
    
    case 3
    % 90/270 degree bumps, 1 field orientation, bias force  270
    clear trial_idx
    trial_idx{1} = intersect(find(trial_table_temp(:,table_columns.bias_force_dir)==bias_force_directions(2)),...
        find(trial_table_temp(:,table_columns.field_orientation)==field_orientations(1)));
    trial_idx{1} = intersect(trial_idx{1},find(trial_table_temp(:,table_columns.bump_direction)==bump_directions(2)));
    trial_idx{2} = intersect(find(trial_table_temp(:,table_columns.bias_force_dir)==bias_force_directions(2)),...
        find(trial_table_temp(:,table_columns.field_orientation)==field_orientations(1)));
    trial_idx{2} = intersect(trial_idx{2},find(trial_table_temp(:,table_columns.bump_direction)==bump_directions(4)));
    
    case 4
    % 90 degree bumps, 1 field orientation, 2 bias force directions
    clear trial_idx
    trial_idx{1} = intersect(find(trial_table_temp(:,table_columns.bias_force_dir)==bias_force_directions(1)),...
        find(trial_table_temp(:,table_columns.field_orientation)==field_orientations(2)));
    trial_idx{1} = intersect(trial_idx{1},find(trial_table_temp(:,table_columns.bump_direction)==bump_directions(2)));
    trial_idx{2} = intersect(find(trial_table_temp(:,table_columns.bias_force_dir)==bias_force_directions(2)),...
        find(trial_table_temp(:,table_columns.field_orientation)==field_orientations(2)));
    trial_idx{2} = intersect(trial_idx{2},find(trial_table_temp(:,table_columns.bump_direction)==bump_directions(2)));

    trial_idx{3} = intersect(find(trial_table_temp(:,table_columns.bias_force_dir)==bias_force_directions(1)),...
        find(trial_table_temp(:,table_columns.field_orientation)==field_orientations(2)));
    trial_idx{3} = intersect(trial_idx{3},find(trial_table_temp(:,table_columns.bump_direction)==bump_directions(4)));
    trial_idx{4} = intersect(find(trial_table_temp(:,table_columns.bias_force_dir)==bias_force_directions(2)),...
        find(trial_table_temp(:,table_columns.field_orientation)==field_orientations(2)));
    trial_idx{4} = intersect(trial_idx{4},find(trial_table_temp(:,table_columns.bump_direction)==bump_directions(4)));
end
%%
plot_colors = lines(8);
figure(1)
clf
subplot(2,2,1)
hold on
for iVar = 1:length(trial_idx)
    hpos{iVar} = plot(x_pos_video(trial_idx{iVar},1),y_pos_video(trial_idx{iVar},1),'o','Color',plot_colors(iVar,:));    
end
hold off
xlim([-7 7])
ylim([-7 7])
title('Position')
xlabel('X pos (cm)')
ylabel('Y pos (cm)')
axis square
subplot(2,2,2)
hold on
for iVar = 1:length(trial_idx)
    hforce{iVar} = plot(x_force_video(trial_idx{iVar},1),y_force_video(trial_idx{iVar},1),'o','Color',plot_colors(iVar,:));    
end
hold off
xlim([-5 5])
ylim([-5 5])
axis square
title('Force')
xlabel('X force (N)')
ylabel('Y force (N)')
subplot(2,2,3)
hold on
for iVar = 1:length(trial_idx)
    hBI{iVar} = plot(start_time,mean(emg_all_video(1,trial_idx{iVar},1)),'-','Color',plot_colors(iVar,:));
end
hold off
xlim([start_time end_time])
ylim([0 median(max(squeeze(emg_all_video(1,:,:)),[],2))])
axis square
title('Biceps','interpreter','none')
xlabel('time (s)')
ylabel('|EMG| (mV)')
subplot(2,2,4)
hold on
for iVar = 1:length(trial_idx)
    hTRI{iVar} = plot(start_time,mean(emg_all_video(2,trial_idx{iVar},1)),'-','Color',plot_colors(iVar,:));
end
hold off
xlim([start_time end_time])
ylim([0 median(max(squeeze(emg_all_video(2,:,:)),[],2))])
axis square
title('Triceps','interpreter','none')
xlabel('time (s)')
ylabel('|EMG| (mV)')
drawnow

for iFrame = 2:frame_step:size(x_pos_video,2)
    tic
    for iVar = 1:length(trial_idx)
        set(hpos{iVar},'XData',x_pos_video(trial_idx{iVar},iFrame),'YData',y_pos_video(trial_idx{iVar},iFrame))
        set(hforce{iVar},'XData',x_force_video(trial_idx{iVar},iFrame),'YData',y_force_video(trial_idx{iVar},iFrame))
        set(hBI{iVar},'XData',t_axis(1:iFrame),'YData',mean(squeeze(emg_all_video(1,trial_idx{iVar},1:iFrame))))
        set(hTRI{iVar},'XData',t_axis(1:iFrame),'YData',mean(squeeze(emg_all_video(2,trial_idx{iVar},1:iFrame))))        
    end
    drawnow
    temp = toc;
    pause(dt*frame_step/play_vel-temp)
end


