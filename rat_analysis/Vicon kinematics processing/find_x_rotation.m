function theta = find_x_rotation(X,r,origin)
% cx = [1 0 0]';
% cy = [0 1 0]';
% cz = [0 0 1]';
% 
% x = X(:,1); y = X(:,2); z = X(:,3);
% Rc = [x'*cx x'*cy x'*cz;  y'*cx y'*cy y'*cz; z'*cx z'*cy z'*cz];

Rc = X'*eye(3);

npoints = size(r,1);
for ii = 1:npoints
    rp = Rc*(r(ii,:)' - origin);  % rotate it to the cartesian frame
    theta(ii) = atan2(rp(3),rp(2));
end