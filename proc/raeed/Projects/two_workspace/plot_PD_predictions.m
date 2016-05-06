%% %% Plot PD change predictions based on different coordinate frame neurons

%% load bdf
% bdf = get_nev_mat_data([folder options.prefix],options.labnum);
folder = '/home/raeed/Projects/limblab/FSMRes/limblab/User_folders/Raeed/Arm Model/Data/Chips/experiment_20151120_RW_003/';
prefix = 'Chips_20151120_RW_003';
labnum = 6;
opensim_prefix = 'Chips_20151120_scaled';

bdf = get_nev_mat_data([folder prefix],labnum);
bdf.meta.task = 'RW';
opts.binsize=0.05;
opts.offset=-.015;
opts.do_trial_table=1;
opts.do_firing_rate=1;
bdf=postprocess_bdf(bdf,opts);
which_units = [];
behaviors = parse_for_tuning(bdf,'continuous','units',which_units);

%% load joint kinematics
joint_pos_mat = csvread([folder 'Analysis/' opensim_prefix '_Kinematics_q.sto'],11,0);
joint_pos = array2table(joint_pos_mat,'VariableNames',{'time','shoulder_adduction','shoulder_rotation','shoulder_flexion','elbow_flexion','radial_pronation','wrist_flexion','wrist_abduction'});
clear joint_kin_mat

%% load muscle kinematics
muscle_pos_mat = csvread([folder 'Analysis/' opensim_prefix '_MuscleAnalysis_Length.sto'],12,0);
muscle_pos = array2table(muscle_pos_mat,'VariableNames',{'time','abd_poll_longus','anconeus','bicep_lh','bicep_sh','brachialis','brachioradialis','coracobrachialis','deltoid_ant','deltoid_med','deltoid_pos','dorsoepitrochlearis','ext_carpi_rad_longus','ext_carp_rad_brevis','ext_carpi_ulnaris','ext_digitorum','ext_digiti','ext_indicis','flex_carpi_radialis','flex_carpi_ulnaris','flex_digit_profundus','flex_digit_superficialis','flex_poll_longus','infraspinatus','lat_dorsi_sup','lat_dorsi_cen','lat_dorsi_inf','palmaris_longus','pectoralis_sup','pectoralis_inf','pronator_quad','pronator_teres','subscapularis','supinator','supraspinatus','teres_major','teres_minor','tricep_lat','tricep_lon','tricep_sho'});
clear muscle_kin_mat

%% filter kinematics (PROBABLY UNNECESSARY, AND UNUSED IN THIS SCRIPT)
% nyq_frq = 1/2*1/mode(diff(joint_kin.time));
% cuttoff = 10/nyq_frq;
% [b,a] = butter(4,cuttoff);
% 
% % filter joint angles
% joint_kin_filt = joint_kin;
% for i=2:size(joint_kin,2)
%     joint_kin{:,i} = filtfilt(b,a,joint_kin{:,i});
% end
% 
% % filter muscle lengths
% muscle_kin_filt = muscle_kin;
% for i=2:size(muscle_kin,2)
%     muscle_kin{:,i} = filtfilt(b,a,muscle_kin{:,i});
% end

%% get intrinsic velocities
% joint velocities
joint_vel = joint_pos;
for i=2:size(joint_pos,2)
    joint_vel{:,i} = gradient(joint_pos{:,i},joint_pos.time);
end

% filter muscle lengths
muscle_vel = muscle_pos;
for i=2:size(muscle_pos,2)
    muscle_vel{:,i} = gradient(muscle_pos{:,i},muscle_pos.time);
end

clear i

%% extract times of workspaces
[bdf_PM,times_PM] = extract_workspace(bdf,[-10 -55],[0 -45]);
[bdf_DL,times_DL] = extract_workspace(bdf,[0 -45],[10 -35]);

%% joint kinematics for each workspace
% PM first
joint_pos_PM = table;
joint_vel_PM = table;
for i = 1:length(times_PM)
    reach_ind = joint_pos.time>times_PM(i,1) & joint_pos.time<times_PM(i,2);
    joint_pos_PM = [joint_pos_PM; joint_pos(reach_ind,:)];
    joint_vel_PM = [joint_vel_PM; joint_vel(reach_ind,:)];
