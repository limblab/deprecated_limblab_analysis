function [newx, newy, newz] = zero_2_point(x,y,z,p_ind)
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here

nframes = size(x,1);
npoints = size(x,2);
xz = x(:,p_ind);
yz = y(:,p_ind);
zz = z(:,p_ind);

for ii = 1:npoints
    newx(:,ii) = x(:,ii) - xz;
    newy(:,ii) = y(:,ii) - yz;
    newz(:,ii) = z(:,ii) - zz;
end



end

