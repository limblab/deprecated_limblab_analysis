

% filename = 'Handle_force_callibration_015';
filepath = 'D:\Data\Kevin_12A2\Data';
% filename = '\Motor_calibration_004';
filelist = dir([filepath '\Kevin_2013-03-26_AT*.nev']);
% filelist = {filelist.name};
% filename = '\Kevin_2013-03-26_AT_002';
% fileExt = '.nev';

cerebus2ElectrodesFile = '\\citadel\limblab\lab_folder\Animal-Miscellany\Kevin 12A2\Microdrive info\MicrodriveMapFile_diagonal.cmp';

bdf = concatenate_bdfs(filepath,filelist);
% temp = dir([filepath filename '.mat']);
% if isempty(temp)
%     bdf = get_cerebus_data([filepath filename fileExt],3);
%     save([filepath filename ''],'bdf');
% else
%     load([filepath filename '.mat'])
% end
% [trial_table,tc] = AT_trial_table([filepath filename]);
[trial_table,tc] = AT_trial_table(bdf);

trial_table = trial_table(trial_table(:,tc.result)~=33,:);
trial_table = trial_table(trial_table(:,tc.result)~=35,:);

visual_trials = find(trial_table(:,tc.trial_type)==0);
proprio_trials = find(trial_table(:,tc.trial_type)==1);
control_trials = find(trial_table(:,tc.trial_type)==2);

reward_trials = find(trial_table(:,tc.result)==32);
fail_trials = find(trial_table(:,tc.result)==34);

bump_directions = trial_table(:,tc.bump_direction);
dot_directions = trial_table(:,tc.moving_dots_direction);

bias_force_x = trial_table(:,tc.bias_force_mag).*cos(trial_table(:,tc.bias_force_dir));
bias_force_y = trial_table(:,tc.bias_force_mag).*sin(trial_table(:,tc.bias_force_dir));

% Displacement as a function of bump direction
bump_duration = trial_table(1,tc.bump_duration);
% bias_ramp = trial_table(1,tc.bias_force_ramp);

% fit_func = 'Pmin + (Pmax - Pmin)/(1+exp(beta*(xthr-x)))';
% f_sigmoid = fittype(fit_func,'independent','x');

% fit_func = @(Pmin,Pmax,beta1,xthr1,beta2,xthr2,x) ((x<=90).*(Pmin+(Pmax-Pmin)./(1+exp(beta1.*(xthr1-x)))) +...
%     (x>=90).*(Pmin+(Pmax-Pmin)./(1+exp(beta2.*(xthr2-x)))));
% 
% f_sigmoid = fittype(fit_func,'independent','x');
% f_opts = fitoptions('Method','NonlinearLeastSquares','StartPoint',[0 1 .01 0 -.01 180],...
%     'MaxFunEvals',100000,'MaxIter',10000,'Lower',[0 0.3 0 -60 -inf 120],'Upper',[0.7 1 inf 60 inf 240]);

fit_func = @(Pmin,Pmax,beta,xthr1,xthr2,x) (((x<=90).*(Pmin+(Pmax-Pmin)./(1+exp(beta.*(xthr1-x)))) +...
    (x>=90).*(Pmin+(Pmax-Pmin)./(1+exp(-beta.*(xthr2-x))))).*(.5.*(x==90) + 1.*(x~=90)));

f_sigmoid = fittype(fit_func,'independent','x');
f_opts = fitoptions('Method','NonlinearLeastSquares','StartPoint',[.3 .7 .01 0 180],...
    'MaxFunEvals',100000,'MaxIter',10000,'Lower',[0 0.3 0 -60 120],'Upper',[0.7 1 inf 60 240]);

%%
num_trials = size(trial_table,1);
dt = diff(bdf.force(:,1));
dt = dt(1);
t_axis = -.1:dt:bump_duration+.1;
% t_axis = -.1:dt:bump_duration/2;

% t_bias_force = -.1:dt:.3;
t_axis = t_axis(1:end-1);
x_forces = zeros(num_trials,length(t_axis));
y_forces = zeros(num_trials,length(t_axis));
x_position = zeros(num_trials,length(t_axis));
y_position = zeros(num_trials,length(t_axis));
t_absolute = zeros(num_trials,length(t_axis));

force_offset_x = zeros(num_trials,100);
force_offset_y = zeros(num_trials,100);

