close all;
clear;
clc;

filenames = { ...
        'Chewie_CO_FF_2013-10-22', ...
        'Chewie_CO_FF_2013-10-23', ...
        'Chewie_CO_FF_2013-10-31', ...
        'Chewie_CO_FF_2013-11-01', ...
        'Chewie_CO_FF_2013-12-03', ...
        'Chewie_CO_FF_2013-12-04', ...
        'Chewie_CO_FF_2015-06-29', ...
    'Chewie_CO_FF_2015-06-30', ...
    'Chewie_CO_FF_2015-07-01', ...
    'Chewie_CO_FF_2015-07-03', ...
    'Chewie_CO_FF_2015-07-06', ...
    'Chewie_CO_FF_2015-07-07', ...
    'Chewie_CO_FF_2015-07-08', ...
    'Mihili_CO_FF_2014-02-17', ...
    'Mihili_CO_FF_2014-02-18', ...
    'Mihili_CO_FF_2014-03-07', ...
    'Mihili_CO_FF_2015-06-10', ...
    'Mihili_CO_FF_2015-06-11', ...
    'Mihili_CO_FF_2015-06-15', ...
    'Mihili_CO_FF_2015-06-16', ...
    'Mihili_CO_FF_2014-02-03', ...
    'Mihili_CO_FF_2015-06-17'};

for iFile = 1:length(filenames)
    
    clearvars -except filenames iFile;
    close all;
    clc;
    
    root_dir = 'F:\trial_data_files\';
    
    %% load in trial data
    load([root_dir filenames{iFile} '.mat']);
    
    %%
    use_models = {'muscle'};
    do_poisson = true;
    
    %%%%%%%%%%%%%%% PARAMETERS %%%%%%%%%%%%%%%%%%%
    pos_offset = [1,-31]; % position offset from behavior
    origin_pos = [0 15];
    dt = 0.01;
    
    %%% biomech model
    % use Cheng/Scott 2000 for parameters
    switch lower(trial_data(1).monkey)
        case 'chewie'
            body_weight = 12.2; % body mass in kg
            M1 = 34.4*body_weight/1000; % from Scott 2000
            M2 = 25.2*body_weight/1000;
            L1 = 0.19;
            L2 = 0.22;
%             M1 = 0.7; % mass of upper arm in kg
%             M2 = 0.7; % mass of lower arm in kg
%             L1 = 0.17; % length of upper arm in m
%             L2 = 0.17; % length of lower arm in m
        case 'mihili'
            body_weight = 8.8;
            M1 = 34.4*body_weight/1000;
            M2 = 25.2*body_weight/1000;
            L1 = 0.17;
            L2 = 0.20;
