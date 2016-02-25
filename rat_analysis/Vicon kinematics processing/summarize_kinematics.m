function [summary, out] = summarize_kinematics(cycles,allx,ally,allz,allframes, IDS)
%  IDS should have the indices of the markers for the x,y,z matrices according to the following order:
%  PELVIS TIP, PELVIS BASE, HIP, KNEE, ANKLE, FOOT
%  

PELVIS_TIP = IDS(1);
PELVIS_BASE = IDS(2);
HIP = IDS(3);
KNEE = IDS(4);
ANKLE = IDS(5);
TOE = IDS(6);
N_IDS = [PELVIS_TIP PELVIS_BASE HIP KNEE ANKLE TOE];

[dist,ang] = calc_point2point_dist_ang(allx,ally,allz,HIP,TOE);  % from the hip(3) to the toe(6)
[hip,knee,ankle] = calc_joint_angles(allx,ally,allz,N_IDS);  % in case there's a mixup in the order, let's be clear
[newx, newy, newz] = zero_2_point(allx,ally,allz,3);  % this normalizes everything relative to the hip - only optional
fmlang = calc_footml_ang(allx,ally,allz,N_IDS);

nsamples = diff(cycles')+1; 
NCYCLES = size(cycles,1);

temp = NaN*zeros(max(nsamples),NCYCLES);
out.frames = temp;  out.limb_ang = temp; out.limb_length = temp;
out.toe_x = temp;  out.toe_y = temp; out.toe_z = temp; 
out.toe_relx = temp;  out.toe_rely = temp; out.toe_relz = temp; 
out.hipang = temp; out.kneeang = temp; out.ankleang = temp;
out.foot_mlang = temp;

for ii = 1:NCYCLES
    ind = cycles(ii,1):cycles(ii,2);
    out.frames(1:(nsamples(ii)),ii) = allframes(ind)';
    out.limb_ang(1:(nsamples(ii)),ii) = ang(ind);
    out.limb_length(1:(nsamples(ii)),ii) = dist(ind)';
    out.toe_x(1:(nsamples(ii)),ii) = allx(ind,TOE)';
    out.toe_y(1:(nsamples(ii)),ii) = ally(ind,TOE)';
    out.toe_z(1:(nsamples(ii)),ii) = allz(ind,TOE)';
    out.toe_relx(1:(nsamples(ii)),ii) = newx(ind,TOE)';
    out.toe_rely(1:(nsamples(ii)),ii) = newy(ind,TOE)';
    out.toe_relz(1:(nsamples(ii)),ii) = newz(ind,TOE)';
    out.hipang(1:(nsamples(ii)),ii) = hip(ind)';
    out.kneeang(1:(nsamples(ii)),ii) = knee(ind)';
    out.ankleang(1:(nsamples(ii)),ii) = ankle(ind)';
    out.foot_mlang(1:(nsamples(ii)),ii) = fmlang(ind)';
    out.nsamples(ii) = nsamples(ii);
    
    summary.limb_ang(:,ii) = [max(out.limb_ang(:,ii)) min(out.limb_ang(:,ii))];
    summary.limb_length(:,ii) = [max(out.limb_length(:,ii)) min(out.limb_length(:,ii))];
    summary.step_length(:,ii) = [max(out.toe_x(:,ii)) min(out.toe_x(:,ii))];
    summary.step_height(:,ii) = [max(out.toe_y(:,ii)) min(out.toe_y(:,ii))];
    summary.hip(:,ii) = [max(out.hipang(:,ii)) min(out.hipang(:,ii))];
    summary.knee(:,ii) = [max(out.kneeang(:,ii)) min(out.kneeang(:,ii))];
    summary.ankle(:,ii) = [max(out.ankleang(:,ii)) min(out.ankleang(:,ii))];
end
    
