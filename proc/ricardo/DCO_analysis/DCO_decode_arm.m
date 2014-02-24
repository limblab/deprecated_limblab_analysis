% function [arm_params,data_struct] = DCO_decode_arm(data_struct,params)

load(params.arm_model_location)
DCO = data_struct.DCO;
bdf = data_struct.bdf;

pos = bdf.pos(DCO.in_task_idx,:);
pos(1:end,1) = bdf.pos(1:length(pos),1);

% pos = bdf.pos;

force = bdf.force(DCO.in_task_idx,:);
force(1:end,1) = force(1:length(force),1);

% force = bdf.force;

new_fs = 20;
new_dt = 1/new_fs;

t_vector = pos(1:round(1/DCO.dt)/new_fs:end,1);
hand_pos_resamp = [resample(pos(:,2),new_fs,round(1/DCO.dt)) ...
    resample(pos(:,3),new_fs,round(1/DCO.dt))]/100;
fr_resamp = zeros(size(DCO.fr,1),size(hand_pos_resamp,1));
for iUnit = 1:size(fr_resamp,1)
    fr_resamp(iUnit,:) = resample(DCO.fr(iUnit,DCO.in_task_idx),new_fs,round(1/DCO.dt));
end
% for iUnit = 1:size(fr_resamp,1)
%     fr_resamp(iUnit,:) = resample(DCO.fr(iUnit,:),new_fs,round(1/DCO.dt));
% end

hand_pos_resamp(:,1) = hand_pos_resamp(:,1)+DCO.trial_table(1,DCO.table_columns.x_offset)/100;
hand_pos_resamp(:,2) = hand_pos_resamp(:,2)+DCO.trial_table(1,DCO.table_columns.y_offset)/100;

hand_force_resamp = [resample(force(:,2),new_fs,round(1/DCO.dt)) ...
    resample(force(:,3),new_fs,round(1/DCO.dt))];