end
% then DL
joint_pos_DL = table;
joint_vel_DL = table;
for i = 1:length(times_DL)
    reach_ind = joint_pos.time>times_DL(i,1) & joint_pos.time<times_DL(i,2);
    joint_pos_DL = [joint_pos_DL; joint_pos(reach_ind,:)];
    joint_vel_DL = [joint_vel_DL; joint_vel(reach_ind,:)];
end

clear i

%% muscle kinematics for each workspace
% PM first
muscle_kin_PM = table;
muscle_vel_PM = table;
for i = 1:length(times_PM)
    reach_ind = muscle_pos.time>times_PM(i,1) & muscle_pos.time<times_PM(i,2);
    muscle_kin_PM = [muscle_kin_PM; muscle_pos(reach_ind,:)];
    muscle_vel_PM = [muscle_vel_PM; muscle_vel(reach_ind,:)];
end
% then DL
muscle_kin_DL = table;
muscle_vel_DL = table;
for i = 1:length(times_DL)
    reach_ind = muscle_pos.time>times_DL(i,1) & muscle_pos.time<times_DL(i,2);
    muscle_kin_DL = [muscle_kin_DL; muscle_pos(reach_ind,:)];
    muscle_vel_DL = [muscle_vel_DL; muscle_vel(reach_ind,:)];
end

clear i
clear reach_ind

%% make fake "neurons"
num_neurons = 100;
joint_weights = randn(7,num_neurons);
joint_neur_PM = joint_vel_PM{:,2:end}*joint_weights;
joint_neur_DL = joint_vel_DL{:,2:end}*joint_weights;

muscle_weights = randn(size(muscle_vel,2)-1,num_neurons);
% muscle_weights = eye(num_neurons);
muscle_neur_PM = muscle_vel_PM{:,2:end}*muscle_weights;
muscle_neur_DL = muscle_vel_DL{:,2:end}*muscle_weights;

%% set up kinematics
t = bdf.pos(:,1);
pos = bdf.pos(:,2:3);
vel = bdf.vel(:,2:3);
spd = sqrt(sum(vel.^2,2));
endpoint_kin = [pos vel spd];

%% Calculate simulated PDs
bootfunc = @(X,y) LinearModel.fit(X,y);

% PM first
% interpolate endpoint kinematics to joint times
endpoint_kin_sim_PM = interp1(t,endpoint_kin,joint_vel_PM.time);

