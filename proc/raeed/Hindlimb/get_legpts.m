function legpts = get_legpts(base_leg,angles)
% Gets list of points on the leg (muscle attachments and segments)
% Note: inputs are segment angles, not joint angles

% first do rotations

a = angles(1)-base_leg.offset_angles(1);
fm = [sin(a) cos(a); -cos(a) sin(a)]*base_leg.femoral;

a = angles(2)-base_leg.offset_angles(2);
tb = [sin(a) cos(a); -cos(a) sin(a)]*base_leg.tibial;

a = angles(3)-base_leg.offset_angles(3);
ft = [sin(a) cos(a); -cos(a) sin(a)]*base_leg.foot;

% then do offsets
%
% Move femur to pelvis
t = base_leg.pelvic(:,1)-fm(:,1);
fm = t*ones(1,7) + fm;

% Move shank to end of femur
t = fm(:,2)-tb(:,1);
tb = t*ones(1,6) + tb;

% Move foot to end of shank
t = tb(:,2)-ft(:,1);
ft = t*ones(1,5) + ft;

legpts = [base_leg.pelvic fm tb ft];