nn_inputs = [hand_pos_resamp hand_force_resamp];
nn_inputs = nn_inputs./repmat(input_range',size(nn_inputs,1),1);
temp_offset = mean(nn_inputs,1);
nn_inputs = (nn_inputs - repmat(temp_offset,size(nn_inputs,1),1))';

muscle_inputs = net(nn_inputs)';

% Not sure why removing offset is necessary:
muscle_inputs = muscle_inputs - repmat(mean(muscle_inputs),size(muscle_inputs,1),1);

fr_range = max(fr_resamp,[],2) - min(fr_resamp,[],2);
fr_resamp_norm = fr_resamp./repmat(fr_range,1,size(fr_resamp,2));
fr_offset = min(fr_resamp_norm,[],2);
% fr_offset = mean(fr_resamp_norm,2);
fr_resamp_norm = 2*(fr_resamp_norm - repmat(fr_offset,1,size(fr_resamp_norm,2)))-1;

[H,~,~]=filMIMO3(fr_resamp_norm',muscle_inputs,params.num_lags,2,new_fs);
% [H,~,~]=filMIMO4(muscle_inputs,fr_resamp_norm',params.num_lags,1,new_fs);

ActualData=zeros(size(fr_resamp'));

[predictedMuscInputs,~,~]=predMIMO3(fr_resamp_norm',H,2,new_fs,ActualData);
predictedMuscInputs = [repmat(predictedMuscInputs(1,:),params.num_lags-1,1); predictedMuscInputs]';
predictedMuscInputs = predictedMuscInputs.*repmat(target_range,1,size(predictedMuscInputs,2));
predictedMuscInputs = predictedMuscInputs + repmat(target_offset,1,size(predictedMuscInputs,2));
predictedMuscInputs = predictedMuscInputs';
%% Show test results

figure(1);
clf
hold on
h_la = plot(0,0,'-k');
h_ua = plot(0,0,'-k');
h_pect = plot(0,0,'-r');
h_del = plot(0,0,'-r');
h_bi = plot(0,0,'-r');
h_tri = plot(0,0,'-r');
h_pred = plot(0,0,'ob');
h_text = text(-.9*sum(arm_params.l),.9*sum(arm_params.l),'t = 0 s');
h_F = plot(0,0,'-b');
xlim([-sum(arm_params.l) sum(arm_params.l)])
ylim([-sum(arm_params.l) sum(arm_params.l)])
axis square

% arm_params.musc_l0 = predictedMuscInputs(1,1:end);
% arm_params.musc_act = predictedMuscInputs(1,end/2+1:end); 
arm_params.musc_l0 = sqrt(2*arm_params.m_ins.^2)+...
                    0*sqrt(2*arm_params.m_ins.^2)/5.*...
                    (rand(1,length(arm_params.m_ins))-.5);
% arm_params.musc_act = predictedMuscInputs(1,:);
x0=[arm_params.null_angles 0 0];
X_e = zeros(length(t_vector)*new_dt/arm_params.dt-1,2);
X_h = zeros(length(t_vector)*new_dt/arm_params.dt-1,2);
F_end = zeros(length(t_vector)*new_dt/arm_params.dt-1,2);
X_hand_real = zeros(length(t_vector)*new_dt/arm_params.dt-1,2);
F_end_real = zeros(length(t_vector)*new_dt/arm_params.dt-1,2);
input_counter = 1;

for i=1:length(t_vector)*new_dt/arm_params.dt-1
    if (mod(i,new_dt/arm_params.dt)==1)    
        temp = predictedMuscInputs(input_counter,:);
        arm_params.musc_act = reshape([temp ; 1-temp],1,[]);
%         arm_params.musc_act = predictedMuscInputs(input_counter,:);   
        arm_params.F_end = [0*hand_force_resamp(input_counter,1);...
                0*hand_force_resamp(input_counter,2)];
        set(h_pred,'XData',hand_pos_resamp(input_counter,1),...
            'YData',hand_pos_resamp(input_counter,2))    
        set(h_F,'XData',hand_pos_resamp(input_counter,1)+[0 .01*hand_force_resamp(input_counter,1)],...
            'YData',hand_pos_resamp(input_counter,2)+[0 .01*hand_force_resamp(input_counter,2)])
        input_counter = input_counter+1;
    end
    X_hand_real(i,:) = hand_pos_resamp(input_counter,:);
    F_end_real(i,:) = hand_force_resamp(input_counter,:);
    t_temp = [i*arm_params.dt (i+1)*arm_params.dt];
    [t,x] = ode45(@(t,x0) robot_2link_abs(t,x0,arm_params),t_temp,x0);
    X_e(i,:) = [arm_params.l(1)*cos(x(end,1)) arm_params.l(1)*sin(x(end,1))];
    X_h(i,:) = X_e(i,:) + [arm_params.l(2)*cos(x(end,2)) arm_params.l(2)*sin(x(end,2))];
    
    musc_end_1_x = [x_gain*arm_params.m_ins(1)*cos(arm_params.null_angles(1))...
        x_gain*arm_params.m_ins(1)*cos(arm_params.null_angles(1)+pi)...
        X_e(i,1)-arm_params.m_ins(3)*cos(x(1))...
        X_e(i,1)+arm_params.m_ins(4)*cos(x(1))];
    musc_end_1_y = [arm_params.m_ins(1)*sin(arm_params.null_angles(1))...
        arm_params.m_ins(1)*sin(arm_params.null_angles(1)+pi)...
        X_e(i,2)-arm_params.m_ins(3)*sin(x(end,1))...
        X_e(i,2)+arm_params.m_ins(4)*sin(x(end,1))];
    musc_end_2_x = [arm_params.m_ins(1)*cos(x(end,1))...
        arm_params.m_ins(2)*cos(x(end,1))...
        X_e(i,1)+arm_params.m_ins(3)*cos(x(end,2))...
        X_e(i,1)+arm_params.m_ins(4)*cos(x(end,2))];
    musc_end_2_y = [arm_params.m_ins(1)*sin(x(end,1))...
        arm_params.m_ins(2)*sin(x(end,1))...
        X_e(i,2)+arm_params.m_ins(3)*sin(x(end,2))...
        X_e(i,2)+arm_params.m_ins(4)*sin(x(end,2))];
    
%     musc_end_1_x = [0*X_e(i,1) 0*X_e(i,1) X_e(i,1)-arm_params.m_ins(3)*cos(x(1)) X_e(i,1)+arm_params.m_ins(4)*cos(x(1))];
%     musc_end_1_y = [arm_params.m_ins(1) -arm_params.m_ins(2) X_e(i,2)-arm_params.m_ins(3)*sin(x(end,1)) X_e(i,2)+arm_params.m_ins(4)*sin(x(end,1))];
%     musc_end_2_x = [arm_params.m_ins(1)*cos(x(end,1)) arm_params.m_ins(2)*cos(x(end,1)) X_e(i,1)+arm_params.m_ins(3)*cos(x(end,2)) X_e(i,1)+arm_params.m_ins(4)*cos(x(end,2))];
%     musc_end_2_y = [arm_params.m_ins(1)*sin(x(end,1)) arm_params.m_ins(2)*sin(x(end,1)) X_e(i,2)+arm_params.m_ins(3)*sin(x(end,2)) X_e(i,2)+arm_params.m_ins(4)*sin(x(end,2))];
    F_end(i,:) = [arm_params.F_end(1) arm_params.F_end(2)];

    set(h_la,'XData',[0 X_e(i,1)]-input_mean(1),'YData',[0 X_e(i,2)]-input_mean(2))
    set(h_ua,'XData',[X_e(i,1) X_h(i,1)]-input_mean(1),'YData',[X_e(i,2) X_h(i,2)]-input_mean(2))
    set(h_pect,'XData',[musc_end_1_x(1) musc_end_2_x(1)]-input_mean(1),...
        'YData',[musc_end_1_y(1) musc_end_2_y(1)]-input_mean(2))
    set(h_del,'XData',[musc_end_1_x(2) musc_end_2_x(2)]-input_mean(1),...
        'YData',[musc_end_1_y(2) musc_end_2_y(2)]-input_mean(2))
    set(h_bi,'XData',[musc_end_1_x(3) musc_end_2_x(3)]-input_mean(1),...
        'YData',[musc_end_1_y(3) musc_end_2_y(3)]-input_mean(2))
    set(h_tri,'XData',[musc_end_1_x(4) musc_end_2_x(4)]-input_mean(1),...
        'YData',[musc_end_1_y(4) musc_end_2_y(4)]-input_mean(2))
    
    set(h_text,'String',['t = ' num2str(t(end)) ' s'])
%     pause(diff(t(end-1:end)))
    drawnow
    x0 = x(end,:);
end
x0
