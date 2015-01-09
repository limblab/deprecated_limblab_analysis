function RP = RP_create_struct(bdf,params)
    RP = params; 
    RP.dt = diff(bdf.pos(1:2,1));
    [RP.trial_table,RP.table_columns,bdf] = RP_trial_table(bdf);
    BMI_data_files = dir([RP.target_folder '*data.txt']);
    BMI_param_files = dir([RP.target_folder '*params.mat']);
    
    if ~isempty(BMI_data_files)
        
        %%
        RP.BMI.dt = 0.05;
        temp = load([RP.target_folder BMI_data_files(1).name]);
        if ~isempty(find(diff(temp(:,1))<0,1,'last'))
            remove_idx = find(diff(temp(:,1))<0,1,'last');
            temp = temp(remove_idx+1:end,:);   
%             temp(:,1) = temp(:,1)+.05*remove_idx;
            temp(:,1) = temp(:,1)+.1;
%             temp(:,1) = temp(:,1)-temp(1,1)+.1;
        end        
        BMI_data = temp;
        for iBMI = 2:length(BMI_data_files)
            temp = load([RP.target_folder BMI_data_files(iBMI).name]);
            if ~isempty(find(diff(temp(:,1))<0,1,'last'))
                remove_idx = find(diff(temp(:,1))<0,1,'last');
                temp = temp(remove_idx+1:end,:);
