function [newx,newy,newz] = rotate_markers(x,y,z, FRAME, LEG)

% get the points that are on the front plate of the plexiglass
plate_x = mean(x(:,FRAME));
plate_y = mean(y(:,FRAME));
plate_z = mean(z(:,FRAME));
% assemble them all into a matrix
temp = [plate_x; plate_y; plate_z];
% make the last one in the line be the origin
origin = temp(:,2);
temp = temp - repmat(origin,1,4);

% define the line of three markers to be the first unit vector
unit1 = -temp(:,3)/norm(temp(:,3));
p1 = temp(:,1)'*unit1;  % project the point off the line onto the line
u2 = p1*unit1 - temp(:,1);  % subtract the two vectors
unit2 = u2/norm(u2);  % this is the second unit vector
unit3 = cross(unit1,unit2);  % find the third unit vector by the cross product

% % plot the results to confirm (scale the unit vectors so they're visible
% plot3(temp(1,:),temp(2,:),temp(3,:),'o-')
% axis('equal')
% grid
% hold on
% quiver3(0,0,0,50*unit1(1),50*unit1(2),50*unit1(3),'r')
% quiver3(0,0,0,50*unit2(1),50*unit2(2),50*unit2(3),'g')
% quiver3(0,0,0,50*unit3(1),50*unit3(2),50*unit3(3),'k')

% now rotate all the points into this new coordinate frame
newframe = [unit1 unit2 unit3];
% newframe = eye(size(newframe));

nframes = size(x,1);  % the number of frames in this capture
npoints = length(LEG);  % 6 markers on the leg
for ii = 1:npoints
    temp = [x(:,LEG(ii)) y(:,LEG(ii)) z(:,LEG(ii))];
    temp2 = newframe'*(temp - repmat(origin',nframes,1))';
    newx(:,ii) = temp2(1,:);
    newy(:,ii) = temp2(2,:);
    newz(:,ii) = temp2(3,:);
end

% [x2, y2,z2] = edit_markers(new_x,new_z,new_z);
% [x2, y2,z2] = edit_markers(new_x,-new_y,new_z);
