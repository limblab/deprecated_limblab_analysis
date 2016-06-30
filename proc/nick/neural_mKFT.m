tic;

% clear all

addpath('Kalman');
addpath('KPMstats');
addpath('KPMtools');

%%load 2 binned data files... call trainData and testData
train_state_col = 1;
test_state_col = 1;

window = 0.500; % in seconds (for spike averaging) should match training

bin = double(trainData.timeframe(2) - trainData.timeframe(1));
window_bins = floor(window/bin);

%%build training set
training_set = zeros(length(trainData.timeframe),(length(trainData.spikeguide)-2)*window_bins); % removed channel 70 for Chewie data
% training_set = zeros(length(trainData.timeframe),length(trainData.spikeguide)*window_bins);

transitions = zeros(length(trainData.timeframe),1);

for x = window_bins:length(trainData.timeframe)
    observation = [];
    for y = 1:window_bins
        observation = [observation trainData.spikeratedata(x-(y-1),1:89) trainData.spikeratedata(x-(y-1),92:97)]; % removed channel 70 for Chewie data
%         observation = [observation trainData.spikeratedata(x-(y-1),:)];
    end
    training_set(x,:) = observation;

    if trainData.states(x,train_state_col) == 1 && trainData.states(x-1,train_state_col) == 0
        transitions(x) = 1;
    end
end

%%separate training data into reaches
startindex = find(transitions);
endindex = [(startindex(2:end) - 1); length(transitions)];

n=0;
for i = 1:length(startindex)
    n=n+1;
    p = trainData.cursorposbin(startindex(i):endindex(i),:);
    v = trainData.velocbin(startindex(i):endindex(i),1:2);
    a = [zeros(1,2); diff(v)];
%     v = [zeros(1,2); diff(p)];
%     a = [zeros(2,2); diff(diff(p))];
    targ = repmat(trainData.cursorposbin(endindex(i),:),length(p),1); % make target average position during posture period
    X{n} = [p v a targ];
    X0{n} = [p v a];
    Z{n} = training_set(startindex(i):endindex(i),:);
end
        
%%train KF parameters
[A, C, Q, R] = train_kf(X,Z);%%with target
[A0, C0, Q0, R0] = train_kf(X0,Z);%%without target
xpredc=zeros(length(transitions),6);
xpred0c = xpredc;
clear X Z X0 transitions

toc

%%build test set
test_set = zeros(length(testData.timeframe),length(testData.spikeguide)*window_bins);

transitions = zeros(length(testData.timeframe),1);

for x = window_bins:length(testData.timeframe)
    observation = [];
    for y = 1:window_bins
        observation = [observation testData.spikeratedata(x-(y-1),:)];
    end
    test_set(x,:) = observation;

    if testData.states(x,test_state_col) == 1 && testData.states(x-1,test_state_col) == 0
        transitions(x) = 1;
    end
end

%%separate test data into reaches
startindex = find(transitions);
endindex = [(startindex(2:end) - 1); length(transitions)];

n=0;
for i = 1:length(startindex)
    n=n+1;
    p = testData.cursorposbin(startindex(i):endindex(i),:);
    v = testData.velocbin(startindex(i):endindex(i),1:2);
    a = [zeros(1,2); diff(v)];
%     v = [zeros(1,2); diff(p)];
%     a = [zeros(2,2); diff(diff(p))];
    targ = repmat(testData.cursorposbin(endindex(i),:),length(p),1); % make target average position during posture period
    X{n} = [p v a targ];
    X0{n} = [p v a];
    Z{n} = test_set(startindex(i):endindex(i),:);
end