%                 temp(:,1) = temp(:,1)+.05*remove_idx;
                temp(:,1) = temp(:,1)-temp(1,1)+.05;
            end
            temp(:,1) = temp(:,1)+BMI_data(end,1)+1.05; % Add one second in between files
            BMI_data = [BMI_data ; temp];
            clear temp
        end
        BMI_data(:,1) = BMI_data(:,1)+.05;
        BMI_data(find(diff(BMI_data(:,1))==0)+1,:) = [];
        new_time_vector = 1:RP.BMI.dt:bdf.pos(end,1);
        new_BMI_data = zeros(length(new_time_vector),size(BMI_data,2));
        new_BMI_data(:,1) = new_time_vector;
        for iCol = 2:size(BMI_data,2)
            new_BMI_data(:,iCol) = interp1(BMI_data(:,1),BMI_data(:,iCol),new_time_vector);
        end
        BMI_data = new_BMI_data;
        clear new_BMI_data        
        RP.BMI.data = BMI_data;
        %%
        if ~isempty(BMI_param_files)
            RP.BMI.params = load([RP.target_folder BMI_param_files(1).name]);
        end
        clear BMI_data
    end
    
    RP.trial_table(RP.trial_table(:,RP.table_columns.result)==33,:) = [];
    RP.perturbation_directions = unique(RP.trial_table(:,RP.table_columns.perturbation_direction)); 
    RP.perturbation_amplitudes = unique(RP.trial_table(:,RP.table_columns.perturbation_amplitude));
    RP.perturbation_frequencies = unique(RP.trial_table(:,RP.table_columns.perturbation_frequency));
    RP.bump_directions = unique(RP.trial_table(:,RP.table_columns.bump_direction));
    RP.bump_directions = RP.bump_directions(~isnan(RP.bump_directions));

    for iAmplitude = 1:length(RP.perturbation_amplitudes)
        RP.perturbation_amplitudes_idx{iAmplitude} = find(RP.trial_table(:,RP.table_columns.perturbation_amplitude)==RP.perturbation_amplitudes(iAmplitude));
    end
    for iDir = 1:length(RP.perturbation_directions)
        RP.perturbation_directions_idx{iDir} = find(RP.trial_table(:,RP.table_columns.perturbation_direction)==RP.perturbation_directions(iDir));
    end
    for iFreq = 1:length(RP.perturbation_frequencies)
        RP.perturbation_frequencies_idx{iFreq} = find(RP.trial_table(:,RP.table_columns.perturbation_frequency)==RP.perturbation_frequencies(iFreq));
    end
    for iBump = 1:length(RP.bump_directions)
        RP.bump_directions_idx{iBump} = find(RP.trial_table(:,RP.table_columns.bump_direction)==RP.bump_directions(iBump));
    end
    
    RP.perturbation_frequencies(cellfun(@length,RP.perturbation_frequencies_idx)<10) = [];
    RP.perturbation_frequencies_idx(cellfun(@length,RP.perturbation_frequencies_idx)<10) = [];
        
    RP.perturbation_direction_colors = hsv(length(RP.perturbation_directions));
    if length(RP.perturbation_amplitudes) == 2
        RP.perturbation_amplitudes_colors = [.8 0 0; 0 0 .8];
    else
        RP.perturbation_amplitudes_colors = jet(length(RP.perturbation_amplitudes));
    end
    if length(RP.perturbation_frequencies) == 1
        RP.perturbation_frequency_colors = [.8 0 0];
    elseif length(RP.perturbation_frequencies) == 2
        RP.perturbation_frequency_colors = [.8 0 0; 0 0 .8];
    else
        RP.perturbation_frequency_colors = copper(length(RP.perturbation_frequencies));
        r = (1:-1/(length(RP.perturbation_frequencies)-1):0)';
        g = zeros(1,length(RP.perturbation_frequencies))';
        b = (0:1/(length(RP.perturbation_frequencies)-1):1)';
        RP.perturbation_frequency_colors = [r g b];
    end
    
    RP.reward_trials = find(RP.trial_table(:,RP.table_columns.result) == 32);
    
    trial_starts = RP.trial_table(:,RP.table_columns.t_ct_hold_on); 
    perturbation_starts = RP.trial_table(:,RP.table_columns.t_start_perturbation); 
    trial_ends = RP.trial_table(:,RP.table_columns.t_trial_end);
    t_bump = RP.trial_table(:,RP.table_columns.t_bump); 
    bump_trials = RP.trial_table(:,RP.table_columns.bump_trial);
    no_bump_trials = ~RP.trial_table(:,RP.table_columns.bump_trial);
    late_bump_trials = bump_trials & ~RP.trial_table(:,RP.table_columns.early_bump);
    if any(isnan(t_bump))
        t_bump(isnan(t_bump)) = RP.trial_table(isnan(t_bump),RP.table_columns.t_trial_end); 
    end
    perturbation_starts(isnan(perturbation_starts)) = t_bump(isnan(perturbation_starts));
    
    perturbation_length = floor(10*(t_bump - perturbation_starts))/10;
    bump_bin_size = 0.25;
    RP.bump_bin_edges = 0:bump_bin_size:max(perturbation_length);
    
    [~,RP.bump_in_bin] = histc(perturbation_length,RP.bump_bin_edges);
    
    idx_vector = round(bdf.pos(:,1)*1000);
    [~,RP.start_idx,~] = intersect(idx_vector,round(1000*trial_starts));
    [~,RP.end_idx,~] = intersect(idx_vector,round(1000*trial_ends));
    [~,RP.perturbation_start_idx,~] = intersect(idx_vector,round(1000*perturbation_starts));   
    [~,RP.bump_onset_idx,~] = intersect(idx_vector,round(1000*t_bump));
    
    if isfield(RP,'BMI')
        idx_vector_bmi = round(RP.BMI.data(:,1)*1/RP.BMI.dt);
        [~,RP.start_idx_bmi,~] = intersect(idx_vector_bmi,round(20*trial_starts));
        [~,RP.end_idx_bmi,~] = intersect(idx_vector_bmi,round(20*trial_ends));
        [~,RP.perturbation_start_idx_bmi,~] = intersect(idx_vector_bmi,round(20*perturbation_starts));   
        [~,RP.bump_onset_idx_bmi,~] = intersect(idx_vector_bmi,round(20*t_bump));
    end
    
    RP.bump_trials = find(RP.trial_table(:,RP.table_columns.bump_trial));    
    RP.no_bump_trials = find(~RP.trial_table(:,RP.table_columns.bump_trial));
    RP.early_bump = intersect(RP.bump_trials,find(RP.trial_table(:,RP.table_columns.early_bump)));
    RP.late_bump = intersect(RP.bump_trials,find(~RP.trial_table(:,RP.table_columns.early_bump)));
    
    RP.in_task_idx = cellfun(@(i,j) (idx_vector(i:j)),...
        num2cell(RP.start_idx), num2cell(RP.end_idx),...
        'UniformOutput',false);
    RP.in_task_idx = cell2mat(RP.in_task_idx);

