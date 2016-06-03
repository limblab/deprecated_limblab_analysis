function [dist, ang] = calc_point2point_dist_ang(x,y,z, ind1, ind2)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

npoints = size(x,2);
nframes = size(x,1);

for ii = 1:nframes
    p1 = [x(ii,ind1) y(ii,ind1)]; % z(ii,ind1)]; 
    p2 = [x(ii,ind2) y(ii,ind2)]; % z(ii,ind2)]; 
    dist(ii) = sqrt(sum((p1-p2).^2));
    p3 = p2-p1;
    ang(ii) = find_angle([1 0],p3);
    
end

ang = ang' - 90;  % positive is in front of the hip, 0 straight below the hip