function [modeled_tuning,curves] = get_intrinsic_predicted_tuning(bdf,bottom_left,top_right,weights)
% GET_MUSCLE_PREDICTED_TUNING Get predicted tuning, assuming neurons draw
% directly from muscle inputs. Assumes GLM for generative model and tuning.
%   Inputs:
%       BDF - postprocessed bdf, including OpenSim kinematics as joint_pos
%       and muscle_pos
%       BOTTOM_LEFT - pair of numbers indicating bottom left corner of
%       workspace. Leave blank to use whole workspace
%       TOP_RIGHT - pair of numbers indicating top right corner of
%       workspace. Leave blank to use whole workspace
%       WEIGHTS - weights on 39 muscles. Includes first column of baseline
%       weights

%% setup
num_neurons = size(weights,2);

% currently only take muscle
intrinsic_pos = bdf.muscle_pos;

% kinematics
t = bdf.pos(:,1);
pos = bdf.pos(:,2:3);
vel = bdf.vel(:,2:3);
spd = sqrt(sum(vel.^2,2));
endpoint_kin = [pos vel spd];

% Get times in workspace
if(~isempty(bottom_left) && ~isempty(top_right))
    times = extract_workspace_times(bdf,bottom_left,top_right);
else
    warning('No workspace corners provided. Using full workspace')
    times = [t(1) t(end)];
end

%% get intrinsic velocities
% muscle velocities
intrinsic_vel = intrinsic_pos;
for i=2:size(intrinsic_pos,2)
    intrinsic_vel{:,i} = gradient(intrinsic_pos{:,i},intrinsic_pos.time);
end

%% muscle kinematics for the workspace
intrinsic_kin = table;
intrinsic_vel = table;
for i = 1:length(times)
    reach_ind = intrinsic_pos.time>times(i,1) & intrinsic_pos.time<times(i,2);
    intrinsic_kin = [intrinsic_kin; intrinsic_pos(reach_ind,:)];
    intrinsic_vel = [intrinsic_vel; intrinsic_vel(reach_ind,:)];
end

% Linear model
% muscle_neur = [ones(length(muscle_vel),1) muscle_vel{:,2:end}]*muscle_weights;

% GLM Poisson model
sim_FR = exp([ones(length(intrinsic_vel),1) intrinsic_vel{:,2:end}]*weights);

% interpolate endpoint kinematics to muscle times
endpoint_kin_sim = interp1(t,endpoint_kin,intrinsic_vel.time);

%% Calculate simulated PDs
% bootfunc = @(X,y) LinearModel.fit(X,y);
bootfunc = @(X,y) GeneralizedLinearModel.fit(X,y,'Distribution','poisson');

tic;
for i = 1:num_neurons
    modeled_tuning(i) = calc_PD_helper(bootfunc,endpoint_kin_sim,sim_FR(:,i),['Processed Intrinsic Neuron ' num2str(i) ' (Time: ' num2str(toc) ')']);
end

%% Calculate simulated tuning curves
for i = 1:num_neurons
    curves(i) = get_single_tuning_curve(endpoint_kin_sim,sim_FR(:,i));
end