%     pert_samples = ceil(max(t_bump-perturbation_starts))*round(1/RP.dt);
%     pert_samples = floor(min(trial_ends(bump_trials)-perturbation_starts(bump_trials)))*round(1/RP.dt);
%     pert_samples = floor(min(trial_ends(late_bump_trials)-perturbation_starts(late_bump_trials)))*round(1/RP.dt);
%     pert_samples = floor(min(trial_ends(no_bump_trials)-perturbation_starts(no_bump_trials)))*round(1/RP.dt);

    
    pert_samples = round(mode(trial_ends(intersect(RP.reward_trials,find(late_bump_trials)))-...
        perturbation_starts(intersect(RP.reward_trials,find(late_bump_trials))))*round(1/RP.dt));

    pert_offset = 100;
    RP.t_pert = (0:RP.dt:RP.dt*pert_samples-RP.dt)-pert_offset*RP.dt;    
    RP.pert_idx_table = repmat(RP.perturbation_start_idx,1,pert_samples) + repmat(1:pert_samples,size(RP.perturbation_start_idx,1),1) - pert_offset;
    RP.pert_idx_table(RP.pert_idx_table<1) = 1;

    RP.force_pert_x = reshape(bdf.force(RP.pert_idx_table,2),[],pert_samples);
    RP.force_pert_y = reshape(bdf.force(RP.pert_idx_table,3),[],pert_samples);

    RP.pos_pert_x = reshape(bdf.pos(RP.pert_idx_table,2),[],pert_samples)+RP.trial_table(1,RP.table_columns.x_offset);
    RP.pos_pert_y = reshape(bdf.pos(RP.pert_idx_table,3),[],pert_samples)+RP.trial_table(1,RP.table_columns.y_offset);

    RP.vel_pert_x = reshape(bdf.vel(RP.pert_idx_table,2),[],pert_samples);
    RP.vel_pert_y = reshape(bdf.vel(RP.pert_idx_table,3),[],pert_samples);
    
    RP.pos_pert_x_rot = zeros(size(RP.pos_pert_x));
    RP.pos_pert_y_rot = zeros(size(RP.pos_pert_x));
    
    RP.force_pert_x_rot = zeros(size(RP.force_pert_x));
    RP.force_pert_y_rot = zeros(size(RP.force_pert_y));
    t_zero = find(RP.t_pert>=0,1,'first');
    for iDir = 1:length(RP.perturbation_directions)
        theta = RP.perturbation_directions(iDir);
        rot_mat = [cos(theta) -sin(theta); sin(theta) cos(theta)];           
        idx = RP.perturbation_directions_idx{iDir};
        temp_x = RP.pos_pert_x(idx,:);
        temp_y = RP.pos_pert_y(idx,:);
        temp = [temp_x(:) temp_y(:)];             
        temp = temp*rot_mat;
        temp_x = reshape(temp(:,1),size(RP.pos_pert_x(idx,:)));
        temp_y = reshape(temp(:,2),size(RP.pos_pert_y(idx,:)));
        temp_x = temp_x - repmat(temp_x(:,t_zero),1,size(temp_x,2));
        temp_y = temp_y - repmat(temp_y(:,t_zero),1,size(temp_y,2));
        RP.pos_pert_x_rot(idx,:) = temp_x;
        RP.pos_pert_y_rot(idx,:) = temp_y;
        
        temp_x = RP.force_pert_x(idx,:);
        temp_y = RP.force_pert_y(idx,:);
        temp = [temp_x(:) temp_y(:)];        
        temp = temp*rot_mat;
        temp_x = reshape(temp(:,1),size(RP.pos_pert_x(idx,:)));
        temp_y = reshape(temp(:,2),size(RP.pos_pert_x(idx,:)));
        RP.force_pert_x_rot(idx,:) = temp_x;
        RP.force_pert_y_rot(idx,:) = temp_y;
    end
    
    if isfield(RP,'BMI')
        pert_samples = round(mode(trial_ends(intersect(RP.reward_trials,find(late_bump_trials)))-...
            perturbation_starts(intersect(RP.reward_trials,find(late_bump_trials))))*round(1/RP.BMI.dt));

        pert_offset = 10;
        RP.t_pert_bmi = (0:RP.BMI.dt:RP.BMI.dt*pert_samples-RP.BMI.dt)-pert_offset*RP.BMI.dt;    
        RP.pert_idx_table_bmi = repmat(RP.perturbation_start_idx_bmi,1,pert_samples) + repmat(1:pert_samples,size(RP.perturbation_start_idx_bmi,1),1) - pert_offset;
        RP.pert_idx_table_bmi(RP.pert_idx_table_bmi<1) = 1;

        force_idx = [find(strcmp(RP.BMI.params.headers,'F_x')) find(strcmp(RP.BMI.params.headers,'F_y'))];
        RP.force_pert_x_bmi = reshape(RP.BMI.data(RP.pert_idx_table_bmi,force_idx(1)),[],pert_samples);
        RP.force_pert_y_bmi = reshape(RP.BMI.data(RP.pert_idx_table_bmi,force_idx(2)),[],pert_samples);

        pos_idx = [find(strcmp(RP.BMI.params.headers,'cursor_x')) find(strcmp(RP.BMI.params.headers,'cursor_y'))];
        RP.pos_pert_x_bmi = reshape(RP.BMI.data(RP.pert_idx_table_bmi,pos_idx(1)),[],pert_samples);
        RP.pos_pert_y_bmi = reshape(RP.BMI.data(RP.pert_idx_table_bmi,pos_idx(2)),[],pert_samples);   
        
        RP.pos_pert_x_rot_bmi = zeros(size(RP.pos_pert_x_bmi));
        RP.pos_pert_y_rot_bmi = zeros(size(RP.pos_pert_x_bmi));

        RP.force_pert_x_rot_bmi = zeros(size(RP.force_pert_x_bmi));
        RP.force_pert_y_rot_bmi = zeros(size(RP.force_pert_y_bmi));
        t_zero = find(RP.t_pert_bmi>=0,1,'first');
        for iDir = 1:length(RP.perturbation_directions)
            theta = RP.perturbation_directions(iDir);
            rot_mat = [cos(theta) -sin(theta); sin(theta) cos(theta)];           
            idx = RP.perturbation_directions_idx{iDir};
            temp_x = RP.pos_pert_x_bmi(idx,:);
            temp_y = RP.pos_pert_y_bmi(idx,:);
            temp = [temp_x(:) temp_y(:)];             
            temp = temp*rot_mat;
            temp_x = reshape(temp(:,1),size(RP.pos_pert_x_bmi(idx,:)));
            temp_y = reshape(temp(:,2),size(RP.pos_pert_y_bmi(idx,:)));
            temp_x = temp_x - repmat(temp_x(:,t_zero),1,size(temp_x,2));
            temp_y = temp_y - repmat(temp_y(:,t_zero),1,size(temp_y,2));
            RP.pos_pert_x_rot_bmi(idx,:) = temp_x;
            RP.pos_pert_y_rot_bmi(idx,:) = temp_y;

            temp_x = RP.force_pert_x_bmi(idx,:);
            temp_y = RP.force_pert_y_bmi(idx,:);
            temp = [temp_x(:) temp_y(:)];        
            temp = temp*rot_mat;
            temp_x = reshape(temp(:,1),size(RP.pos_pert_x_bmi(idx,:)));
            temp_y = reshape(temp(:,2),size(RP.pos_pert_x_bmi(idx,:)));
            RP.force_pert_x_rot_bmi(idx,:) = temp_x;
            RP.force_pert_y_rot_bmi(idx,:) = temp_y;
        end
    end
    
    
    t_zero = find(RP.t_pert==0);
    RP.pert_displacement = sqrt((RP.pos_pert_x-repmat(RP.pos_pert_x(:,t_zero),1,size(RP.pos_pert_x,2))).^2 +...
        (RP.pos_pert_y-repmat(RP.pos_pert_y(:,t_zero),1,size(RP.pos_pert_y,2))).^2);
    RP.pert_displacement(RP.pert_displacement==0) = 0.01;
    RP.pert_displacement_angle = atan2((RP.pos_pert_y-repmat(RP.pos_pert_y(:,t_zero),1,size(RP.pos_pert_y,2))),...
        (RP.pos_pert_x-repmat(RP.pos_pert_x(:,t_zero),1,size(RP.pos_pert_x,2))));
    
    RP.force_pert_magnitude = sqrt((RP.force_pert_x-repmat(RP.force_pert_x(:,t_zero),1,size(RP.force_pert_x,2))).^2 +...
        (RP.force_pert_y-repmat(RP.force_pert_y(:,t_zero),1,size(RP.force_pert_y,2))).^2);
    RP.force_pert_magnitude(RP.force_pert_magnitude==0) = 0.01;
    RP.force_pert_angle = atan2((RP.force_pert_y-repmat(RP.force_pert_y(:,t_zero),1,size(RP.force_pert_y,2))),...
        (RP.force_pert_x-repmat(RP.force_pert_x(:,t_zero),1,size(RP.force_pert_x,2))));
    
    RP.stiffness_magnitude_pert = RP.force_pert_magnitude./RP.pert_displacement;
           
    bump_t_offset = 50;
    bump_samples = round(RP.trial_table(RP.bump_trials(1),RP.table_columns.bump_duration)/RP.dt) + bump_t_offset;    
    if isnan(bump_samples)
        bump_samples = 2*bump_t_offset;
    end
    
    RP.t_bump = RP.dt*((1:bump_samples) - bump_t_offset -1);
    RP.bump_idx_table = repmat(RP.bump_onset_idx,1,bump_samples) + repmat(1:bump_samples,size(RP.bump_onset_idx,1),1) - bump_t_offset;
    RP.bump_idx_table(RP.bump_idx_table<1) = 1;
    
    RP.force_bump_x = reshape(bdf.force(RP.bump_idx_table,2),[],bump_samples);
    RP.force_bump_y = reshape(bdf.force(RP.bump_idx_table,3),[],bump_samples);
        
    RP.pos_bump_x = reshape(bdf.pos(RP.bump_idx_table,2),[],bump_samples)+RP.trial_table(1,RP.table_columns.x_offset);
    RP.pos_bump_y = reshape(bdf.pos(RP.bump_idx_table,3),[],bump_samples)+RP.trial_table(1,RP.table_columns.y_offset);
    
    RP.vel_bump_x = reshape(bdf.vel(RP.bump_idx_table,2),[],bump_samples);
    RP.vel_bump_y = reshape(bdf.vel(RP.bump_idx_table,3),[],bump_samples);
    
    RP.pos_bump_x_rot = zeros(size(RP.pos_bump_x));
    RP.pos_bump_y_rot = zeros(size(RP.pos_bump_x));
    RP.force_bump_x_rot = zeros(size(RP.pos_bump_x));
    RP.force_bump_y_rot = zeros(size(RP.pos_bump_x));
   
    for iDir = 1:length(RP.bump_directions)
        theta = RP.bump_directions(iDir);
        idx = RP.bump_directions_idx{iDir};
        idx = intersect(idx,find(RP.trial_table(:,RP.table_columns.bump_trial)));
        temp_x = RP.pos_bump_x(idx,:);
        temp_y = RP.pos_bump_y(idx,:);
        temp = [temp_x(:) temp_y(:)];
        rot_mat = [cos(theta) -sin(theta); sin(theta) cos(theta)];        
        temp = temp*rot_mat;
        temp_x = reshape(temp(:,1),size(RP.pos_bump_x(idx,:)));
        temp_y = reshape(temp(:,2),size(RP.pos_bump_x(idx,:)));
        RP.pos_bump_x_rot(idx,:) = temp_x;
        RP.pos_bump_y_rot(idx,:) = temp_y;
        
        temp_x = RP.force_bump_x(idx,:);
        temp_y = RP.force_bump_y(idx,:);
        temp = [temp_x(:) temp_y(:)];        
        temp = temp*rot_mat;
        temp_x = reshape(temp(:,1),size(RP.pos_bump_x(idx,:)));
        temp_y = reshape(temp(:,2),size(RP.pos_bump_x(idx,:)));
        RP.force_bump_x_rot(idx,:) = temp_x;
        RP.force_bump_y_rot(idx,:) = temp_y;
    end
    bump_onset_idx = find(RP.t_bump==0);
    for iTrial = 1:size(RP.trial_table,1)
        RP.pos_bump_x_rot(iTrial,:) = RP.pos_bump_x_rot(iTrial,:)-RP.pos_bump_x_rot(iTrial,bump_onset_idx);
        RP.pos_bump_y_rot(iTrial,:) = RP.pos_bump_y_rot(iTrial,:)-RP.pos_bump_y_rot(iTrial,bump_onset_idx);
        RP.force_bump_x_rot(iTrial,:) = RP.force_bump_x_rot(iTrial,:)-RP.force_bump_x_rot(iTrial,bump_onset_idx);
        RP.force_bump_y_rot(iTrial,:) = RP.force_bump_y_rot(iTrial,:)-RP.force_bump_y_rot(iTrial,bump_onset_idx);       
    end
    
    t_zero = find(RP.t_bump==0);
    RP.bump_displacement = sqrt((RP.pos_bump_x-repmat(RP.pos_bump_x(:,t_zero),1,size(RP.pos_bump_x,2))).^2 +...
        (RP.pos_bump_y-repmat(RP.pos_bump_y(:,t_zero),1,size(RP.pos_bump_y,2))).^2);
    RP.bump_displacement(RP.bump_displacement==0) = 0.01;
    RP.bump_displacement_angle = atan2((RP.pos_bump_y-repmat(RP.pos_bump_y(:,t_zero),1,size(RP.pos_bump_y,2))),...
        (RP.pos_bump_x-repmat(RP.pos_bump_x(:,t_zero),1,size(RP.pos_bump_x,2))));
    
    RP.force_bump_magnitude = sqrt((RP.force_bump_x-repmat(RP.force_bump_x(:,t_zero),1,size(RP.force_bump_x,2))).^2 +...
        (RP.force_bump_y-repmat(RP.force_bump_y(:,t_zero),1,size(RP.force_bump_y,2))).^2);
    RP.force_bump_magnitude(RP.force_bump_magnitude==0) = 0.01;
    RP.force_bump_angle = atan2((RP.force_bump_y-repmat(RP.force_bump_y(:,t_zero),1,size(RP.force_bump_y,2))),...
        (RP.force_bump_x-repmat(RP.force_bump_x(:,t_zero),1,size(RP.force_bump_x,2))));
    
    RP.stiffness_magnitude_bump = RP.force_bump_magnitude./RP.bump_displacement;
    
    
    if isfield(RP,'BMI')
        
        bump_t_offset = 2;
        bump_samples = round(RP.trial_table(RP.bump_trials(1),RP.table_columns.bump_duration)/RP.BMI.dt) + bump_t_offset;    
        if isnan(bump_samples)
            bump_samples = 2*bump_t_offset;
        end

        RP.t_bump_bmi = RP.dt*((1:bump_samples) - bump_t_offset -1);
        RP.bump_idx_table_bmi = repmat(RP.bump_onset_idx_bmi,1,bump_samples) + repmat(1:bump_samples,size(RP.bump_onset_idx_bmi,1),1) - bump_t_offset;
        RP.bump_idx_table_bmi(RP.bump_idx_table_bmi<1) = 1;

        force_idx = [find(strcmp(RP.BMI.params.headers,'F_x')) find(strcmp(RP.BMI.params.headers,'F_y'))];
        RP.force_bump_x_bmi = reshape(RP.BMI.data(RP.bump_idx_table_bmi,force_idx(1)),[],bump_samples);
        RP.force_bump_y_bmi = reshape(RP.BMI.data(RP.bump_idx_table_bmi,force_idx(2)),[],bump_samples);

        pos_idx = [find(strcmp(RP.BMI.params.headers,'cursor_x')) find(strcmp(RP.BMI.params.headers,'cursor_y'))];
        RP.pos_bump_x_bmi = reshape(RP.BMI.data(RP.bump_idx_table_bmi,pos_idx(1)),[],bump_samples);
        RP.pos_bump_y_bmi = reshape(RP.BMI.data(RP.bump_idx_table_bmi,pos_idx(2)),[],bump_samples);

        RP.pos_bump_x_rot_bmi = zeros(size(RP.pos_bump_x_bmi));
        RP.pos_bump_y_rot_bmi = zeros(size(RP.pos_bump_x_bmi));
        RP.force_bump_x_rot_bmi = zeros(size(RP.pos_bump_x_bmi));
        RP.force_bump_y_rot_bmi = zeros(size(RP.pos_bump_x_bmi));

        for iDir = 1:length(RP.bump_directions)
            theta = RP.bump_directions(iDir);
            idx = RP.bump_directions_idx{iDir};
            idx = intersect(idx,find(RP.trial_table(:,RP.table_columns.bump_trial)));
            temp_x = RP.pos_bump_x_bmi(idx,:);
            temp_y = RP.pos_bump_y_bmi(idx,:);
            temp = [temp_x(:) temp_y(:)];
            rot_mat = [cos(theta) -sin(theta); sin(theta) cos(theta)];        
            temp = temp*rot_mat;
            temp_x = reshape(temp(:,1),size(RP.pos_bump_x_bmi(idx,:)));
            temp_y = reshape(temp(:,2),size(RP.pos_bump_x_bmi(idx,:)));
            RP.pos_bump_x_rot_bmi(idx,:) = temp_x;
            RP.pos_bump_y_rot_bmi(idx,:) = temp_y;

            temp_x = RP.force_bump_x_bmi(idx,:);
            temp_y = RP.force_bump_y_bmi(idx,:);
            temp = [temp_x(:) temp_y(:)];        
            temp = temp*rot_mat;
            temp_x = reshape(temp(:,1),size(RP.pos_bump_x_bmi(idx,:)));
            temp_y = reshape(temp(:,2),size(RP.pos_bump_x_bmi(idx,:)));
            RP.force_bump_x_rot_bmi(idx,:) = temp_x;
            RP.force_bump_y_rot_bmi(idx,:) = temp_y;
        end
        bump_onset_idx = find(RP.t_bump_bmi==0);
        for iTrial = 1:size(RP.trial_table,1)
            RP.pos_bump_x_rot_bmi(iTrial,:) = RP.pos_bump_x_rot_bmi(iTrial,:)-RP.pos_bump_x_rot_bmi(iTrial,bump_onset_idx);
            RP.pos_bump_y_rot_bmi(iTrial,:) = RP.pos_bump_y_rot_bmi(iTrial,:)-RP.pos_bump_y_rot_bmi(iTrial,bump_onset_idx);
            RP.force_bump_x_rot_bmi(iTrial,:) = RP.force_bump_x_rot_bmi(iTrial,:)-RP.force_bump_x_rot_bmi(iTrial,bump_onset_idx);
            RP.force_bump_y_rot_bmi(iTrial,:) = RP.force_bump_y_rot_bmi(iTrial,:)-RP.force_bump_y_rot_bmi(iTrial,bump_onset_idx);       
        end
        
    end
    
    if isfield(bdf,'units')
        units = unit_list(bdf,1);
        RP.firingrates_pert = zeros([size(RP.pert_idx_table) length(units)]); 
        RP.firingrates_bump = zeros([size(RP.bump_idx_table) length(units)]); 
        all_chans = reshape([bdf.units.id],2,[])';
        fr_tc = 0.02;
