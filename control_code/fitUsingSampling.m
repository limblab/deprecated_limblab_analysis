function rcurve = fitUsingSampling(rcurve,vecGood)

% sampling to form recruitment curve
opts.TOOLBOX_HOME=pwd;
addpath(genpath(opts.TOOLBOX_HOME));

tc_func_name = 'sigmoid';
noise_model_name = 'add_normal';

% for ii = 1:size(magForce,2)
%     exp_params = rcurve.sigParams(:,k);
%     % which maps to (see above definition for sigmoid function)
%     params(1) = exp_params(1)*exp_params(2);
%     params(2) = exp_params(1)*(1-exp_params(2));
%     params(3) = exp_params(4)/exp_params(3);
%     params(4) = exp_params(3);
% 
% end
opts.burnin_samples=10000;
opts.num_samples=100000;
opts.sample_period=100;
downsample = 50;
for k = 1:length(vecGood)
    ind2use = vecGood(k);
    % sampled points
    x0 = rcurve.amps(:,ind2use)';
    % how many samples per data point?
    tr = length(rcurve.forceCloud(1,ind2use).fX);
    % let's downsample data, the more data the longer the code takes?
    index = 1:downsample:tr;
    tr = length(index);
    x = reshape(repmat(x0,[tr 1]), [length(x0)*tr 1]);

    % (noisy) observations
    y = zeros(length(x),1);
    cnt = 1;
    for i = 1:length(x0)
        for j = index
            % Force magnitude
            y(cnt) = sqrt( rcurve.forceCloud(i,ind2use).fX(j)^2 + rcurve.forceCloud(i,ind2use).fY(j)^2 );
            cnt = cnt + 1;
        end
    end
    
    % Perform sampling
    S(k) = tc_sample(x,y,tc_func_name,noise_model_name,opts);

    
    x1 = linspace(min(x0),max(x0),1000);
    % Posterior Samples
%     y2=zeros(length(S.P1),length(x1));
    for i=1:length(S(k).P1)
        y2(k).data(i,:)=getTCval(x1,tc_func_name,[S(k).P1(i) S(k).P2(i) S(k).P3(i) S(k).P4(i)])';
    end

    % Store variables in structure
    rcurve.x1(:,k) = x1;
    rcurve.y(:,k) = y;
    rcurve.x(:,k) = x;
end
rcurve.downsample = downsample;
rcurve.opts = opts;
rcurve.y2 = y2;
rcurve.S = S;
rcurve.vecGood = vecGood;