% Inverse dynamic model ANN fitting

% load('\\citadel\data\TestData\David_EMG\Ricardo_2014-06-12_DCO\Output_Data\bdf')
% load('\\citadel\data\TestData\Ricardo_DCO\Ricardo_2014-06-12_DCO\Output_Data\DCO')
data_folder = '\\citadel\data\TestData\David_EMG';
file_name = 'David_2014-06-18_RW_EMG_001';

% Arm lengths (David)
l = [12 16.5]*.0254;  % [upper_arm lower_arm]
x_sh = [6 -19]*.0254; 

if ~exist([data_folder filesep file_name '.mat'],'file')
    bdf = get_cerebus_data([data_folder filesep file_name '.nev'],'rothandle',1,3);
    save([data_folder filesep file_name],'bdf')
else
    load([data_folder filesep file_name],'bdf')
end
% Subsample
idx = 1:50:size(bdf.pos,1);

emg_data = zeros(length(bdf.pos(:,1)),length(bdf.emg.emgnames));
[b_lp,a_lp] = butter(4,10/(bdf.emg.emgfreq/2));        
[b_hp,a_hp] = butter(4,70/(bdf.emg.emgfreq/2),'high'); 
for iEMG = 1:length(bdf.emg.emgnames)
    emg = double(bdf.emg.data(:,1+iEMG));          
    emg = filtfilt(b_hp,a_hp,emg);
    emg = abs(emg);
    emg = filtfilt(b_lp,a_lp,emg);
%             DCO.emg(iEMG,:) = emg;
    emg_data(:,iEMG) = emg;            
end
        
% Reorder emg_data
emg_data = emg_data(idx,[3 4 1 2]);

% Normalize EMG
emg_norm = emg_data;
% emg_norm = max(emg_norm,0);
% emg_norm = emg_norm./repmat(max(emg_norm),size(emg_norm,1),1);
emg_norm = zscore(emg_norm);
emg_norm = emg_norm - repmat(min(emg_norm),size(emg_norm,1),1);

% Joint angles from endpoint position.
x_off = bytes2float(bdf.databursts{1,2}(7:10));  % ONLY WORKS FOR RW AND CO TASKS
y_off = bytes2float(bdf.databursts{1,2}(11:14));
x = [bdf.pos(idx,2)+repmat(x_off,length(idx),1) bdf.pos(idx,3)+repmat(y_off,length(idx),1)];
x = .01*x;
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




            
