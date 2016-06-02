% function test_nn_inv_arm
% http%3A%2F%2Fwww.pages.drexel.edu%2F~rwe24%2FBipedLectures%2FLecture%25202%2520-%2520(Robotic%2520Control).ppt
arm_params = get_arm_params();

script_filename = mfilename('fullpath');
[location,~,~] = fileparts(script_filename);

if arm_params.left_handed
    file_suffix = 'left';
else
    file_suffix = 'right';
end
% if ~arm_params.clear_all
%     try
%         temp = arm_params;
%         load([location '\training_set_' file_suffix '.mat'])
%         arm_params = temp;       
%     catch
%         arm_params.clear_all = 1;
%     end
% end

% if arm_params.plot
    figure(1);
    clf
    hold on
    h_la = plot(0,0,'-k');
    h_ua = plot(0,0,'-k');
    h_pect = plot(0,0,'-r');
    h_del = plot(0,0,'-r');
    h_bi = plot(0,0,'-r');
    h_tri = plot(0,0,'-r');   
    h_text = text(-.9*sum(arm_params.l),.9*sum(arm_params.l),'t = 0 s');
    h_F = plot(0,0,'-b');
    h_actual = plot(0,0,'ob');
    xlim([-sum(arm_params.l) sum(arm_params.l)])
    ylim([-sum(arm_params.l) sum(arm_params.l)])
    axis square
% end

rand_counter = 100;

musc_input_mat_test = [];
hand_position_mat_test = [];
force_mat_test = [];

input_counter = 1;
                  
new_params = 1;  
if ~arm_params.left_handed
    x0=[pi/4 pi/2 0 0];
else
    x0=[3*pi/4 pi/2 0 0];
end
this_set_counter = 0;
x_gain = -2*arm_params.left_handed+1;
% musc_inputs = zeros(length(arm_params.t)-1,length([arm_params.F_max arm_params.F_max]));
hand_position = zeros(length(arm_params.t)-1,2);        
for i=1:length(arm_params.t)-1   
    if new_params 
        arm_params.musc_act = rand(1,length(arm_params.m_ins));
        arm_params.musc_act(2:2:end) = 1-arm_params.musc_act(1:2:end);
        arm_params.musc_l0 = sqrt(2*arm_params.m_ins.^2)+...
                0*sqrt(2*arm_params.m_ins.^2)/5.*...
                (rand(1,length(arm_params.m_ins))-.5);

        arm_params.F_end = [5*rand*(2*(rand>.5)-1);...
            5*rand*(2*(rand>.5)-1)];

        if (rand>.5)
            arm_params.F_end = 0*arm_params.F_end;
        end

        rand_counter = rand_counter+1;
        new_params = 0;
    end
%     musc_inputs(i,:) = [arm_params.musc_l0 arm_params.musc_act];
    t_temp = [arm_params.t(i) arm_params.t(i+1)];
%     [t,x] = ode45(@(t,x0) robot_2link_abs(t,x0,arm_params),t_temp,x0);
    [t,x] = ode45(@(t,x0) muscle_arm(t,x0),t_temp,x0);
    X_e = [arm_params.l(1)*cos(x(end,1)) arm_params.l(1)*sin(x(end,1))];
    X_h = X_e + [arm_params.l(2)*cos(x(end,2)) arm_params.l(2)*sin(x(end,2))];
    hand_position(i,:) = X_h;

    musc_end_1_x = [x_gain*arm_params.m_ins(1)*cos(arm_params.null_angles(1))...
        x_gain*arm_params.m_ins(1)*cos(arm_params.null_angles(1)+pi)...
        X_e(1)-arm_params.m_ins(3)*cos(x(1))...
        X_e(1)+arm_params.m_ins(4)*cos(x(1))];
    musc_end_1_y = [arm_params.m_ins(1)*sin(arm_params.null_angles(1))...
        arm_params.m_ins(1)*sin(arm_params.null_angles(1)+pi)...
        X_e(2)-arm_params.m_ins(3)*sin(x(end,1))...
        X_e(2)+arm_params.m_ins(4)*sin(x(end,1))];
    musc_end_2_x = [arm_params.m_ins(1)*cos(x(end,1))...
        arm_params.m_ins(2)*cos(x(end,1))...
        X_e(1)+arm_params.m_ins(3)*cos(x(end,2))...
        X_e(1)+arm_params.m_ins(4)*cos(x(end,2))];
    musc_end_2_y = [arm_params.m_ins(1)*sin(x(end,1))...
        arm_params.m_ins(2)*sin(x(end,1))...
        X_e(2)+arm_params.m_ins(3)*sin(x(end,2))...
        X_e(2)+arm_params.m_ins(4)*sin(x(end,2))];
    
    F_end = [arm_params.F_end(1) arm_params.F_end(2)];           
    x0 = x(end,:);     
%     if arm_params.plot
        set(h_la,'XData',[0 X_e(1)],'YData',[0 X_e(2)])
        set(h_ua,'XData',[X_e(1) X_h(1)],'YData',[X_e(2) X_h(2)])
        set(h_pect,'XData',[musc_end_1_x(1) musc_end_2_x(1)],'YData',[musc_end_1_y(1) musc_end_2_y(1)])
        set(h_del,'XData',[musc_end_1_x(2) musc_end_2_x(2)],'YData',[musc_end_1_y(2) musc_end_2_y(2)])
        set(h_bi,'XData',[musc_end_1_x(3) musc_end_2_x(3)],'YData',[musc_end_1_y(3) musc_end_2_y(3)])
        set(h_tri,'XData',[musc_end_1_x(4) musc_end_2_x(4)],'YData',[musc_end_1_y(4) musc_end_2_y(4)])
        set(h_F,'XData',X_h(1)+[0 .01*F_end(1)],'YData',X_h(2)+[0 .01*F_end(2)])
        set(h_text,'String',['Creating test set    t = ' num2str(t(end)) ' s'])   
        drawnow
