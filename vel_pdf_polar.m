function [pdf theta rho] = vel_pdf_polar(vel)

% $Id$

k_width = 10; % sigma of gaussian kernel

%[rho theta] = meshgrid(0:.5:50, 0:pi/32:2*pi);
[rho theta] = meshgrid(0:1:50, 0:pi/16:2*pi);
x = rho .* cos(theta);
y = rho .* sin(theta);

pdf = zeros(size(x));
tic
for i = 1:size(x,1)
    %disp(x(1,i))
    %toc
    for j = 1:size(x,2)
        dist = sqrt( (x(i,j)-vel(:,1)).^2 + (y(i,j)-vel(:,2)).^2 );
        pdf(i,j) = sum(normpdf(dist,0,k_width));
    end
end