for iTrial = 1:num_trials-1
%     bias_force_onset = trial_table(iTrial,tc.t_ct_hold_on);
%     force_offset_idx = find(bdf.force(:,1)>=bias_force_onset-0.1,length(t_bias_force),'first');
    bump_onset = trial_table(iTrial,tc.t_stimuli_onset);
    force_offset_idx = find(bdf.force(:,1)<bump_onset-.1,100,'last');
    force_offset_x(iTrial,:) = bdf.force(force_offset_idx,2);
    force_offset_y(iTrial,:) = bdf.force(force_offset_idx,3);
    
    bump_onset = trial_table(iTrial,tc.t_stimuli_onset);
    force_idx = find(bdf.force(:,1)>=bump_onset-0.1,length(t_axis),'first');
    x_forces(iTrial,:) = bdf.force(force_idx,2);
    y_forces(iTrial,:) = bdf.force(force_idx,3);
    x_position(iTrial,:) = bdf.pos(force_idx,2)+trial_table(iTrial,tc.x_offset);
    y_position(iTrial,:) = bdf.pos(force_idx,3)+trial_table(iTrial,tc.y_offset);
    x_position(iTrial,:) = x_position(iTrial,:)-mean(x_position(iTrial,1:199));
    y_position(iTrial,:) = y_position(iTrial,:)-mean(y_position(iTrial,1:199));
    t_absolute(iTrial,:) = bdf.force(force_idx,1);
end

% force_offset_x = mean(mean(force_offset_x(:,1:find(t_bias_force<0,1,'last')),2));
% force_offset_y = mean(mean(force_offset_y(:,1:find(t_bias_force<0,1,'last')),2));
% x_forces = x_forces-force_offset_x;
% y_forces = y_forces-force_offset_y;
x_forces = x_forces - repmat(mean(force_offset_x,2),1,size(x_forces,2));
y_forces = y_forces - repmat(mean(force_offset_y,2),1,size(y_forces,2));

bias_force_x = mean(mean(x_forces(:,1:find(t_axis<0,1,'last')),2));
bias_force_y = mean(mean(y_forces(:,1:find(t_axis<0,1,'last')),2));

% force_offset_x = mean(force_offset_x(:,1:find(t_bias_force<0,1,'last')),2);
% force_offset_y = mean(force_offset_y(:,1:find(t_bias_force<0,1,'last')),2);
% x_forces = x_forces-repmat(force_offset_x,1,size(x_forces,2));
% y_forces = y_forces-repmat(force_offset_y,1,size(y_forces,2));
% bias_force_x = mean(x_forces(:,1:find(t_axis<0,1,'last')),2);
% bias_force_y = mean(y_forces(:,1:find(t_axis<0,1,'last')),2);

%%
% Bump direction figure
figure; 
plot(cos(bump_directions(visual_trials)),sin(bump_directions(visual_trials)),'b.')
hold on
plot(cos(bump_directions(proprio_trials)),sin(bump_directions(proprio_trials)),'r.')
title('Bump directions')
xlabel('X force (N)')
ylabel('Y force (N)')

%% Position figure
figure; 
plot(x_position(visual_trials,:)',y_position(visual_trials,:)','b-')
hold on
plot(x_position(proprio_trials,:)',y_position(proprio_trials,:)','r-')
axis square
title('Hand displacement')
xlabel('X position (cm)')
ylabel('Y position (cm)')
lim = 1.1*max(max(max(abs(x_position))),max(max(abs(y_position))));
xlim([-lim lim])
ylim([-lim lim])

%% Projection figure
x_projection = x_position.*(repmat(cos(bump_directions),1,length(t_axis)))+...
                y_position.*(repmat(sin(bump_directions),1,length(t_axis)));
y_projection = -x_position.*(repmat(sin(bump_directions),1,length(t_axis)))+...
    y_position.*(repmat(cos(bump_directions),1,length(t_axis)));
x_forces_projection = x_forces.*(repmat(cos(bump_directions),1,length(t_axis)))+...
                y_forces.*(repmat(sin(bump_directions),1,length(t_axis)));
y_forces_projection = -x_forces.*(repmat(sin(bump_directions),1,length(t_axis)))+...
    y_forces.*(repmat(cos(bump_directions),1,length(t_axis)));

figure; 
plot(x_projection(visual_trials,:)',y_projection(visual_trials,:)','b-')
hold on
plot(x_projection(proprio_trials,:)',y_projection(proprio_trials,:)','r-')
axis equal
title('Bump projection (cm)')
xlabel('Projection parallel to bump direction (cm)')
ylabel('Projection perpendicular to bump direction (cm)')

%% Comparison of same bump directions for different trial types
unique_bump_directions = unique(bump_directions(proprio_trials));
visual_idx = cell(length(unique_bump_directions),1);
proprio_idx = cell(length(unique_bump_directions),1);
for iBumpDir = 1:length(unique_bump_directions)
    proprio_idx{iBumpDir} = [proprio_idx{iBumpDir} intersect(proprio_trials,find(bump_directions==unique_bump_directions(iBumpDir)))];
    visual_idx{iBumpDir} = [visual_idx{iBumpDir} intersect(visual_trials,find(bump_directions==unique_bump_directions(iBumpDir)))];
end

