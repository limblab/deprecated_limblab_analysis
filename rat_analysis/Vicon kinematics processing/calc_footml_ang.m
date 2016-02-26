function [fmlang] = calc_footml_ang(x,y,z,IDS)

PELVIS_TIP = IDS(1);
PELVIS_BASE = IDS(2);
HIP = IDS(3);
KNEE = IDS(4);
ANKLE = IDS(5);
TOE = IDS(6);

v1 = [x(:,PELVIS_TIP) z(:,PELVIS_TIP)] - [x(:,PELVIS_BASE) z(:,PELVIS_BASE)];
v2 = [x(:,ANKLE) z(:,ANKLE)] - [x(:,TOE) z(:,TOE)];
fmlang = find_angle(v1,-v2)*pi/180;
fmlang = atan2(sin(fmlang),cos(fmlang)); 
fmlang = fmlang*180/pi;