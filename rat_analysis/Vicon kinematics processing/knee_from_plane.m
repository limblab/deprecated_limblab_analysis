function [fx, dfx] = knee_from_plane(k_pos,points)

% find the orthogonal to the plane defined by the hip, knee, ankle
v1 = points(1,:) - points(2,:);  % vector from knee to hip
v2 = points(3,:) - points(2,:);  % vector from knee to ankle

v_orth = cross(v1,v2);  % orthogonal vector

% now do the same to the estimated knee
v1 = points(1,:) - k_pos;  % vector from knee to hip
v2 = points(3,:) - k_pos;  % vector from knee to ankle

v_orth_est = cross(v1,v2);

v1 = v_orth;
v2 = v_orth_est;
proj = (v1*v2')/(norm(v1)*norm(v2));
ang = acos(proj);  % find the angle between the two vectors

dist = sqrt(sum((points(2,:) - k_pos).^2));
fx = 1-proj; %+.1*dist;
% ang = ang + 0*dist/10;

dfx = grad_knee_from_plane(k_pos,points);