averaged_x_position_visual = zeros(length(unique_bump_directions),length(t_axis));
averaged_y_position_visual = zeros(length(unique_bump_directions),length(t_axis));
averaged_x_position_proprio = zeros(length(unique_bump_directions),length(t_axis));
averaged_y_position_proprio = zeros(length(unique_bump_directions),length(t_axis));

averaged_x_forces_visual = zeros(length(unique_bump_directions),length(t_axis));
averaged_y_forces_visual = zeros(length(unique_bump_directions),length(t_axis));
averaged_x_forces_proprio = zeros(length(unique_bump_directions),length(t_axis));
averaged_y_forces_proprio = zeros(length(unique_bump_directions),length(t_axis));

averaged_x_projection_visual = zeros(length(unique_bump_directions),length(t_axis));
averaged_y_projection_visual = zeros(length(unique_bump_directions),length(t_axis));
averaged_x_projection_proprio = zeros(length(unique_bump_directions),length(t_axis));
averaged_y_projection_proprio = zeros(length(unique_bump_directions),length(t_axis));
max_x_projection_visual = zeros(length(unique_bump_directions),1);
max_y_projection_visual = zeros(length(unique_bump_directions),1);
max_x_projection_proprio = zeros(length(unique_bump_directions),1);
max_y_projection_proprio = zeros(length(unique_bump_directions),1);

averaged_displacement_visual = zeros(length(unique_bump_directions),length(t_axis));
averaged_displacement_proprio = zeros(length(unique_bump_directions),length(t_axis));
max_displacement_visual = zeros(length(unique_bump_directions),1);
max_displacement_proprio = zeros(length(unique_bump_directions),1);

averaged_forces_visual = zeros(length(unique_bump_directions),length(t_axis));
averaged_forces_proprio = zeros(length(unique_bump_directions),length(t_axis));

stiffness_x_visual = zeros(length(unique_bump_directions),length(t_axis));
stiffness_y_visual = zeros(length(unique_bump_directions),length(t_axis));

stiffness_visual = zeros(length(unique_bump_directions),1);
stiffness_proprio = zeros(length(unique_bump_directions),1);

for iBumpDir = 1:length(unique_bump_directions)
    averaged_x_position_visual(iBumpDir,:) = mean(x_position(visual_idx{iBumpDir},:),1);
    averaged_y_position_visual(iBumpDir,:) = mean(y_position(visual_idx{iBumpDir},:),1);
    averaged_x_position_proprio(iBumpDir,:) = mean(x_position(proprio_idx{iBumpDir},:),1);
    averaged_y_position_proprio(iBumpDir,:) = mean(y_position(proprio_idx{iBumpDir},:),1);
    
    averaged_x_forces_visual(iBumpDir,:) = mean(x_forces(visual_idx{iBumpDir},:),1);
    averaged_y_forces_visual(iBumpDir,:) = mean(y_forces(visual_idx{iBumpDir},:),1);
    averaged_x_forces_proprio(iBumpDir,:) = mean(x_forces(proprio_idx{iBumpDir},:),1);
    averaged_y_forces_proprio(iBumpDir,:) = mean(y_forces(proprio_idx{iBumpDir},:),1);
    
    averaged_x_projection_visual(iBumpDir,:) = mean(x_projection(visual_idx{iBumpDir},:),1);
    averaged_y_projection_visual(iBumpDir,:) = mean(y_projection(visual_idx{iBumpDir},:),1);
    averaged_x_projection_proprio(iBumpDir,:) = mean(x_projection(proprio_idx{iBumpDir},:),1);
    averaged_y_projection_proprio(iBumpDir,:) = mean(y_projection(proprio_idx{iBumpDir},:),1);
    max_x_projection_visual(iBumpDir) = max(averaged_x_projection_visual(iBumpDir,:));
    max_y_projection_visual(iBumpDir) = max(averaged_y_projection_visual(iBumpDir,:));
    max_x_projection_proprio(iBumpDir) = max(averaged_x_projection_proprio(iBumpDir,:));
    max_y_projection_proprio(iBumpDir) = max(averaged_y_projection_proprio(iBumpDir,:));
    
    averaged_displacement_visual(iBumpDir,:) = sqrt(averaged_x_projection_visual(iBumpDir,:).^2 +...
        averaged_y_projection_visual(iBumpDir,:).^2);
    averaged_displacement_proprio(iBumpDir,:) = sqrt(averaged_x_projection_proprio(iBumpDir,:).^2 +...
        averaged_y_projection_proprio(iBumpDir,:).^2);
    max_displacement_visual(iBumpDir) = max(averaged_displacement_visual(iBumpDir,:));
    max_displacement_proprio(iBumpDir) = max(averaged_displacement_proprio(iBumpDir,:));
    
    averaged_forces_visual(iBumpDir,:) = mean(x_forces_projection(visual_idx{iBumpDir},:),1);
    averaged_forces_proprio(iBumpDir,:) = mean(x_forces_projection(proprio_idx{iBumpDir},:),1);    
    
    large_displacement_idx = find(abs(averaged_x_projection_visual(iBumpDir,:))>0.5);
    
    stiffness_visual(iBumpDir) =  abs(mean(averaged_forces_visual(iBumpDir,large_displacement_idx)./...
        averaged_x_projection_visual(iBumpDir,large_displacement_idx)));
    
    large_displacement_idx = find(abs(averaged_x_projection_proprio(iBumpDir,:))>0.5);
    
    stiffness_proprio(iBumpDir) =  abs(mean(averaged_forces_proprio(iBumpDir,large_displacement_idx)./...
        averaged_x_projection_proprio(iBumpDir,large_displacement_idx)));
    
    stiffness_x_visual(iBumpDir,:) = averaged_x_forces_visual(iBumpDir,:)./...
        averaged_x_projection_visual(iBumpDir,:);
    stiffness_y_visual(iBumpDir,:) = averaged_y_forces_visual(iBumpDir,:)./...
        averaged_y_projection_visual(iBumpDir,:);
