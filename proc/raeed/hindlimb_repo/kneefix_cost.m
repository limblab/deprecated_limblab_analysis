function y = kneefix_cost(x)
global my_ep;
global base_angles;
global pelvic_points femoral_points tibial_points foot_points;

%angles = [x(1) x(2) x(2)+pi/2];
angles = x;

% endpoint distance
get_mp;
mtp = mp(:,17);
ep_dist = norm(my_ep-mtp);

%y = ep_dist;
knee_dist = (base_angles(2) - angles(2))^2;
y = 10*ep_dist + 50*knee_dist;
%y = 3*ep_dist + -.5*norm(mp(:,16) - mp(:,1)); + a_dist;
