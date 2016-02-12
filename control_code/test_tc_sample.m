% Example code to sample tuning curves from simulated data...

opts.TOOLBOX_HOME=pwd;
addpath(genpath(opts.TOOLBOX_HOME));

%% Create simulated data

% M1 Example
params = [20 10 pi+pi/180*20 1];
tc_func_name = 'positiveCosine';
noise_model_name = 'poisson';
x0 = linspace(0,2*pi,9);   % Direction in radians
x0 = x0(1:end-1);

% V1 Example
% params = [1 4 90 20];
% tc_func_name = 'circular_gaussian_180';
% noise_model_name = 'poisson';
% x0 = linspace(0,179,10);  % Direction in degrees

tr=5;
x=reshape(repmat(x0,[tr 1]), [length(x0)*tr 1]);    
v=getTCval(x,tc_func_name,params);
y=poissrnd(v);

clf;
plot(x+randn(size(y))*mean(diff(x0))/10,y,'.k');
hold on
x1 = linspace(0,2*pi,1000);
plot(x1,getTCval(x1,tc_func_name,params),'k')
title('Simulated Data')
xlabel('Direction (Jittered)')
ylabel('Response')
axis tight
hold off

%% Perform sampling

opts.burnin_samples=10000;
opts.num_samples=20000;
opts.sample_period=50;

S=tc_sample(x,y,tc_func_name,noise_model_name,opts);

%% Plot individual samples, as well as median

clf

% Posterior Samples
y2=zeros(length(S.P1),length(x1));
for i=1:length(S.P1)
    y2(i,:)=getTCval(x1,tc_func_name,[S.P1(i) S.P2(i) S.P3(i) S.P4(i)])';
end
h0 = plot(x1,y2,'Color',[0.8 0.1 0.1]);
hold on

% Median
y1=getTCval(x1,tc_func_name,[S.P1_median S.P2_median S.P3_median S.P4_median]);
h1 = plot(x1,y1,'r','linewidth',3);
% Data
h2 = plot(x+randn(size(y))*mean(diff(x0))/10,y,'.k');
% True TC
y1=getTCval(x1,tc_func_name,params);
h3 = plot(x1,y1,'k','linewidth',3);
xlabel('Direction')
ylabel('Response')
legend([h0(1); h1; h3],{'Samples','Median','True'})
hold off
axis tight
title('Posterior Samples')