%         temp = spikes2FrMovAve(bdf.units(1).ts,bdf.pos(:,1),fr_tc);
%         RP.fr = zeros(size(units,1),length(temp));

        for iUnit = 1:size(units,1)    
            unit_idx = find(all_chans(:,1)==units(iUnit,1) & all_chans(:,2)==units(iUnit,2));
%             fr = spikes2fr(bdf.units(unit_idx).ts,bdf.pos(:,1),fr_tc);  
            fr = spikes2FrMovAve( bdf.units(unit_idx).ts, bdf.pos(:,1), .05 ); 
            RP.firingrates_pert(:,:,iUnit) = fr(RP.pert_idx_table);     
            RP.firingrates_bump(:,:,iUnit) = fr(RP.bump_idx_table);     
%             RP.fr(iUnit,:) = fr;
        end    
    else
        RP.firingrates_pert = [];
%         RP.fr = [];        
    end
    
    if isfield(bdf,'emg')
        RP.emg = zeros(length(bdf.emg.emgnames),length(bdf.pos(:,1)));
        RP.emg_pert = zeros([size(RP.pert_idx_table) length(bdf.emg.emgnames)]);       
        RP.emg_bump = zeros([size(RP.bump_idx_table) length(bdf.emg.emgnames)]);          
        RP.emg_pert_raw = zeros([size(RP.pert_idx_table) length(bdf.emg.emgnames)]);       
        RP.emg_bump_raw = zeros([size(RP.bump_idx_table) length(bdf.emg.emgnames)]);
        [b_lp,a_lp] = butter(4,10/(bdf.emg.emgfreq/2));        
        [b_hp,a_hp] = butter(4,70/(bdf.emg.emgfreq/2),'high'); 
        for iEMG = 1:length(bdf.emg.emgnames)
            raw_emg = double(bdf.emg.data(:,1+iEMG));          
            emg = filtfilt(b_hp,a_hp,raw_emg);