% do joint velocity regression
tic;
for i = 1:num_neurons
%     mdl = LinearModel.fit(endpoint_kin_PM,joint_vel_PM{:,i});
    boot_tuning = bootstrp(100,@(X,y) {bootfunc(X,y)}, endpoint_kin_sim_PM, joint_neur_PM(:,i));
    %Display verbose information
    disp(['Processed Joint PM ' num2str(i) ' (Time: ' num2str(toc) ')']);
    
    %extract coefficiencts from boot_tuning
    boot_coef = cell2mat(cellfun(@(x) x.Coefficients.Estimate',boot_tuning,'uniformoutput',false));
    
    %coefficient covariance
%     coef_cov = cov(boot_coef);
    
    %get coefficient means
    coef_means = mean(boot_coef);
    
    %get 95% CIs for coefficients
    coef_CIs = prctile(boot_coef,[2.5 97.5]); 
    
    % bootstrap directions
    boot_dirs = atan2(boot_coef(:,5),boot_coef(:,4));
    % recenter boot_dirs
    mean_dir = atan2(coef_means(5),coef_means(4));
    centered_boot_dirs = boot_dirs-mean_dir;
    while(sum(centered_boot_dirs<-pi))
        centered_boot_dirs(centered_boot_dirs<-pi) = centered_boot_dirs(centered_boot_dirs<-pi)+2*pi;
    end
    while(sum(centered_boot_dirs>pi))
        centered_boot_dirs(centered_boot_dirs>pi) = centered_boot_dirs(centered_boot_dirs>pi)-2*pi;
    end

    % Calculate dir CI
    dir_CI = prctile(centered_boot_dirs,[2.5 97.5]);

    % uncenter CI
    dir_CI = dir_CI+mean_dir;

    joint_tuning_PM(i).dir = mean_dir;
    joint_tuning_PM(i).dir_CI = dir_CI';
%     joint_tuning_PM(i).name = joint_vel_PM.Properties.VariableNames{i};
    joint_tuning_PM(i).moddepth = sqrt(sum(coef_means(4:5).^2));
end

for i = 1:num_neurons
%     mdl = LinearModel.fit(endpoint_kin_PM,joint_vel_PM{:,i});
    boot_tuning = bootstrp(100,@(X,y) {bootfunc(X,y)}, endpoint_kin_sim_PM, muscle_neur_PM(:,i));
    %Display verbose information
    disp(['Processed Muscle PM ' num2str(i) ' (Time: ' num2str(toc) ')']);
    
    %extract coefficiencts from boot_tuning
    boot_coef = cell2mat(cellfun(@(x) x.Coefficients.Estimate',boot_tuning,'uniformoutput',false));
    
    %coefficient covariance
%     coef_cov = cov(boot_coef);
    
    %get coefficient means
    coef_means = mean(boot_coef);
    
    %get 95% CIs for coefficients
    coef_CIs = prctile(boot_coef,[2.5 97.5]); 
    
    % bootstrap directions
    boot_dirs = atan2(boot_coef(:,5),boot_coef(:,4));
    % recenter boot_dirs
    mean_dir = atan2(coef_means(5),coef_means(4));
    centered_boot_dirs = boot_dirs-mean_dir;
    while(sum(centered_boot_dirs<-pi))
        centered_boot_dirs(centered_boot_dirs<-pi) = centered_boot_dirs(centered_boot_dirs<-pi)+2*pi;
    end
    while(sum(centered_boot_dirs>pi))
        centered_boot_dirs(centered_boot_dirs>pi) = centered_boot_dirs(centered_boot_dirs>pi)-2*pi;
    end

    % Calculate dir CI
    dir_CI = prctile(centered_boot_dirs,[2.5 97.5]);

    % uncenter CI
    dir_CI = dir_CI+mean_dir;

    muscle_tuning_PM(i).dir = mean_dir;
    muscle_tuning_PM(i).dir_CI = dir_CI';
%     joint_tuning_PM(i).name = joint_vel_PM.Properties.VariableNames{i};
    muscle_tuning_PM(i).moddepth = sqrt(sum(coef_means(4:5).^2));
end

% interpolate endpoint kinematics to joint times
endpoint_kin_sim_DL = interp1(t,endpoint_kin,joint_vel_DL.time);

% do joint velocity regression
for i = 1:num_neurons
%     mdl = LinearModel.fit(endpoint_kin_PM,joint_vel_PM{:,i});
    boot_tuning = bootstrp(100,@(X,y) {bootfunc(X,y)}, endpoint_kin_sim_DL, joint_neur_DL(:,i));
    %Display verbose information
    disp(['Processed Joint DL ' num2str(i) ' (Time: ' num2str(toc) ')']);
    
    %extract coefficiencts from boot_tuning
    boot_coef = cell2mat(cellfun(@(x) x.Coefficients.Estimate',boot_tuning,'uniformoutput',false));
    
    %coefficient covariance
%     coef_cov = cov(boot_coef);
    
    %get coefficient means
    coef_means = mean(boot_coef);
    
    %get 95% CIs for coefficients
    coef_CIs = prctile(boot_coef,[2.5 97.5]); 
    
    % bootstrap directions
    boot_dirs = atan2(boot_coef(:,5),boot_coef(:,4));
    % recenter boot_dirs
    mean_dir = atan2(coef_means(5),coef_means(4));
    centered_boot_dirs = boot_dirs-mean_dir;
    while(sum(centered_boot_dirs<-pi))
        centered_boot_dirs(centered_boot_dirs<-pi) = centered_boot_dirs(centered_boot_dirs<-pi)+2*pi;
    end
    while(sum(centered_boot_dirs>pi))
        centered_boot_dirs(centered_boot_dirs>pi) = centered_boot_dirs(centered_boot_dirs>pi)-2*pi;
    end

    % Calculate dir CI
    dir_CI = prctile(centered_boot_dirs,[2.5 97.5]);

    % uncenter CI
    dir_CI = dir_CI+mean_dir;

    joint_tuning_DL(i).dir = mean_dir;
    joint_tuning_DL(i).dir_CI = dir_CI';
%     joint_tuning_DL(i).name = joint_vel_DL.Properties.VariableNames{i};
    joint_tuning_DL(i).moddepth = sqrt(sum(coef_means(4:5).^2));
end

for i = 1:num_neurons
%     mdl = LinearModel.fit(endpoint_kin_PM,joint_vel_PM{:,i});
    boot_tuning = bootstrp(100,@(X,y) {bootfunc(X,y)}, endpoint_kin_sim_DL, muscle_neur_DL(:,i));
    %Display verbose information
    disp(['Processed Muscle DL ' num2str(i) ' (Time: ' num2str(toc) ')']);
    
    %extract coefficiencts from boot_tuning
    boot_coef = cell2mat(cellfun(@(x) x.Coefficients.Estimate',boot_tuning,'uniformoutput',false));
    
    %coefficient covariance
%     coef_cov = cov(boot_coef);
    
    %get coefficient means
    coef_means = mean(boot_coef);
    
    %get 95% CIs for coefficients
    coef_CIs = prctile(boot_coef,[2.5 97.5]); 
    
    % bootstrap directions
    boot_dirs = atan2(boot_coef(:,5),boot_coef(:,4));
    % recenter boot_dirs
    mean_dir = atan2(coef_means(5),coef_means(4));
    centered_boot_dirs = boot_dirs-mean_dir;
    while(sum(centered_boot_dirs<-pi))
        centered_boot_dirs(centered_boot_dirs<-pi) = centered_boot_dirs(centered_boot_dirs<-pi)+2*pi;
    end
    while(sum(centered_boot_dirs>pi))
        centered_boot_dirs(centered_boot_dirs>pi) = centered_boot_dirs(centered_boot_dirs>pi)-2*pi;
    end

    % Calculate dir CI
    dir_CI = prctile(centered_boot_dirs,[2.5 97.5]);

    % uncenter CI
    dir_CI = dir_CI+mean_dir;

    muscle_tuning_DL(i).dir = mean_dir;
    muscle_tuning_DL(i).dir_CI = dir_CI';
%     joint_tuning_DL(i).name = joint_vel_DL.Properties.VariableNames{i};
    muscle_tuning_DL(i).moddepth = sqrt(sum(coef_means(4:5).^2));
end

clear boot_tuning
clear boot_coef
% clear coef_cov
clear coef_means
clear coefCIs
clear boot_dirs
clear mean_dir
clear centered_boot_dirs
clear dir_CI
clear i
clear endpoint_kin_sim_PM
clear endpoint_kin_sim_DL
clear bootfunc

%% Do som real neuron accounting

%condense real neurons into one matrix
bin_times = bdf.units(1).FR(:,1); %time vector
real_neur = [];
for unit_ctr = 1:length(bdf.units)
    if bdf.units(unit_ctr).id(2)~=0 && bdf.units(unit_ctr).id(2)~=255
        real_neur = [real_neur bdf.units(unit_ctr).FR(:,2)/0.05]; % append firing rates for all sorted neurons (DIVIDE BY BINSIZE)
    end
end

% find time bins to look in for PM and DL
% PM first
is_PM_time = zeros(size(bin_times));
for i = 1:length(times_PM)
    is_PM_time = is_PM_time | (bin_times>times_PM(i,1) & bin_times<times_PM(i,2));
end
% then DL
is_DL_time = zeros(size(bin_times));
for i = 1:length(times_DL)
    is_DL_time = is_DL_time | (bin_times>times_DL(i,1) & bin_times<times_DL(i,2));
end

clear i
clear unit_ctr

%% Calculate actual PDs

% use GLM for actual neurons
bootfunc = @(X,y) GeneralizedLinearModel.fit(X,y);

% interpolate endpoint kinematics to joint times
endpoint_kin_real_PM = interp1(t,endpoint_kin,bin_times(is_PM_time));

for i = 1:size(real_neur,2)
%     mdl = LinearModel.fit(endpoint_kin_PM,joint_vel_PM{:,i});
    boot_tuning = bootstrp(100,@(X,y) {bootfunc(X,y)}, endpoint_kin_real_PM, real_neur(is_PM_time,i));
    %Display verbose information
    disp(['Processed Real PM ' num2str(i) ' (Time: ' num2str(toc) ')']);
    
    %extract coefficiencts from boot_tuning
    boot_coef = cell2mat(cellfun(@(x) x.Coefficients.Estimate',boot_tuning,'uniformoutput',false));
    
    %coefficient covariance
    coef_cov = cov(boot_coef);
    
    %get coefficient means
    coef_means = mean(boot_coef);
    
    %get 95% CIs for coefficients
    coef_CIs = prctile(boot_coef,[2.5 97.5]); 
    
    % bootstrap directions
    boot_dirs = atan2(boot_coef(:,5),boot_coef(:,4));
    % recenter boot_dirs
    mean_dir = atan2(coef_means(5),coef_means(4));
    centered_boot_dirs = boot_dirs-mean_dir;
    while(sum(centered_boot_dirs<-pi))
        centered_boot_dirs(centered_boot_dirs<-pi) = centered_boot_dirs(centered_boot_dirs<-pi)+2*pi;
    end
    while(sum(centered_boot_dirs>pi))
        centered_boot_dirs(centered_boot_dirs>pi) = centered_boot_dirs(centered_boot_dirs>pi)-2*pi;
    end

    % Calculate dir CI
    dir_CI = prctile(centered_boot_dirs,[2.5 97.5]);

    % uncenter CI
    dir_CI = dir_CI+mean_dir;

    real_tuning_PM(i).dir = mean_dir;
    real_tuning_PM(i).dir_CI = dir_CI';
    real_tuning_PM(i).moddepth = sqrt(sum(coef_means(4:5).^2));
end

% interpolate endpoint kinematics to joint times
endpoint_kin_real_DL = interp1(t,endpoint_kin,bin_times(is_DL_time));

for i = 1:size(real_neur,2)
%     mdl = LinearModel.fit(endpoint_kin_PM,joint_vel_PM{:,i});
    boot_tuning = bootstrp(100,@(X,y) {bootfunc(X,y)}, endpoint_kin_real_DL, real_neur(is_DL_time,i));
    %Display verbose information
    disp(['Processed Real DL ' num2str(i) ' (Time: ' num2str(toc) ')']);
    
    %extract coefficiencts from boot_tuning
    boot_coef = cell2mat(cellfun(@(x) x.Coefficients.Estimate',boot_tuning,'uniformoutput',false));
    
    %coefficient covariance
    coef_cov = cov(boot_coef);
    
    %get coefficient means
    coef_means = mean(boot_coef);
    
    %get 95% CIs for coefficients
    coef_CIs = prctile(boot_coef,[2.5 97.5]); 
    
    % bootstrap directions
    boot_dirs = atan2(boot_coef(:,5),boot_coef(:,4));
    % recenter boot_dirs
    mean_dir = atan2(coef_means(5),coef_means(4));
    centered_boot_dirs = boot_dirs-mean_dir;
    while(sum(centered_boot_dirs<-pi))
        centered_boot_dirs(centered_boot_dirs<-pi) = centered_boot_dirs(centered_boot_dirs<-pi)+2*pi;
    end
    while(sum(centered_boot_dirs>pi))
        centered_boot_dirs(centered_boot_dirs>pi) = centered_boot_dirs(centered_boot_dirs>pi)-2*pi;
    end

    % Calculate dir CI
    dir_CI = prctile(centered_boot_dirs,[2.5 97.5]);

    % uncenter CI
    dir_CI = dir_CI+mean_dir;

    real_tuning_DL(i).dir = mean_dir;
    real_tuning_DL(i).dir_CI = dir_CI';
    real_tuning_DL(i).moddepth = sqrt(sum(coef_means(4:5).^2));
end

clear boot_tuning
clear boot_coef
% clear coef_cov
clear coef_means
clear coefCIs
clear boot_dirs
clear mean_dir
clear centered_boot_dirs
clear dir_CI
clear i
clear endpoint_kin_real_PM
clear endpoint_kin_real_DL
clear bootfunc

%% plot joint and muscle PDs
angs_PM = [joint_tuning_PM.dir];
rad_PM = [joint_tuning_PM.moddepth];
dir_CI_PM = [joint_tuning_PM.dir_CI]';
angs_DL = [joint_tuning_DL.dir];
rad_DL = [joint_tuning_DL.moddepth];
dir_CI_DL = [joint_tuning_DL.dir_CI]';
% for i = 1:length(angs_DL)
%     figure
%     
%     h=polar(repmat(angs_PM(:,i),2,1),[0;1]*rad_PM(i));
%     set(h,'linewidth',2,'color',[0.6 0.5 0.7])
%     th_fill = [dir_CI_PM(i,2) angs_PM(i) dir_CI_PM(i,1) 0];
%     r_fill = [rad_PM(i) rad_PM(i) rad_PM(i) 0];
%     [x_fill,y_fill] = pol2cart(th_fill,r_fill);
%     patch(x_fill,y_fill,[0.6 0.5 0.7],'facealpha',0.3);
%     
%     hold on
%     
%     h=polar(repmat(angs_DL(:,i),2,1),[0;1]*rad_DL(i));
%     set(h,'linewidth',2,'color',[1 0 0])
%     th_fill = [dir_CI_DL(i,2) angs_DL(i) dir_CI_DL(i,1) 0];
%     r_fill = [rad_DL(i) rad_DL(i) rad_DL(i) 0];
%     [x_fill,y_fill] = pol2cart(th_fill,r_fill);
%     patch(x_fill,y_fill,[1 0 0],'facealpha',0.3);
% end
% 
angs_muscle_PM = [muscle_tuning_PM.dir];
rad_muscle_PM = [muscle_tuning_PM.moddepth];
dir_muscle_CI_PM = [muscle_tuning_PM.dir_CI]';
angs_muscle_DL = [muscle_tuning_DL.dir];
rad_muscle_DL = [muscle_tuning_DL.moddepth];
dir_muscle_CI_DL = [muscle_tuning_DL.dir_CI]';
% for i = 1:length(angs_DL)
%     figure
%     
%     h=polar(repmat(angs_muscle_PM(:,i),2,1),[0;1]*rad_muscle_PM(i));
%     set(h,'linewidth',2,'color',[0.6 0.5 0.7])
%     th_fill = [dir_muscle_CI_PM(i,2) angs_muscle_PM(i) dir_muscle_CI_PM(i,1) 0];
%     r_fill = [rad_muscle_PM(i) rad_muscle_PM(i) rad_muscle_PM(i) 0];
%     [x_fill,y_fill] = pol2cart(th_fill,r_fill);
%     patch(x_fill,y_fill,[0.6 0.5 0.7],'facealpha',0.3);
%     
%     hold on
%     
%     h=polar(repmat(angs_muscle_DL(:,i),2,1),[0;1]*rad_muscle_DL(i));
%     set(h,'linewidth',2,'color',[1 0 0])
%     th_fill = [dir_muscle_CI_DL(i,2) angs_muscle_DL(i) dir_muscle_CI_DL(i,1) 0];
%     r_fill = [rad_muscle_DL(i) rad_muscle_DL(i) rad_muscle_DL(i) 0];
%     [x_fill,y_fill] = pol2cart(th_fill,r_fill);
%     patch(x_fill,y_fill,[1 0 0],'facealpha',0.3);
% end

%% Iris plots
DL_CI_width = diff(dir_CI_DL,1,2); % get CI widths
PM_CI_width = diff(dir_CI_PM,1,2);
DL_CI_width(DL_CI_width<0) = DL_CI_width(DL_CI_width<0)+2*pi;
PM_CI_width(PM_CI_width<0) = PM_CI_width(PM_CI_width<0)+2*pi;
tuned_neurons = DL_CI_width<pi/8 & PM_CI_width<pi/8;
angs_PM_tuned = angs_PM(tuned_neurons);
angs_DL_tuned = angs_DL(tuned_neurons);

h=figure('name','joint_PD_diff');
%plot circles
h=polar(linspace(-pi,pi,1000),ones(1,1000));
set(h,'linewidth',2,'color',[1 0 0])
hold all
h=polar(linspace(-pi,pi,1000),0.5*ones(1,1000));
set(h,'linewidth',2,'color',[0.6 0.5 0.7])

% plot changes with alpha dependent on CI width
for unit_ctr = 1:length(angs_PM_tuned)
    h=polar(linspace(angs_PM_tuned(unit_ctr),angs_DL_tuned(unit_ctr),2),linspace(0.5,1,2));
    set(h,'linewidth',2,'color',[0.1 0.6 1])
end

set(findall(gcf, 'String','  0.2','-or','String','  0.4','-or','String','  0.6','-or','String','  0.8',...
        '-or','String','  1') ,'String', ' '); % remove a bunch of labels from the polar plot; radial and tangential

title('Plot of PD changes (joint)')

DL_muscle_CI_width = diff(dir_muscle_CI_DL,1,2); % get CI widths
PM_muscle_CI_width = diff(dir_muscle_CI_PM,1,2);
DL_muscle_CI_width(DL_muscle_CI_width<0) = DL_muscle_CI_width(DL_muscle_CI_width<0)+2*pi;
PM_muscle_CI_width(PM_muscle_CI_width<0) = PM_muscle_CI_width(PM_muscle_CI_width<0)+2*pi;
tuned_muscle_neurons = DL_muscle_CI_width<pi/8 & PM_muscle_CI_width<pi/8;
angs_muscle_PM_tuned = angs_muscle_PM(tuned_muscle_neurons);
angs_muscle_DL_tuned = angs_muscle_DL(tuned_muscle_neurons);

h=figure('name','muscle_PD_diff');
%plot circles
h=polar(linspace(-pi,pi,1000),ones(1,1000));
set(h,'linewidth',2,'color',[1 0 0])
hold all
h=polar(linspace(-pi,pi,1000),0.5*ones(1,1000));
set(h,'linewidth',2,'color',[0.6 0.5 0.7])

% plot changes with alpha dependent on CI width
for unit_ctr = 1:length(angs_muscle_PM_tuned)
    h=polar(linspace(angs_muscle_PM_tuned(unit_ctr),angs_muscle_DL_tuned(unit_ctr),2),linspace(0.5,1,2));
    set(h,'linewidth',2,'color',[0.1 0.6 1])
end

set(findall(gcf, 'String','  0.2','-or','String','  0.4','-or','String','  0.6','-or','String','  0.8',...
        '-or','String','  1') ,'String', ' '); % remove a bunch of labels from the polar plot; radial and tangential

title('Plot of PD changes (muscle)')

%% Real iris plot
angs_real_PM = [real_tuning_PM.dir];
rad_real_PM = [real_tuning_PM.moddepth];
dir_real_CI_PM = [real_tuning_PM.dir_CI]';
angs_real_DL = [real_tuning_DL.dir];
rad_real_DL = [real_tuning_DL.moddepth];
dir_real_CI_DL = [real_tuning_DL.dir_CI]';

DL_real_CI_width = diff(dir_real_CI_DL,1,2); % get CI widths
PM_real_CI_width = diff(dir_real_CI_PM,1,2);
DL_real_CI_width(DL_real_CI_width<0) = DL_real_CI_width(DL_real_CI_width<0)+2*pi;
PM_real_CI_width(PM_real_CI_width<0) = PM_real_CI_width(PM_real_CI_width<0)+2*pi;
tuned_real_neurons = DL_real_CI_width<pi/8 & PM_real_CI_width<pi/8;
angs_real_PM_tuned = angs_real_PM(tuned_real_neurons);
angs_real_DL_tuned = angs_real_DL(tuned_real_neurons);

h=figure('name','real_PD_diff');
%plot circles
h=polar(linspace(-pi,pi,1000),ones(1,1000));
set(h,'linewidth',2,'color',[1 0 0])
hold all
h=polar(linspace(-pi,pi,1000),0.5*ones(1,1000));
set(h,'linewidth',2,'color',[0.6 0.5 0.7])

% plot changes with alpha dependent on CI width
for unit_ctr = 1:length(angs_real_PM_tuned)
    h=polar(linspace(angs_real_PM_tuned(unit_ctr),angs_real_DL_tuned(unit_ctr),2),linspace(0.5,1,2));
    set(h,'linewidth',2,'color',[0.1 0.6 1])
end

set(findall(gcf, 'String','  0.2','-or','String','  0.4','-or','String','  0.6','-or','String','  0.8',...
        '-or','String','  1') ,'String', ' '); % remove a bunch of labels from the polar plot; radial and tangential

title('Plot of PD changes (real)')

%% Check kinematics
move_corr = endpoint_kin_sim_PM(:,3:4);
dir = atan2(move_corr(:,2),move_corr(:,1));
spd = sqrt(sum(move_corr.^2,2));

% bin directions
dir_bins = round(dir/(pi/4))*(pi/4);
dir_bins(dir_bins==-pi) = pi;

% find baseline move_corr...somehow


% average firing rates for directions
bins = -3*pi/4:pi/4:pi;
bins = bins';

full_binned_FR = [];
groups = [];
for i = 1:length(bins)
    vel_in_bin = joint_vel_PM{dir_bins==bins(i),2:end};
    spd_in_bin = spd(dir_bins==bins(i));
    
    % Mean binned FR has normal-looking distribution (checked with
    % bootstrapping)
    binned_FR(i,:) = mean(vel_in_bin); % mean firing rate
    binned_spd(i,:) = mean(spd_in_bin); % mean speed
    binned_stderr(i,:) = std(vel_in_bin)/sqrt(length(vel_in_bin)); % standard error
    binned_spd_err(i,:) = std(spd_in_bin)/sqrt(length(spd_in_bin)); % standard error of speed
    tscore = tinv(0.975,length(vel_in_bin)-1); % t-score for 95% CI
    binned_CI_high(i,:) = binned_FR(i,:)+tscore*binned_stderr(i,:); %high CI
    binned_CI_low(i,:) = binned_FR(i,:)-tscore*binned_stderr(i,:); %low CI
    binned_CI_high_spd(i,:) = binned_spd(i,:)+tscore*binned_spd_err(i,:); %high CI
    binned_CI_low_spd(i,:) = binned_spd(i,:)-tscore*binned_spd_err(i,:); %low CI
end

% plot tuning curves
figure_handles = zeros(size(binned_FR,2),1);
% plot speed curves
figure_handles(1) = figure('name','Binned Speed');
polar(repmat(bins,2,1),repmat(binned_spd,2,1))

% plot confidence intervals 
th_fill = [flipud(bins); bins(end); bins(end); bins];
r_fill = [flipud(binned_CI_high_spd); binned_CI_high_spd(end); binned_CI_low_spd(end); binned_CI_low_spd];
[x_fill,y_fill] = pol2cart(th_fill,r_fill);
patch(x_fill,y_fill,[0 0 1],'facealpha',0.3,'edgealpha',0);

% plot unit tuning curves
unit_ids = behaviors.unit_ids;
for i=1:length(figure_handles)
    figure_handles(i+1) = figure('name',['channel_' num2str(unit_ids(i,1)) '_unit_' num2str(unit_ids(i,2)) '_tuning_plot']);

    % plot tuning curve
%     polar(repmat(bins,2,1),repmat(binned_FR(:,i),2,1))

    % plot confidence intervals 
    th_fill = [flipud(bins); bins(end); bins(end); bins];
    r_fill = [flipud(binned_CI_high(:,i)); binned_CI_high(end,i); binned_CI_low(end,i); binned_CI_low(:,i)];
    [x_fill,y_fill] = pol2cart(th_fill,r_fill);
    patch(x_fill,y_fill,[0 0 1],'facealpha',0.3,'edgealpha',0);
    
    plot(bins,binned_FR(:,i))
end

%% plot PD change prediction assuming joint-based neurons
