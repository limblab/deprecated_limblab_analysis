% function [arm_params,data_struct] = DCO_decode_arm(data_struct,params)

% load(params.arm_model_location)
DCO = data_struct.DCO;
bdf = data_struct.bdf;

% idx = DCO.in_task_idx;
idx = 1:size(bdf.pos,1);

pos = bdf.pos(idx,:);
pos(1:end,1) = bdf.pos(1:length(pos),1);

vel = bdf.vel(idx,:);
vel(1:end,1) = bdf.vel(1:length(pos),1);

% pos = bdf.pos;

force = bdf.force(idx,:);
force(1:end,1) = force(1:length(force),1);

% force = bdf.force;

new_fs = 50;
new_dt = 1/new_fs;

t_vector = pos(1:round(1/DCO.dt)/new_fs:end,1);
hand_pos_resamp = [resample(pos(:,2),new_fs,round(1/DCO.dt)) ...
    resample(pos(:,3),new_fs,round(1/DCO.dt))]/100;
fr_resamp = zeros(size(DCO.fr,1),size(hand_pos_resamp,1));
for iUnit = 1:size(fr_resamp,1)
    fr_resamp(iUnit,:) = resample(DCO.fr(iUnit,idx),new_fs,round(1/DCO.dt));
end

hand_pos_resamp(:,1) = hand_pos_resamp(:,1)+DCO.trial_table(1,DCO.table_columns.x_offset)/100;
hand_pos_resamp(:,2) = hand_pos_resamp(:,2)+DCO.trial_table(1,DCO.table_columns.y_offset)/100;

hand_force_resamp = [resample(force(:,2),new_fs,round(1/DCO.dt)) ...
    resample(force(:,3),new_fs,round(1/DCO.dt))];

train_outputs = hand_pos_resamp;
train_inputs = fr_resamp';

remove_idx = unique([find(abs(train_outputs(:,1))>6*std(abs(train_outputs(:,1))));...
    find(abs(train_outputs(:,2))>6*std(abs(train_outputs(:,2))))]);
keep_idx = setxor(1:length(train_outputs),remove_idx);
train_outputs = train_outputs(keep_idx,:);
train_inputs = train_inputs(keep_idx,:);

train_outputs_offset = mean(train_outputs);
train_outputs_gain = max(train_outputs) - min(train_outputs);
train_outputs = (train_outputs - repmat(train_outputs_offset,size(train_outputs,1),1))./...
    repmat(train_outputs_gain,size(train_outputs,1),1);

train_inputs_offset = mean(train_inputs);
train_inputs_gain = max(train_inputs) - min(train_inputs);
train_inputs = (train_inputs - repmat(train_inputs_offset,size(train_inputs,1),1))./...
    repmat(train_inputs_gain,size(train_inputs,1),1);


