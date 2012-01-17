% circ_rho_examples.m
%
% Creates a set of plots showing points of a variety of rho values.

N = 250; % number of points

v = [.05 .2 .5 1 1.5 3];

for i = 1:6
    x = 2*pi*rand(N, 1);
    y = x + v(i).*randn(N,1);

    x = mod(x, 2*pi);
    y = mod(y, 2*pi);

    rho = rho_c(x,y);

    subplot(3,2,i),plot(x,y,'k.');
    axis([0 2*pi 0 2*pi]);
    axis square;
    title(sprintf('%2.2f',rho));
end

suptitle(sprintf('%d Samples', N));


