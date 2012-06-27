% load file
curr_dir = pwd;
cd('..\..\..\')
load_paths;
cd(curr_dir)

filename = 'AT_test_020';
fileExt = '.nev';
filepath = 'Y:\TestData\Attention cpp\';

% temp = dir([filepath filename '_bdf.mat']);
% if isempty(temp)
%     bdf = get_cerebus_data([filepath filename fileExt],3);
%     save([filepath filename '_bdf'],'bdf');
% else
%     load([filepath filename '_bdf.mat'])
% end
% [trial_table tc] = AT_trial_table([filepath filename '_bdf']);


trial_table = trial_table(trial_table(:,tc.result)~=33,:);
trial_table(:,tc.bump_direction) = mod(trial_table(:,tc.bump_direction),2*pi);

visual_trials = find(trial_table(:,tc.trial_type)==0);
proprio_trials = find(trial_table(:,tc.trial_type)==1);
control_trials = find(trial_table(:,tc.trial_type)==2);
bump_directions = trial_table(:,tc.bump_direction);
bias_force_x = trial_table(:,tc.bias_force_mag).*cos(trial_table(:,tc.bias_force_dir));
bias_force_y = trial_table(:,tc.bias_force_mag).*sin(trial_table(:,tc.bias_force_dir));

% Displacement as a function of bump direction
bump_duration = trial_table(1,tc.bump_duration);
% bias_ramp = trial_table(1,tc.bias_force_ramp);

%%
num_trials = size(trial_table,1);
dt = diff(bdf.force(:,1));
dt = dt(1);
t_axis = -.1:dt:bump_duration+.1;
t_bias_force = -.1:dt:3;
t_axis = t_axis(1:end-1);
x_forces = zeros(num_trials,length(t_axis));
y_forces = zeros(num_trials,length(t_axis));
x_position = zeros(num_trials,length(t_axis));
y_position = zeros(num_trials,length(t_axis));
t_absolute = zeros(num_trials,length(t_axis));

force_offset_x = zeros(num_trials,length(t_bias_force));
force_offset_y = zeros(num_trials,length(t_bias_force));

for iTrial = 1:num_trials
    bias_force_onset = trial_table(iTrial,tc.t_ct_hold_on);
    force_offset_idx = find(bdf.force(:,1)>=bias_force_onset-0.1,length(t_bias_force),'first');
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

force_offset_x = mean(mean(force_offset_x(:,1:find(t_bias_force<0,1,'last')),2));
force_offset_y = mean(mean(force_offset_y(:,1:find(t_bias_force<0,1,'last')),2));
x_forces = x_forces-force_offset_x;
y_forces = y_forces-force_offset_y;
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

% Position figure
figure; 
plot(x_position(visual_trials,:)',y_position(visual_trials,:)','b-')
hold on
plot(x_position(proprio_trials,:)',y_position(proprio_trials,:)','r-')
axis equal

% Projection figure
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

% Comparison of same bump directions for different trial types
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
    
    large_displacement_idx = find(abs(averaged_x_projection_visual(iBumpDir,:))>2);
    
    stiffness_visual(iBumpDir) =  abs(mean(averaged_forces_visual(iBumpDir,large_displacement_idx)./...
        averaged_x_projection_visual(iBumpDir,large_displacement_idx)));
    
    large_displacement_idx = find(abs(averaged_x_projection_proprio(iBumpDir,:))>2);
    
    stiffness_proprio(iBumpDir) =  abs(mean(averaged_forces_proprio(iBumpDir,large_displacement_idx)./...
        averaged_x_projection_proprio(iBumpDir,large_displacement_idx)));
    
    stiffness_x_visual(iBumpDir,:) = averaged_x_forces_visual(iBumpDir,:)./...
        averaged_x_projection_visual(iBumpDir,:);
    stiffness_y_visual(iBumpDir,:) = averaged_y_forces_visual(iBumpDir,:)./...
        averaged_y_projection_visual(iBumpDir,:);
end

t_axis_short_idx = find(t_axis>.2 & t_axis<.5);


% for iBumpDir = 1:length(unique_bump_directions)
%     figure
%     plot(t_axis,averaged_x_projection_visual(iBumpDir,:),'-b')
%     hold on
%     plot(t_axis,averaged_x_projection_proprio(iBumpDir,:),'-r')
% end

% Maximum displacement
figure;
plot(unique_bump_directions*180/pi,max_x_projection_visual,'.b')
hold on
plot(unique_bump_directions*180/pi,max_x_projection_proprio,'.r')
legend('Visual','Proprioceptive')
title('Max projection (cm)')

figure;
plot(unique_bump_directions*180/pi,max_displacement_visual,'.b')
hold on
plot(unique_bump_directions*180/pi,max_displacement_proprio,'.r')
legend('Visual','Proprioceptive')
title('Max displacement (cm)')

figure;
plot(cos(unique_bump_directions).*max_x_projection_visual,sin(unique_bump_directions).*max_x_projection_visual,'.b')
hold on
plot(cos(unique_bump_directions).*max_x_projection_proprio,sin(unique_bump_directions).*max_x_projection_proprio,'.r')
legend('Visual','Proprioceptive')
title('Max projection (cm)')
axis square

figure;
plot(cos(unique_bump_directions).*max_displacement_visual,sin(unique_bump_directions).*max_displacement_visual,'.b')
hold on
plot(cos(unique_bump_directions).*max_displacement_proprio,sin(unique_bump_directions).*max_displacement_proprio,'.r')
legend('Visual','Proprioceptive')
title('Max displacement (cm)')
axis square

%%
% Forces and stiffness
figure;
plot(averaged_x_forces_visual',averaged_y_forces_visual','-b')

figure;
plot(cos(unique_bump_directions).*stiffness_visual,sin(unique_bump_directions).*stiffness_visual,'.b')
hold on
plot(cos(unique_bump_directions).*stiffness_proprio,sin(unique_bump_directions).*stiffness_proprio,'.r')
plot(cos(0:.05:2*pi),sin(0:0.05:2*pi),'k-')
axis equal