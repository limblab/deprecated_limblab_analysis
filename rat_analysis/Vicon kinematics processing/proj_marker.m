function [onax,perp] = proj_marker(origin,direction,marker)

p1 = origin;  % origin of the axis
ang = direction;   % direction (azimuth, elevation) of the axis

% here's the axis vector unit vector
ax_vector = [cos(ang(2))*cos(ang(1)) cos(ang(2))*sin(ang(1)) sin(ang(2))]';

% now find the nearest point on the axis for a given marker

npoints = size(marker,1);

% x = ax_vector;
% plot3([p1(1) x(1)],[p1(2) x(2)],[p1(3) x(3)],'r')
% hold on
% plot3([p1(1) y(1)],[p1(2) y(2)],[p1(3) y(3)],'b')
% plot3([p1(1) z(1)],[p1(2) z(2)],[p1(3) z(3)],'g')

for ii = 1:npoints
    markerp = marker(ii,:)' - p1;  % the vector from the axis origin (arbitrary) to the marker
    proj = markerp'*ax_vector;  % the projection of the marker along the axis
    markeronaxis = proj*ax_vector + p1;  % the vector along the axis
    markerinplane = marker(ii,:)' - markeronaxis;
    onax(ii) = norm(markeronaxis);
    perp(ii) = norm(markerinplane);
    
%     markerp = marker - p1;  % the vector from the axis origin (arbitrary) to the marker
% proj = markerp'*(ax_vector);  % the projection of the marker along the axis
% markeronaxis = proj*(ax_vector)+p1;  % the vector along the axis
% markerinplane = marker-markeronaxis;

    
    
%     plot3(markerp(1),markerp(2),markerp(3),'r.');
%     
%     plot3([p1(1) markeronaxis(1)],[p1(2) markeronaxis(2)],[p1(3) markeronaxis(3)],'m')
%     plot3([markeronaxis(1) markeronaxis(1)+markerinplane(1)],[markeronaxis(2) markeronaxis(2)+markerinplane(2)],[markeronaxis(3) markeronaxis(3)+markerinplane(3)],'k')
end

%     axis('equal')
%     grid
% 
% hold off

ii;