end

t_axis_short_idx = find(t_axis>.2 & t_axis<.5);

% figure; plot(averaged_x_forces_visual',averaged_y_forces_visual')
%% Average maximum projection
figure;
plot(unique_bump_directions*180/pi,max_x_projection_visual,'.b')
hold on
plot(unique_bump_directions*180/pi,max_x_projection_proprio,'.r')
legend('Visual','Proprioceptive')
title('Max projection (cm)')
if ~isempty(max_x_projection_visual) && ~isempty(max_x_projection_proprio)
    ylim([0 1.1*max(max(max_x_projection_visual),max(max_x_projection_proprio))])
end
xlabel('Bump direction (deg)')
ylabel('Max projection parallel to bump (cm)')

%% Maximum projection
figure
plot(bump_directions(visual_trials),max(x_projection(visual_trials,:),[],2),'.b')
hold on
plot(bump_directions(proprio_trials),max(x_projection(proprio_trials,:),[],2),'.r')
legend('Visual','Proprioceptive')
title('Max projection (cm)')
xlabel('Bump direction (deg)')
ylabel('Max projection parallel to bump (cm)')

%% Maximum projection by result
figure
subplot(211)
plot(180/pi*bump_directions(intersect(visual_trials,reward_trials)),max(x_projection(intersect(visual_trials,reward_trials),:),[],2),'.b')
hold on
plot(180/pi*bump_directions(intersect(visual_trials,fail_trials)),max(x_projection(intersect(visual_trials,fail_trials),:),[],2),'.r')
title('Visual trials')
legend('Reward','Fail')
xlabel('Bump direction (deg)')
ylabel('Max projection parallel to bump (cm)')
xlim([0 360])

subplot(212)
plot(180/pi*bump_directions(intersect(proprio_trials,reward_trials)),max(x_projection(intersect(proprio_trials,reward_trials),:),[],2),'.b')
hold on
plot(180/pi*bump_directions(intersect(proprio_trials,fail_trials)),max(x_projection(intersect(proprio_trials,fail_trials),:),[],2),'.r')
title('Proprio trials')
legend('Reward','Fail')
xlabel('Bump direction (deg)')
ylabel('Max projection parallel to bump (cm)')
xlim([0 360])

%% Maximum displacement
figure;
plot(unique_bump_directions*180/pi,max_displacement_visual,'.b')
hold on
plot(unique_bump_directions*180/pi,max_displacement_proprio,'.r')
legend('Visual','Proprioceptive')
title('Max displacement (cm)')
if ~isempty(max_displacement_visual) && ~isempty(max_displacement_proprio)
    ylim([0 1.1*max(max(max_displacement_visual),max(max_displacement_proprio))])
end
xlabel('Bump direction (deg)')
ylabel('Max displacement (cm)')

%% Maximum projection polar
figure;
plot(cos(unique_bump_directions).*max_x_projection_visual,sin(unique_bump_directions).*max_x_projection_visual,'.b')
hold on
plot(cos(unique_bump_directions).*max_x_projection_proprio,sin(unique_bump_directions).*max_x_projection_proprio,'.r')
legend('Visual','Proprioceptive')
title('Max projection (cm)')
xlabel('Max X projection (cm)')
ylabel('Max Y projection (cm)')
lim = max(max(max_x_projection_proprio),max(max_x_projection_visual));
if ~isempty(lim)
    xlim([-lim lim])
    ylim([-lim lim])
end
axis square

%% Maximum displacement polar
figure;
plot(cos(unique_bump_directions).*max_displacement_visual,sin(unique_bump_directions).*max_displacement_visual,'.b')
hold on
plot(cos(unique_bump_directions).*max_displacement_proprio,sin(unique_bump_directions).*max_displacement_proprio,'.r')
legend('Visual','Proprioceptive')
title('Max displacement (cm)')
xlabel('Max X displacement (cm)')
ylabel('Max Y displacement (cm)')
lim = max(max(max_displacement_proprio),max(max_displacement_visual));
if ~isempty(lim)
    xlim([-lim lim])    
    ylim([-lim lim])
