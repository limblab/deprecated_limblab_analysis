% Inverse dynamic model ANN fitting

load('\\citadel\data\TestData\Ricardo_DCO\Ricardo_2014-06-12_DCO\Output_Data\bdf')
load('\\citadel\data\TestData\Ricardo_DCO\Ricardo_2014-06-12_DCO\Output_Data\DCO')

% Subsample
idx = 1:50:size(bdf.pos,1);

% Reorder emg_data
emg_data = DCO.emg';
emg_data = emg_data(idx,[3 4 1 2]);

% Normalize EMG
emg_norm = emg_data;
% emg_norm = max(emg_norm,0);
% emg_norm = emg_norm./repmat(max(emg_norm),size(emg_norm,1),1);
emg_norm = zscore(emg_norm);
emg_norm = emg_norm - repmat(min(emg_norm),size(emg_norm,1),1);

% Arm lengths
l = [.4 .35];

% Joint angles from endpoint position.
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
x_el = [l(1)*cos(theta_1) l(1)*sin(theta_1)];
x_hand = x_el + [l(2)*cos(theta_2) l(2)*sin(theta_2)];
theta = [theta_1 theta_2];

% Fit ANN
% input = theta
% output = emg_norm




            
