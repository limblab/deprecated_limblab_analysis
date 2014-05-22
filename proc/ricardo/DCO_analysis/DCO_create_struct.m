function DCO = DCO_create_struct(bdf,params)
    DCO = params; 
    DCO.dt = diff(bdf.pos(1:2,1));
    [DCO.trial_table,DCO.table_columns,bdf] = DCO_trial_table(bdf);
    
    for i = 1:2
        DCO.trial_table = DCO.trial_table(DCO.trial_table(:,DCO.table_columns.result)==32,:);
        DCO.target_forces = unique(DCO.trial_table(:,DCO.table_columns.target_force)); 
        DCO.target_force_range = round(1000*unique(DCO.trial_table(:,DCO.table_columns.target_force_range)))/1000;
        DCO.target_stiffnesses = unique(DCO.trial_table(:,DCO.table_columns.outer_target_stiffness)); 
        DCO.target_locations = unique(DCO.trial_table(:,DCO.table_columns.outer_target_direction)); 
        DCO.direction_colors = hsv(length(DCO.target_locations));
        DCO.force_colors = copper(length(DCO.target_forces));

        for iForces = 1:length(DCO.target_forces)
            DCO.target_forces_idx{iForces} = find(DCO.trial_table(:,DCO.table_columns.target_force)==DCO.target_forces(iForces));
        end
        for iDir = 1:length(DCO.target_locations)
            DCO.target_locations_idx{iDir} = find(DCO.trial_table(:,DCO.table_columns.outer_target_direction)==DCO.target_locations(iDir));
        end
        for iStiffness = 1:length(DCO.target_stiffnesses)
            DCO.target_stiffness_idx{iStiffness} = find(DCO.trial_table(:,DCO.table_columns.outer_target_stiffness)==DCO.target_stiffnesses(iStiffness));
        end

        % Remove spurious target locations
        remove_idx = cell2mat(DCO.target_locations_idx(cellfun(@length,DCO.target_locations_idx) < mean(cellfun(@length,DCO.target_locations_idx))-2*std(cellfun(@length,DCO.target_locations_idx))));
        DCO.trial_table(remove_idx,:) = [];
    end  
    
    DCO.reward_trials = find(DCO.trial_table(:,DCO.table_columns.result) == 32);
    
    trial_starts = DCO.trial_table(:,DCO.table_columns.t_ct_hold_on);
    trial_starts = trial_starts(DCO.reward_trials);
    go_cue = DCO.trial_table(:,DCO.table_columns.t_go_cue);
    go_cue = go_cue(DCO.reward_trials);
    trial_ends = DCO.trial_table(:,DCO.table_columns.t_trial_end);
    trial_ends = trial_ends(DCO.reward_trials);
    t_ot_first_hold = DCO.trial_table(:,DCO.table_columns.t_ot_first_hold);
    t_ot_first_hold = t_ot_first_hold(DCO.reward_trials);
    t_ot_last_hold = DCO.trial_table(:,DCO.table_columns.t_ot_last_hold);
    t_ot_last_hold = t_ot_last_hold(DCO.reward_trials);   
    
    idx_vector = round(bdf.pos(:,1)*1000);
    [~,DCO.start_idx,~] = intersect(idx_vector,round(1000*trial_starts));
    [~,DCO.end_idx,~] = intersect(idx_vector,round(1000*trial_ends));
    [~,DCO.go_cue_idx,~] = intersect(idx_vector,round(1000*go_cue));
    [~,DCO.ot_first_hold_idx,~] = intersect(idx_vector,round(1000*t_ot_first_hold));
    [~,DCO.ot_last_hold_idx,~] = intersect(idx_vector,round(1000*t_ot_last_hold));
    
    pos_x_smooth = smooth(bdf.pos(:,2)+DCO.trial_table(2,DCO.table_columns.x_offset),30);
    pos_y_smooth = smooth(bdf.pos(:,3)+DCO.trial_table(2,DCO.table_columns.y_offset),30);
    DCO.mov_onset_idx_table = repmat(DCO.go_cue_idx,1,1000) + repmat(-499:500,size(DCO.go_cue_idx,1),1);
    pos_x_smooth_mat = reshape(pos_x_smooth(DCO.mov_onset_idx_table),[],size(DCO.mov_onset_idx_table,2));
    pos_y_smooth_mat = reshape(pos_y_smooth(DCO.mov_onset_idx_table),[],size(DCO.mov_onset_idx_table,2));    
    pos_smooth_mat = sqrt(pos_x_smooth_mat.^2 + pos_y_smooth_mat.^2);