end
axis square

%%
% Forces and stiffness
figure;
plot(0,0,'-b',0,0,'-r')
hold on
% plot(averaged_x_forces_visual(:,:)',averaged_y_forces_visual(:,:)','-b')
% plot(averaged_x_forces_proprio(:,:)',averaged_y_forces_proprio(:,:)','-r')
plot(averaged_x_forces_visual(:,:)',averaged_y_forces_visual(:,:)')
plot(averaged_x_forces_proprio(:,:)',averaged_y_forces_proprio(:,:)')
axis equal
legend('Visual','Proprioceptive')
xlabel('X force (N)')
ylabel('Y force (N)')
title('Forces')

%% Directional stiffness
figure;
plot(cos(unique_bump_directions).*stiffness_visual,sin(unique_bump_directions).*stiffness_visual,'.b')
hold on
plot(cos(unique_bump_directions).*stiffness_proprio,sin(unique_bump_directions).*stiffness_proprio,'.r')
plot(cos(0:.05:2*pi+.05),sin(0:0.05:2*pi+.05),'k-')
axis equal
title('Stiffness')
xlabel('X stiffness (N/m)')
ylabel('Y stiffness (N/m)')
legend('Visual','Proprioceptive')

% %% Forces test
% force_magnitude = sqrt(x_forces.^2+y_forces.^2);
% force_direction = atan2(y_forces,x_forces);
% bump_directions = unique(trial_table(:,tc.bump_direction));
% mean_bump = zeros(length(bump_directions),1);
% mean_dir = zeros(length(bump_directions),1);
% for i=1:length(bump_directions)
%     mean_bump(i) = mean(mean(force_magnitude(trial_table(:,tc.bump_direction)==bump_directions(i),150:249)));
%     mean_dir(i) = mean(mean(force_direction(trial_table(:,tc.bump_direction)==bump_directions(i),150:249)))+pi;
% end
% figure; plot(bump_directions*180/pi,mean_bump,'.')
% % figure; plot(cos(bump_directions).*mean_bump,sin(bump_directions).*mean_bump,'.')
% % axis equal
% cos_fun = 'a+b*sin(2*x+c)';
% fit_bumps = fit(bump_directions,mean_bump,cos_fun);
% hold on
% plot_fit_bumps = fit_bumps(0:.1:2*pi);
% plot(180/pi*(0:.1:2*pi),plot_fit_bumps,'-')
% figure
% plot(bump_directions,mean_dir','.')
% axis equal

%% Performance as a function of time
figure; 
plot(trial_table((trial_table(:,tc.result)==32|trial_table(:,tc.result)==34) & trial_table(:,tc.trial_type)==0,tc.t_trial_start),...
    100*smooth(trial_table((trial_table(:,tc.result)==32|trial_table(:,tc.result)==34) & trial_table(:,tc.trial_type)==0,tc.result)==32,50),'.b')
hold on
plot(trial_table((trial_table(:,tc.result)==32|trial_table(:,tc.result)==34) & trial_table(:,tc.trial_type)==1,tc.t_trial_start),...
    100*smooth(trial_table((trial_table(:,tc.result)==32|trial_table(:,tc.result)==34) & trial_table(:,tc.trial_type)==1,tc.result)==32,50),'.r')
xlabel('t (s)')
ylabel('Percent correct (smoothed)')
title('Performance')
legend('Visual','Proprio')

%% Directional performance
% Visual trials
figure;
visual_response = trial_table(visual_trials,tc.result)==32;
unique_dot_dirs = unique(dot_directions);
visual_response_mean = zeros(size(unique_dot_dirs));
for iDir = 1:length(unique_dot_dirs)
    visual_response_mean(iDir) = mean(trial_table(intersect(visual_trials,find(dot_directions==unique_dot_dirs(iDir))),tc.result)==32);
end
   
unique_bump_dirs = unique(bump_directions);
proprio_response_mean = zeros(size(unique_bump_dirs));
for iDir = 1:length(unique_bump_dirs)
    proprio_response_mean(iDir) = mean(trial_table(intersect(proprio_trials,find(bump_directions==unique_bump_dirs(iDir))),tc.result)==32);
end

plot(180/pi*unique_dot_dirs,...
    visual_response_mean,'.b')
hold on
plot(180/pi*unique_bump_dirs,proprio_response_mean,'.r')
plot([0 360],[mean(proprio_response_mean(~isnan(proprio_response_mean))) mean(proprio_response_mean(~isnan(proprio_response_mean)))],'-r')
plot([0 360],[mean(visual_response_mean(~isnan(visual_response_mean))) mean(visual_response_mean(~isnan(visual_response_mean)))],'-b')
legend('Visual','Proprioceptive')
title('Performance as a function of direction')
xlabel('Bump/dots direction (deg)')
ylabel('Response')
ylim([0 1])
xlim([0 360])

%% Psychophysics
main_directions = trial_table(:,tc.main_direction);
unique_main_directions = unique(main_directions);
stim_directions = nan(size(main_directions));
stim_directions(visual_trials) = dot_directions(visual_trials);
stim_directions(proprio_trials) = bump_directions(proprio_trials);
left_stim = mod(stim_directions - main_directions,2*pi) < mod(main_directions-stim_directions,2*pi);

temp_diff = main_directions - stim_directions;
temp_diff(temp_diff>3*pi/2) = -2*pi+temp_diff(temp_diff>3*pi/2);
temp_diff(temp_diff<-pi/2) = 2*pi+temp_diff(temp_diff<-pi/2);
temp_diff = round(temp_diff*1E6)/1E6;

if length(unique(temp_diff))>=4
    result_temp = (left_stim & trial_table(:,tc.result)==34) | (~left_stim & trial_table(:,tc.result)==32);

    for iMainDir = 1:length(unique_main_directions)
        dir_idx = find(main_directions==unique_main_directions(iMainDir));    
        visual_idx_temp = intersect(dir_idx,visual_trials);
        proprio_idx_temp = intersect(dir_idx,proprio_trials);

        if length(visual_idx_temp)>=4 && length(proprio_idx_temp)>=4
            [unique_visual_temp] = unique(temp_diff(visual_idx_temp));
            [unique_proprio_temp] = unique(temp_diff(proprio_idx_temp));

            response_vis = zeros(size(unique_visual_temp));
            response_pro = zeros(size(unique_proprio_temp));
            response_vis_vector = [];
            response_pro_vector = [];
            vis_dir_vector = [];
            pro_dir_vector = [];
            for iVis = 1:length(unique_visual_temp)
                response_vis_vector = [response_vis_vector; result_temp(intersect(visual_idx_temp,find(temp_diff == unique_visual_temp(iVis))))];
                vis_dir_vector = [vis_dir_vector; unique_visual_temp(iVis)*ones(size(result_temp(intersect(visual_idx_temp,find(temp_diff == unique_visual_temp(iVis))))))];
                response_vis(iVis) = mean(result_temp(intersect(visual_idx_temp,find(temp_diff == unique_visual_temp(iVis)))));
            end

            for iPro = 1:length(unique_proprio_temp)
                response_pro_vector = [response_pro_vector; result_temp(intersect(proprio_idx_temp,find(temp_diff == unique_proprio_temp(iPro))))];
                pro_dir_vector = [pro_dir_vector; unique_proprio_temp(iPro)*ones(size(result_temp(intersect(proprio_idx_temp,find(temp_diff == unique_proprio_temp(iPro))))))];
                response_pro(iPro) = mean(result_temp(intersect(proprio_idx_temp,find(temp_diff == unique_proprio_temp(iPro)))));
            end    

            figure; 
            plot(180/pi*unique_visual_temp,response_vis,'b.');
            hold on
            plot(180/pi*unique_proprio_temp,response_pro,'r.');

%             vis_fit = fit(180/pi*unique_visual_temp,response_vis,f_sigmoid,f_opts);
            vis_fit = fit(180/pi*vis_dir_vector,response_vis_vector,f_sigmoid,f_opts);
            plot(vis_fit,'b')

            pro_fit = fit(180/pi*pro_dir_vector,response_pro_vector,f_sigmoid,f_opts);
            plot(pro_fit,'r')
            legend('Visual','Proprio')
            xlabel('Relative stimulus direction (deg)')
            ylabel('Probability of moving to the right')
            title(['Main direction: ' num2str(unique_main_directions(iMainDir)*180/pi) ' (deg)'])
        end
    end
    
end

%%
figure; 
reward_difference = 180/pi*abs(trial_table(intersect(visual_trials,find(trial_table(:,tc.result)==32)),tc.moving_dots_direction)-trial_table(intersect(visual_trials,find(trial_table(:,tc.result)==32)),tc.bump_direction));
% reward_difference = 180/pi*abs(trial_table(intersect(visual_trials,find(trial_table(:,tc.result)==32)),tc.moving_dots_direction)-trial_table(intersect(visual_trials,find(trial_table(:,tc.result)==32)),tc.reward_target_direction));
reward_difference(reward_difference>180) = reward_difference(reward_difference>180)-180;
fail_difference = 180/pi*abs(trial_table(intersect(visual_trials,find(trial_table(:,tc.result)==34)),tc.moving_dots_direction)-trial_table(intersect(visual_trials,find(trial_table(:,tc.result)==34)),tc.bump_direction));
% fail_difference = 180/pi*abs(trial_table(intersect(visual_trials,find(trial_table(:,tc.result)==34)),tc.moving_dots_direction)-trial_table(intersect(visual_trials,find(trial_table(:,tc.result)==34)),tc.reward_target_direction));

fail_difference(fail_difference>180) = fail_difference(fail_difference>180)-180;
reward_difference_count = hist(reward_difference,0:15:180);
fail_difference_count = hist(fail_difference,0:15:180);
reward_ratio = reward_difference_count./(reward_difference_count+fail_difference_count);
reward_ratio(isnan(reward_ratio) | isinf(reward_ratio)) = 0;
bar(0:15:180,reward_ratio);
h = findobj(gca,'Type','patch');
% set(h,'FaceColor','r','FaceAlpha',0.5)
% hold on; 
% hist(fail_difference,0:15:180)
% disp(['Ratio of coherent bumps and dots in visual trials: ' num2str(sum(abs(trial_table(visual_trials,tc.moving_dots_direction)-trial_table(visual_trials,tc.bump_direction))<pi/2)/...
%     length(abs(trial_table(visual_trials,tc.moving_dots_direction)-trial_table(visual_trials,tc.bump_direction))<pi/2))]);
% h2 = findobj(gca,'Type','patch');
% h2 = h2(h2~=h);
xlim([-7.5 187.5])
legend('Reward ratio')
xlabel('|bump direction - dot direction| (deg)')
ylabel('Reward ratio')
title('Visual trials')
% set(h2,'FaceColor','b','FaceAlpha',0.5)


%% Units!
% Read cerebus to electrode map
if isfield(bdf,'units')
    kernel_width = 0.01;
    elec_map = cerebusToElectrodeMap(cerebus2ElectrodesFile);
    unit_list = reshape([bdf.units.id],2,[])';
    unit_idx = find(unit_list(:,2)~=0);
    fr_cell = cell(size(unit_idx));
    electrode = [];    
    figure
    for iUnit = 1:length(unit_idx)
        electrode(iUnit) = elec_map(find(elec_map(:,3)==unit_list(unit_idx(iUnit))),4);
        fr_cell{iUnit} = zeros(size(trial_table,1),length(t_axis));
        ts = bdf.units(unit_idx(iUnit)).ts;
        ts_vec = [];
        ts_cell = {};
        for iTrial = 1:size(trial_table,1)
            ts_temp = ts(ts>trial_table(iTrial,tc.t_stimuli_onset)+t_axis(1) & ts<trial_table(iTrial,tc.t_stimuli_onset)+t_axis(end));
            ts_temp = ts_temp' - trial_table(iTrial,tc.t_stimuli_onset);
            ts_vec = [ts_vec ts_temp];
%             ts_trial = ts(ts>trial_table(iTrial,tc.t_stimuli_onset)+t_axis(1) & ts<trial_table(iTrial,tc.t_stimuli_onset)+t_axis(end));
            fr_cell{iUnit}(iTrial,:) = spikes2fr(ts,[trial_table(iTrial,tc.t_stimuli_onset)+t_axis(1):dt:trial_table(iTrial,tc.t_stimuli_onset)+t_axis(end)],kernel_width);           
            ts_cell{iTrial} = ts_temp;
        end
        
        clf
        max_y = 0;
        for iBump = 1:size(proprio_idx)
            subplot(2,2,iBump)
            hold on
            area([t_axis t_axis(end:-1:1)], [mean(fr_cell{iUnit}(proprio_idx{iBump},:)) mean(fr_cell{iUnit}(proprio_idx{iBump},end:-1:1))]+...
                [std(fr_cell{iUnit}(proprio_idx{iBump},:)) -std(fr_cell{iUnit}(proprio_idx{iBump},end:-1:1))],...
                'FaceColor',[1 .9 .9],'LineStyle','none')
            area([t_axis t_axis(end:-1:1)], [mean(fr_cell{iUnit}(visual_idx{iBump},:)) mean(fr_cell{iUnit}(visual_idx{iBump},end:-1:1))]+...
                [std(fr_cell{iUnit}(visual_idx{iBump},:)) -std(fr_cell{iUnit}(visual_idx{iBump},end:-1:1))],...
                'FaceColor',[.9 .9 1],'LineStyle','none')
            
            plot(t_axis,mean(fr_cell{iUnit}(proprio_idx{iBump},:)),'r')            
            plot(t_axis,mean(fr_cell{iUnit}(visual_idx{iBump},:)),'b')
            
            if iBump == 1
                title(['Electrode: ' num2str(electrode(iUnit)) '   Bump: ' num2str(unique_bump_directions(iBump)*180/pi) ' deg'])
                legend('Proprio','Visual')
            else
                title(['Bump: ' num2str(unique_bump_directions(iBump)*180/pi) ' deg'])
            end
            max_y = max(max_y,max(mean(fr_cell{iUnit}(visual_idx{iBump},:))+std(fr_cell{iUnit}(visual_idx{iBump},:))));
            max_y = max(max_y,max(mean(fr_cell{iUnit}(proprio_idx{iBump},:))+std(fr_cell{iUnit}(proprio_idx{iBump},:))));
            xlabel('t (s)')
            ylabel('fr (Hz?)')
            
        end
        for iBump = 1:size(proprio_idx)
            subplot(2,2,iBump)
            ylim([0 max_y+5])
            plot(t_axis(1:end-1),.9*(max_y+5)+.1*(max_y+5)*diff(averaged_x_projection_proprio(iBump,:))/max(diff(averaged_x_projection_proprio(iBump,:))),'r')
            plot(t_axis(1:end-1),.9*(max_y+5)+.1*(max_y+5)*diff(averaged_x_projection_visual(iBump,:))/max(diff(averaged_x_projection_visual(iBump,:))),'b')
            text(t_axis(100),max_y*0.8+3,['n = ' num2str(length(proprio_idx{iBump}))],'Color','r')
            text(t_axis(100),max_y*0.75+2,['n = ' num2str(length(visual_idx{iBump}))],'Color','b')
        end
        pause

    end
end

%% Units!
% Read cerebus to electrode map
t_axis = t_axis;
if isfield(bdf,'units')    
    figure
    bin_width = 0.02;
    for iUnit = 1:length(unit_idx)        
        clf
        max_y = 0;
        ts = bdf.units(unit_idx(iUnit)).ts;
        ts_cell = {};
        for iTrial = 1:size(trial_table,1)
            ts_temp = ts(ts>trial_table(iTrial,tc.t_stimuli_onset)+t_axis(1) & ts<trial_table(iTrial,tc.t_stimuli_onset)+t_axis(end));
            ts_temp = ts_temp' - trial_table(iTrial,tc.t_stimuli_onset);
            ts_cell{iTrial} = ts_temp;
        end
        
        max_y = 0;
        for iBump = 1:size(proprio_idx)
            subplot(2,2,iBump)
            hist_proprio = hist([ts_cell{proprio_idx{iBump}}],t_axis(1):bin_width:t_axis(end));
            hist_visual = hist([ts_cell{visual_idx{iBump}}],t_axis(1):bin_width:t_axis(end));
            max_y = max([max_y hist_proprio/bin_width/length(proprio_idx{iBump}) hist_visual/bin_width/length(visual_idx{iBump})]);
            
            hold on
%             hist([ts_cell{proprio_idx{iBump}}],t_axis(1):bin_width:t_axis(end))
            bar(t_axis(1):bin_width:t_axis(end),hist_proprio/bin_width/length(proprio_idx{iBump}),'FaceColor',[1 .9 .9],'LineStyle','none')
%             h1 = findobj(gca,'Type','patch');
%             set(h1,'FaceColor',[1 .9 .9],'LineStyle','none')
            bar(t_axis(1):bin_width:t_axis(end),hist_visual/bin_width/length(visual_idx{iBump}),'FaceColor',[.9 .9 1],'LineStyle','none')
%             hist([ts_cell{visual_idx{iBump}}],t_axis(1):bin_width:t_axis(end))
%             h2 = findobj(gca,'Type','patch');
%             set(h2(1),'FaceColor',[.9 .9 1],'LineStyle','none')
            
            for iTrial = 1:length(proprio_idx{iBump})
                plot(ts_cell{proprio_idx{iBump}(iTrial)},repmat(iTrial * max_y/length(proprio_idx{iBump}),1,length(ts_cell{proprio_idx{iBump}(iTrial)})),'.r')
            end            
            
            for iTrial = 1:length(visual_idx{iBump})
                plot(ts_cell{visual_idx{iBump}(iTrial)},repmat(iTrial * max_y/length(visual_idx{iBump}),1,length(ts_cell{visual_idx{iBump}(iTrial)})),'.b')
            end  
                        
            if iBump == 1
                title(['Electrode: ' num2str(electrode(iUnit)) '   Bump: ' num2str(unique_bump_directions(iBump)*180/pi) ' deg'])
                legend('Proprio','Visual')
            else
                title(['Bump: ' num2str(unique_bump_directions(iBump)*180/pi) ' deg'])
            end
            xlabel('t (s)')
            ylabel('fr (Hz)')
        end
        for iBump = 1:size(proprio_idx)
            subplot(2,2,iBump)
            ylim([0 1.2*(max_y+5)])
            plot(t_axis(1:end-1),.9*(max_y+5)+.1*(max_y+5)*diff(averaged_x_projection_proprio(iBump,:))/max(diff(averaged_x_projection_proprio(iBump,:))),'r')
            plot(t_axis(1:end-1),.9*(max_y+5)+.1*(max_y+5)*diff(averaged_x_projection_visual(iBump,:))/max(diff(averaged_x_projection_visual(iBump,:))),'b')
        end
        pause

    end
end
