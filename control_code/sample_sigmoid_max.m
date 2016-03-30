% Example code to sample tuning curves from simulated data...

opts.TOOLBOX_HOME=pwd;
addpath(genpath(opts.TOOLBOX_HOME));

%% Create simulated data

% Sigmoidal Example
params = [1 10 0 10];
% y= params(1) + params(2)*(1./(1+exp(-params(4)*(x-params(3)))));
tc_func_name = 'sigmoid';
noise_model_name = 'add_normal';
x0 = linspace(-2,2,10);   % Direction in radians
%x0 = x0(1:end-1);

% V1 Example
% params = [1 4 90 20];
% tc_func_name = 'circular_gaussian_180';
% noise_model_name = 'poisson';
% x0 = linspace(0,179,10);  % Direction in degrees

% number of samples at each point along x0
tr=5;
x=reshape(repmat(x0,[tr 1]), [length(x0)*tr 1]);    
% true function sampled at points, x
v=getTCval(x,tc_func_name,params);
% noisy observations
y=randn(size(v))+v;

clf;
plot(x+randn(size(y))*mean(diff(x0))/10,y,'.k');
hold on
x1 = linspace(min(x0),max(x0),1000);
plot(x1,getTCval(x1,tc_func_name,params),'k')
title('Simulated Data')
xlabel('Direction (Jittered)')
ylabel('Response')
axis tight
hold off

%% load experimental data

tc_func_name = 'sigmoid';
noise_model_name = 'add_normal';

% which muscle?
k = 9;

% recruitment curve data
load rcurve_max

% sig = p(1)*(p(2) + (1-p(2))./(1+exp(-p(3)*x + p(4))));
exp_params = rcurve.sigParams(:,k);
% which maps to (see above definition for sigmoid function)
params(1) = exp_params(1)*exp_params(2);
params(2) = exp_params(1)*(1-exp_params(2));
params(3) = exp_params(4)/exp_params(3);
params(4) = exp_params(3);


% sampled points
x0 = rcurve.amps(:,k)';
% how many samples per data point?
tr = length(rcurve.forceCloud(1,k).fX);
% let's downsample data, the more data the longer the code takes?
index = 1:10:tr;
tr = length(index);
x = reshape(repmat(x0,[tr 1]), [length(x0)*tr 1]);

% (noisy) observations
y = zeros(length(x),1);
cnt = 1;
for i = 1:length(x0)
    for j = index
        
        y(cnt) = sqrt( rcurve.forceCloud(i,k).fX(j)^2 + rcurve.forceCloud(i,k).fY(j)^2 );
        cnt = cnt + 1;
    end
end

figure
plot(x+mean(diff(x0)/20)*randn(size(y)),y,'.')
hold on
plot(x0,rcurve.magForce(:,k),'r.')
title(['Experimental data from recruitment curve of muscle ',num2str(k)])
xlabel('amplitude of stimulus')
ylabel('force magnitude')
axis tight

%% Perform sampling

opts.burnin_samples=10000;
opts.num_samples=50000;
opts.sample_period=50;

S=tc_sample(x,y,tc_func_name,noise_model_name,opts);

%% Plot individual samples, as well as median

clf
x1 = linspace(min(x0),max(x0),1000);
% Posterior Samples
y2=zeros(length(S.P1),length(x1));
for i=1:length(S.P1)
    y2(i,:)=getTCval(x1,tc_func_name,[S.P1(i) S.P2(i) S.P3(i) S.P4(i)])';
end
h0 = plot(x1,y2,'Color',[0.8 0.1 0.1]);
hold on

% Median
y1=getTCval(x1,tc_func_name,[S.P1_median S.P2_median S.P3_median S.P4_median]);
h1 = plot(x1,y1,'k','linewidth',1);
% Data
h2 = plot(x+randn(size(y))*mean(diff(x0))/20,y,'.');
h3 = plot(x0,rcurve.magForce(:,k),'r.');
% Experimental fit used
y3 = getTCval(x1, tc_func_name,params);
h4 = plot(x1,y3,'m','linewidth',2);
xlabel('Direction')
ylabel('Response')
legend([h2; h3; h0(1); h1; h4],{'Samples','Mean','Sample fits','Median fit','Exp Fit'},'Location','NorthWest')
title(['Experimental data from recruitment curve of muscle ',num2str(k)])
xlabel('amplitude of stimulus')
ylabel('force magnitude')
axis tight

figure
subplot(2,2,1)
hist(S.P1,50)
hold on
temp = axis;
line([S.P1_median S.P1_median],[0 temp(4)],'Color','r','linewidth',2)
line([params(1) params(1)],[0 temp(4)],'Color','m','linewidth',2)
title('param 1, samples and experimental value')
%
subplot(2,2,2)
hist(S.P2,50)
hold on
temp = axis;
line([S.P2_median S.P2_median],[0 temp(4)],'Color','r','linewidth',2)
line([params(2) params(2)],[0 temp(4)],'Color','m','linewidth',2)
title('param 2, samples and experimental value')
%
subplot(2,2,3)
hist(S.P3,50)
hold on
temp = axis;
line([S.P3_median S.P3_median],[0 temp(4)],'Color','r','linewidth',2)
line([params(3) params(3)],[0 temp(4)],'Color','m','linewidth',2)
title('param 3, samples and experimental value')
%
subplot(2,2,4)
hist(S.P4,50)
hold on
temp = axis;
line([S.P4_median S.P4_median],[0 temp(4)],'Color','r','linewidth',2)
line([params(4) params(4)],[0 temp(4)],'Color','m','linewidth',2)
title('param 4, samples and experimental value')

%% save data

% samples from posterior
Ysamples = y2;

savefile = ['Muscle',num2str(k),'RecruitFit'];
disp(['saving file : ',savefile])

save(savefile, 'S','Ysamples')
