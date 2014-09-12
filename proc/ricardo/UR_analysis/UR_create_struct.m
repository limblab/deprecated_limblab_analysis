function UR = UR_create_struct(bdf,params)
    UR = params; 
    UR.dt = diff(bdf.pos(1:2,1));
    [UR.trial_table,UR.table_columns,bdf] = UR_trial_table(bdf);
    BMI_data_files = dir([UR.target_folder '*data.txt']);
    BMI_param_files = dir([UR.target_folder '*params.mat']);
    BMI_data = [];
    for iBMI = 1:length(BMI_data_files)
        temp = load([UR.target_folder BMI_data_files(iBMI).name]);
        if ~isempty(find(diff(temp(:,1))<0,1,'last'))
            temp = temp(find(diff(temp(:,1))<0,1,'last')+1:end,:);
        end
        temp(:,1) = temp(:,1)+iBMI-1; % Add one second in between files
        BMI_data = [BMI_data ; temp];
        clear temp
    end
    UR.BMI.data = BMI_data;
    if ~isempty(BMI_param_files)
        UR.BMI.params = load([UR.target_folder BMI_param_files(1).name]);
    end
    
    for i = 1:2
        UR.trial_table = UR.trial_table(UR.trial_table(:,UR.table_columns.result)==32,:);
        UR.movement_directions = unique(UR.trial_table(:,UR.table_columns.movement_direction)); 
        UR.stiffnesses = unique(UR.trial_table(:,UR.table_columns.trial_stiffness));
        UR.stiffness_colors = copper(length(UR.stiffnesses));

        for iStiffness = 1:length(UR.stiffnesses)
            UR.stiffnesses_idx{iStiffness} = find(UR.trial_table(:,UR.table_columns.trial_stiffness)==UR.stiffnesses(iStiffness));
        end
        for iDir = 1:length(UR.movement_directions)
            UR.movement_directions_idx{iDir} = find(UR.trial_table(:,UR.table_columns.movement_direction)==UR.movement_directions(iDir));
        end

        % Remove spurious target locations
