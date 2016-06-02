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
arm_params.dt = .05;
arm_params.t = 0:arm_params.dt:1000;
arm_params.l = [.2 .2];
arm_params.m = [1 1];
arm_params.d = arm_params.l/2;
arm_params.theta_ref = [pi/4 pi/2]; 
arm_params.theta_ref_dot_dot = [0.1 0];
arm_params.r = arm_params.l/5;
arm_params.k = [100 100];
arm_params.b = .3;
arm_params.theta_e = 0;
arm_params.F_end = [0 0];
arm_params.left_handed = 1;
arm_params.monkey_control = 0;

temp = [(rand(1,2000+length(arm_params.t)));
    (rand(1,2000+length(arm_params.t)))];
[b,a] = butter(4,4*(1/2*arm_params.dt));
temp = filter(b,a,temp')';
temp = temp(:,1001:end-1000);
temp_range = max(temp,[],2) - min(temp,[],2);
temp_mean = mean(temp,2);
temp = pi*(temp-repmat(temp_mean,1,size(temp,2)))./repmat(temp_range,1,size(temp,2));
arm_params.theta_vector = repmat(arm_params.theta_ref',1,size(temp,2))+.8*temp;

hFig = create_arm_figure(arm_params);

x0=[arm_params.theta_vector(:,1)' .0000002 .0000002];
t_temp = [arm_params.t(1) arm_params.t(2)];
while (abs(x0(3:4)) > .0000001)
    [t,x] = ode45(@(t,x0) arm_dynamics(t,x0,arm_params),t_temp,x0);
    x0=x(end,:);
end

this_set_counter = 0;
arm_params.X_gain = -2*arm_params.left_handed+1;
hand_position = zeros(length(arm_params.t)-1,2);   
new_params = 1;
theta_ref_past = repmat(x0(1:2),3,1);
T_feedback = nan(length(arm_params.t)-1,3);
T_feedforward = nan(length(arm_params.t)-1,3);
T_musc = nan(length(arm_params.t)-1,2);
T_endpoint = nan(length(arm_params.t)-1,2);
T_feedback_vel = nan(length(arm_params.t)-1,2);
F_endpoint = nan(length(arm_params.t)-1,2);
running_time = nan(length(arm_params.t)-1,1);

theta = nan(length(arm_params.t)-1,2);
k = nan(length(arm_params.t)-1,1);
for i=1:length(arm_params.t)-1  
    tic
    arm_params.theta_ref_dot_dot = [0 0];    
    if mod(i,500)==0
        rand_ang = 2*pi*round(rand*7)/8;
        arm_params.F_end = [3*cos(rand_ang);...
            3*sin(rand_ang)];
        rand_k = rand*1000+100;
%         arm_params.k = [rand_k rand_k];
        arm_params.k = [1000 1000];
        arm_params.F_end = 0*arm_params.F_end;
        if (rand>.9)
            arm_params.F_end = 0*arm_params.F_end;
        end
        new_params = 0;
    end
    arm_params.theta_ref = arm_params.theta_vector(:,i)';
    theta_ref_past(2:end,:) = theta_ref_past(1:end-1,:);
    theta_ref_past(1,:) = arm_params.theta_ref;
    arm_params.theta_ref_dot_dot = diff(theta_ref_past,2)/(arm_params.dt^2);
    t_temp = [arm_params.t(i) arm_params.t(i+1)];
    [t,x] = ode45(@(t,x0) arm_dynamics(t,x0,arm_params),t_temp,x0);
    x0 = x(end,:);
    [~,temp] = arm_dynamics(t,x(end,:),arm_params);
    T_feedback(i,:) = temp(end,1:3);
    T_feedforward(i,:) = temp(end,4:6);
    T_musc(i,:) = temp(end,7:8);
    T_endpoint(i,:) = temp(end,9:10);
    T_feedback_vel(i,:) = temp(end,11:12);
    F_endpoint(i,:) = arm_params.F_end;
    theta(i,1) = x0(1);
    theta(i,2) = x0(1)+x0(2);
    k(i) = arm_params.k(1);
    arm_params.theta = theta(i,:);
    arm_params.X_e = [arm_params.l(1)*cos(theta(i,1)) arm_params.l(1)*sin(theta(i,1))];
    arm_params.X_h = arm_params.X_e + [arm_params.l(2)*cos(theta(i,2)) arm_params.l(2)*sin(theta(i,2))];
    hand_position(i,:) = arm_params.X_h;
    arm_params.X_e2 = [arm_params.l(1)*cos(arm_params.theta_ref(1)) arm_params.l(1)*sin(arm_params.theta_ref(1))];
    arm_params.X_h2 = arm_params.X_e2 + [arm_params.l(2)*cos(sum(arm_params.theta_ref)) arm_params.l(2)*sin(sum(arm_params.theta_ref))];
    arm_params.t_now = t(end);
    
    update_arm_figure(hFig,arm_params);
    
    if i>5
        if abs(sum(diff(hand_position(i-5:i,:)))) < 1E-5     
            new_params = 1;    
            set(hFig.h_hist,'XData',[get(hFig.h_hist,'XData') arm_params.X_h(1)],'YData',[get(hFig.h_hist,'YData') arm_params.X_h(2)])            
        end
    end
    running_time(i) = toc;
end