%     movement_onset = zeros(size(DCO.trial_table,1));
    [movement_onset,~,~]=MACCInitV4(pos_smooth_mat',.001,[15,15],[],0);
    DCO.mov_onset_idx = DCO.go_cue_idx + round(movement_onset*size(DCO.mov_onset_idx_table,2))' - 499;
    DCO.mov_onset_idx(isnan(DCO.mov_onset_idx)) = DCO.go_cue_idx(isnan(DCO.mov_onset_idx));
%     for iTrial = 1:size(DCO.trial_table,1)
%         [movement_onset(iTrial),~,~]=MACCInitV4(pos_smooth_mat(iTrial,:),.001,[15,15],[],1);
%         pause
%     end
    
    DCO.in_task_idx = cellfun(@(i,j) (idx_vector(i:j)),...
        num2cell(DCO.start_idx), num2cell(DCO.end_idx),...
        'UniformOutput',false);
    DCO.in_task_idx = cell2mat(DCO.in_task_idx);

    mov_samples = 0.3*round(1/DCO.dt);
    DCO.t_mov = 0:DCO.dt:DCO.dt*mov_samples-DCO.dt;
    hold_samples = DCO.end_idx(DCO.reward_trials(1))-DCO.ot_last_hold_idx(DCO.reward_trials(1))-1;
    DCO.t_hold = 0:DCO.dt:DCO.dt*hold_samples-DCO.dt;
    DCO.mov_idx_table = repmat(DCO.mov_onset_idx,1,mov_samples) + repmat(1:mov_samples,size(DCO.go_cue_idx,1),1) - 50;
    DCO.hold_idx_table = repmat(DCO.ot_last_hold_idx,1,hold_samples) + repmat(1:hold_samples,size(DCO.ot_last_hold_idx,1),1);
    
    DCO.force_mov_x = reshape(bdf.force(DCO.mov_idx_table,2),[],mov_samples);
    DCO.force_mov_y = reshape(bdf.force(DCO.mov_idx_table,3),[],mov_samples);
    DCO.force_hold_x = reshape(bdf.force(DCO.hold_idx_table,2),[],hold_samples);
    DCO.force_hold_y = reshape(bdf.force(DCO.hold_idx_table,3),[],hold_samples);
        
    DCO.pos_mov_x = reshape(bdf.pos(DCO.mov_idx_table,2),[],mov_samples)+DCO.trial_table(1,DCO.table_columns.x_offset);
    DCO.pos_mov_y = reshape(bdf.pos(DCO.mov_idx_table,3),[],mov_samples)+DCO.trial_table(1,DCO.table_columns.y_offset);
    DCO.pos_hold_x = reshape(bdf.pos(DCO.hold_idx_table,2),[],hold_samples)+DCO.trial_table(1,DCO.table_columns.x_offset);
    DCO.pos_hold_y = reshape(bdf.pos(DCO.hold_idx_table,3),[],hold_samples)+DCO.trial_table(1,DCO.table_columns.y_offset);
    
    DCO.vel_mov_x = reshape(bdf.vel(DCO.mov_idx_table,2),[],mov_samples);
    DCO.vel_mov_y = reshape(bdf.vel(DCO.mov_idx_table,3),[],mov_samples);
    
    if isfield(bdf,'units')
        units = unit_list(bdf,1);
        DCO.mov_firingrates = zeros([size(DCO.mov_idx_table) length(units)]);
        DCO.hold_firingrates = zeros([size(DCO.hold_idx_table) length(units)]);
        all_chans = reshape([bdf.units.id],2,[])';
        fr_tc = 0.02;
        temp = spikes2fr(bdf.units(1).ts,bdf.pos(:,1),fr_tc);
        DCO.fr = zeros(size(units,1),length(temp));

        for iUnit = 1:size(units,1)    
            unit_idx = find(all_chans(:,1)==units(iUnit,1) & all_chans(:,2)==units(iUnit,2));
    %         fr = spikes2fr(bdf.units(unit_idx).ts,bdf.pos(:,1),fr_tc);  %#ok<FNDSB>
            fr = spikes2FrMovAve( bdf.units(unit_idx).ts, bdf.pos(:,1), .05 ); %#ok<FNDSB>
            DCO.firingrates_mov(:,:,iUnit) = fr(DCO.mov_idx_table);
            DCO.firingrates_hold(:,:,iUnit) = fr(DCO.hold_idx_table);
            DCO.fr(iUnit,:) = fr;
        end    
    else
        DCO.firingrates_mov = [];
        DCO.firingrates_hold = [];
        DCO.fr = [];        
    end
    
    if isfield(bdf,'emg')
        DCO.emg = zeros(length(bdf.emg.emgnames),length(bdf.pos(:,1)));
        DCO.emg_mov = zeros([size(DCO.mov_idx_table) length(bdf.emg.emgnames)]);
        DCO.emg_hold = zeros([size(DCO.hold_idx_table) length(bdf.emg.emgnames)]);
        [b_lp,a_lp] = butter(4,10/(bdf.emg.emgfreq/2));        
        [b_hp,a_hp] = butter(4,70/(bdf.emg.emgfreq/2),'high'); 
        for iEMG = 1:length(bdf.emg.emgnames)
            emg = double(bdf.emg.data(:,1+iEMG));          
            emg = filtfilt(b_hp,a_hp,emg);
            emg = abs(emg);
            emg = filtfilt(b_lp,a_lp,emg);
%             DCO.emg(iEMG,:) = emg;
            DCO.emg(iEMG,:) = emg;            
            DCO.emg_mov(:,:,iEMG) = emg(DCO.mov_idx_table)/max([emg(DCO.mov_idx_table(:)); emg(DCO.hold_idx_table(:))]);
            DCO.emg_hold(:,:,iEMG) = emg(DCO.hold_idx_table)/max([emg(DCO.mov_idx_table(:)); emg(DCO.hold_idx_table(:))]);
        end
    else
        DCO.emg = [];
        DCO.emg_hold = [];
        DCO.emg_mov = [];
    end
end 