%         if isfield(UR,'target_locations_idx')
%             remove_idx = cell2mat(UR.target_locations_idx(cellfun(@length,UR.target_locations_idx) < mean(cellfun(@length,UR.target_locations_idx))-2*std(cellfun(@length,UR.target_locations_idx))));
%             UR.trial_table(remove_idx,:) = [];
%         end
    end  
    
    UR.reward_trials = find(UR.trial_table(:,UR.table_columns.result) == 32);
    
    trial_starts = UR.trial_table(:,UR.table_columns.t_ct_hold_on);
    trial_starts = trial_starts(UR.reward_trials);
    go_cue = UR.trial_table(:,UR.table_columns.t_go_cue);
    go_cue = go_cue(UR.reward_trials);
    ot_on = UR.trial_table(:,UR.table_columns.t_ot_on);
    ot_on = ot_on(UR.reward_trials);
    trial_ends = UR.trial_table(:,UR.table_columns.t_trial_end);
    trial_ends = trial_ends(UR.reward_trials);
    t_ot_hold = UR.trial_table(:,UR.table_columns.t_ot_hold);
    t_ot_hold = t_ot_hold(UR.reward_trials);    
    
    idx_vector = round(bdf.pos(:,1)*1000);
    [~,UR.start_idx,~] = intersect(idx_vector,round(1000*trial_starts));
    [~,UR.end_idx,~] = intersect(idx_vector,round(1000*trial_ends));
    if ~sum(isnan(go_cue))
        [~,UR.go_cue_idx,~] = intersect(idx_vector,round(1000*go_cue));
    else
        [~,UR.go_cue_idx,~] = intersect(idx_vector,round(1000*ot_on));
    end
    [~,UR.ot_hold_idx,~] = intersect(idx_vector,round(1000*t_ot_hold));   
    
    pos_x_smooth = smooth(bdf.pos(:,2)+UR.trial_table(2,UR.table_columns.x_offset),30);
    pos_y_smooth = smooth(bdf.pos(:,3)+UR.trial_table(2,UR.table_columns.y_offset),30);
    UR.mov_onset_idx_table = repmat(UR.go_cue_idx,1,600) + repmat(-99:500,size(UR.go_cue_idx,1),1);
    UR.mov_onset_idx_table(UR.mov_onset_idx_table<1) = 1;
    pos_x_smooth_mat = reshape(pos_x_smooth(UR.mov_onset_idx_table),[],size(UR.mov_onset_idx_table,2));
    pos_y_smooth_mat = reshape(pos_y_smooth(UR.mov_onset_idx_table),[],size(UR.mov_onset_idx_table,2));    
    pos_smooth_mat = sqrt(pos_x_smooth_mat.^2 + pos_y_smooth_mat.^2);
    if isempty(strfind(lower(params.UR_file_prefix),'iso'))
        [movement_onset,~,~]=MACCInitV4(pos_smooth_mat',.001,[15,15],[],1);
    else
        movement_onset = zeros(1,size(UR.mov_onset_idx_table,1));
    end
    UR.mov_onset_idx = UR.go_cue_idx + round(movement_onset*size(UR.mov_onset_idx_table,2))' - 99;
    UR.mov_onset_idx(isnan(UR.mov_onset_idx)) = UR.go_cue_idx(isnan(UR.mov_onset_idx));

    
    UR.in_task_idx = cellfun(@(i,j) (idx_vector(i:j)),...
        num2cell(UR.start_idx), num2cell(UR.end_idx),...
        'UniformOutput',false);
    UR.in_task_idx = cell2mat(UR.in_task_idx);

    mov_samples = 0.3*round(1/UR.dt);
    UR.t_mov = 0:UR.dt:UR.dt*mov_samples-UR.dt;
    hold_samples = UR.end_idx(UR.reward_trials(1))-UR.ot_last_hold_idx(UR.reward_trials(1))-1;
    UR.t_hold = 0:UR.dt:UR.dt*hold_samples-UR.dt;
    UR.mov_idx_table = repmat(UR.mov_onset_idx,1,mov_samples) + repmat(1:mov_samples,size(UR.go_cue_idx,1),1) - 50;
    UR.hold_idx_table = repmat(UR.ot_last_hold_idx,1,hold_samples) + repmat(1:hold_samples,size(UR.ot_last_hold_idx,1),1);
    UR.mov_idx_table(UR.mov_idx_table<1) = 1;
    UR.hold_idx_table(UR.hold_idx_table<1) = 1;
    
    UR.force_mov_x = reshape(bdf.force(UR.mov_idx_table,2),[],mov_samples);
    UR.force_mov_y = reshape(bdf.force(UR.mov_idx_table,3),[],mov_samples);
    UR.force_hold_x = reshape(bdf.force(UR.hold_idx_table,2),[],hold_samples);
    UR.force_hold_y = reshape(bdf.force(UR.hold_idx_table,3),[],hold_samples);
        
    UR.pos_mov_x = reshape(bdf.pos(UR.mov_idx_table,2),[],mov_samples)+UR.trial_table(1,UR.table_columns.x_offset);
    UR.pos_mov_y = reshape(bdf.pos(UR.mov_idx_table,3),[],mov_samples)+UR.trial_table(1,UR.table_columns.y_offset);
    UR.pos_hold_x = reshape(bdf.pos(UR.hold_idx_table,2),[],hold_samples)+UR.trial_table(1,UR.table_columns.x_offset);
    UR.pos_hold_y = reshape(bdf.pos(UR.hold_idx_table,3),[],hold_samples)+UR.trial_table(1,UR.table_columns.y_offset);
    
    UR.vel_mov_x = reshape(bdf.vel(UR.mov_idx_table,2),[],mov_samples);
    UR.vel_mov_y = reshape(bdf.vel(UR.mov_idx_table,3),[],mov_samples);
    
    if isfield(bdf,'units')
        units = unit_list(bdf,1);
        UR.mov_firingrates = zeros([size(UR.mov_idx_table) length(units)]);
        UR.hold_firingrates = zeros([size(UR.hold_idx_table) length(units)]);
        all_chans = reshape([bdf.units.id],2,[])';
        fr_tc = 0.02;
        temp = spikes2fr(bdf.units(1).ts,bdf.pos(:,1),fr_tc);
        UR.fr = zeros(size(units,1),length(temp));

        for iUnit = 1:size(units,1)    
            unit_idx = find(all_chans(:,1)==units(iUnit,1) & all_chans(:,2)==units(iUnit,2));
    %         fr = spikes2fr(bdf.units(unit_idx).ts,bdf.pos(:,1),fr_tc);  %#ok<FNDSB>
            fr = spikes2FrMovAve( bdf.units(unit_idx).ts, bdf.pos(:,1), .05 ); %#ok<FNDSB>
            UR.firingrates_mov(:,:,iUnit) = fr(UR.mov_idx_table);
            UR.firingrates_hold(:,:,iUnit) = fr(UR.hold_idx_table);
            UR.fr(iUnit,:) = fr;
        end    
    else
        UR.firingrates_mov = [];
        UR.firingrates_hold = [];
        UR.fr = [];        
    end
    
    if isfield(bdf,'emg')
        UR.emg = zeros(length(bdf.emg.emgnames),length(bdf.pos(:,1)));
        UR.emg_mov = zeros([size(UR.mov_idx_table) length(bdf.emg.emgnames)]);
        UR.emg_hold = zeros([size(UR.hold_idx_table) length(bdf.emg.emgnames)]);
        [b_lp,a_lp] = butter(4,10/(bdf.emg.emgfreq/2));        
        [b_hp,a_hp] = butter(4,70/(bdf.emg.emgfreq/2),'high'); 
        for iEMG = 1:length(bdf.emg.emgnames)
            emg = double(bdf.emg.data(:,1+iEMG));          
            emg = filtfilt(b_hp,a_hp,emg);
            emg = abs(emg);
            emg = filtfilt(b_lp,a_lp,emg);
%             UR.emg(iEMG,:) = emg;
            UR.emg(iEMG,:) = emg;            
            UR.emg_mov(:,:,iEMG) = emg(UR.mov_idx_table)/max([emg(UR.mov_idx_table(:)); emg(UR.hold_idx_table(:))]);
            UR.emg_hold(:,:,iEMG) = emg(UR.hold_idx_table)/max([emg(UR.mov_idx_table(:)); emg(UR.hold_idx_table(:))]);
        end
    else
        UR.emg = [];
        UR.emg_hold = [];
        UR.emg_mov = [];
    end
end 