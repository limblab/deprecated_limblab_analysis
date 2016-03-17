function allerr = eval_axis(para,markers)

origin = para(1:3)';
direction = para(4:5);

nmarkers = length(markers);
for ii = 1:nmarkers
    [on,perp] = proj_marker(origin,direction,markers{ii});
    err(ii) = var(on)*length(on) + var(perp)*length(perp);
end

ang = direction; p1 = origin;
ax_vector = [cos(ang(2))*cos(ang(1)) cos(ang(2))*sin(ang(1)) sin(ang(2))]';
x = ax_vector;
x = x/norm(x);
y = [0 x(3) -x(2)]';
y = y/norm(y);
z = cross(x,y);
z = z/norm(z);
X = [x y z];

theta = find_x_rotation(X,markers{1},p1);
allerr = sum(err);
disp(allerr)    
    