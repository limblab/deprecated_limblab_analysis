% function test_nn_inv_arm
% http%3A%2F%2Fwww.pages.drexel.edu%2F~rwe24%2FBipedLectures%2FLecture%25202%2520-%2520(Robotic%2520Control).ppt
% arm_params = get_arm_params();
% 
% script_filename = mfilename('fullpath');
% [location,~,~] = fileparts(script_filename);
% 
% if arm_params.left_handed
%     file_suffix = 'left';
% else
%     file_suffix = 'right';
% end
% if ~arm_params.clear_all
%     try
%         temp = arm_params;
%         load([location '\training_set_' file_suffix '.mat'])
%         arm_params = temp;       
%     catch
%         arm_params.clear_all = 1;
%     end
% end

% Parameters
arm_params.dt = .01;
arm_params.t = 0:arm_params.dt:1000;
arm_params.l = [.2 .2];
arm_params.m = [1 1];
arm_params.d = arm_params.l/2;
arm_params.theta_ref = [pi/4 pi/2]; 
arm_params.theta_ref_dot_dot = [0.1 0];
arm_params.r = arm_params.l/5;
arm_params.k = [1000 1000];
arm_params.b = .1;
arm_params.theta_e = 0;
arm_params.F_end = [0 0];
arm_params.left_handed = 1;
temp = [smooth(rand(1,2000+length(arm_params.t)),1000)';
    smooth(rand(1,2000+length(arm_params.t)),1000)'];
[b,a] = butter(4,1*(1/2*arm_params.dt));
temp = filter(b,a,temp')';
temp = temp(:,1001:end-1000);
temp_range = max(temp,[],2) - min(temp,[],2);
temp_mean = mean(temp,2);
temp = pi*(temp-repmat(temp_mean,1,size(temp,2)))./repmat(temp_range,1,size(temp,2));
arm_params.theta = repmat(arm_params.theta_ref',1,size(temp,2))+temp/2;

% if arm_params.plot
    figure;
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
    h_hist = plot(0,0,'.b');
    h_la2 = plot(0,0,'-','Color',[.5 .5 .5]);
    h_ua2 = plot(0,0,'-','Color',[.5 .5 .5]);
    xlim([-sum(arm_params.l) sum(arm_params.l)])
    ylim([-sum(arm_params.l) sum(arm_params.l)])
    axis square
% end

x0=[arm_params.theta(:,1)' 1 1];
t_temp = [arm_params.t(1) arm_params.t(2)];
while (abs(x0(3:4)) > .0000001)
    [t,x] = ode45(@(t,x0) arm_dynamics(t,x0,arm_params),t_temp,x0);
    x0=x(end,:);
end

% x0(3:4) = 0;
% else
%     x0=[3*pi/4 pi/2 0 0];
% end

this_set_counter = 0;
x_gain = -2*arm_params.left_handed+1;
% musc_inputs = zeros(length(arm_params.t)-1,length([arm_params.F_max arm_params.F_max]));
hand_position = zeros(length(arm_params.t)-1,2);   
new_params = 1;
theta_ref_past = repmat(x0(1:2),3,1);
for i=1:length(arm_params.t)-1  
    arm_params.theta_ref_dot_dot = [0 0];    
    if mod(i,100)==0        
        rand_ang = 2*pi*round(rand*7)/8;
        arm_params.F_end = [3*cos(rand_ang);...
            3*sin(rand_ang)];
        if (rand>.9)
            arm_params.F_end = 0*arm_params.F_end;
        end
        new_params = 0;
    end        
%     arm_params.theta_ref = .99*arm_params.theta_ref + .002*rand(1,2)*2*pi - .01;
%     arm_params.theta_ref(1) = max(min(arm_params.theta_ref(1),pi/2),0);
%     arm_params.theta_ref(2) = max(min(arm_params.theta_ref(2),pi),0);
    arm_params.theta_ref = arm_params.theta(:,i)';
    theta_ref_past(2:end,:) = theta_ref_past(1:end-1,:);
    theta_ref_past(1,:) = arm_params.theta_ref;   
    arm_params.theta_ref_dot_dot = diff(theta_ref_past,2)/(arm_params.dt^2);
%     musc_inputs(i,:) = [arm_params.musc_l0 arm_params.musc_act];
    t_temp = [arm_params.t(i) arm_params.t(i+1)];
    [t,x] = ode45(@(t,x0) arm_dynamics(t,x0,arm_params),t_temp,x0);
    x0 = x(end,:);
    theta(1) = x0(1);
    theta(2) = x0(1)+x0(2);
    X_e = [arm_params.l(1)*cos(theta(1)) arm_params.l(1)*sin(theta(1))];
    X_h = X_e + [arm_params.l(2)*cos(theta(2)) arm_params.l(2)*sin(theta(2))];
    hand_position(i,:) = X_h;
    X_e2 = [arm_params.l(1)*cos(arm_params.theta_ref(1)) arm_params.l(1)*sin(arm_params.theta_ref(1))];
    X_h2 = X_e2 + [arm_params.l(2)*cos(sum(arm_params.theta_ref)) arm_params.l(2)*sin(sum(arm_params.theta_ref))];

    musc_end_1_x = [x_gain*arm_params.r(1)*cos(arm_params.theta_ref(1))...
        x_gain*arm_params.r(1)*cos(arm_params.theta_ref(1)+pi)...
        X_e(1)-arm_params.r(1)*cos(x(1))...
        X_e(1)+arm_params.r(1)*cos(x(1))];
    musc_end_1_y = [arm_params.r(1)*sin(arm_params.theta_ref(1))...
        arm_params.r(1)*sin(arm_params.theta_ref(1)+pi)...
        X_e(2)-arm_params.r(1)*sin(theta(1))...
        X_e(2)+arm_params.r(1)*sin(theta(1))];
    musc_end_2_x = [arm_params.r(1)*cos(theta(1))...
        arm_params.r(1)*cos(theta(1))...
        X_e(1)+arm_params.r(1)*cos(theta(2))...
        X_e(1)+arm_params.r(1)*cos(theta(2))];
    musc_end_2_y = [arm_params.r(1)*sin(theta(1))...
        arm_params.r(1)*sin(theta(1))...
        X_e(2)+arm_params.r(1)*sin(theta(2))...
        X_e(2)+arm_params.r(1)*sin(theta(2))];
    
    F_end = [arm_params.F_end(1) arm_params.F_end(2)];  
    set(h_la,'XData',[0 X_e(1)],'YData',[0 X_e(2)])
    set(h_ua,'XData',[X_e(1) X_h(1)],'YData',[X_e(2) X_h(2)])
    set(h_la2,'XData',[0 X_e2(1)],'YData',[0 X_e2(2)])
    set(h_ua2,'XData',[X_e2(1) X_h2(1)],'YData',[X_e2(2) X_h2(2)])
    
    set(h_pect,'XData',[musc_end_1_x(1) musc_end_2_x(1)],'YData',[musc_end_1_y(1) musc_end_2_y(1)])
    set(h_del,'XData',[musc_end_1_x(2) musc_end_2_x(2)],'YData',[musc_end_1_y(2) musc_end_2_y(2)])
    set(h_bi,'XData',[musc_end_1_x(3) musc_end_2_x(3)],'YData',[musc_end_1_y(3) musc_end_2_y(3)])
    set(h_tri,'XData',[musc_end_1_x(4) musc_end_2_x(4)],'YData',[musc_end_1_y(4) musc_end_2_y(4)])
    set(h_F,'XData',X_h(1)+[0 .01*F_end(1)],'YData',X_h(2)+[0 .01*F_end(2)])
    set(h_text,'String',['t = ' num2str(t(end)) ' s'])   
    drawnow
    
    if i>5
        if abs(sum(diff(hand_position(i-5:i,:)))) < 1E-5      
%             input_counter = input_counter+1;
            new_params = 1;    
            set(h_hist,'XData',[get(h_hist,'XData') X_h(1)],'YData',[get(h_hist,'YData') X_h(2)])            
        end
    end
    
end
