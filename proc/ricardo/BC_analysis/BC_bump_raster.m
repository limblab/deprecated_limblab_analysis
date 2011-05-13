function BC_bump_raster(filenames,unit_list_param)
% type = 'raster' or 'heatmap'

% if length(filenames)==1
%     load([filenames.datapath 'Processed\' filenames.name],'bdf','trial_table','table_columns')
% else
    trial_table_concat = [];
    for iFile = 1:length(filenames)
        load([filenames(iFile).datapath 'Processed\' filenames(iFile).name],'bdf','trial_table','table_columns')
        bdf_all(iFile) = bdf;
        table_columns_all{iFile} = table_columns;
        end_time(iFile) = bdf.pos(end,1);
        if iFile>1
            trial_table(:,[table_columns.cursor_on_ct table_columns.start...
                table_columns.bump_time table_columns.end]) = ...
                trial_table(:,[table_columns.cursor_on_ct table_columns.start...
                table_columns.bump_time table_columns.end]) + sum(end_time(1:iFile-1));
            bdf_concat.pos = [bdf_concat.pos ; [bdf.pos(:,1)+sum(end_time(1:iFile-1)) bdf.pos(:,2:3)]];
            bdf_concat.vel = [bdf_concat.vel ; [bdf.vel(:,1)+sum(end_time(1:iFile-1)) bdf.vel(:,2:3)]];
        else
            bdf_concat.pos = bdf.pos;
            bdf_concat.vel = bdf.vel;
        end
        trial_table_concat = [trial_table_concat; trial_table];
    end
    % concatenate datafiles
    for i=1:length(bdf.units)
        bdf_concat.units(i).id = bdf(1).units(i).id;
        bdf_concat.units(i).ts = bdf(1).units(i).ts;
        for iFile = 2:length(filenames)
            bdf_concat.units(i).ts = [bdf_concat.units(i).ts; bdf_all(iFile).units(i).ts + sum(end_time(1:iFile-1))];
        end
    end
    trial_table = trial_table_concat;
    bdf.units = bdf_concat.units;
% end

time_bin_fr = [0 .1];
time_pre_bump = .25;
time_post_bump = 0.75;    
chan_unit = reshape([bdf.units(:).id],2,[])';
% if strcmp(unit_list_param,'all')
%     unit_list_param = chan_unit(chan_unit(:,2)>0 & chan_unit(:,2)<255,:);
% end
if nargin==1
    unit_list_param = chan_unit(chan_unit(:,2)>0 & chan_unit(:,2)<255,:);
end
trial_table =  trial_table(trial_table(:,table_columns.result)==32,:);
bump_table = trial_table(trial_table(:,table_columns.bump_magnitude)>0,:);
bump_times = bump_table(:,table_columns.bump_time);
    
for i=1:length(bump_times)-1        
    bump_dirs(i,:) = [bump_times(i) bump_table(find(bump_table(:,table_columns.bump_time)>bump_times(i),1,'first'),6)];
end

dir_bin_num = 4;
dir_bins = 0:2*pi/dir_bin_num:2*pi;
bump_dir_hist = histc(bump_dirs(:,2),dir_bins);

time_bin_num = 4;
time_length = (time_post_bump-(-time_pre_bump));
time_bins = -time_pre_bump:time_length/time_bin_num:time_post_bump;
bump_dir_prior = repmat(bump_dir_hist(1:end-1),1,time_bin_num);
fr_hist_all = zeros(length(unit_list_param),dir_bin_num,time_bin_num);
mov_fr_hist_all = zeros(length(unit_list_param),dir_bin_num,time_bin_num);

speed_bin_num = 10;
max_speed = 0;

[temp iBDF iTemp] = intersect(round(1000*bdf_concat.pos(:,1)),round(1000*bump_dirs(:,1)));
bump_pos = cell(length(bump_dirs),1);
bump_vel = cell(length(bump_dirs),1);
bump_mov_dir = zeros(length(bump_dirs),time_bin_num);
for iBump = 1:length(bump_dirs)    
    bump_pos{iBump} = bdf_concat.pos(iBDF(iBump)+1000*[-time_pre_bump:time_length/time_bin_num:time_post_bump],:);
%     bump_vel{iBump} = bdf_concat.vel(iBDF(iBump)+1000*[-time_pre_bump:.001:time_post_bump],:);
    mov_dir = unwrap(atan2(diff(bump_pos{iBump}(:,3)),diff(bump_pos{iBump}(:,2))));
%     mov_dir(mov_dir<0) = mov_dir(mov_dir<0)+2*pi;
    bump_mov_dir(iBump,:) = mov_dir;
    max_speed = max(max_speed,max(sqrt(sum(bdf_concat.vel(iBDF(iBump)+...
        1000*[-time_pre_bump:time_length/time_bin_num:time_post_bump],2:3).^2,2))));
end
speed_bins = linspace(0,max_speed,speed_bin_num+1);

bump_mov_dir = mod(bump_mov_dir,2*pi);
mov_dir_prior = histc(bump_mov_dir,dir_bins);
mov_dir_prior = mov_dir_prior(1:end-1,:);

dir_bins_center = dir_bins(1:end-1)+diff(dir_bins)/2;
time_bins_center = time_bins(1:end-1)+diff(time_bins)/2;
% mov_dir_prior = hist(mov_dir_prior',time_bin_num)'
%% Raster
for unit = 1:length(unit_list_param)
    figure(unit);
    subplot(3,1,1)
    area([time_bin_fr(1) time_bin_fr(1) time_bin_fr(2) time_bin_fr(2)],...
        [0 2*pi 2*pi 0],'LineStyle','none','FaceColor',[1 .7 .7])
    hold on
    for iBump = 1:length(bump_dirs)
        unit_index = find(chan_unit(:,1) ==unit_list_param(unit,1) & chan_unit(:,2) ==unit_list_param(unit,2));
        time_bin = bdf.units(unit_index).ts(bdf.units(unit_index).ts>bump_dirs(iBump,1)-time_pre_bump &...
            bdf.units(unit_index).ts<bump_dirs(iBump,1)+time_post_bump)-bump_dirs(iBump,1);
        if ~isempty(time_bin)
            plot(time_bin,bump_dirs(iBump,2),'k.')
        end
    end
    xlim([-time_pre_bump time_post_bump])
    ylim([0 2*pi])
    set(gca,'YDir','reverse')
    plot([0 0],[0 2*pi],'r')
    title([num2str(chan_unit(unit_index,1)) '-' num2str(chan_unit(unit_index,2))])
    ylabel('Bump direction (rad)')
    xlabel('Time (s)')

    unit_bin_spikes = zeros(dir_bin_num,time_bin_num);
    unit_mov_bin_spikes = zeros(dir_bin_num,time_bin_num);
    unit_vel_bin_spikes = zeros(dir_bin_num,speed_bin_num);

    subplot(3,1,2)
    hold on
    for iBump = 1:length(bump_dirs)
        this_bump_dir = bump_dirs(iBump,2);
        unit_index = find(chan_unit(:,1) ==unit_list_param(unit,1) & chan_unit(:,2) ==unit_list_param(unit,2));        
        time_stamps = bdf.units(unit_index).ts(bdf.units(unit_index).ts>bump_dirs(iBump,1)-time_pre_bump &...
            bdf.units(unit_index).ts<bump_dirs(iBump,1)+time_post_bump)-bump_dirs(iBump,1);
        temp_hist = histc(time_stamps',time_bins);
        unit_bin_spikes(find(histc(this_bump_dir,dir_bins)),:) = unit_bin_spikes(find(histc(this_bump_dir,dir_bins)),:)+...
            temp_hist(1:end-1);
        for iTimeBin = 1:time_bin_num
            unit_mov_bin_spikes(find(histc(bump_mov_dir(iBump,iTimeBin),dir_bins)),iTimeBin) = ...
                unit_mov_bin_spikes(find(histc(bump_mov_dir(iBump,iTimeBin),dir_bins)),iTimeBin) + ...
                temp_hist(iTimeBin);
        end
    end
            
    this_fr_hist = unit_bin_spikes./bump_dir_prior;
    this_fr_hist = this_fr_hist/(time_length/time_bin_num);
    fr_hist_all(unit,:,:) = this_fr_hist;
    inverted_fr = 1-(this_fr_hist-min(min(this_fr_hist)))/(max(max(this_fr_hist))-min(min(this_fr_hist)));
    imagesc([time_bins_center(1) time_bins_center(end)],[dir_bins_center(1) dir_bins_center(end)],...
        inverted_fr)
    colormap(gray)
    hold on
    plot([0 0],[0 2*pi],'r')
    xlim([-time_pre_bump time_post_bump])
    ylim([0 2*pi])
    set(gca,'YDir','reverse')
    ylabel('Bump direction (rad)')
    xlabel('Time (s)')
    title(['Black = ' num2str(max(max(this_fr_hist)),2) ', White = ' num2str(min(min(this_fr_hist)),2) ' (sp/s)'])
    
    subplot(3,1,3)
    this_mov_fr_hist = unit_mov_bin_spikes./mov_dir_prior;
    this_mov_fr_hist = this_mov_fr_hist/(time_length/time_bin_num);
    max_mov_fr = max(max(this_mov_fr_hist));
    min_mov_fr = min(min(this_mov_fr_hist));
    this_mov_fr_hist(isnan(this_mov_fr_hist)) = min(min(this_mov_fr_hist));
    mov_fr_hist_all(unit,:,:) = this_mov_fr_hist;
    inverted_mov_fr = 1-(this_mov_fr_hist-min(min(this_mov_fr_hist)))/(max(max(this_mov_fr_hist))-min(min(this_mov_fr_hist)));
    imagesc([time_bins_center(1) time_bins_center(end)],[dir_bins_center(1) dir_bins_center(end)],...
        inverted_mov_fr)
    colormap(gray)
    hold on
    plot([0 0],[0 2*pi],'r')
    xlim([-time_pre_bump time_post_bump])
    ylim([0 2*pi])
    set(gca,'YDir','reverse')
    ylabel('Movement direction (rad)')
    xlabel('Time (s)')
    title(['Black = ' num2str(max_mov_fr,2) ', White = ' num2str(min_mov_fr,2) ' (sp/s)'])
    
    subplot(4,1,4)
    this_mov_fr_hist = unit_mov_bin_spikes./mov_dir_prior;
    this_mov_fr_hist = this_mov_fr_hist/(time_length/time_bin_num);
    max_mov_fr = max(max(this_mov_fr_hist));
    min_mov_fr = min(min(this_mov_fr_hist));
    this_mov_fr_hist(isnan(this_mov_fr_hist)) = min(min(this_mov_fr_hist));
    mov_fr_hist_all(unit,:,:) = this_mov_fr_hist;
    inverted_mov_fr = 1-(this_mov_fr_hist-min(min(this_mov_fr_hist)))/(max(max(this_mov_fr_hist))-min(min(this_mov_fr_hist)));
    imagesc([time_bins_center(1) time_bins_center(end)],[dir_bins_center(1) dir_bins_center(end)],...
        inverted_mov_fr)
    colormap(gray)
    hold on
    plot([0 0],[0 2*pi],'r')
    xlim([-time_pre_bump time_post_bump])
    ylim([0 2*pi])
    set(gca,'YDir','reverse')
    ylabel('Movement direction (rad)')
    xlabel('Time (s)')
    title(['Black = ' num2str(max_mov_fr,2) ', White = ' num2str(min_mov_fr,2) ' (sp/s)'])
    
end
this_mov_fr_hist;