%     end
    if i>5
        if abs(sum(diff(hand_position(i-5:i,:)))) < 1E-5    
            this_set_counter = this_set_counter+1;
%             musc_input_mat_test(input_counter,:) = [arm_params.musc_l0 arm_params.musc_act];
            musc_input_mat_test(input_counter,:) = [arm_params.musc_act];
            hand_position_mat_test(input_counter,:) = X_h;
            force_mat_test(input_counter,:) = arm_params.F_end;
            input_counter = input_counter+1;
            new_params = 1;                
        end
    end
end

load([location '\' file_suffix '_arm_nn'])

inputs = [hand_position_mat_test force_mat_test]';
inputs = inputs./repmat(input_range,1,size(inputs,2));
inputs = 2*(inputs - repmat(input_offset,1,size(inputs,2)))-1;

muscle_inputs = net(inputs);
muscle_inputs = .5*(muscle_inputs) + repmat(target_offset,1,size(muscle_inputs,2));
muscle_inputs = muscle_inputs.*repmat(target_range,1,size(muscle_inputs,2));
muscle_inputs = muscle_inputs';
%% 
input_counter = 1;
new_params = 1;
for i=1:length(arm_params.t)-1   
    if new_params 
        temp = muscle_inputs(input_counter,1:end);
        arm_params.musc_act = reshape([temp; 1-temp],1,[]);
%         arm_params.musc_act = muscle_inputs(input_counter,1:end);
%         arm_params.musc_act(1:2:end) = muscle_inputs(input_counter,1:end);
%         arm_params.musc_act(2:2:end) = 1-muscle_inputs(input_counter,1:end);
% %         arm_params.musc_l0 = muscle_inputs(input_counter,end/2+1:end);
        arm_params.musc_l0 = sqrt(2*arm_params.m_ins.^2)+...
                    0*sqrt(2*arm_params.m_ins.^2)/5.*...
                    (rand(1,length(arm_params.m_ins))-.5);
                
        arm_params.F_end = force_mat_test(input_counter,:);        
        new_params = 0;
    end
    t_temp = [arm_params.t(i) arm_params.t(i+1)];
    [t,x] = ode45(@(t,x0) robot_2link_abs(t,x0,arm_params),t_temp,x0);
    X_e = [arm_params.l(1)*cos(x(end,1)) arm_params.l(1)*sin(x(end,1))];
    X_h = X_e + [arm_params.l(2)*cos(x(end,2)) arm_params.l(2)*sin(x(end,2))];
    hand_position(i,:) = X_h;

    musc_end_1_x = [0*X_e(1) 0*X_e(1) X_e(1)-arm_params.m_ins(3)*cos(x(1)) X_e(1)+arm_params.m_ins(4)*cos(x(1))];
    musc_end_1_y = [arm_params.m_ins(1) -arm_params.m_ins(2) X_e(2)-arm_params.m_ins(3)*sin(x(end,1)) X_e(2)+arm_params.m_ins(4)*sin(x(end,1))];
    musc_end_2_x = [arm_params.m_ins(1)*cos(x(end,1)) arm_params.m_ins(2)*cos(x(end,1)) X_e(1)+arm_params.m_ins(3)*cos(x(end,2)) X_e(1)+arm_params.m_ins(4)*cos(x(end,2))];
    musc_end_2_y = [arm_params.m_ins(1)*sin(x(end,1)) arm_params.m_ins(2)*sin(x(end,1)) X_e(2)+arm_params.m_ins(3)*sin(x(end,2)) X_e(2)+arm_params.m_ins(4)*sin(x(end,2))];
    F_end = [arm_params.F_end(1) arm_params.F_end(2)];           
    x0 = x(end,:);     
%     if arm_params.plot
        set(h_la,'XData',[0 X_e(1)],'YData',[0 X_e(2)])
        set(h_ua,'XData',[X_e(1) X_h(1)],'YData',[X_e(2) X_h(2)])
        set(h_pect,'XData',[musc_end_1_x(1) musc_end_2_x(1)],'YData',[musc_end_1_y(1) musc_end_2_y(1)])
        set(h_del,'XData',[musc_end_1_x(2) musc_end_2_x(2)],'YData',[musc_end_1_y(2) musc_end_2_y(2)])
        set(h_bi,'XData',[musc_end_1_x(3) musc_end_2_x(3)],'YData',[musc_end_1_y(3) musc_end_2_y(3)])
        set(h_tri,'XData',[musc_end_1_x(4) musc_end_2_x(4)],'YData',[musc_end_1_y(4) musc_end_2_y(4)])
        set(h_F,'XData',X_h(1)+[0 .01*F_end(1)],'YData',X_h(2)+[0 .01*F_end(2)])
        set(h_actual,'XData',hand_position_mat_test(input_counter,1),'YData',hand_position_mat_test(input_counter,2))
        set(h_text,'String',['Test set    t = ' num2str(t(end)) ' s'])   
        drawnow
%     end
    if i>5
        if abs(sum(diff(hand_position(i-5:i,:)))) < 1E-5    
            input_counter = input_counter+1;
            new_params = 1;                
        end
    end
end
