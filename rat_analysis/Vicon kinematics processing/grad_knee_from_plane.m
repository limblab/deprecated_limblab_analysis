function dfx = grad_knee_from_plane(k_pos,points)

x = k_pos;
h = points(1,:);
k = points(2,:);
a = points(3,:);

p = cross(h-k,a-k);  % orthogonal vector
pmag = norm(p);

q = cross(h-x,a-x);
qmag = norm(q);

q1x1 = 0;
q1x2 = h(3) - a(3);
q1x3 = a(2) - h(2); 
q2x1 = h(3) - a(3);
q2x2 = 0;
q2x3 = a(1) - h(1);
q3x1 = h(2) - a(2);
q3x2 = a(1) - h(1);
q3x3 = 0;

k = 4*p*q'/(norm(q)^3);
dfx(1) = (p(1)*q1x1 +p(2)*q2x1 + p(3)*q3x1)/norm(q) + k*(q(1)*q1x1 + q(2)*q2x1 + q(3)*q3x1);
dfx(2) = (p(1)*q1x2 +p(2)*q2x2 + p(3)*q3x2)/norm(q) + k*(q(1)*q1x2 + q(2)*q2x2 + q(3)*q3x2);
dfx(3) = (p(1)*q1x3 +p(2)*q2x3 + p(3)*q3x3)/norm(q) + k*(q(1)*q1x3 + q(2)*q2x3 + q(3)*q3x3);

