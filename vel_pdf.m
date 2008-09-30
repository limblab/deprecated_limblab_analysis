function [pdf x y] = vel_pdf(vel)

k_width = 10; % sigma of gaussian kernel

[x y] = meshgrid(-50:2.5:50, -50:2.5:50);

pdf = zeros(size(x));
tic
for i = 1:size(x,1)
    disp(x(1,i))
    toc
    for j = 1:size(x,2)
        dist = sqrt( (x(i,j)-vel(:,1)).^2 + (y(i,j)-vel(:,2)).^2 );
        pdf(i,j) = sum(normpdf(dist,0,k_width));
    end
end
