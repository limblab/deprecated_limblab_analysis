function [hip, knee, ankle] = calc_joint_angles(x,y,z,IDS)
%  IDS should have the indices of the markers for the x,y,z matrices according to the following order:
%  PELVIS TIP, PELVIS BASE, HIP, KNEE, ANKLE, FOOT
%  

PELVIS_TIP = IDS(1);
PELVIS_BASE = IDS(2);
HIP = IDS(3);
KNEE = IDS(4);
ANKLE = IDS(5);
TOE = IDS(6);

v1 = [x(:,HIP) y(:,HIP)] - [x(:,KNEE) y(:,KNEE)];
v2 = [x(:,ANKLE) y(:,ANKLE)] - [x(:,KNEE) y(:,KNEE)];
knee = find_angle(v1,v2);

v1 = [x(:,KNEE) y(:,KNEE)] - [x(:,ANKLE) y(:,ANKLE)];
v2 = [x(:,TOE) y(:,TOE)] - [x(:,ANKLE) y(:,ANKLE)];
ankle = find_angle(v1,v2);
% ankle = unwrap(ankle*pi/180);
ankle = -ankle;

v1 = [x(:,PELVIS_TIP) y(:,PELVIS_TIP)] - [x(:,HIP) y(:,HIP)];
v2 = [x(:,KNEE) y(:,KNEE)] - [x(:,HIP) y(:,HIP)];
hip = find_angle(v1,v2);
hip = -hip;
