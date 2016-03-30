function [c, ceq] = link_constr(k_pos,points,real_links)
% points is POINT BY DIM (3 X 3), with each row being a different marker
% position (hip knee ankle)

% find link1 - from hip to k_pos
link1 = sqrt(sum((points(1,:) - k_pos).^2));  % dist from actual hip to new knee position 
link2 = sqrt(sum((points(3,:) - k_pos).^2));  % dist from actual ankle to new knee position 

ceq = [];  % no inequality constraint - this could be a tolerance constraint on the links
c = (link1 - real_links(1))^2 + (link2 - real_links(2))^2 - .1;  % equality constraint on the links
