function [pxyang,pmlang,fxyang,fmlang,fxyrelang,fmlrelang] = calc_pelvis_foot_angles(x,y,z,IDS)
%  IDS should have the indices of the markers for the x,y,z matrices according to the following order:
%  PELVIS TIP, PELVIS BASE, HIP, KNEE, ANKLE, FOOT
%  

PELVIS_TIP = IDS(1);
PELVIS_BASE = IDS(2);
HIP = IDS(3);
KNEE = IDS(4);
ANKLE = IDS(5);
TOE = IDS(6);
rad2ang = 180/pi;

% find angle of pelvis relative to the treadmill in sagittal plane
v1 = [x(:,PELVIS_TIP) y(:,PELVIS_TIP)] - [x(:,PELVIS_BASE) y(:,PELVIS_BASE)];
v2 = [0 0] - [1 0];  % define horizontal to be zero degrees
pxyang = find_angle(v1,v2)*rad2ang;  %pelvis_saggital_angle

% find angle of the pelvis relative to the treadmill in ML plane
v1 = [y(:,PELVIS_TIP) z(:,PELVIS_TIP)] - [y(:,PELVIS_BASE) z(:,PELVIS_BASE)];
v2 = [0 0] - [0 1];  % define straight forward to be zero degrees
pmlang = find_angle(v1,v2)*rad2ang;  %pelvis_ML_angle

% find angle of the foot relative to the treadmill in the saggital plane
v1 = [x(:,ANKLE) y(:,ANKLE)] - [x(:,TOE) y(:,TOE)];
v2 = [0 0] - [1 0];  % define horizontal to be zero degrees
fxyang = find_angle(v1,v2)*rad2ang;  %foot_saggital_angle 

% find the angle of the foot relative to the treadmill in the ML plane
v1 = [y(:,ANKLE) z(:,ANKLE)] - [y(:,TOE) z(:,TOE)];
v2 = [0 0] - [0 1];  % define straight forward to be zero degrees
fmlang = find_angle(v1,v2)*rad2ang;  %foot_ML_angle

% find the angle of the foot relative to the pelvis in the saggital plane
v1 = [x(:,ANKLE) y(:,ANKLE)] - [x(:,TOE) y(:,TOE)];
v2 = [x(:,PELVIS_TIP) y(:,PELVIS_TIP)] - [x(:,PELVIS_BASE) y(:,PELVIS_BASE)];
fxyrelang = find_angle(v1,v2)*rad2ang;  %foot_saggital_relative_angle

% find the angle of the foot relative to the pelvis in the ML plane
v1 = [y(:,ANKLE) z(:,ANKLE)] - [y(:,TOE) z(:,TOE)];
v2 = [y(:,PELVIS_TIP) z(:,PELVIS_TIP)] - [y(:,PELVIS_BASE) z(:,PELVIS_BASE)];
fmlrelang = find_angle(v1,v2)*rad2ang;  %foot_ML_relative_angle 

