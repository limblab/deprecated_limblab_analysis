function plot_ellipse(mu,cov,val)
%   PLOT_ELLIPSE
%       plots in figure 12345 the ellipse defined by
%       (x-mu)'*cov^(-1)*(x-mu) = val^2
%       
%       Note: mu must be two dimensional column vector, cov must be 2x2
%       matrix, val must be scalar.

figure(12345)
clf

% get parameter to plot
theta = linspace(0,2*pi,200);

% set x_prime = (x-mu)
x_prime = [cos(theta); sin(theta)];
%x = x_prime + mu;

basis_mat = cov;

plot(val*basis_mat(1,:)*x_prime+mu(1),val*basis_mat(2,:)*x_prime+mu(2))
hold on
plot(linspace(0,1,200)*mu(1),linspace(0,1,200)*mu(2))