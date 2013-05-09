% clear all
UF_file_prefix = 'Kevin_2013-05-08_UF';
RW_file_prefix = 'Kevin_2013-05-08_RW_001';
datapath = 'D:\Data\Kevin_12A2\Data\';
cerebus2ElectrodesFile = '\\citadel\limblab\lab_folder\Animal-Miscellany\Kevin 12A2\Microdrive info\MicrodriveMapFile_diagonal.cmp';
elec_map = cerebusToElectrodeMap(cerebus2ElectrodesFile);

reload_data = 1;
plot_behavior = 0;
plot_emg = 1;
plot_units = 0;
plot_STEMG = 0;

if ~exist([datapath UF_file_prefix '-bdf.mat'],'file')
    reload_data = 1;
end

if reload_data        
    % Experimental!        (but then again, what isn't?)
    NEVNSx = concatenate_NEVs(datapath,UF_file_prefix);
    bdf = get_nev_mat_data(NEVNSx,3);

    NEVNSx_RW = concatenate_NEVs(datapath,RW_file_prefix);
    rw_bdf = get_nev_mat_data(NEVNSx_RW,3);
    save([datapath UF_file_prefix '-bdf'],'bdf','rw_bdf');
else
    if ~exist('bdf','var') || ~exist('rw_bdf','var')
        load([datapath UF_file_prefix '-bdf'],'bdf','rw_bdf');
    end
end        
       
PDs = PD_table(rw_bdf,0);
[trial_table table_columns] = UF_trial_table(bdf);

bump_duration = trial_table(1,table_columns.bump_duration);

t_lim = min(trial_table(:,table_columns.bump_duration));
fs = 1/diff(bdf.pos(1:2,1));



markerlist = {'^','o','.','*'};
linelist = {'-','-.','--',':'};

rewarded_trials = find(trial_table(:,table_columns.result)==32);
aborted_trials = find(trial_table(:,table_columns.result)==33);


trial_range = [-.5 .5];
if isfield(bdf,'emg')
    num_emg = size(bdf.emg.emgnames,2);
else
    num_emg = 0;
end

% num_emg = 0;

% Adjust kinematics
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


trial_table_temp = trial_table(rewarded_trials,:);
trial_table_temp = trial_table_temp(1:end-1,:);

if num_emg>0
    emg_all = zeros(num_emg,size(trial_table_temp,1),length(find(bdf.emg.data(:,1)>trial_table_temp(1,table_columns.t_bump_onset)+trial_range(1) &...
            bdf.emg.data(:,1)<trial_table_temp(1,table_columns.t_bump_onset)+trial_range(2))));

    % Process EMG
    emg_filtered = zeros(size(bdf.emg.data,1),num_emg);
    for iEMG = 1:num_emg
        [b,a] = butter(4,10/(bdf.emg.emgfreq/2),'high');
        emg_filtered(:,iEMG)=abs(filtfilt(b,a,double(bdf.emg.data(:,iEMG+1))));   
    end
end

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
x_force = -reshape(bdf.force(idx_table,2),[],num_samples);
y_force = -reshape(bdf.force(idx_table,3),[],num_samples);

clear vel acc

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

%         mean_y = mean(y_pos_rot_field(:,t_zero_idx));
%         std_y = std(y_pos_rot_field(:,t_zero_idx));
%         outliers = ~(y_pos_rot_field(:,t_zero_idx)<mean_y+3*std_y & y_pos_rot_field(:,t_zero_idx)>mean_y-3*std_y);
    outliers = zeros(size(x_pos,1),1);

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

field_orientations = unique(trial_table_temp(:,table_columns.field_orientation));
bump_directions = unique(trial_table_temp(:,table_columns.bump_direction));
bias_force_directions = unique(trial_table_temp(:,table_columns.bias_force_dir));
bump_magnitudes = unique(trial_table_temp(:,table_columns.bump_velocity));

colors_bump = lines(length(bump_directions));
colors_field = lines(length(field_orientations));
colors_field = [0 0 1; 1 0 0; 0 1 0];
colors_bump_mag = lines(length(bump_magnitudes));

colors_field_bias = lines(length(field_orientations)*length(bias_force_directions));

field_indexes = cell(1,length(field_orientations));
bump_indexes = cell(1,length(bump_directions));
bias_indexes = cell(1,length(bias_force_directions));
bump_mag_indexes = cell(1,length(bump_magnitudes));

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

for iBumpMag = 1:length(bump_magnitudes)
    bump_mag_indexes{iBumpMag} = find(trial_table_temp(:,table_columns.bump_velocity)==bump_magnitudes(iBumpMag));
end

t_axis = (1/fs:1/fs:size(x_pos,2)/fs)+trial_range(1);
[tmp t_idx] = min(abs(t_axis)); 
[~,t_end_idx] = min(abs(t_axis-t_lim));
bump_dir_actual = zeros(length(bump_indexes),length(field_indexes));
x_temp = x_pos_translated(:,t_idx:t_end_idx);
y_temp = y_pos_translated(:,t_idx:t_end_idx);
max_x_pos = sign(x_temp(:,end)).*max(abs(x_temp),[],2);
max_y_pos = sign(y_temp(:,end)).*max(abs(y_temp),[],2);
for iField = 1:length(field_orientations)
    for iBump = 1:length(bump_directions)
        idx = intersect(field_indexes{iField},bump_indexes{iBump});
        mean_x = mean(max_x_pos(idx));
        std_x = std(max_x_pos(idx));
        mean_y = mean(max_y_pos(idx));
        std_y = std(max_y_pos(idx));
        bump_dir_actual(iBump,iField) = atan2(mean_y,mean_x);
    end    
end
bump_dir_actual(bump_dir_actual<0)=2*pi+bump_dir_actual(bump_dir_actual<0);
bump_dir_actual = mean(bump_dir_actual,2);

bump_force_dir_actual = atan2(mean(y_force(:,t_axis>0.03 & t_axis<bump_duration),2)-...
    mean(y_force(:,t_axis>-.05 & t_axis<0),2),...
    mean(x_force(:,t_axis>0.03 & t_axis<bump_duration),2)-...
    mean(x_force(:,t_axis>-.05 & t_axis<0),2));
bump_force_dir_actual(bump_force_dir_actual<0) = bump_force_dir_actual(bump_force_dir_actual<0)+2*pi;

% %% Bump magnitude test (remove when done)
% t_axis = (1/fs:1/fs:size(x_pos,2)/fs)+trial_range(1);
% figure
% subplot(211)
% hold on
% for iBumpMag = 1:length(bump_magnitudes)
%     plot(t_axis,x_force_rot_bump(bump_mag_indexes{iBumpMag},:)','Color',colors_bump_mag(iBumpMag,:))
% end
% xlabel('t (s)')
% ylabel('F (N)')
% title('Force parallel to bump')
% xlim([t_axis(1) t_axis(end)])
% subplot(212)
% hold on
% for iBumpMag = 1:length(bump_magnitudes)
%     mean_bump_mag(iBumpMag) = mean(mean(x_force_rot_bump(bump_mag_indexes{iBumpMag},find(t_axis>.05 & t_axis<bump_duration))));
%     plot(bump_magnitudes(iBumpMag),mean_bump_mag(iBumpMag),...
%         '.','Color',colors_bump_mag(iBumpMag,:),'MarkerSize',15)
% end
% plot(bump_magnitudes,mean_bump_mag)
% xlabel('Commanded force (N)')
% ylabel('Mean bump force (N)')
% 
% % Bump magnitude test (remove when done)
% t_axis = (1/fs:1/fs:size(x_pos,2)/fs)+trial_range(1);
% figure
% subplot(211)
% hold on
% for iBiasForce = 1:length(bias_force_directions)   
%     for iBumpMag = 1:length(bump_magnitudes)
%         idx = intersect(bias_indexes{iBiasForce},bump_mag_indexes{iBumpMag});
%         idx = intersect(idx,bump_indexes{4});
%         if iBiasForce == 1
%             plot(t_axis,mean(x_force_rot_bump(idx,:)),'Color',colors_bump_mag(iBumpMag,:)) 
%         else
%             plot(t_axis,mean(x_force_rot_bump(idx,:)),'Color',colors_bump_mag(iBumpMag,:),'LineStyle','--')  
%         end
%     end
% end
% xlabel('t (s)')
% ylabel('F (N)')
% title('Force parallel to bump')
% xlim([t_axis(1) t_axis(end)])
% subplot(212)
% hold on
% for iBumpMag = 1:length(bump_magnitudes)
%     mean_bump_mag(iBumpMag) = mean(mean(x_force_rot_bump(bump_mag_indexes{iBumpMag},find(t_axis>.05 & t_axis<bump_duration))));
%     plot(bump_magnitudes(iBumpMag),mean_bump_mag(iBumpMag),...
%         '.','Color',colors_bump_mag(iBumpMag,:),'MarkerSize',15)
% end
% plot(bump_magnitudes,mean_bump_mag)
% xlabel('Commanded force (N)')
% ylabel('Mean bump force (N)')
%%
if plot_behavior
    %% Raw positions
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

%     bump_dir_actual = zeros(length(bump_indexes),length(field_indexes));

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
%             bump_dir_actual(iBump,iField) = atan2(mean_y,mean_x);
        end    
    end
%     bump_dir_actual(bump_dir_actual<0)=2*pi+bump_dir_actual(bump_dir_actual<0);
%     bump_dir_actual = mean(bump_dir_actual,2);
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

    % %% Individual bump accelerations
    % figure;
    % plot_range = [-.05 t_lim];
    % t_axis = (1/fs:1/fs:size(value_matrix,2)/fs)+trial_range(1);
    % [~, t_idx] = min(abs(t_axis));
    % 
    % % t_axis = 1/fs:1/fs:size(x_acc_rot_bump,2)/fs;
    % y_limit = [min(min(x_acc_rot_bump(:,t_axis<t_lim))) max(max(x_acc_rot_bump(:,t_axis<t_lim)))];
    % x_limit = plot_range;
    % for iBump = 1:length(bump_directions)
    %     subplot(2,length(bump_directions)/2,iBump)
    %     hold on
    %     for iField = 1:length(field_orientations)           
    %         idx = intersect(field_indexes{iField},bump_indexes{iBump});
    %         temp_std = [mean(x_acc_rot_bump(idx,:),1)+std(x_acc_rot_bump(idx,:),[],1),...            
    %             mean(x_acc_rot_bump(idx,end:-1:1),1)-std(x_acc_rot_bump(idx,end:-1:1),[],1)];
    %         temp_t = [t_axis t_axis(end:-1:1)];
    %         area(temp_t,temp_std,'FaceColor',min(colors_field(iField,:)*1,[1 1 1]),'LineStyle','none')   
    %     end    
    %     alpha(0.1)
    % end
    % for iBump = 1:length(bump_directions)
    %     subplot(2,length(bump_directions)/2,iBump)
    %     hold on
    %     for iField = 1:length(field_orientations)           
    %         idx = intersect(field_indexes{iField},bump_indexes{iBump});
    %         plot(t_axis,mean(x_acc_rot_bump(idx,:)),'Color',colors_field(iField,:),'LineStyle','-');
    %     end
    %     ylabel('Acc (cm/s^2)')
    %     xlabel('t (s)')
    %     title(['Acceleration parallel to bump at ' num2str(180*bump_directions(iBump)/pi) '^o'])
    %     xlim(x_limit)
    %     ylim(y_limit)
    %     axis square
    % end
    % 
    % text(x_limit(1)+.2*(x_limit(2)-x_limit(1)),y_limit(1)+.4*(y_limit(2)-y_limit(1)),'Field orientations','HorizontalAlignment','center')
    % for iField = 1:length(field_orientations)
    %     plot(x_limit(1)+.2*(x_limit(2)-x_limit(1))+.1*(x_limit(2)-x_limit(1))*[-cos(field_orientations(iField)) cos(field_orientations(iField))],...
    %        y_limit(1)+.2*(y_limit(2)-y_limit(1))+.1*(y_limit(2)-y_limit(1))*[-sin(field_orientations(iField)) sin(field_orientations(iField))],... 
    %        'LineStyle','-','LineWidth',2,'Color',colors_field(iField,:))
    % end
    % 
    % %% Individual bump jerks
    % figure;
    % values_matrix = x_jerk_rot_bump;
    % % t_axis = 1/fs:1/fs:size(values_matrix,2)/fs;
    % t_axis = (1/fs:1/fs:size(values_matrix,2)/fs)+trial_range(1);
    % [~, t_idx] = min(abs(t_axis));
    % 
    % y_limit = [min(min(values_matrix(:,t_axis<t_lim))) max(max(values_matrix(:,t_axis<t_lim)))];
    % x_limit = [-0.05 t_lim];
    % 
    % for iBump = 1:length(bump_directions)
    %     subplot(2,length(bump_directions)/2,iBump)
    %     hold on
    %     for iField = 1:length(field_orientations)           
    %         idx = intersect(field_indexes{iField},bump_indexes{iBump});
    %         temp_std = [mean(values_matrix(idx,:),1)+std(values_matrix(idx,:),[],1),...            
    %             mean(values_matrix(idx,end:-1:1),1)-std(values_matrix(idx,end:-1:1),[],1)];
    %         temp_t = [t_axis t_axis(end:-1:1)];
    %         area(temp_t,temp_std,'FaceColor',min(colors_field(iField,:)*1,[1 1 1]),'LineStyle','none')   
    %     end    
    %     alpha(0.1)
    % end
    % for iBump = 1:length(bump_directions)
    %     subplot(2,length(bump_directions)/2,iBump)
    %     hold on
    %     for iField = 1:length(field_orientations)           
    %         idx = intersect(field_indexes{iField},bump_indexes{iBump});
    %         plot(t_axis,mean(values_matrix(idx,:)),'Color',colors_field(iField,:),'LineStyle','-');
    %     end
    %     ylabel('Jerk (cm/s^3)')
    %     xlabel('t (s)')
    %     title(['Jerk parallel to bump at ' num2str(180*bump_directions(iBump)/pi) '^o'])
    %     xlim(x_limit)
    %     ylim(y_limit)
    %     axis square
    % end
    % 
    % text(x_limit(1)+.2*(x_limit(2)-x_limit(1)),y_limit(1)+.4*(y_limit(2)-y_limit(1)),'Field orientations','HorizontalAlignment','center')
    % for iField = 1:length(field_orientations)
    %     plot(x_limit(1)+.2*(x_limit(2)-x_limit(1))+.1*(x_limit(2)-x_limit(1))*[-cos(field_orientations(iField)) cos(field_orientations(iField))],...
    %        y_limit(1)+.2*(y_limit(2)-y_limit(1))+.1*(y_limit(2)-y_limit(1))*[-sin(field_orientations(iField)) sin(field_orientations(iField))],... 
    %        'LineStyle','-','LineWidth',2,'Color',colors_field(iField,:))
    % end

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
end

if plot_emg
    %% EMG

    for iEMG = 1:num_emg
        figure
        temp_emg = squeeze(emg_all(iEMG,:,:));
        t_axis = (1/fs:1/fs:size(x_pos,2)/fs)+trial_range(1);
        max_emg = 0.001;
        emg_mean = zeros(length(bias_indexes),length(field_indexes),length(bump_indexes));
        emg_std = zeros(length(bias_indexes),length(field_indexes),length(bump_indexes));
        mean_range = [0.05 0.1];
        min_n = 1000;
        max_n = 0;
        for iBias = 1:length(bias_indexes)
            for iField = 1:length(field_indexes)
                for iBump = 1:length(bump_indexes)
                    idx = intersect(field_indexes{iField},bump_indexes{iBump}); 
                    idx = intersect(idx,bias_indexes{iBias}); 
                    idx = idx(~(std(temp_emg(idx,:)') > 3*mean(std(temp_emg(idx,:)'))));
                    [a t_idx] = min(abs(t_axis-t_lim));
                    subplot(2,length(bump_indexes)/2,iBump)            
                    hold on
                    plot(t_axis,smooth(mean(temp_emg(idx,:)),10),...
                        'Color',colors_field_bias((iBias-1)*length(field_indexes)+iField,:))
    %                 plot(t_axis,(temp_emg(idx,:)),...
    %                     'Color',colors_field_bias((iBias-1)*length(field_indexes)+iField,:))
                    title([bdf.emg.emgnames{iEMG} ' B:' num2str(bump_directions(iBump)*180/pi) ' deg'],'interpreter','none')
                    xlabel('t (s)')
                    ylabel('EMG (mV)')
                    xlim([-.05 .15])
                    max_emg = max(max_emg,max(mean(temp_emg(idx,t_axis>-.05 & t_axis<.15))));
                    emg_mean(iBias,iField,iBump) = mean(mean(temp_emg(idx,t_axis>mean_range(1) & t_axis<mean_range(2))));
                    emg_std(iBias,iField,iBump) = std(mean(temp_emg(idx,t_axis>mean_range(1) & t_axis<mean_range(2))));
                    min_n = min(min_n,length(idx));
                    max_n = max(max_n,length(idx));
                end
                legend_str{(iBias-1)*length(field_indexes)+iField} = ['UF: ' num2str(field_orientations(iField)*180/pi) ' deg' ' BF: ' num2str(round(bias_force_directions(iBias)*180/pi)) ' deg'];

            end      
        end
        legend(legend_str,'interpreter','none')
        for iBump=1:length(bump_indexes)
            subplot(2,length(bump_indexes)/2,iBump)
            ylim([0 1.1*max_emg])
        end
        set(gcf,'NextPlot','add');
        gca = axes;
        h = title(UF_file_prefix,'Interpreter','none');
        set(gca,'Visible','off');
        set(h,'Visible','on');

        figure
        temp_axes = axes;
        hold on
        for iBias = 1:length(bias_indexes)
            for iField = 1:length(field_indexes)
                plot(180/pi*[bump_dir_actual;bump_dir_actual(1)+2*pi],squeeze(emg_mean(iBias,iField,[1:end 1])),...
                    'Color',colors_field_bias((iBias-1)*length(field_indexes)+iField,:));
    %             plot(cos(bump_dir_actual([1:end 1])).*squeeze(emg_mean(iBias,iField,[1:end 1])),...
    %                 sin(bump_dir_actual([1:end 1])).*squeeze(emg_mean(iBias,iField,[1:end 1])),...
    %                 'Color',colors_field_bias((iBias-1)*length(field_indexes)+iField,:))
            end
        end
        for iBias = 1:length(bias_indexes)
            for iField = 1:length(field_indexes)
                errorbar(180/pi*[bump_dir_actual;bump_dir_actual(1)+2*pi],squeeze(emg_mean(iBias,iField,[1:end 1])),...
                    squeeze(emg_std(iBias,iField,[1:end 1])/2),...
                    'Color',colors_field_bias((iBias-1)*length(field_indexes)+iField,:));
            end
        end
        axis on
        xlim([0 360])
        xlabel('Bump direction (deg)')
        ylabel('EMG (mV)')
        legend(legend_str,'interpreter','none')
        title({UF_file_prefix;...
            [bdf.emg.emgnames{iEMG} '.  Average EMG between ' num2str(mean_range(1)) ' and ' num2str(mean_range(2)) ' s. '...
            num2str(min_n) ' <= n <= ' num2str(max_n)]},...
            'interpreter','none')

    end
end

if plot_units
    %% Units
    tic
    if isfield(bdf,'units')
        t_axis = trial_range(1); 
        all_chans = reshape([bdf.units.id],2,[])';
        all_chans_rw = reshape([rw_bdf.units.id],2,[])';
        units = unit_list(bdf);
        units_rw = unit_list(rw_bdf);
        dt = round(mean(diff(bdf.pos(:,1)))*10000)/10000;

        bin_size = dt;
        neuron_t_axis = (0:(trial_range(2)-trial_range(1))/bin_size-1)*bin_size+trial_range(1);
    %     bin_width = 0.02;
        fr_tc = 0.02;

        bin_width = 0.01;
        analysis_bin_edges = 0.015:bin_width:0.085;
        analysis_bin_centers = analysis_bin_edges(1:end-1)+bin_width/2;
        short_neuron_t_axis = neuron_t_axis(neuron_t_axis > analysis_bin_edges(1) & neuron_t_axis < analysis_bin_edges(end));
        short_neuron_t_axis = short_neuron_t_axis(1:floor(length(short_neuron_t_axis)/length(analysis_bin_edges))*length(analysis_bin_centers));

        idx_mat = reshape(1:length(short_neuron_t_axis),[],length(analysis_bin_centers));


        varnames = {'Bin','Bump X','Bump Y','Field orientation','Trial number','Bump on'};       

        hist_centers = neuron_t_axis(1):bin_width:neuron_t_axis(end);
        anova_bins = hist_centers > -0.1 & hist_centers < 0.15;      
        all_unit_fr = zeros((size(trial_table_temp,1))*size(units,1),length(neuron_t_axis));
        trial_type_mat = zeros(length(bias_indexes)*length(field_indexes)*length(bump_indexes),3);
        active_PD = zeros(1,0);

        for iUnit = 1:size(units,1)    
            unit_idx = find(all_chans(:,1)==units(iUnit,1) & all_chans(:,2)==units(iUnit,2));

            electrode = elec_map(find(elec_map(:,3)==all_chans(unit_idx,1)),4);

            rw_unit_idx = find(PDs(:,1)==units(iUnit,1) & PDs(:,2)==units(iUnit,2));
            PD = PDs(rw_unit_idx,[3 4]);
            ts = bdf.units(unit_idx).ts; %#ok<FNDSB>
            ts_cell = {};    
            max_y = 0;

    %         % anova independent variables
    %         bump_dir_mat = zeros(size(trial_table_temp,1)-1,length(hist_centers));
            bump_x_mat = zeros(size(trial_table_temp,1),length(hist_centers));
            bump_y_mat = zeros(size(trial_table_temp,1),length(hist_centers));
            field_orientation_mat = zeros(size(trial_table_temp,1),length(hist_centers));    
            trial_number_mat = zeros(size(trial_table_temp,1),length(hist_centers));         
            bin_mat = zeros(size(trial_table_temp,1),length(hist_centers)); 
            bump_on_mat = zeros(size(trial_table_temp,1),length(hist_centers));         
            bump_on_mat(:,hist_centers>=0 & hist_centers <= bump_duration) = 1; 
    %         %anova dependent variable
            hist_mat = zeros(size(trial_table_temp,1),length(hist_centers));
    %         fr_mat = zeros(size(trial_table_temp,1),length(neuron_t_axis));

            unit_idx = find(all_chans(:,1)==units(iUnit,1) & all_chans(:,2)==units(iUnit,2));    
            fr = spikes2fr(bdf.units(unit_idx).ts,bdf.pos(:,1),fr_tc);
            unit_all_trials = zeros(size(trial_table_temp,1),length(neuron_t_axis));
            spikes_vector = [];
            used_spikes_idx = [];
            for iTrial = 1:size(trial_table_temp,1)
                idx = idx_table(iTrial,:);
                unit_all_trials(iTrial,:) = fr(idx);
                all_unit_fr((iUnit-1)*(size(trial_table_temp,1)) + iTrial,:) = fr(idx);
                used_spikes_idx = [used_spikes_idx find(bdf.units(unit_idx).ts>trial_table_temp(iTrial,table_columns.t_bump_onset)+trial_range(1) &...
                    bdf.units(unit_idx).ts < trial_table_temp(iTrial,table_columns.t_bump_onset)+trial_range(2))];
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
            max_y = 0;

            if length(spikes_vector) > 0
                figure(iUnit+50)
                clf
                hold on


                % Rasters
                trial_type_number = zeros(1,size(trial_table_temp,1));
                trial_type_vector = zeros(1,size(trial_table_temp,1));
                for iBias = 1:length(bias_indexes)
                    for iField = 1:length(field_indexes)
                        for iBump = 1:length(bump_indexes)  
                            subplot(2,length(bump_indexes)/2,iBump)
                            hold on
                            plot(0,-1,'Color',...
                                colors_field_bias((iBias-1)*length(field_indexes)+iField,:),'LineWidth',2)
                        end
                    end
                end
                for iBias = 1:length(bias_indexes)
                    for iField = 1:length(field_indexes)
                        for iBump = 1:length(bump_indexes)                        
                            idx = intersect(field_indexes{iField},bump_indexes{iBump});
                            idx = intersect(idx,bias_indexes{iBias});
                            max_y = max(max_y,max(mean(unit_all_trials(idx,:),1)));
                            subplot(2,length(bump_indexes)/2,iBump)   
                            hold on
                            spikes_idx = [];
                            trial_type_index = (iBias-1)*(length(field_indexes)*length(bump_indexes)) + (iField-1)*(length(bump_indexes)) + iBump;
                            trial_type_mat(trial_type_index,:) = [iBias iField iBump];
                            for iTrial = 1:length(idx)
                                trial_type_vector(idx) = trial_type_index;                            
                                spikes_idx = [spikes_idx find(spikes_vector(2,:)==idx(iTrial))];
                            end
                            plot(spikes_vector(1,spikes_idx),max_y*spikes_vector(2,spikes_idx)/spikes_vector(2,end),'.','Color',...
                                min([1,1,1],colors_field_bias((iBias-1)*length(field_indexes)+iField,:)+.5),'MarkerSize',5)                        
                        end
                    end
                end

                    % Firing rates
                for iBias = 1:length(bias_indexes)
                    for iField = 1:length(field_indexes)
                        for iBump = 1:length(bump_indexes)
                            idx = intersect(field_indexes{iField},bump_indexes{iBump});
                            idx = intersect(idx,bias_indexes{iBias});
                            subplot(2,length(bump_indexes)/2,iBump) 
                            plot(neuron_t_axis,mean(unit_all_trials(idx,:),1),'Color',...
                                colors_field_bias((iBias-1)*length(field_indexes)+iField,:),'LineWidth',2)
                            title(['B:' num2str(bump_directions(iBump)*180/pi) ' deg'],'interpreter','none')
                            ylim([0 size(trial_table_temp,1)/2])
                            ylabel('Firing rate (1/s)')
                            xlabel('t (s)')

                        end
                        legend_str{(iBias-1)*length(field_indexes)+iField} = ['UF: ' num2str(field_orientations(iField)*180/pi) ' deg' ' BF: ' num2str(round(bias_force_directions(iBias)*180/pi)) ' deg'];
                    end
                end

                legend(legend_str,'interpreter','none')
                set(gcf,'name',['Electrode: ' num2str(electrode) ' - ' num2str(units(iUnit,2))],'numbertitle','off')
                drawnow 

                for iBump = 1:length(bump_indexes)
                    subplot(2,length(bump_indexes)/2,iBump)
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

    %             [p,table,stats] = anovan(hist_mat(:),{bin_mat(:),bump_x_mat(:),bump_y_mat(:),field_orientation_mat(:),...
    %                 trial_number_mat(:),bump_on_mat(:)},...
    %                 'model','interaction','continuous',[1 2 3 5],'varnames',varnames,'display','off');
    %             table(find(p<0.05)+1,1)

    %             subplot(2,length(bump_indexes),1)
    %             text(-.05,1.1*max_y,UF_file_prefix,'Interpreter','none')
    %             if ~isempty(PD)
    %                 text(-.05,1.05*max_y,['PD: ' num2str(PD(1)*180/pi,3) ' +/- ' num2str(PD(2)*180/pi,3) ' deg']);        
    %             end

                rw_unit_idx = find(PDs(:,1)==units(iUnit,1) & PDs(:,2)==units(iUnit,2));
    %             figure(iUnit+50)

                unit_mean_fr = zeros(size(trial_type_mat,1),...
                    sum(neuron_t_axis > analysis_bin_edges(1) & neuron_t_axis < analysis_bin_edges(end)));
                unit_binned_mean_fr = zeros(size(trial_type_mat,1),size(idx_mat,2));
                unit_binned_std_fr = zeros(size(trial_type_mat,1),size(idx_mat,2));

    %             unit_mean_fr = zeros(length(unique(trial_type_vector)),...
    %                 sum(neuron_t_axis > analysis_bin_edges(1) & neuron_t_axis < analysis_bin_edges(end)));
    %             unit_binned_mean_fr = zeros(length(unique(trial_type_vector)),size(idx_mat,2));
    %             unit_binned_std_fr = zeros(length(unique(trial_type_vector)),size(idx_mat,2));
                for iTrialType = 1:length(unique(trial_type_vector))
                    iBias = trial_type_mat(iTrialType,1);
                    iField = trial_type_mat(iTrialType,2);
                    iBump = trial_type_mat(iTrialType,3);        
                    idx = (iUnit-1)*(size(trial_table_temp,1))+find(trial_type_vector==iTrialType);
                    fr_trial_type = all_unit_fr(idx,neuron_t_axis > analysis_bin_edges(1) & neuron_t_axis < analysis_bin_edges(end));
                    if ~isempty(fr_trial_type)
                        unit_mean_fr = mean(fr_trial_type,1);
                        unit_binned_mean_fr(iTrialType,:) = mean(unit_mean_fr(idx_mat),1);  

                        unit_std_fr = std(fr_trial_type,[],1);        
                        unit_binned_std_fr(iTrialType,:) = mean(unit_std_fr(idx_mat),1);    
                    end
                end
                [~,max_std_idx] = max(std(unit_binned_mean_fr));
            %     [~,max_std_idx] = min(abs(analysis_bin_centers-0.05));
                max_mod_latency = analysis_bin_centers(max_std_idx);
                [~,max_mean_idx] = max(mean(unit_binned_mean_fr));
                max_act_latency = analysis_bin_centers(max_mean_idx);
                legend_str = {};
                max_radius = max(.1,1.1*max(unit_binned_mean_fr(:,max_std_idx)));

                set(gcf,'NextPlot','add');
                gca = axes;
                h = title({[UF_file_prefix ' ' RW_file_prefix];...
                    ['Elec: ' num2str(electrode) ' (Chan: ' num2str(units(iUnit,1)) ') Unit: ' num2str(units(iUnit,2))];...
                    ['Max modulation latency: ' num2str(max_mod_latency) ' s'];...
                    ['Max activity latency: ' num2str(max_act_latency) ' s']},'Interpreter','none');
                set(gca,'Visible','off');
                set(h,'Visible','on');

                figure(iUnit+150)
                subplot(2,2,1)    
                hold on
    %             for iBias = 1:length(bias_indexes)
    %                  for iField = 1:length(field_indexes)
    %                     for iBump = 1:length(bump_indexes)
    %                         gca = plot(0,max_radius,'Color',colors_field_bias((iBias-1)*length(field_indexes)+iField,:));
    %                         set(gca,'Color',colors_field_bias((iBias-1)*length(field_indexes)+iField,:))
    %                         hold on
    %                     end
    %                  end
    %              end
    %             gca = polar(0,max_radius);
    %             set(gca,'Visible','off')
    %             hold on

                unit_mean_fr_bump_field_bias = zeros(size(trial_type_mat,1),1);   

                for iBias = 1:length(bias_indexes)      
    %                 unit_mean_fr_bump_field = zeros(length(field_indexes),length(bump_indexes));        

                    for iField = 1:length(field_indexes)

                        for iBump = 1:length(bump_indexes)
                            unit_mean_fr_bump_field_bias(trial_type_mat(:,1)==iBias &...
                                trial_type_mat(:,2)==iField & trial_type_mat(:,3)==iBump) =...
                                mean(unit_binned_mean_fr(trial_type_mat(:,1)==iBias &...
                                trial_type_mat(:,2)==iField & trial_type_mat(:,3)==iBump,max_std_idx));           
                        end                    
                        temp = unit_mean_fr_bump_field_bias(trial_type_mat(:,1)==iBias &...
                                trial_type_mat(:,2)==iField,:);
                        plot([bump_dir_actual;bump_dir_actual(1)+2*pi]*180/pi,[temp;temp(1)],...
                            'Color',colors_field_bias((iBias-1)*length(field_indexes)+iField,:))
    %                     gca = polar([bump_dir_actual;bump_dir_actual(1)]',[temp;temp(1)]');
    %                     hold on
    %                     set(gca,'Color',colors_field_bias((iBias-1)*length(field_indexes)+iField,:))
                        legend_str{(iBias-1)*length(field_indexes)+iField} = ['UF: ' num2str(field_orientations(iField)*180/pi) ' deg  BF: ' num2str(round(bias_force_directions(iBias)*180/pi)) ' deg'];
                    end

                end


                % Passive PDs
                mean_fr_bump = zeros(length(bump_indexes),1);
                for iBump = 1:length(bump_indexes)
                    mean_fr_bump(iBump) =  mean(unit_binned_mean_fr(trial_type_mat(:,3)==iBump,max_std_idx));
                end
                % Fit sine
    %             a = mean(mean_fr_bump);
    %             b = (max(mean_fr_bump)-min(mean_fr_bump))/2;
    %             cosine = [num2str(a,10) '+' num2str(b,10) '*cos(x*10/(2*pi) + d)'];
                exp_cosine = 'a + exp(b*cos(x - d))/e';
                s = fitoptions('Method','NonlinearLeastSquares','StartPoint',[0 1 pi 1],'Lower',[0 0 0 0],...
                    'Upper',[100 100 2*pi 100]);
                f = fittype(exp_cosine,'options',s);
                fit_cosine = fit(bump_dir_actual,mean_fr_bump,f);
                active_PD(rw_unit_idx) = fit_cosine.d;
    %             compass(max_radius*cos(active_PD(rw_unit_idx)),max_radius*sin(active_PD(rw_unit_idx)),'r');
                plot([active_PD(rw_unit_idx) active_PD(rw_unit_idx)]*180/pi,[0 max_radius],'r')

                PD = PDs(rw_unit_idx,[3 4]);
                PD_f = PDs(rw_unit_idx,[9 10]);
                if ~isempty(PD)
                    if PD(2) < pi     
                          plot([PD(1) PD(1)]*180/pi,[0 max_radius],'k')
                          temp = plot([PD(1)+PD(2)/2 PD(1)+PD(2)/2]*180/pi,[0 max_radius],'k');
                          set(temp,'Color',[0.6 0.6 0.6])
                          temp = plot([PD(1)-PD(2)/2 PD(1)-PD(2)/2]*180/pi,[0 max_radius],'k');
                          set(temp,'Color',[0.6 0.6 0.6])
                    end
                end
                ylim([0 max_radius])
                xlim([0 360])
                xlabel('Bump direction')
                ylabel('Mean fr (Hz)')
    %             if ~isempty(PD_f)
    %                 if PD_f(2) < pi                    
    %                     compass(max_radius*cos(PD_f(1)),max_radius*sin(PD_f(1)),'b');
    %                     temp = compass(max_radius*cos(PD_f(1)-PD_f(2)/2),max_radius*sin(PD_f(1)-PD_f(2)/2),'b');
    %                     set(temp,'Color',[0 0 0.6])
    %                     temp = compass(max_radius*cos(PD_f(1)+PD_f(2)/2),max_radius*sin(PD_f(1)+PD_f(2)/2),'b');
    %                     set(temp,'Color',[0 0 0.6])
    %                 end
    %             end
                legend(legend_str)
            %     title(['BF: ' num2str(round(bias_force_directions(iBias)*180/pi)) ' deg'])

                subplot(2,2,2)
                mean_wf = double(mean(bdf.units(unit_idx).waveforms(used_spikes_idx,:)));
                std_wf = std(double(bdf.units(unit_idx).waveforms(used_spikes_idx,:)));            
    %             ga = area([1:length(mean_wf) length(mean_wf):-1:1],[mean_wf+std_wf mean_wf(end:-1:1)-std_wf(end:-1:1)]);
    %             set(ga,'LineStyle','none','FaceColor',[0.7 0.7 1])            
                hold on
                plot(mean_wf)
                plot(mean_wf+std_wf,'--')
                plot(mean_wf-std_wf,'--')
                plot(max(bdf.units(unit_idx).waveforms(used_spikes_idx,:)),'-.')
                plot(min(bdf.units(unit_idx).waveforms(used_spikes_idx,:)),'-.')

                subplot(2,2,3)
                plot(elec_map(:,1),elec_map(:,2),'ob','MarkerSize',12)
                hold on
                plot(elec_map(elec_map(:,4)==electrode,1),elec_map(elec_map(:,4)==electrode,2),'or','MarkerSize',12)
                text(median(elec_map(:,1)),max(elec_map(:,2))+1,'Anterior')
                text(max(elec_map(:,1)),median(elec_map(:,2))+1,'Lateral')
                axis equal
                axis off

                subplot(2,2,4)
                hist(diff(bdf.units(unit_idx).ts(used_spikes_idx)),[0:0.001:0.1])
    %             h = findobj(gca,'Type','patch');
    %             set(h,'FaceColor','w','EdgeColor','k')

                xlim([0 .09])
                ylabel('Count')
                xlabel('ISI (s)')

                set(gcf,'NextPlot','add');
                gca = axes;
                h = title({[UF_file_prefix ' ' RW_file_prefix];...
                    ['Elec: ' num2str(electrode) ' (Chan: ' num2str(units(iUnit,1)) ') Unit: ' num2str(units(iUnit,2))];...
                    ['Max modulation latency: ' num2str(max_mod_latency) ' s'];...
                    ['Max activity latency: ' num2str(max_act_latency) ' s']},'Interpreter','none');
                set(gca,'Visible','off');
                set(h,'Visible','on');
    %             pause
            else
                disp('Less than 50 spikes, skipping plotting')
            end
        end
    end
    toc

    %% Active vs passive PDs
    % atan2(sin(PDs(:,3)-active_PD),cos(PDs(:,3)-active_PD));
    figure; 
    hist(abs(180*atan2(sin(PDs(:,3)-active_PD'),cos(PDs(:,3)-active_PD'))/pi),30)
    xlabel('|passive - active PD| (deg)')
    ylabel('Count')
end

%% Spike triggered EMG
if plot_STEMG
    %% Units
    tic
    if isfield(bdf,'units')
        
        t_axis = bdf.pos(:,1);
        all_chans = reshape([bdf.units.id],2,[])';
        all_chans_rw = reshape([rw_bdf.units.id],2,[])';
        units = unit_list(bdf);
        units_rw = unit_list(rw_bdf);
        dt = round(mean(diff(bdf.pos(:,1)))*10000)/10000;
        emg_window = -.1:dt:.1;
        idx_vec = emg_window/dt;
        bin_size = dt;     
        t = double(bdf.emg.data(:,1))';
        t = round(t/dt)*dt;     

        for iUnit = 1:size(units,1)    
            unit_idx = find(all_chans(:,1)==units(iUnit,1) & all_chans(:,2)==units(iUnit,2));
            electrode = elec_map(find(elec_map(:,3)==all_chans(unit_idx,1)),4);  
            ts = bdf.units(unit_idx).ts; 
            ts = round(ts/dt)*dt;            
           
            spike_vector = zeros(size(t));
            [~,it,~] = intersect(t,ts);      
            figure;
            for iEMG = 1:num_emg
                emg_mat = zeros(length(ts),length(emg_window));
                t_mat = repmat(emg_window,length(ts),1);
                idx_mat = round(repmat(idx_vec,length(ts),1) + repmat(it',1,size(idx_vec,2)));
                emg_mat(idx_mat>0 & idx_mat<length(bdf.emg.data)) =...
                    emg_filtered(idx_mat(idx_mat>0 & idx_mat<length(bdf.emg.data)),iEMG);
                emg_mat = abs(emg_mat);
                keep_idx = sum(emg_mat > repmat(mean(emg_mat)+3*std(emg_mat),size(emg_mat,1),1),2)==0;
                emg_mat = emg_mat(keep_idx,:);
                
            	subplot(num_emg,1,iEMG)
                
                plot(emg_window,mean(emg_mat))  
                hold on
                plot(emg_window,mean(emg_mat)+1.96*std(emg_mat)/sqrt(sum(keep_idx)),'r')
                plot(emg_window,mean(emg_mat)-1.96*std(emg_mat)/sqrt(sum(keep_idx)),'r')
                
%                 plot(emg_window,max(emg_mat)/max(emg_mat(:)),'k')
                
                xlabel('t (s)')
                ylabel(['|' bdf.emg.emgnames{iEMG} '| (mV)'],'interpreter','none')
            end
            set(gcf,'NextPlot','add');
            gca = axes;
            h = title({UF_file_prefix;...
                ['Elec: ' num2str(electrode) ' (Chan: ' num2str(units(iUnit,1)) ') Unit: ' num2str(units(iUnit,2))];...
                ['n = ' num2str(sum(keep_idx))]},...
                'interpreter','none');
            set(gca,'Visible','off');
            set(h,'Visible','on');
        end
    end
end
%% TODO

% poop