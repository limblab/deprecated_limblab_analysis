function [xmtm, Vmtm, VVmtm, loglik, weight] = kalman_filter_mix3(y, A, C, Q, R, init_x, init_V, Pm)
% mixture of Kalman filters.
% [x, V, VV, loglik, weight] = kalman_filter(y, A, C, Q, R, Rmult, init_x, init_V, Pm)
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
% OUTPUTS (where X is the hidden state being estimated)
% x(:,t) = E[X(:,t) | y(:,1:t)]
% V(:,:,t) = Cov[X(:,t) | y(:,1:t)]
% VV(:,:,t) = Cov[X(:,t), X(:,t-1) | y(:,1:t)] t >= 2
% loglik = sum{t=1}^T log P(y(:,t))
% weight = Pm*exp(loglik);

[os T] = size(y); % number of neurons

for i = 1:length(init_x)
    ss{i} = length(init_x{i}); % size of state space for each mixture
end

% set default params
xmtm = zeros(ss{end}, T);
Vmtm = zeros(ss{end}, ss{end}, T);
VVmtm = zeros(ss{end},ss{end},T);

x = cell(1,length(init_x));
V = cell(1,length(init_x));
VV = cell(1,length(init_x));
LL = cell(1,length(init_x));
% prevV = cell(1,length(init_x));
loglik = cell(1,length(init_x));
weight = zeros(T,length(init_x));
for i = 1:length(init_x)
    x{i} = zeros(ss{i}, T);
    V{i} = zeros(ss{i}, ss{i}, T);
    VV{i} = zeros(ss{i}, ss{i}, T);
    loglik{i} = 0;
end

for t=1:T

    if t==1
        prevx = init_x;
        prevV = init_V;
%         for i = 1:length(prevx)
%             prevV{i} =init_V{i};
%         end
        initial = 1;
    else
        for i = 1:length(prevx)
            prevx{i} = x{i}(:,t-1);
            prevV{i} = V{i}(:,:,t-1);
        end
        initial = 0;
    end

    toobig = 0;
    for i = 1:length(prevx)

        [x{i}(:,t), V{i}(:,:,t), LL{i}, VV{i}(:,:,t)] = ...
        kalman_update(A, C, Q, R, y(:,t), prevx{i}, prevV{i}, 'initial', initial);

        loglik{i} = loglik{i} + LL{i};
        if abs(loglik{i}) > 700
            toobig = 1;
        end
    end

    for i = 1:length(prevx)
        if toobig
            if loglik{i} < 0
                weight(t,i) = Pm(i)*exp(loglik{i}-min(cell2num(loglik)));
            else
                weight(t,i) = Pm(i)*exp(loglik{i}-max(cell2num(loglik)));
            end
        else
            weight(t,i) = Pm(i)*exp(loglik{i});
        end
    end
    
    if isnan(sum(weight(t,:)))
        if t > 1
            weight(t,:) = weight(t-1,:);
        else
            weight(t,:) = ones(1,size(weight,2))./size(weight,2);
        end
    elseif sum(weight(t,:))
        weight(t,:) = weight(t,:)/sum(weight(t,:));
        if (isnan(sum(weight(t,:))) && t > 1)
            weight(t,:) = weight(t-1,:);
        end
    end

%     xmtm(:,t) = 0;
%     Vmtm(:,:,t) = 0;
%     VVmtm(:,:,t) = 0;
    for i = 1:length(prevx)
        xmtm(:,t) = xmtm(:,t) + weight(t,i)*x{i}(1:ss{end},t);
        Vmtm(:,:,t) = Vmtm(:,:,t) + weight(t,i)*(V{i}(1:ss{end},1:ss{end},t));% + x{i}(1:ss{end},t)*x{i}(1:ss{end},t)');
        VVmtm(:,:,t) = VVmtm(:,:,t) + weight(t,i)*VV{i}(1:ss{end},1:ss{end},t);
    end

end





