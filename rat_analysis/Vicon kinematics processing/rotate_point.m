function rp = rotate_point(X,r,theta)
% cx = [1 0 0]';
% cy = [0 1 0]';
% cz = [0 0 1]';
% 
% x = X(:,1); y = X(:,2); z = X(:,3);
% Rc = [x'*cx x'*cy x'*cz;  y'*cx y'*cy y'*cz; z'*cx z'*cy z'*cz];

Rc = X'*eye(3);

Rx = [1 0 0; 0 cos(theta(1)) -sin(theta(1)); 0 sin(theta(1)) cos(theta(1))];
Ry = [cos(theta(2)) 0 sin(theta(2)); 0 1 0; -sin(theta(2)) 0 cos(theta(2))];
Rz = [cos(theta(3)) -sin(theta(3)) 0; sin(theta(3)) cos(theta(3)) 0; 0 0 1];

rp = Rc'*(Rx*Rc)*r;  % this rotates purely around the x-axis (F/E)
rp = Rc'*(Ry*Rc)*rp;  % this rotates purely around the x-axis (F/E)
rp = Rc'*(Rz*Rc)*rp;  % this rotates purely around the x-axis (F/E)