%%test KF
for i = 1:length(X)
    if i == 1
        initx = X{i}(1,:)';
        initx0 = X0{i}(1,:)';
        initV = zeros(length(initx));
        initV0 = zeros(length(initx0));
    else
        initx = [xpred{i-1}(1:end-2,end); X{i}(1,end-1:end)'];
        initV = squeeze(Vpred{i-1}(:,:,end));

        initx0 = xpred0{i-1}(:,end);
        initV0 = squeeze(Vpred0{i-1}(:,:,end));
    end
    [xpred{i}, Vpred{i}, VV{i}, loglik(i)] = kalman_filter(Z{i}', A, C, Q, R, initx, initV); %%with target
    [xpred0{i}, Vpred0{i}, VV0{i}, loglik0(i)] = kalman_filter(Z{i}', A0, C0, Q0, R0, initx0, initV0); %%without target

    xpredc(startindex(i):endindex(i),:) = xpred{i}(1:6,:)';
    xpred0c(startindex(i):endindex(i),:) = xpred0{i}(1:6,:)';
end

toc

[r2 vaf mse] = getvaf(testData.cursorposbin(startindex(1):end,1:2),xpredc(startindex(1):end,1:2));
[r20 vaf0 mse0] = getvaf(testData.cursorposbin(startindex(1):end,1:2),xpred0c(startindex(1):end,1:2));

KF_mVAF = getmvaf(testData.cursorposbin(startindex(1):end,:),xpred0c(startindex(1):end,1:2))
KFT_mVAF = getmvaf(testData.cursorposbin(startindex(1):end,:),xpredc(startindex(1):end,1:2))

figure
plot((startindex(1):length(testData.cursorposbin))./bin, testData.cursorposbin(startindex(1):end,1),'k')
hold on
plot((startindex(1):length(testData.cursorposbin))./bin, xpredc(startindex(1):end,1),'g')
plot((startindex(1):length(testData.cursorposbin))./bin, xpred0c(startindex(1):end,1),'r')
title(['x Predictions - KFT VAF = ' num2str(vaf(1)) '; KF VAF = ' num2str(vaf0(1))])
ylabel('Handle Position (cm)')
xlabel('Time (x)')
legend('Real', 'KFT', 'KF')

figure
plot((startindex(1):length(testData.cursorposbin))./bin, testData.cursorposbin(startindex(1):end,2),'k')
hold on
plot((startindex(1):length(testData.cursorposbin))./bin, xpredc(startindex(1):end,2),'g')
plot((startindex(1):length(testData.cursorposbin))./bin, xpred0c(startindex(1):end,2),'r')
title(['y Predictions - KFT VAF = ' num2str(vaf(2)) '; KF VAF = ' num2str(vaf0(2))])
ylabel('Handle Position (cm)')
xlabel('Time (x)')
legend('Real', 'KFT', 'KF')

%%plot with transitions

figure
plot((startindex(1):length(testData.cursorposbin)).*bin, testData.cursorposbin(startindex(1):end,1)-mean(testData.cursorposbin(startindex(1):end,1)),'b')
hold on
plot((startindex(1):length(testData.cursorposbin)).*bin, xpredc(startindex(1):end,1)-mean(testData.cursorposbin(startindex(1):end,1)),'g')
plot((startindex(1):length(testData.cursorposbin)).*bin, xpred0c(startindex(1):end,1)-mean(testData.cursorposbin(startindex(1):end,1)),'r')
plot((startindex(1):length(testData.cursorposbin)).*bin, transitions(startindex(1):end)*20-20,'k*')
title(['x Predictions - KFT VAF = ' num2str(vaf(1)) '; KF VAF = ' num2str(vaf0(1))])
ylabel('Handle Position (cm)')
xlabel('Time (x)')
axis([startindex(1)*bin length(testData.cursorposbin)*bin min(xpred0c(:,1)) max(xpred0c(:,1))])
legend('Real', 'KFT', 'KF', 'Trans')

figure
plot((startindex(1):length(testData.cursorposbin)).*bin, testData.cursorposbin(startindex(1):end,2)-mean(testData.cursorposbin(startindex(1):end,2)),'b')
hold on
plot((startindex(1):length(testData.cursorposbin)).*bin, xpredc(startindex(1):end,2)-mean(testData.cursorposbin(startindex(1):end,2)),'g')
plot((startindex(1):length(testData.cursorposbin)).*bin, xpred0c(startindex(1):end,2)-mean(testData.cursorposbin(startindex(1):end,2)),'r')
plot((startindex(1):length(testData.cursorposbin)).*bin, transitions(startindex(1):end)*20-20,'k*')
title(['y Predictions - KFT VAF = ' num2str(vaf(2)) '; KF VAF = ' num2str(vaf0(2))])
ylabel('Handle Position (cm)')
xlabel('Time (x)')
axis([startindex(1)*bin length(testData.cursorposbin)*bin min(xpred0c(:,1)) max(xpred0c(:,1))])
legend('Real', 'KFT', 'KF', 'Trans')
