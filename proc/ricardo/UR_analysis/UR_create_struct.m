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
    
    UR.trial_table(UR.trial_table(:,UR.table_columns.result)==33,:) = [];
    UR.movement_directions = unique(UR.trial_table(:,UR.table_columns.movement_direction)); 
    UR.stiffnesses = unique(UR.trial_table(:,UR.table_columns.trial_stiffness));    
    UR.bump_directions = unique(UR.trial_table(:,UR.table_columns.bump_direction));
    UR.bump_directions = UR.bump_directions(~isnan(UR.bump_directions));

    UR.direction_colors = hsv(length(UR.movement_directions));    
    for i = 1:2
%         UR.trial_table = UR.trial_table(UR.trial_table(:,UR.table_columns.result)==32,:);
        

    for iStiffness = 1:length(UR.stiffnesses)
        UR.stiffnesses_idx{iStiffness} = find(UR.trial_table(:,UR.table_columns.trial_stiffness)==UR.stiffnesses(iStiffness));
    end
    for iDir = 1:length(UR.movement_directions)
        UR.movement_directions_idx{iDir} = find(UR.trial_table(:,UR.table_columns.movement_direction)==UR.movement_directions(iDir));
    end
    for iBump = 1:length(UR.bump_directions)
        UR.bump_directions_idx{iBump} = find(UR.trial_table(:,UR.table_columns.bump_direction)==UR.bump_directions(iBump));
    end

    end  
    remove_stiffness = [];
    for iStiffness=1:length(UR.stiffnesses)
        if length(UR.stiffnesses_idx{iStiffness}) < 10
            remove_stiffness = [remove_stiffness iStiffness];
            disp(['Removing ' num2str(length(UR.stiffnesses_idx{iStiffness})) ' trials '...
                'with stiffness ' num2str(UR.stiffnesses(iStiffness)) ' N/cm'])
        end
    end    
    UR.stiffnesses_idx(remove_stiffness) = [];
    UR.stiffnesses(remove_stiffness) = [];
    
    if length(UR.stiffnesses) == 2
        UR.stiffness_colors = [.8 0 0; 0 0 .8];
    else
        UR.stiffness_colors = copper(length(UR.stiffnesses));
    end
    
    UR.reward_trials = find(UR.trial_table(:,UR.table_columns.result) == 32);
    
    trial_starts = UR.trial_table(:,UR.table_columns.t_ct_hold_on);
%     trial_starts = trial_starts(UR.reward_trials);   
    leave_target = UR.trial_table(:,UR.table_columns.t_leave_target);
%     leave_target = leave_target(UR.reward_trials);
    ot_on = UR.trial_table(:,UR.table_columns.t_ot_on);
%     ot_on = ot_on(UR.reward_trials);
    trial_ends = UR.trial_table(:,UR.table_columns.t_trial_end);
%     trial_ends = trial_ends(UR.reward_trials);
    t_ot_hold = UR.trial_table(:,UR.table_columns.t_ot_hold);
