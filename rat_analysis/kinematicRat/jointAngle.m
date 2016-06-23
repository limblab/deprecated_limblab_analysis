clear all

%% Load data

pathName = '../../../vicondata/160614_files/';
filename = '16061431'; 
path     = [pathName filename '.csv'];

ratName = 'two_spineMJ';
tdmName = '';
ratMks  = {'spine_top','spine_bottom',...
            'hip_top','hip_bottom', ...
            'hip_middle', 'knee', ...
            'heel', 'foot_mid', 'toe'};
tdmMks  = {};

[events,rat,treadmill] = ...
            importViconData(path,ratName,tdmName,ratMks,tdmMks);
         
 %% XY positions       

figure;
subplot(2, 1, 1); 
plot(rat.foot_mid(:, 1))
subplot(2, 1, 2); 
plot(rat.foot_mid(:, 2))


pathName = '../../../vicondata/160614_files/';
filename = '16061432'; 
path     = [pathName filename '.csv'];

ratName = 'two_spineMJ';
tdmName = '';
ratMks  = {'spine_top','spine_bottom',...
            'hip_top','hip_bottom', ...
            'hip_middle', 'knee', ...
            'heel', 'foot_mid', 'toe'};
tdmMks  = {};

[events,rat,treadmill] = ...
            importViconData(path,ratName,tdmName,ratMks,tdmMks);
        
figure;
subplot(2, 1, 1); 
plot(rat.foot_mid(:, 1))
subplot(2, 1, 2); 
plot(rat.foot_mid(:, 2))
        
        
%% Joint angles

rat.knee_ang = computeAngle(rat.hip_middle, rat.knee, rat.heel);
rat.hip_ang  = computeAngle(rat.hip_bottom, rat.hip_middle, rat.knee);
rat.limb_ang = computeAngle(rat.hip_bottom, rat.hip_middle, rat.foot_mid);
rat.ankle_ang = computeAngle(rat.knee, rat.heel, rat.foot_mid); 

rat.knee_ang = 1.01*max(rat.knee_ang) - rat.knee_ang;
rat.ankle_ang = 1.01*max(rat.ankle_ang) - rat.ankle_ang;
% figure; plot(rat.knee_ang); 
% figure; plot(rat.ankle_ang); 
% figure; plot(rat.hip_ang); 
% figure; plot(rat.limb_ang); 

%finding the location to split these
%figure;
%findpeaks(rat.hip_ang,'MinPeakProminence',1)
% figure;
% findpeaks(rat.knee_ang,'MinPeakProminence',18)
% figure;
% findpeaks(rat.ankle_ang,'MinPeakProminence',18)
% figure;
% findpeaks(rat.limb_ang,'MinPeakProminence',5)
%[pks,locs,w,p] = findpeaks(rat.hip_ang,'MinPeakProminence',1); 
locs = [825, 1025]; 

%split into individual steps
hold on;
for i=1:length(locs)-1
    h_ang{i} = rat.hip_ang(locs(i):locs(i+1)); 
    k_ang{i} = rat.knee_ang(locs(i):locs(i+1)); 
    a_ang{i} = rat.ankle_ang(locs(i):locs(i+1)); 
    l_ang{i} = rat.limb_ang(locs(i):locs(i+1)); 
end

angle_cell = {h_ang, k_ang, a_ang, l_ang}; 
lbl = {'hip [deg]', 'knee [deg]', 'ankle [deg]', 'limb [deg]'}; 
%interpolate so steps are the same length and average together
%get the error
% for i=1:length(angle_cell)
%     figure;
%     angle_cell{i}{end+1} = [1:100].'
%     ds = dnsamp(angle_cell{i});
%     m_ds = mean(ds(1:length(angle_cell{i})-1, :));
%     %dev = std(ds(1:length(angle_cell{i})-1, :));
%     plot(ds(1:length(angle_cell{i})-1, :));
%     %shadedErrorBar(1:length(m_ds), m_ds, dev);
%     xlabel('gait cycle [%]')
%     ylabel(lbl{i}); 
% end


%processing thresholds
%DataInv = 1.01*max(rat.ankle_ang) - rat.ankle_ang;
%figure; 
%findpeaks(DataInv, 100,'MinPeakDistance',7)
%findpeaks(DataInv, 'MinPeakProminence',4)
%[pks,locs,w,p] = findpeaks(DataInv, 100,'MinPeakDistance',7)
%plot([0 .2 .4 .6 .8 1.0], p, 'b--o'); xlabel('Current (mA)', 'FontSize',14); ylabel('\Delta Ankle Angle', 'FontSize',14); 

%% Animation

figure(1); 
title('fast');
% Connect markers in a sequence (within a cell)
%{
rat_mat = {rat.hip_top(:,[2,3])    ...
             rat.hip_bottom(:,[2,3]) ...
             rat.hip_middle(:,[2,3]) ...
             rat.knee(:,[2,3])       ...
             rat.heel(:,[2,3])       ...
             rat.foot_mid(:,[2,3]) ...
             rat.toe(:,[2,3]) };
%}

rat_mat = {rat.hip_top    ...
             rat.hip_bottom ...
             rat.hip_middle ...
             rat.knee       ...
             rat.heel       ...
             rat.foot_mid ...
             rat.toe };          

xMin = cell2mat(cellfun(@(x)min(x(:,1)),rat_mat,'UniformOutput', false));
xMin = min(xMin);

xMax = cell2mat(cellfun(@(x)max(x(:,1)),rat_mat,'UniformOutput', false));
xMax = max(xMax);

yMin = cell2mat(cellfun(@(x)min(x(:,2)),rat_mat,'UniformOutput', false));
yMin = min(yMin);

yMax = cell2mat(cellfun(@(x)max(x(:,2)),rat_mat,'UniformOutput', false));
yMax = max(yMax);

axis([xMin xMax yMin yMax])
grid on
hold on

saveGaitMovie( rat_mat , rat.f);

%
pathName = '../../../vicondata/';
filename = '16060310'; 
path     = [pathName filename '.csv'];

ratName = 'two_spineMJ';
tdmName = '';
ratMks  = {'spine_top','spine_bottom',...
            'hip_top','hip_bottom', ...
            'hip_middle', 'knee', ...
            'heel', 'foot_mid', 'toe'};
tdmMks  = {};

[events,rat,treadmill] = ...
            importViconData(path,ratName,tdmName,ratMks,tdmMks);



figure(2);
title('slow');
rat_mat = {rat.hip_top    ...
             rat.hip_bottom ...
             rat.hip_middle ...
             rat.knee       ...
             rat.heel       ...
             rat.foot_mid ...
             rat.toe };          

xMin = cell2mat(cellfun(@(x)min(x(:,1)),rat_mat,'UniformOutput', false));
xMin = min(xMin);

xMax = cell2mat(cellfun(@(x)max(x(:,1)),rat_mat,'UniformOutput', false));
xMax = max(xMax);

yMin = cell2mat(cellfun(@(x)min(x(:,2)),rat_mat,'UniformOutput', false));
yMin = min(yMin);

yMax = cell2mat(cellfun(@(x)max(x(:,2)),rat_mat,'UniformOutput', false));
yMax = max(yMax);

axis([xMin xMax yMin yMax])
grid on
hold on

saveGaitMovie( rat_mat , rat.f);