%             emg = raw_emg;
            emg = abs(emg);
            emg = filtfilt(b_lp,a_lp,emg);
%             RP.emg(iEMG,:) = emg;
            RP.emg(iEMG,:) = emg;            
            RP.emg_pert(:,:,iEMG) = emg(RP.pert_idx_table)/max(emg(RP.pert_idx_table(:)));
            RP.emg_pert(RP.emg_pert<0) = 0;
            RP.emg_bump(:,:,iEMG) = emg(RP.bump_idx_table)/max(emg(RP.bump_idx_table(:)));
            RP.emg_pert_raw(:,:,iEMG) = raw_emg(RP.pert_idx_table);
            RP.emg_bump_raw(:,:,iEMG) = raw_emg(RP.bump_idx_table);
        end
        emg_idx = find(~cellfun(@isempty,strfind(bdf.emg.emgnames,'BI')));
        emg_idx = [emg_idx find(~cellfun(@isempty,strfind(bdf.emg.emgnames,'TRI')))];
        
        temp_1 = RP.emg_pert(:,:,emg_idx(1))./RP.emg_pert(:,:,emg_idx(2));
        temp_2 = RP.emg_pert(:,:,emg_idx(2))./RP.emg_pert(:,:,emg_idx(1));
        temp = min(temp_1,temp_2);
        
        RP.emg_cocontraction_bi_tri = temp .* (RP.emg_pert(:,:,emg_idx(1)) + ...
            RP.emg_pert(:,:,emg_idx(2)));
    else
        RP.emg = [];
        RP.emg_hold = [];
        RP.emg_pert = [];
    end
    
    if isfield(RP,'BMI')
        emg_idx = find(~cellfun(@isempty,strfind(RP.BMI.params.headers,'EMG')));        
        RP.BMI.emgnames = RP.BMI.params.headers(emg_idx);
        RP.emg_pert_bmi = zeros([size(RP.pert_idx_table_bmi) length(RP.BMI.emgnames)]);       
        RP.emg_bump_bmi = zeros([size(RP.bump_idx_table_bmi) length(RP.BMI.emgnames)]);       
        RP.cocontraction_pert_bmi = zeros([size(RP.pert_idx_table_bmi) length(RP.BMI.emgnames)]);
        for iEMG = 1:length(RP.BMI.emgnames)
            emg = RP.BMI.data(:,emg_idx(iEMG));
            RP.emg_pert_bmi(:,:,iEMG) = emg(RP.pert_idx_table_bmi);
            RP.emg_bump_bmi(:,:,iEMG) = emg(RP.bump_idx_table_bmi);            
        end
        cocontraction_idx = find(~cellfun(@isempty,strfind(RP.BMI.params.headers,'cocontraction')));    
        cocontraction = RP.BMI.data(:,cocontraction_idx); %#ok<FNDSB>
%         emg_idx = find(~cellfun(@isempty,strfind(RP.BMI.emgnames,'BI')));
%         emg_idx = [emg_idx find(~cellfun(@isempty,strfind(RP.BMI.emgnames,'TRI')))];
%         
%         temp_1 = RP.emg_pert_bmi(:,:,emg_idx(1))./RP.emg_pert_bmi(:,:,emg_idx(2));
%         temp_2 = RP.emg_pert_bmi(:,:,emg_idx(2))./RP.emg_pert_bmi(:,:,emg_idx(1));
%         temp = min(temp_1,temp_2);
%         
%         RP.emg_cocontraction_bmi_bi_tri = temp .* (RP.emg_pert_bmi(:,:,emg_idx(1)) + ...
%             RP.emg_pert_bmi(:,:,emg_idx(2)));
        RP.emg_cocontraction_bmi_bi_tri = cocontraction(RP.pert_idx_table_bmi);
    end
end 