%     t_ot_hold = t_ot_hold(UR.reward_trials); 
    t_bump = UR.trial_table(:,UR.table_columns.t_bump);
    t_bump(isnan(t_bump)) = UR.trial_table(isnan(t_bump),UR.table_columns.t_leave_target);
    
    idx_vector = round(bdf.pos(:,1)*1000);
    [~,UR.start_idx,~] = intersect(idx_vector,round(1000*trial_starts));
    [~,UR.end_idx,~] = intersect(idx_vector,round(1000*trial_ends));
    if ~sum(isnan(leave_target))
        [~,UR.leave_target_idx,~] = intersect(idx_vector,round(1000*leave_target));
    else
        [~,UR.leave_target_idx,~] = intersect(idx_vector,round(1000*ot_on));
    end
    [~,UR.ot_hold_idx,~] = intersect(idx_vector,round(1000*t_ot_hold));   
    [~,UR.bump_onset_idx,~] = intersect(idx_vector,round(1000*t_bump));
    
    pos_x_smooth = smooth(bdf.pos(:,2)+UR.trial_table(2,UR.table_columns.x_offset),30);
    pos_y_smooth = smooth(bdf.pos(:,3)+UR.trial_table(2,UR.table_columns.y_offset),30);
    mov_onset_range = -499:300;
    UR.mov_onset_idx_table = repmat(UR.leave_target_idx,1,length(mov_onset_range)) + repmat(mov_onset_range,size(UR.leave_target_idx,1),1);
    UR.mov_onset_idx_table(UR.mov_onset_idx_table<1) = 1;
    pos_x_smooth_mat = reshape(pos_x_smooth(UR.mov_onset_idx_table),[],size(UR.mov_onset_idx_table,2));
    pos_x_smooth_mat = pos_x_smooth_mat - repmat(pos_x_smooth_mat(:,1),1,size(pos_x_smooth_mat,2));
    pos_y_smooth_mat = reshape(pos_y_smooth(UR.mov_onset_idx_table),[],size(UR.mov_onset_idx_table,2));    
    pos_y_smooth_mat = pos_y_smooth_mat - repmat(pos_y_smooth_mat(:,1),1,size(pos_y_smooth_mat,2));
    pos_smooth_mat = sqrt(pos_x_smooth_mat.^2 + pos_y_smooth_mat.^2);
    pos_smooth_mat = .01*(pos_smooth_mat);
    if isempty(strfind(lower(params.UR_file_prefix),'iso'))
        [movement_onset,~,~]=MACCInitV4(pos_smooth_mat',.001,[50,50],[],0);
    else
        movement_onset = zeros(1,size(UR.mov_onset_idx_table,1));
    end
    movement_onset = zeros(1,size(UR.mov_onset_idx_table,1));
%     UR.mov_onset_idx = UR.leave_target_idx + round(movement_onset*size(UR.mov_onset_idx_table,2))' + mov_onset_range(1);    
%     UR.mov_onset_idx = UR.leave_target_idx + round(movement_onset*1000)' + mov_onset_range(1);    
    UR.mov_onset_idx = UR.leave_target_idx;    
    UR.mov_onset_idx(isnan(UR.mov_onset_idx)) = UR.leave_target_idx(isnan(UR.mov_onset_idx));
     
    UR.in_task_idx = cellfun(@(i,j) (idx_vector(i:j)),...
        num2cell(UR.start_idx), num2cell(UR.end_idx),...
        'UniformOutput',false);
    UR.in_task_idx = cell2mat(UR.in_task_idx);

    mov_samples = 2.5*round(1/UR.dt);
    mov_offset = 500;
    UR.t_mov = (0:UR.dt:UR.dt*mov_samples-UR.dt)-mov_offset*UR.dt;
    UR.mov_idx_table = repmat(UR.mov_onset_idx,1,mov_samples) + repmat(1:mov_samples,size(UR.leave_target_idx,1),1) - mov_offset;
    UR.mov_idx_table(UR.mov_idx_table<1) = 1;
      
    UR.force_mov_x = reshape(bdf.force(UR.mov_idx_table,2),[],mov_samples);
    UR.force_mov_y = reshape(bdf.force(UR.mov_idx_table,3),[],mov_samples);
        
    UR.pos_mov_x = reshape(bdf.pos(UR.mov_idx_table,2),[],mov_samples)+UR.trial_table(1,UR.table_columns.x_offset);
    UR.pos_mov_y = reshape(bdf.pos(UR.mov_idx_table,3),[],mov_samples)+UR.trial_table(1,UR.table_columns.y_offset);
    
    UR.vel_mov_x = reshape(bdf.vel(UR.mov_idx_table,2),[],mov_samples);
    UR.vel_mov_y = reshape(bdf.vel(UR.mov_idx_table,3),[],mov_samples);
    
    UR.pos_mov_x_rot = zeros(size(UR.pos_mov_x));
    UR.pos_mov_y_rot = zeros(size(UR.pos_mov_x));
    
    UR.force_mov_x_rot = zeros(size(UR.force_mov_x));
    UR.force_mov_y_rot = zeros(size(UR.force_mov_y));
    
    for iDir = 1:length(UR.movement_directions)
        theta = UR.movement_directions(iDir);
        rot_mat = [cos(theta) -sin(theta); sin(theta) cos(theta)];   
        idx = UR.trial_table(:,UR.table_columns.movement_direction) == theta;
        
        temp_x = UR.pos_mov_x(idx,:);
        temp_y = UR.pos_mov_y(idx,:);
        temp = [temp_x(:) temp_y(:)];             
        temp = temp*rot_mat;
        temp_x = reshape(temp(:,1),size(UR.pos_mov_x(idx,:)));
        temp_y = reshape(temp(:,2),size(UR.pos_mov_x(idx,:)));
        offset_x = UR.trial_table(idx,UR.table_columns.movement_distance)/2;        
        temp_x = temp_x + repmat(offset_x,1,size(temp_x,2));
        UR.pos_mov_x_rot(idx,:) = temp_x;
        UR.pos_mov_y_rot(idx,:) = temp_y;
        
        temp_x = UR.force_mov_x(idx,:);
        temp_y = UR.force_mov_y(idx,:);
        temp = [temp_x(:) temp_y(:)];        
        temp = temp*rot_mat;
        temp_x = reshape(temp(:,1),size(UR.pos_mov_x(idx,:)));
        temp_y = reshape(temp(:,2),size(UR.pos_mov_x(idx,:)));
        UR.force_mov_x_rot(idx,:) = temp_x;
        UR.force_mov_y_rot(idx,:) = temp_y;
    end
    
    leave_target = UR.trial_table(:,UR.table_columns.t_leave_target);
    reach_target = UR.trial_table(:,UR.table_columns.t_trial_end);
    idx_vector = round(bdf.pos(:,1)*1000);
    [~,UR.leave_target_idx,~] = intersect(idx_vector,round(1000*leave_target));
    [~,UR.reach_target_idx,~] = intersect(idx_vector,round(1000*reach_target));
    for iTrial = 1:size(UR.trial_table,1)    
        pos_x = bdf.pos(UR.leave_target_idx(iTrial):UR.reach_target_idx(iTrial),2)+UR.trial_table(iTrial,UR.table_columns.x_offset);
        pos_y = bdf.pos(UR.leave_target_idx(iTrial):UR.reach_target_idx(iTrial),3)+UR.trial_table(iTrial,UR.table_columns.y_offset);
        UR.pos_mov_x_cell{iTrial} = pos_x;
        UR.pos_mov_y_cell{iTrial} = pos_y;
        UR.path_length(iTrial) = sum(sqrt(diff(pos_x).^2 + diff(pos_y).^2));
        theta = UR.trial_table(iTrial,UR.table_columns.movement_direction);
        rot_mat = [cos(theta) -sin(theta); sin(theta) cos(theta)];
        pos_rot = [pos_x pos_y]*rot_mat;
        pos_rot(:,1) = pos_rot(:,1)+UR.trial_table(iTrial,UR.table_columns.movement_distance)/2;        
        UR.signed_error(iTrial) = sum(pos_rot(:,2));
        UR.pos_mov_x_rot_cell{iTrial} = pos_rot(:,1);
        UR.pos_mov_y_rot_cell{iTrial} = pos_rot(:,2);
    end
    
    UR.bump_trials = find(UR.trial_table(:,UR.table_columns.bump_trial));
    UR.no_bump_trials = find(~UR.trial_table(:,UR.table_columns.bump_trial));
%     bump_samples = (UR.trial_table(:,UR.table_columns.bump_duration)/UR.dt);   
    bump_samples = 400;
    bump_samples(isnan(bump_samples)) = [];
    bump_samples = round(bump_samples(1));
%     bump_t_offset = 50;
    bump_t_offset = 0;
    UR.t_bump = UR.dt*((1:bump_samples) - bump_t_offset -1);
    UR.bump_idx_table = repmat(UR.bump_onset_idx,1,bump_samples) + repmat(1:bump_samples,size(UR.bump_onset_idx,1),1) - bump_t_offset;
    UR.bump_idx_table(UR.bump_idx_table<1) = 1;
    
    UR.force_bump_x = reshape(bdf.force(UR.bump_idx_table,2),[],bump_samples);
    UR.force_bump_y = reshape(bdf.force(UR.bump_idx_table,3),[],bump_samples);
        
    UR.pos_bump_x = reshape(bdf.pos(UR.bump_idx_table,2),[],bump_samples)+UR.trial_table(1,UR.table_columns.x_offset);
    UR.pos_bump_y = reshape(bdf.pos(UR.bump_idx_table,3),[],bump_samples)+UR.trial_table(1,UR.table_columns.y_offset);
    
    UR.vel_bump_x = reshape(bdf.vel(UR.bump_idx_table,2),[],bump_samples);
    UR.vel_bump_y = reshape(bdf.vel(UR.bump_idx_table,3),[],bump_samples);
    
    UR.pos_bump_x_rot = zeros(size(UR.pos_bump_x));
    UR.pos_bump_y_rot = zeros(size(UR.pos_bump_x));
    UR.force_bump_x_rot = zeros(size(UR.pos_bump_x));
    UR.force_bump_y_rot = zeros(size(UR.pos_bump_x));
    UR.stiffness = zeros(size(UR.pos_bump_x));
    for iDir = 1:length(UR.movement_directions)
        theta = UR.movement_directions(iDir);
        idx = find(UR.trial_table(:,UR.table_columns.movement_direction) == theta);
        idx = intersect(idx,find(UR.trial_table(:,UR.table_columns.bump_trial)));
        temp_x = UR.pos_bump_x(idx,:);
        temp_y = UR.pos_bump_y(idx,:);
        temp = [temp_x(:) temp_y(:)];
        rot_mat = [cos(theta) -sin(theta); sin(theta) cos(theta)];        
        temp = temp*rot_mat;
        temp_x = reshape(temp(:,1),size(UR.pos_bump_x(idx,:)));
        temp_y = reshape(temp(:,2),size(UR.pos_bump_x(idx,:)));
%         offset_x = UR.trial_table(idx,UR.table_columns.movement_distance)/2;        
%         temp_x = temp_x + repmat(offset_x,1,size(temp_x,2));
        UR.pos_bump_x_rot(idx,:) = temp_x;
        UR.pos_bump_y_rot(idx,:) = temp_y;
        
        temp_x = UR.force_bump_x(idx,:);
        temp_y = UR.force_bump_y(idx,:);
        temp = [temp_x(:) temp_y(:)];        
        temp = temp*rot_mat;
        temp_x = reshape(temp(:,1),size(UR.pos_bump_x(idx,:)));
        temp_y = reshape(temp(:,2),size(UR.pos_bump_x(idx,:)));
        UR.force_bump_x_rot(idx,:) = temp_x;
        UR.force_bump_y_rot(idx,:) = temp_y;
    end
    bump_onset_idx = find(UR.t_bump==0);
    for iTrial = 1:size(UR.trial_table,1)
        UR.pos_bump_x_rot(iTrial,:) = UR.pos_bump_x_rot(iTrial,:)-UR.pos_bump_x_rot(iTrial,bump_onset_idx);
        UR.pos_bump_y_rot(iTrial,:) = UR.pos_bump_y_rot(iTrial,:)-UR.pos_bump_y_rot(iTrial,bump_onset_idx);
        UR.force_bump_x_rot(iTrial,:) = UR.force_bump_x_rot(iTrial,:)-UR.force_bump_x_rot(iTrial,bump_onset_idx);
        UR.force_bump_y_rot(iTrial,:) = UR.force_bump_y_rot(iTrial,:)-UR.force_bump_y_rot(iTrial,bump_onset_idx);
        UR.stiffness(iTrial,:) = UR.force_bump_y_rot(iTrial,:)./UR.pos_bump_y_rot(iTrial,:);
    end
    
    
    
%     % Curvature
%     pos_x_smooth = smooth(bdf.pos(:,2)+UR.trial_table(2,UR.table_columns.x_offset),100);
%     pos_y_smooth = smooth(bdf.pos(:,3)+UR.trial_table(2,UR.table_columns.y_offset),100);
%     
%     pos_x_smooth_mat = reshape(pos_x_smooth(UR.mov_idx_table),[],size(UR.mov_idx_table,2));
%     pos_x_smooth_mat = pos_x_smooth_mat - repmat(pos_x_smooth_mat(:,1),1,size(pos_x_smooth_mat,2));
%     pos_y_smooth_mat = reshape(pos_y_smooth(UR.mov_idx_table),[],size(UR.mov_idx_table,2));    
%     pos_y_smooth_mat = pos_y_smooth_mat - repmat(pos_y_smooth_mat(:,1),1,size(pos_y_smooth_mat,2));
%         
%     x_prime = diff(pos_x_smooth_mat,1,2);
%     x_prime = [x_prime(:,1) x_prime];
%     x_prime = smoothts(x_prime,'b',30);
%     x_prime_prime = diff(x_prime,1,2);
%     x_prime_prime = [x_prime_prime(:,1) x_prime_prime];
%     y_prime = diff(pos_y_smooth_mat,1,2);
%     y_prime = [y_prime(:,1) y_prime];
%     y_prime = smoothts(y_prime,'b',30);
%     y_prime_prime = diff(y_prime,1,2);
%     y_prime_prime = [y_prime_prime(:,1) y_prime_prime];
%     
%     UR.K = (x_prime.*y_prime_prime - y_prime.*x_prime_prime)./...
%         ((x_prime.^2+y_prime.^2).^1.5);
    
    if isfield(bdf,'units')
        units = unit_list(bdf,1);
        UR.firingrates_mov = zeros([size(UR.mov_idx_table) length(units)]); 
        UR.firingrates_bump = zeros([size(UR.bump_idx_table) length(units)]); 
        all_chans = reshape([bdf.units.id],2,[])';
        fr_tc = 0.02;
%         temp = spikes2FrMovAve(bdf.units(1).ts,bdf.pos(:,1),fr_tc);
%         UR.fr = zeros(size(units,1),length(temp));

        for iUnit = 1:size(units,1)    
            unit_idx = find(all_chans(:,1)==units(iUnit,1) & all_chans(:,2)==units(iUnit,2));
            fr = spikes2fr(bdf.units(unit_idx).ts,bdf.pos(:,1),fr_tc);  
%             fr = spikes2FrMovAve( bdf.units(unit_idx).ts, bdf.pos(:,1), .05 ); 
            UR.firingrates_mov(:,:,iUnit) = fr(UR.mov_idx_table);     
            UR.firingrates_bump(:,:,iUnit) = fr(UR.bump_idx_table);     
%             UR.fr(iUnit,:) = fr;
        end    
    else
        UR.firingrates_mov = [];
%         UR.fr = [];        
    end
    
    if isfield(bdf,'emg')
        UR.emg = zeros(length(bdf.emg.emgnames),length(bdf.pos(:,1)));
        UR.emg_mov = zeros([size(UR.mov_idx_table) length(bdf.emg.emgnames)]);       
        [b_lp,a_lp] = butter(4,10/(bdf.emg.emgfreq/2));        
        [b_hp,a_hp] = butter(4,70/(bdf.emg.emgfreq/2),'high'); 
        for iEMG = 1:length(bdf.emg.emgnames)
            emg = double(bdf.emg.data(:,1+iEMG));          
            emg = filtfilt(b_hp,a_hp,emg);
            emg = abs(emg);
            emg = filtfilt(b_lp,a_lp,emg);
%             UR.emg(iEMG,:) = emg;
            UR.emg(iEMG,:) = emg;            
            UR.emg_mov(:,:,iEMG) = emg(UR.mov_idx_table)/max(emg(UR.mov_idx_table(:)));
        end
    else
        UR.emg = [];
        UR.emg_hold = [];
        UR.emg_mov = [];
    end
end 