[H,~,~]=filMIMO3(train_inputs,train_outputs,params.num_lags,2,new_fs);
ActualData=zeros(size(fr_resamp'));

[predOutputs,~,~] = predMIMO3(train_inputs,H,2,new_fs,ActualData);
predOutputs = [repmat(predOutputs(1,:),params.num_lags-2,1); predOutputs];
predictedHandPos = predOutputs.*repmat(train_outputs_gain,size(predOutputs,1),1) +...
    repmat(train_outputs_offset,size(predOutputs,1),1);

% [a,b] = fit(train_outputs(:,1),predOutputs(:,1),lin_fun)
% [a,b] = fit(train_outputs(:,2),predOutputs(:,2),lin_fun)
%% Show test results
% Parameters
arm_params.dt = .05;
arm_params.t = 0:arm_params.dt:1000;
arm_params.l = [.2 .2];
arm_params.m = [5 5];
arm_params.d = arm_params.l/2;
arm_params.theta_ref = [pi/4 pi/2]; 
arm_params.theta_ref_dot_dot = [0.1 0];
arm_params.r = arm_params.l/5;
arm_params.k = [100 100];
arm_params.b = .3;
arm_params.theta_e = 0;
arm_params.F_end = [0 0];
arm_params.monkey_control = 0;
arm_params.left_handed = 1;
arm_params.X_s = [-.05 -.2];

hFig = create_arm_figure(arm_params);
arm_params.X_gain = -2*arm_params.left_handed+1;
X_e = zeros(length(t_vector)*new_dt/arm_params.dt-1,2);
X_h = zeros(length(t_vector)*new_dt/arm_params.dt-1,2);
F_end = zeros(length(t_vector)*new_dt/arm_params.dt-1,2);
X_hand_real = zeros(length(t_vector)*new_dt/arm_params.dt-1,2);
F_end_real = zeros(length(t_vector)*new_dt/arm_params.dt-1,2);
input_counter = 1;

x0 = [x2theta(hand_pos_resamp(1,:),arm_params) .000000000002 .000000000002];
t_temp = [arm_params.t(1) arm_params.t(2)];
while (abs(x0(3:4)) > .000000000001)
    [t,x] = ode45(@(t,x0) arm_dynamics(t,x0,arm_params),t_temp,x0);
    x0=x(end,:);
end

clear dist
for i=1:length(t_vector)*new_dt/arm_params.dt-1    
    X_hand_real(i,:) = hand_pos_resamp(i,:);
    F_end_real(i,:) = hand_force_resamp(i,:);
    arm_params.X_hand_real = X_hand_real(i,:);
    arm_params.F_end_real = F_end_real(i,:);
    arm_params.F_end = F_end_real(i,:);
    
   
%     theta = x2theta(hand_pos_resamp(i,:),arm_params);
    
    theta = x2theta(predictedHandPos(i,:),arm_params);
    x0 = [theta x0([3 4])];
    
    t_temp = [0 new_dt];
    [t,x] = ode45(@(t,x0) arm_dynamics(t,x0,arm_params),t_temp,x0);
    x0 = x(end,:);
    
    t_temp = [0 new_dt];
    arm_params.theta = x(1:2);
    arm_params.X_e = arm_params.X_s+[arm_params.l(1)*cos(x(end,1)) arm_params.l(1)*sin(x(end,1))];
    arm_params.X_h = arm_params.X_e + [arm_params.l(2)*cos(x(end,2)) arm_params.l(2)*sin(x(end,2))];
    
    arm_params.t_now = (i-1)*new_dt;
    update_arm_figure(hFig,arm_params)

%     set(h_text,'String',['t = ' num2str(t(end)) ' s'])
%     pause(diff(t(end-1:end)))
    drawnow
    dist(i) = sqrt((arm_params.X_h(1)-X_hand_real(i,1))^2+(arm_params.X_h(2)-X_hand_real(i,2))^2);
end



% nn_inputs = [hand_pos_resamp hand_force_resamp];
% nn_inputs = nn_inputs./repmat(input_range',size(nn_inputs,1),1);
% temp_offset = mean(nn_inputs,1);
% nn_inputs = (nn_inputs - repmat(temp_offset,size(nn_inputs,1),1))';
% 
% muscle_inputs = net(nn_inputs)';
% 
% % Not sure why removing offset is necessary:
% muscle_inputs = muscle_inputs - repmat(mean(muscle_inputs),size(muscle_inputs,1),1);
% [H,~,~]=filMIMO3(fr_resamp_norm',muscle_inputs,params.num_lags,2,new_fs);
% % [H,~,~]=filMIMO4(muscle_inputs,fr_resamp_norm',params.num_lags,1,new_fs);
% 
% ActualData=zeros(size(fr_resamp'));
% 
% [predictedMuscInputs,~,~]=predMIMO3(fr_resamp_norm',H,2,new_fs,ActualData);
% predictedMuscInputs = [repmat(predictedMuscInputs(1,:),params.num_lags-1,1); predictedMuscInputs]';
% predictedMuscInputs = predictedMuscInputs.*repmat(target_range,1,size(predictedMuscInputs,2));
% predictedMuscInputs = predictedMuscInputs + repmat(target_offset,1,size(predictedMuscInputs,2));
% predictedMuscInputs = predictedMuscInputs';