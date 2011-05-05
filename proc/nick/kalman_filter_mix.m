function [xmtm,Vmtm, VVmtm, loglik,weight] = kalman_filter_mix(y, A, C, Q, R, init_x, init_V,Pm, varargin)
% Kalman filter.
% [x, V, VV, loglik] = kalman_filter(y, A, C, Q, R, init_x, init_V, ...)
%
% INPUTS:
% y(:,t)   - the observation at time t
% A - the system matrix
% C - the observation matrix
% Q - the system covariance
% R - the observation covariance
% init_x - cell array containing each instance of the initial state (column) vector
% init_V - cell array containing each instance of the initial state covariance
% Pm - prior probability for each instance of init_x

%
% OPTIONAL INPUTS (string/value pairs [default in brackets])
% 'model' - model(t)=m means use params from model m at time t [ones(1,T) ]
%     In this case, all the above matrices take an additional final dimension,
%     i.e., A(:,:,m), C(:,:,m), Q(:,:,m), R(:,:,m).
%     However, init_x and init_V are independent of model(1).
% 'extended' - run extended kalman filter for time warping (default 0)
%'isObserved' - 1 at timepoints where valid observation, 0 if observation
% is to be hidden (default ones(1,T))
%
% OUTPUTS (where X is the hidden state being estimated)
% x(:,t) = E[X(:,t) | y(:,1:t)]
% V(:,:,t) = Cov[X(:,t) | y(:,1:t)]
% VV(:,:,t) = Cov[X(:,t), X(:,t-1) | y(:,1:t)] t >= 2
% loglik = sum{t=1}^T log P(y(:,t))
%
% If an input signal is specified, we also condition on it:
% e.g., x(:,t) = E[X(:,t) | y(:,1:t), u(:, 1:t)]
% If a model sequence is specified, we also condition on it:
% e.g., x(:,t) = E[X(:,t) | y(:,1:t), u(:, 1:t), m(1:t)]

[os T] = size(y);
ss = length(init_x{1}); % size of state space
xmtm = zeros(ss, T);
Vmtm = zeros(ss, ss, T);
VVmtm = zeros(ss,ss,T);
% set default params
model = ones(1,T);
obs = ones(1,T);
extended = 0;

args = varargin;
nargs = length(args);
for i=1:2:nargs
    switch args{i}
        case 'model', model = args{i+1};
        case 'isObserved', obs=double(args{i+1});
        case 'extended', extended = args{i+1};
        case 'ntargets', ntargets = args{i+1};
        otherwise, error(['unrecognized argument ' args{i}])
    end
end
obs(obs==0)= 10000000;
obs(obs==1)=0;
x = cell(length(init_x));
V = cell(length(init_x));
VV = cell(length(init_x));
prevV = cell(length(init_x));
loglik= cell(length(init_x));
weight = zeros(T,length(init_x));
for i = 1:length(init_x)
    x{i} = zeros(ss, T);
    V{i} = zeros(ss, ss, T);
    VV{i} = zeros(ss, ss, T);

    loglik{i} = 0;
end

for t=1:T
    m = model(t);
    if t==1
        prevx = init_x;
        for i = 1:length(prevx)

            prevV{i} =init_V{i};

        end

        initial = 1;
    else
        for i = 1:length(prevx)
            prevx{i} = x{i}(:,t-1);
            prevV{i} = V{i}(:,:,t-1);

        end
        initial = 0;
    end


    toobig=0;
    for i = 1:length(prevx)

        if extended

            [x{i}(:,t), V{i}(:,:,t), LL{i}, VV{i}(:,:,t)] = ...
                extended_kalman_update(A(:,:,m), C(:,:,m), Q(:,:,m), R(:,:,m)+obs(t), y(:,t), prevx{i}, prevV{i}, 'initial', initial,'log',1,'ntargets',ntargets);
        else
            [x{i}(:,t), V{i}(:,:,t), LL{i}, VV{i}(:,:,t)] = ...
                kalman_update(A(:,:,m), C(:,:,m), Q(:,:,m), R(:,:,m)+obs(t), y(:,t), prevx{i}, prevV{i}, 'initial', initial);



        end
        loglik{i} = loglik{i} + LL{i};

        if loglik{i}>700
            toobig=1;
        end



    end

    for i = 1:length(prevx)
        if toobig

            weight(t,i) = Pm(i)*exp(loglik{i}-max(cell2num(loglik)));

        else
            weight(t,i) = Pm(i)*exp(loglik{i});
        end



    end



    if sum(weight(t,:))
        weight(t,:) = weight(t,:)/sum(weight(t,:));
    end

    xmtm(:,t) = 0;
    Vmtm(:,:,t) = 0;
    VVmtm(:,:,t) = 0;
    for i = 1:length(prevx)

        xmtm(:,t) = xmtm(:,t) + weight(t,i)*x{i}(:,t);
        Vmtm(:,:,t) = Vmtm(:,:,t) + weight(t,i)*(V{i}(:,:,t) + x{i}(:,t)*x{i}(:,t)');
        VVmtm(:,:,t) = VVmtm(:,:,t) + weight(t,i)*VV{i}(:,:,t);
    end

end





