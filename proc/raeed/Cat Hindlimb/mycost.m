function y = mycost(x)
global my_ep;
global base_angles;
global pelvic_points femoral_points tibial_points foot_points;

angles = x;

% endpoint distance
get_mp;
mtp = mp(:,17);
ep_dist = norm(my_ep-mtp);

% angle distance
a_dist = sum(abs(base_angles - angles));
y = 10*ep_dist + a_dist;