%             M1 = 0.55; % mass of upper arm in kg
%             M2 = 0.55; % mass of lower arm in kg
%             L1 = 0.14; % length of upper arm in m
%             L2 = 0.14; % length of lower arm in m
    end
    
    TH_1_min = 0;  % minimum shoulder angle
    TH_1_max = pi; % maximum shoulder angle
    TH_2_min = 0;  % minimum elbow angle
    TH_2_max = pi; % maximum elbow angle
    
    %%% muscle model
    % This is insertion distance as proportion of segment length
    %   For now, assume muscles have same lever arm on both segments
    muscle_d = [0.02, 0.02, 0.02, 0.02]; % 2cm insertion distance
    
    %%% neural activity model
    num_neurons = 50;
    muscle_gains = [1,1,1,1]; % gain terms for [sh flex, sh ext, el flex, el ext]
    use_synergy = false; % use "synergies" (e.g. only flexors or extensors)
    mean_lag = 10; % mean lag in bins, will be shifted before tuning
    std_lag = 3; % how many bins of standard deviation
    
    
    % build params struct
    params = struct('use_models',{use_models},'do_poisson',do_poisson,'pos_offset',pos_offset,'origin_pos',origin_pos,'dt',dt,'M1',M1,'M2',M2,'L1',L1,'L2',L2, ...
        'muscle_d',muscle_d,'num_neurons',num_neurons,'muscle_gains',muscle_gains,'use_synergy',use_synergy,'mean_lag',mean_lag,'std_lag',std_lag);

    
    %% Make Washout into Baseline
    % % % idx = strcmpi({trial_data.epoch},'WO');
    % % % trial_data(idx) = [];
    % % % idx = strcmpi({trial_data.epoch},'BL');
    % % % temp = trial_data(idx);
    % % % for i = 1:length(temp)
    % % %     temp(i).epoch = 'WO';
    % % % end
    % % % trial_data = [trial_data temp];
    
    %% get behavioral data
    epochs = unique({trial_data.epoch});
    
    idx = find(strcmpi({trial_data.epoch},'AD'));
    
    trial_err = zeros(length(idx),1);
    
    v = trial_data(idx(1)).vel;
    move_idx = trial_data(idx(1)).idx_movement_on:trial_data(idx(1)).idx_movement_on+10;
    trial_err(1) = angleDiff(trial_data(idx(1)).target_direction, atan2(v( move_idx(end),2)-v( move_idx(1),2),v( move_idx(end),1)-v( move_idx(1),1)), true, true);
    
    for iTrial = 2:length(idx)
        v = trial_data(idx(iTrial)).vel;
        move_idx = trial_data(idx(iTrial)).idx_movement_on:trial_data(idx(iTrial)).idx_movement_on+10;
        trial_err(iTrial) = angleDiff(trial_data(idx(iTrial)).target_direction, atan2(v(move_idx(end),2)-v(move_idx(1),2),v(move_idx(end),1)-v(move_idx(1),1)), true, true);
    end
    % fit an exponential
    f = fit((1:length(idx))',trial_err,'exp1');
    cf_errs = f.a*exp(f.b*(1:length(idx)));
    
    cf_errs_diff = [0, cumsum(diff(cf_errs))];
    
    cf_direction = sign(trial_data(idx(1)).perturbation_info(1));
    
    %% loop along trials and do modeling
    disp('Calculating kinematics and dynamics...');
    
    cf_count = 0;
    for iTrial = 1:length(trial_data)
        
        if strcmpi(trial_data(iTrial).epoch,'AD')
            K = trial_data(iTrial).perturbation_info(1); % curl field constant
        else
            K = 0;
        end
        TH_c = trial_data(iTrial).perturbation_info(2); % angle of curl field application
        
        % get position and convert to meters
        p = (trial_data(iTrial).pos - repmat(pos_offset,size(trial_data(iTrial).pos,1),1) + repmat(origin_pos,size(trial_data(iTrial).pos,1),1)) / 100;
        v = trial_data(iTrial).vel / 100;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% calculate joint angles
        th = zeros(size(p,1),2);
        for t = 1:size(p,1)
            d = (p(t,1)^2 + p(t,2)^2 - L1^2 - L2^2)/(2*L1*L2);
            
            if d > 1
                disp('OH CRAP SOMETHING IS WEIRD IN THE POSITION');
                d = 1;
            end
            
            % there are two solutions to the quadratic, so pick one in the bound
            %th(t,2) = atan2(sqrt(1-d^2) , d);
            th(t,2) = acos(d);
            
            th(t,1) = ( -L2*sin(th(t,2))*p(t,1) + (L1 + L2*cos(th(t,2)))*p(t,2) ) / ( L2*sin(th(t,2))*p(t,2) + (L1 + L2*cos(th(t,2)))*p(t,1) );
            %th(t,1) = atan2(p(t,2),p(t,1)) - atan2( (L2*sin(th(t,2))) , (L1+L2*cos(th(t,2))) );
        end
        
        % get joint angular velocity and acceleration
        dth = zeros(size(th,1),2);
        ddth = zeros(size(th,1),2);
        dth(:,1) = gradient(th(:,1),dt);
        dth(:,2) = gradient(th(:,2),dt);
        ddth(:,1) = gradient(dth(:,1),dt);
        ddth(:,2) = gradient(dth(:,2),dt);
        
        %%% calculate curl field force vector
        Fc = zeros(size(v,1),2);
        for t = 1:size(v,1)
            Fc(t,:) = 100 * K * [cos(TH_c)*v(t,1) - sin(TH_c)*v(t,2), sin(TH_c)*v(t,1) + cos(TH_c) * v(t,2)];
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% calculate joint torques at each time bin
        
        % calculate constants for equations of motion
        R1 = 1/2*L1;
        R2 = 1/2*L2;
        I1 = 1/3*M1*(L1^2);
        I2 = 1/3*M2*(L2^2);
        
        A = I1 + I2 + M1*(R1^2) + M2*(L1^2 + R2^2);
        B = M2*L1*R2;
        C = I2 + M2*(R2^2);
        
        % loop through time and compute torques
        T = zeros(size(ddth,1),2);
        T_plan = zeros(size(ddth,1),2);
        T_force = zeros(size(ddth,1),2);
        for t = 1:size(ddth,1)
            
            % build vector for X force
            fxTerms = [L1*sin(th(t,1)) + L2*sin(th(t,1)+th(t,2)); ...
                L2*sin(th(t,1) + th(t,2))];
            
            % build vector for Y force
            fyTerms = [L1*cos(th(t,1)) + L2*cos(th(t,1)+th(t,2)); ...
                L2*cos(th(t,1) + th(t,2))];
            
            if 1
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % build matrix of inertial terms
                ddTerms = [A + 2*B*cos(th(t,2)), C + B*cos(th(t,2)); ...
                    C + B*cos(th(t,2)),   C];
                % build matrix of coriolis terms
                dTerms = [-B*sin(th(t,2))*dth(t,2), -B*sin(th(t,2))*(dth(t,1) + dth(t,2)); ...
                    B*sin(th(t,2))*dth(t,1),  0];
                
                % compute torques for this time
                T(t,:) = ddTerms * ddth(t,:)' + dTerms * dth(t,:)' - fxTerms*Fc(t,1) + fyTerms*Fc(t,2);
                T_plan(t,:) = ddTerms * ddth(t,:)' + dTerms * dth(t,:)';
            else
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % THIS METHOD ASSUMES SAME MASS AND LENGTH
                T(t,1) = (1/2*M1*L1^2) * ( ddth(t,1)*2*(5/3 + cos(th(t,2))) + ddth(t,2)*(2/3 + cos(th(t,2))) + sin(th(t,2))*dth(t,2)*(2*dth(t,1)+dth(t,2)) );
                T(t,2) = (1/2*M2*L2^2) * ( ddth(t,1)*(2/3 + cos(th(t,2))) + ddth(t,2)*2/3 + sin(th(t,2))*(dth(t,1)^2) );
            end

            
            T_force(t,:) = -fxTerms*Fc(t,1) + fyTerms*Fc(t,2);
            
            T_plan(t,:) = T(t,:);
            T(t,:) = T(t,:) + T_force(t,:);
            
        end

        sim_data(iTrial).kin.real.pos = p;
        sim_data(iTrial).kin.real.vel = v;
        sim_data(iTrial).torques = T;
        sim_data(iTrial).torques_plan = T_plan;
        sim_data(iTrial).torques_force = T_force;
        sim_data(iTrial).kin.real.angles = th;
        sim_data(iTrial).kin.real.dangles = dth;
        sim_data(iTrial).kin.real.ddangles = ddth;
        
        % This is complicated... here's the goal:
        %   Find the kinematic trajectory (velocity) with NO curl field that
        %   gives the observed trajectory WITH a curl field
        %%%%%%%%%
        T = T_plan;
        v = zeros(size(dth,1),2);
        ddth = zeros(size(T,1),2);
        dth = zeros(size(T,1)+1,2);
        th = zeros(size(T,1)+1,2);
        dth(1,:) = sim_data(iTrial).kin.real.dangles(1,:);
        th(1,:) = sim_data(iTrial).kin.real.angles(1,:);
        for t = 1:size(T,1)
            
            % use Jacobian to get endpoint velocities from
            % angular kinematics
            J = [-L1*sin(th(t,1))-L2*sin(th(t,1) + th(t,2)), -L2*sin(th(t,1)+th(t,2)); L1*cos(th(t,1))+L2*cos(th(t,1)+th(t,2)), L2*cos(th(t,1)+th(t,2))];
            v(t,:) = J*[dth(t,1);dth(t,2)];
            
            % compute angular acceleration
            T1p = T(t,1)/(1/2*M1*L1^2) + sin(th(t,2))*dth(t,2)*(2*dth(t,1) + dth(t,2));
            T2p = T(t,2)/(1/2*M2*L2^2) - sin(th(t,2))*dth(t,1)*dth(t,1);
            
            ddth(t,1) = ( 2/3*T1p - (2/3+cos(th(t,2)))*T2p )/(16/9  - (cos(th(t,2)))^2);
            ddth(t,2) = ( -(2/3 + cos(th(t,2)))*T1p + 2*(5/3 + cos(th(t,2)))*T2p ) / (16/9 - (cos(th(t,2)))^2);
            
            dth(t+1,1) = dth(1,1) + trapz(ddth(1:t,1))*dt;
            dth(t+1,2) = dth(1,2) + trapz(ddth(1:t,2))*dt;
            th(t+1,1) = th(1,1) + trapz(dth(1:t,1))*dt;
            th(t+1,2) = th(1,2) + trapz(dth(1:t,2))*dt;
        end
        
        th = th(1:end-1,:);
        dth = dth(1:end-1,:);
        
        p = cumtrapz(v,1)*dt;
        
        sim_data(iTrial).kin.plan.pos = p;
        sim_data(iTrial).kin.plan.vel = v;
        sim_data(iTrial).kin.plan.angles = th;
        sim_data(iTrial).kin.plan.dangles = dth;
        sim_data(iTrial).kin.plan.ddangles = ddth;
        
        
        % if it's a curl field trial, get error
        if strcmpi(trial_data(iTrial).epoch,'AD')
            cf_count = cf_count + 1;
            curr_err = cf_errs_diff(cf_count);
            % rotate velocity trace
            R = [cos(curr_err), -sin(curr_err); ...
                sin(curr_err), cos(curr_err)];
            v_plan = zeros(size(v));
            for t = 1:size(ddth,1)
                v_plan(t,:) = R*[v(t,1); v(t,2)];
            end
            
        else
            v_plan = v;
        end
        
        sim_data(iTrial).kin.reaim.vel = v_plan;
        
        % % %     Alternative means of doing forward dynamics
        % % %             % get center of mass for current state of arm
        % % %             cm_x = M1/(M1+M2) * (R1*cos(th(t,1))) + M2/(M1+M2) * (L1*cos(th(t,1)) + R2*cos(th(t,1)+th(t,2)));
        % % %             cm_y = M1/(M1+M2) * (R1*sin(th(t,1))) + M2/(M1+M2) * (L1*sin(th(t,1)) + R2*sin(th(t,1)+th(t,2)));
        % % %             % use parallel axis theorem to get Icm
        % % %             Icm = (I1/4 + M1*hypot(cm_x - R1*cos(th(t,1)), cm_y - R1*sin(th(t,1)))^2) + ...
        % % %                 (I2/4 + M2*hypot(cm_x - L1*cos(th(t,1)) + R2*cos(th(t,1)+th(t,2)), cm_y - L1*sin(th(t,1)) + R2*sin(th(t,1)+th(t,2)))^2);
        % % %             % now use parallel axis theorem again to get I
        % % %             % around shoulder joint
        % % %             Is = Icm + (M1+M2)*hypot(cm_x,cm_y)^2;
        % % % %             Is = I1 + I2/4 + ...
        % % % %                 M2*( (L1*cos(th(t,1)) + R2*cos(th(t,1)+th(t,2)) )^2 + ...
        % % % %                 ( L1*sin(th(t,1)) + R2*sin(th(t,1)+th(t,2)) )^2 );
        % % %             % compute moment of inertia of elbow
        % % %             Ie = I1+I2;
        % % %
        % % %             ddth(t,1) = T(t,1)/Is;
        % % %             ddth(t,2) = T(t,2)/Ie;
        
    end
    
    %% Calculate muscle activations
    disp('Calculating muscle activations...');
    for iTrial = 1:length(trial_data)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % calculate muscle activations
        %   - scaled from 0 to 1
        %   [sh flex, sh ext, el flex, el ext]
        muscles = zeros(size(sim_data(iTrial).torques,1),4);
        
        % calculate muscle action angles as a function of time
        %muscle_angles = [sim_data(iTrial).angles(:,1)/2, (pi-sim_data(iTrial).angles(:,1))/2, sim_data(iTrial).angles(:,2)/2, (pi-sim_data(iTrial).angles(:,2))/2];
        %muscle_angles = repmat([pi/2,pi/2,pi/2,pi/2],size(stim_data(iTrial).angles,1),1);
        muscle_angles = repmat([15,4.88,80.86,19.32]*pi/180,size(sim_data(iTrial).torques,1),1); % from Lillicrap supplementary materials
        
        % Now calculate muscle force needed to cause the observed torque
        % shoulder flexion
        idx = sim_data(iTrial).torques(:,1) > 0;
        muscles(idx,1) = sim_data(iTrial).torques(idx,1)./(muscle_d(1)*sin(muscle_angles(idx,1)));
        
        % shoulder extension
        idx = sim_data(iTrial).torques(:,1) < 0;
        muscles(idx,2) = abs(sim_data(iTrial).torques(idx,1))./(muscle_d(2)*sin(muscle_angles(idx,2)));
        
        % elbow flexion
        idx = sim_data(iTrial).torques(:,2) > 0;
        muscles(idx,3) = sim_data(iTrial).torques(idx,2)./(muscle_d(3)*sin(muscle_angles(idx,3)));
        
        % elbow extension
        idx = sim_data(iTrial).torques(:,2) < 0;
        muscles(idx,4) = abs(sim_data(iTrial).torques(idx,2))./(muscle_d(4)*sin(muscle_angles(idx,4)));
        
        sim_data(iTrial).muscles = muscles;
        
    end
    
    % First, get max torque across all trials
    T_max = max(cell2mat(cellfun(@(x) max(x)',{sim_data.torques},'UniformOutput',false))',[],1);
    T_min = min(cell2mat(cellfun(@(x) min(x)',{sim_data.torques},'UniformOutput',false))',[],1);
    % Now, max velocity across all trials
    % V_max = max(cell2mat(cellfun(@(x) max(x)',{sim_data.kin.real.vel},'UniformOutput',false))',[],1);
    % V_min = min(cell2mat(cellfun(@(x) min(x)',{sim_data.kin.real.vel},'UniformOutput',false))',[],1);
    % Now, max muscles across all trials
    M_max = max(cell2mat(cellfun(@(x) max(x)',{sim_data.muscles},'UniformOutput',false))',[],1);
    M_min = min(cell2mat(cellfun(@(x) min(x)',{sim_data.muscles},'UniformOutput',false))',[],1);
    
    %% Now, generate neural activity for each trial
    
    for iModel = 1:length(use_models)
        um = use_models{iModel};
        
        if strcmpi(um(1:3),'kin')
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % generate neurons from kinematic model
            disp('Generating firing rates from kinematics...');
            fr_gain = 100;
            tc_gain = [0.2 1 1 1];
            
            % use moran and schwartz 1999 JNP model
            %   parameters are: [b0,bn,bx,by]
            
            tc = zeros(num_neurons,size(tc_gain,2));
            for unit = 1:num_neurons
                % generate random tuning curve
                tc(unit,1) = tc_gain(1) .* rand;
                tc(unit,2) = tc_gain(2) .* rand;
                % in this model, bx and by can be - or +
                tc(unit,3) = tc_gain(3) .* (-1 + 2*rand);
                tc(unit,4) = tc_gain(4) .* (-1 + 2*rand);
            end
            
            for iTrial = 1:length(sim_data)
                % assume each label begins with 'kin_'
                v = sim_data(iTrial).kin.(um(5:end)).vel;
                v_mag = hypot(v(:,1),v(:,2));
                
                fr = zeros(size(sim_data(iTrial).torques,1),num_neurons);
                for unit = 1:num_neurons
                    temp = fr_gain * (tc(unit,1) + ...
                        tc(unit,2) .* v_mag + ...
                        tc(unit,3) .* v(:,1) + ...
                        tc(unit,4) .* v(:,2));
                    
                    temp(temp < 0) = 0;
                    
                    if do_poisson
                        fr(:,unit) = poissrnd(temp);
                    else
                        fr(:,unit) = temp;
                    end
                end
                
                sim_data(iTrial).([um '_neurons']) = fr;
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % generate neurons from torque model
        elseif strcmpi(um,'torque')
            disp('Generating firing rates from joint torques...');
            fr_gain = 100;
            tc_gain = [0.2 1 1 1 1];
            
            % linear combination of all muscles
            tc = zeros(num_neurons,size(tc_gain,2));
            for unit = 1:num_neurons
                % tc(unit,:) = tc_gain .* rand(1,size(tc_gain,2));
                % tc(unit,randi(size(tc_gain,2)-1)+1) = 1; % for one torque only
                tc(unit,1) = tc_gain(1) .* rand(1);
                tc(unit,2:end) = tc_gain(2:end) .* (-1 + 2.*rand(1,size(tc_gain,2)-1)); % for negative values
            end
            for iTrial = 1:length(sim_data)
                % Get temporary matrix separating torques for flexion/extension
                temp_T = zeros(size(sim_data(iTrial).torques,1),4);
                % shoulder flexion
                idx = sim_data(iTrial).torques(:,1) > 0;
                temp_T(idx,1) = sim_data(iTrial).torques(idx,1)./T_max(1);
                % shoulder extension
                idx = sim_data(iTrial).torques(:,1) < 0;
                temp_T(idx,2) = abs(sim_data(iTrial).torques(idx,1)./T_min(1));
                % elbow flexion
                idx = sim_data(iTrial).torques(:,2) > 0;
                temp_T(idx,3) = sim_data(iTrial).torques(idx,2)./T_max(2);
                % elbow extension
                idx = sim_data(iTrial).torques(:,2) < 0;
                temp_T(idx,4) = abs(sim_data(iTrial).torques(idx,2)./T_min(2));
                
                fr = zeros(size(sim_data(iTrial).torques,1),num_neurons);
                for unit = 1:num_neurons
                    temp = fr_gain * (tc(unit,1) + sum(repmat(tc(unit,2:end),size(sim_data(iTrial).torques,1),1) .* temp_T,2));
                    temp(temp < 0) = 0;
                    if do_poisson
                        fr(:,unit) = poissrnd(temp);
                    else
                        fr(:,unit) = temp;
                    end
                end
                sim_data(iTrial).([um '_neurons']) = fr;
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % generate neurons from muscle model
        elseif strcmpi(um,'muscle')
            disp('Generating firing rates from muscle activity...');
            fr_gain = 100;
            tc_gain = [0.2 1 1 1 1];
            %     tc_gain = [0.17 0.7 0.4 0.7 0.4];
            
            % linear combination of all muscles
            tc = zeros(num_neurons,size(tc_gain,2));
            unit_lag = zeros(1,num_neurons);
            for unit = 1:num_neurons
                if use_synergy % pick flexors OR extensors
                    if rand > 0.5 % flexors
                        temp_gain = tc_gain .* [1 1 0 1 0];
                    else % extensors
                        temp_gain = tc_gain .* [1 0 1 0 1];
                    end
                    tc(unit,1) = temp_gain(1) .* rand(1);
                    tc(unit,2:end) = temp_gain(2:end) .* (-1 + 2.*rand(1,size(tc_gain,2)-1));
                else % select from all muscles equally
                    tc(unit,1) = tc_gain(1) .* rand(1);
                    tc(unit,2:end) = tc_gain(2:end) .* (-1 + 2.*rand(1,size(tc_gain,2)-1));
                    %                 tc(unit,randi(size(tc_gain,2)-1)+1) = 1; % modeled to be predominantly one muscle
                end
                
                % get a random unit-specific lag
                unit_lag(unit) = floor(normrnd(mean_lag,std_lag));
                
            end
            
            unit_lag(unit_lag < 1) = 1;
            
            for iTrial = 1:length(sim_data)
                fr = zeros(size(sim_data(iTrial).torques,1),num_neurons);
                for unit = 1:num_neurons
                    
                    temp = fr_gain * (tc(unit,1) + sum(repmat(tc(unit,2:end),size(sim_data(iTrial).torques,1),1) .* (sim_data(iTrial).muscles./repmat(M_max,size(sim_data(iTrial).torques,1),1)),2));
                    temp(temp < 0) = 0;
                    
                    %shift neural data back by lags and pad with zeros
                    temp = [temp(unit_lag(unit)+1:end); zeros(unit_lag(unit),1)];
                    
                    if do_poisson
                        fr(:,unit) = poissrnd(temp);
                    else
                        fr(:,unit) = temp;
                    end
                end
                sim_data(iTrial).([um '_neurons']) = fr;
            end
        else
            error('Model not recognized.');
        end
        neural_tcs.(um) = tc;
    end
    
    %%
    arm_sim_tuning;
    
    save([root_dir filenames{iFile} '_results.mat'],'sw_data','tc_data','neural_tcs','params');
    
end

%% Plot the simulation
if 0
    params.M1 = M1; % mass of upper arm in kg
    params.M2 = M2; % mass of lower arm in kg
    params.L1 = L1; % length of upper arm in m
    params.L2 = L2; % length of lower arm in m
    params.pos_offset = pos_offset; % position offset from behavior
    params.origin_pos = origin_pos;
    params.dt = dt;
    params.M_max = M_max;
    params.M_min = M_min;
    % params.V_max = V_max;
    % params.V_min = V_min;
    params.T_max = T_max;
    params.T_min = T_min;
    params.num_neurons = num_neurons;
    
    % params.type = 'time_signals';
    params.type = 'time_signals';
    params.resolution = 1;
    params.signals = {'vel','muscles','kin_real_neurons','muscle_neurons'};
    params.kin_model = 'real';
    
    
    iTrial = 3;
    plot_arm_sim(sim_data(iTrial),params);
end
