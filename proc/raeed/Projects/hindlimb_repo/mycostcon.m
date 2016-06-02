function y = mycostcon(x)
global my_ep;
global base_angles;
global pelvic_points femoral_points tibial_points foot_points;

%angles = [x(1) x(2) x(2)+pi/2];
angles = x;

con_angles = base_angles;

% endpoint distance
get_mp;
mtp = mp(:,17);
ep_dist = norm(my_ep-mtp)^2;

%y = ep_dist;
% a_dist = sum(abs(con_angles - angles));
% k_dist = (3*pi/8 - abs(x(2)-x(3)))^2;
% y = 10*ep_dist + 10*k_dist + a_dist;
%y = 3*ep_dist + -.5*norm(mp(:,16) - mp(:,1)); + a_dist;
y = 10*ep_dist;
