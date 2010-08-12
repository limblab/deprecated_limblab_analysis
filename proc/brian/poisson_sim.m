% poisson_sim.m

point = [5 8];
%baseline = 10;
%gain = 10;

%pds = [repmat(0, 1, 5) repmat(pi/2, 1, 5)];
pds = 0:pi/99:pi/2;
pdcomps = [cos(pds); sin(pds)];
num_cells = size(pds,2);

%[x y] = meshgrid(0:1:50, 0:1:50);
x = point(1); y = point(2);

L = ones(size(x));

lambda = 30; %baseline + point*pdcomps*gain;

num_reps = 100;
states = zeros(num_cells, num_reps);

options = optimset('LargeScale', 'off', 'Display', 'off');

%pp = zeros(size(x));
xpoints = zeros(num_reps,2);
for rep = 1:num_reps
    n = zeros(size(pds));
    for cell = 1:num_cells;
        %%% L Fitting
        lambda = point*pdcomps(:,cell);
        n(cell) = random('poiss', x*pdcomps(1,cell) + y*pdcomps(2,cell), 1, 1);

        %%% Point Cloud Fitting
        %lambda = point*pdcomps(:,cell);
        %states(cell, :) = random('poiss', lambda, 1, num_reps);
    end

    L = @(x) -poisll(x, pds, n);
    xopt = fmincon(L, [1 1], -eye(2), [0 0], ...
        [], [], [], [], [], options);
    xpoints(rep,:) = xopt;
end

c = cov(xpoints)

%figure; hold on;
%surf(x,y,pp);
%plot(x, pp, 'ko-');
%plot(x, log(p), 'ro-');

% x = zeros(1,num_reps); y = zeros(1,num_reps);
% for itr = 1:num_reps
%     x(itr) = mean(states(:,itr)'.*cos(pds));
%     y(itr) = mean(states(:,itr)'.*sin(pds));
% end
%     
% figure;
% plot(x,y,'rx'); 
% axis([0 50 0 50])

    
    