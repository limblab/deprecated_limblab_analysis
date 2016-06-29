function y = mycost(x)
global my_ep;
global base_angles;
global segments;
global base_lengths;

angles = x';

% endpoint distance
get_mp;
mtp = mp(:,segments(end,end));
ep_dist = norm(my_ep-mtp)^2;

% muscle length distance
get_lengths;
musc_dist = sum((base_lengths-lengths).^2);

% angle distance
a_dist = sum((base_angles - angles).^2);
y = 10*ep_dist + a_dist;
