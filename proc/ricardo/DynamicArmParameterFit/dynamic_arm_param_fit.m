% Dynamic model parameter fitting

load('D:\Data\TestData\Ricardo_2014-06-12_DCO\Output_Data\bdf')
load('D:\Data\TestData\Ricardo_2014-06-12_DCO\Output_Data\DCO')

idx = 1:50:size(bdf.pos,1);
% tm = round(bdf.pos(idx,1)*1000-999)';
tm = 1:length(idx);

emg_data = DCO.emg';
emg_data = emg_data(idx,[3 4 1 2]);
emg_norm = emg_data;

% emg_norm = max(emg_norm,0);
% emg_norm = emg_norm./repmat(max(emg_norm),size(emg_norm,1),1);
emg_norm = zscore(emg_norm);
emg_norm = emg_norm - repmat(min(emg_norm),size(emg_norm,1),1);

global musc_act
musc_act = emg_data;

l = [.4 .35];

x_off = DCO.trial_table(1,DCO.table_columns.x_offset);
y_off = DCO.trial_table(1,DCO.table_columns.y_offset);

x = [bdf.pos(idx,2)+repmat(x_off,length(idx),1) bdf.pos(idx,3)+repmat(y_off,length(idx),1)];
x = .01*x;

x_sh = [0 -.40];
x_temp = x - repmat(x_sh,length(idx),1);

c2 = (x_temp(:,1).^2 + x_temp(:,2).^2 - l(1)^2 -l(2)^2)/(2*l(1)*l(2));
s2 = sqrt(1-c2.^2);
theta_2 = atan2(s2,c2);

k = [l(1)+l(2)*c2 l(2)*s2];
theta_1 = atan2(x_temp(:,2),x_temp(:,1)) - atan2(k(:,2),k(:,1));
theta_2 = theta_2 + theta_1;

theta = [theta_1 theta_2];

x_el = [l(1)*cos(theta_1) l(1)*sin(theta_1)];
x_hand = x_el + [l(2)*cos(theta_2) l(2)*sin(theta_2)];
dtheta_1 = [0;diff(theta_1)];
dtheta_2 = [0;diff(theta_2)];
z = [theta_1 theta_2 dtheta_1 dtheta_2];

% xdot = sandercock_param_fit(t,theta,arm_params)
theta0 = [.5 .5 500 500 500 500 .02 .02 .02 .02 23]'; % initial guess - parameters
z0 = z(1,:)';  % state variable

% dummy_ode = @(t,z,p) [-p(1)*z(1) + 4; 
%                 2*z(1) - p(1)*z(2) + 5; 
%                 -4*z(1) - 2*z(2)*z(3) - p(2);
%                 2*p(1)*z(4)- z(2)];

            
Opt = opti('ode',@sandercock_param_fit,'data',tm,z,'z0',z0,'theta0',theta0);
[theta,fval,exitflag,info] = solve(Opt);