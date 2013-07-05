% get_mp
% gets the points for the leg in global coordinates


% first do rotations

a = angles(1);
fm = [sin(a) cos(a); -cos(a) sin(a)]*femoral_points;

a = angles(2);
tb = [sin(a) cos(a); -cos(a) sin(a)]*tibial_points;

a = angles(3);
ft = [sin(a) cos(a); -cos(a) sin(a)]*foot_points;

% then do offsets
%
% Move femur to pelvis
t = pelvic_points(:,1)-fm(:,1);
fm = t*ones(1,6) + fm;

% Move shank to end of femur
t = fm(:,2)-tb(:,1);
tb = t*ones(1,7) + tb;

% Move foot to end of shank
t = tb(:,2)-ft(:,1);
ft = t*ones(1,5) + ft;
cal = t;

mp = [pelvic_points fm tb ft];