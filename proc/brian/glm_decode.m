% glm_decode.m 

%% Clear everything except 'bdf'

x = whos;
for i = 1:length(x)
    if ~strcmp(x(i).name, 'bdf')
        clear(x(i).name)
    end
end; 
clear i x

%% Fit the GLM

ts = 100; % Samples (ms) per bin

vt = bdf.vel(:,1);
tidx = 1:length(vt);
tidx = tidx(mod(tidx,ts)==0);
t = vt(tidx);
glmx = bdf.pos(tidx,[2 3]);
glmv = bdf.vel(tidx,[2 3]);

ul = unit_list(bdf);
b = zeros(3,length(ul));

ss = [];

for unit = 1:length(ul)
    spike_times = get_unit(bdf,ul(unit,1),ul(unit,2));
    spike_times = spike_times - ts/2000;
    spike_times = spike_times(spike_times>t(1) & spike_times<t(end));
    s = train2bins(spike_times, t);
    ss = [ss, s'];
    
    b(:,unit) = glmfit(glmv, s, 'poisson');
end

%%

%ss = ss(1:200, :);
rng = 1:100;
s = ss(rng, :);
%x_real = [glmx(rng,:) glmv(rng,:)];
x_real = glmv(rng,:);

%x_guess = randn(1,2*size(s,1))*10;
x_guess = zeros(1,2*size(s,1));

sigma = mean(var(diff(glmv)));
alpha = 50/2/sigma.^2/sqrt(2*pi*sigma.^2);

L = @(x) -sum(sum(s*b'.*[ones(1,length(x)/2); reshape(x,2,[])]')) + ...
    sum(sum(exp(b'*[ones(1,length(x)/2); reshape(x,2,[])]))) + ...
    alpha * sum(sum(diff(reshape(x,2,[])').^2));

options = optimset('MaxFunEvals', 1e8, 'MaxIter', 2e5);
x_readout = fminsearch(L, x_guess, options);

x_readout = reshape(x_readout, 2, []);


%figure; hold on;
%plot(x_readout(1,:),x_readout(2,:),'ko-');
%x_guess = reshape(x_guess,2,[]);
%plot(x_guess(1,:),x_guess(2,:),'ro-');
%plot(x_real(:,1),x_real(:,2),'bo-');

figure;
subplot(2,1,1),plot(1:length(x_real),x_real(:,1), 'kx-', 1:length(x_readout), x_readout(1,:), 'rx-')
subplot(2,1,2),plot(1:length(x_real),x_real(:,2), 'kx-', 1:length(x_readout), x_readout(2,:), 'rx-')
%subplot(4,1,3),plot(1:length(x_real),x_real(:,3), 'kx-', 1:length(x_readout), x_readout(3,:), 'rx-')
%subplot(4,1,4),plot(1:length(x_real),x_real(:,4), 'kx-', 1:length(x_readout), x_readout(4,:), 'rx-')

