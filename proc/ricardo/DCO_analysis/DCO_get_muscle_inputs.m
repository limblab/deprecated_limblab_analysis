function [nn_params,data_struct] = DCO_get_muscle_inputs(data_struct,params)

load(params.arm_model_location)
DCO = data_struct.DCO;
bdf = data_struct.bdf;
new_fs = 10;

t_vector = bdf.pos(1:round(1/DCO.dt)/new_fs:end,1);
hand_pos_resamp = [resample(bdf.pos(:,2),new_fs,round(1/DCO.dt)) ...
    resample(bdf.pos(:,3),new_fs,round(1/DCO.dt))]/100;
fr_resamp = zeros(size(DCO.fr,1),size(hand_pos_resamp,1));
for iUnit = 1:size(fr_resamp,1)
    fr_resamp(iUnit,:) = resample(DCO.fr(iUnit,:),new_fs,round(1/DCO.dt));
end

hand_pos_resamp(:,1) = hand_pos_resamp(:,1)+DCO.trial_table(1,DCO.table_columns.x_offset)/100+.05;
hand_pos_resamp(:,2) = hand_pos_resamp(:,2)+DCO.trial_table(1,DCO.table_columns.y_offset)/100+.12;

hand_force_resamp = [resample(bdf.force(:,2),new_fs,round(1/DCO.dt)) ...
    resample(bdf.force(:,3),new_fs,round(1/DCO.dt))];

inputs_test = [hand_pos_resamp hand_force_resamp]';
muscle_inputs = net(inputs_test)';

[H,~,~]=filMIMO4(fr_resamp',muscle_inputs,params.num_lags,1,new_fs);

ActualData=zeros(size(fr_resamp'));

[predictedMuscInputs,~,~]=predMIMO4(fr_resamp',H,1,new_fs,ActualData);
predictedMuscInputs = [repmat(predictedMuscInputs(1,:),params.num_lags-1,1); predictedMuscInputs];
%% Show test results
%parameters
nn_params.g = 0;
nn_params.m = [1, 1];
nn_params.l = [.1, .1];%segment lengths l1, l2
nn_params.m_ins = [.02 .02 .02 .02];
nn_params.lc =[.05, .05]; %distance from center
nn_params.i = [nn_params.m(1)*nn_params.l(1)^2/3, nn_params.m(2)*nn_params.l(2)^2/3]; %moments of inertia i1, i2, need to validate coef's
nn_params.c = [.20,.20];
nn_params.T = 0*[2;-.2];
nn_params.t = t_vector;
nn_params.dt = diff(nn_params.t(1:2));
nn_params.F_max = [200 200 50 50];

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
h_text = text(-.9*sum(nn_params.l),.9*sum(nn_params.l),'t = 0 s');
h_F = plot(0,0,'-b');
xlim([-sum(nn_params.l) sum(nn_params.l)])
ylim([-sum(nn_params.l) sum(nn_params.l)])
axis square

nn_params.musc_l0 = predictedMuscInputs(1,1:end/2);
nn_params.musc_act = predictedMuscInputs(1,end/2+1:end); 
x0=[pi/4 pi/2 0 0];
for i=1:size(predictedMuscInputs,1)-1
    nn_params.musc_l0 = predictedMuscInputs(i,1:end/2);
    nn_params.musc_act = predictedMuscInputs(i,end/2+1:end);        
    nn_params.F_end = [nn_params.t(i)*ones(1,length(nn_params.t));...
        hand_force_resamp(i,1)*ones(1,length(nn_params.t));...
        hand_force_resamp(i,2)*ones(1,length(nn_params.t))];

    t_temp = [nn_params.t(i) nn_params.t(i+1)];
    [t,x] = ode45(@(t,x0) robot_2link_abs(t,x0,nn_params),t_temp,x0);
    X_e = [nn_params.l(1)*cos(x(end,1)) nn_params.l(1)*sin(x(end,1))];
    X_h = X_e + [nn_params.l(2)*cos(x(end,2)) nn_params.l(2)*sin(x(end,2))];
    musc_end_1_x = [0*X_e(1) 0*X_e(1) X_e(1)-nn_params.m_ins(3)*cos(x(1)) X_e(1)+nn_params.m_ins(4)*cos(x(1))];
    musc_end_1_y = [nn_params.m_ins(1) -nn_params.m_ins(2) X_e(2)-nn_params.m_ins(3)*sin(x(end,1)) X_e(2)+nn_params.m_ins(4)*sin(x(end,1))];
    musc_end_2_x = [nn_params.m_ins(1)*cos(x(end,1)) nn_params.m_ins(2)*cos(x(end,1)) X_e(1)+nn_params.m_ins(3)*cos(x(end,2)) X_e(1)+nn_params.m_ins(4)*cos(x(end,2))];
    musc_end_2_y = [nn_params.m_ins(1)*sin(x(end,1)) nn_params.m_ins(2)*sin(x(end,1)) X_e(2)+nn_params.m_ins(3)*sin(x(end,2)) X_e(2)+nn_params.m_ins(4)*sin(x(end,2))];
    F_end = [nn_params.F_end(2,i) nn_params.F_end(3,i)];    

    set(h_la,'XData',[0 X_e(1)],'YData',[0 X_e(2)])
    set(h_ua,'XData',[X_e(1) X_h(1)],'YData',[X_e(2) X_h(2)])
    set(h_pect,'XData',[musc_end_1_x(1) musc_end_2_x(1)],'YData',[musc_end_1_y(1) musc_end_2_y(1)])
    set(h_del,'XData',[musc_end_1_x(2) musc_end_2_x(2)],'YData',[musc_end_1_y(2) musc_end_2_y(2)])
    set(h_bi,'XData',[musc_end_1_x(3) musc_end_2_x(3)],'YData',[musc_end_1_y(3) musc_end_2_y(3)])
    set(h_tri,'XData',[musc_end_1_x(4) musc_end_2_x(4)],'YData',[musc_end_1_y(4) musc_end_2_y(4)])
    
    set(h_pred,'XData',hand_pos_resamp(i,1),'YData',hand_pos_resamp(i,2))
    
    set(h_F,'XData',X_h(1)+[0 .01*F_end(1)],'YData',X_h(2)+[0 .01*F_end(2)])
    set(h_text,'String',['t = ' num2str(t(end)) ' s'])
    pause(diff(t(end-1:end)))
    x0 = x(end,:);
end