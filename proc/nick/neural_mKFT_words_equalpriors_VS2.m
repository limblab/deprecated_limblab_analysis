tic;

% clear all

trainData = binnedData1;
testData = binnedData2;

if isempty(trainData.targets.corners)
    trainData.targets.corners = VS_corners(trainData,8,8,2);
end

if isempty(testData.targets.corners)
    testData.targets.corners = VS_corners(testData,8,8,2);
end

% x_offset = mean(trainData.cursorposbin(:,1));
% y_offset = mean(trainData.cursorposbin(:,2));
x_offset = 5;
y_offset = 33;


VStargets = [0 8; 0 -8; 8 0; -8 0; 5.657 5.657; 5.657 -5.657; -5.657 5.657; -5.657 -5.657];
VStargets(:,1) = VStargets(:,1) - x_offset;
VStargets(:,2) = VStargets(:,2) - y_offset;

addpath('Kalman');
addpath('KPMstats');
addpath('KPMtools');

% window = 0.500; % in seconds (for spike averaging) should match training
window = 0.100; % in seconds (for spike averaging) should match training
delay = 0.100;

bin = double(trainData.timeframe(2) - trainData.timeframe(1));
window_bins = floor(window/bin);
delay_bins = floor(delay/bin);

%%adjust timing of words and target info to coincide with bins
trainData.words(:,1) = ceil(trainData.words(:,1)./bin).*bin;
trainData.targets.corners(:,1) = ceil(trainData.targets.corners(:,1)./bin).*bin;

%%added to compensate for small variations in timestamps
trainData.words(:,1) = floor(trainData.words(:,1).*100 + 0.1);
trainData.targets.corners(:,1) = floor(trainData.targets.corners(:,1).*100 + 0.1);
trainData.timeframe = floor(trainData.timeframe.*100 + 0.1);

%%extract target times and positions for center and outer targets
trainData.centergoals = zeros(length(find(trainData.words(:,2) == 27)),3); %changed from 48
trainData.centergoals(:,1) = trainData.words(trainData.words(:,2) == 27,1);%changed from 48
trainData.centergoals(:,2) = trainData.centergoals(:,2) - x_offset;
trainData.centergoals(:,3) = trainData.centergoals(:,3) - y_offset;
% trainData.outergoals = zeros(size(trainData.targets.corners,1),3);
trainData.outergoals = repmat(trainData.words([false; false; (trainData.words(3:end-3,2) >= 64 & trainData.words(3:end-3,2) < 80)],1),1,3);
for x = 1:length(trainData.outergoals)
    trainData.outergoals(x,2) = mean(trainData.targets.corners(find(trainData.targets.corners(:,1) == trainData.outergoals(x,1),1,'first'),[2 4]),2) - x_offset;
    trainData.outergoals(x,3) = mean(trainData.targets.corners(find(trainData.targets.corners(:,1) == trainData.outergoals(x,1),1,'first'),[3 5]),2) - y_offset; % include offset
end
trainData.goals = [trainData.centergoals; trainData.outergoals];

%%build training set
training_set = zeros(length(trainData.timeframe),(length(trainData.spikeguide)));

transitions = zeros(length(trainData.timeframe),1);
targets = zeros(length(trainData.timeframe),2);

for x = (window_bins + delay_bins):length(trainData.timeframe)
    training_set(x,:) = mean(trainData.spikeratedata(x-(window_bins + delay_bins-1):x-(delay_bins-1),:));

    if sum(trainData.goals(:,1) == trainData.timeframe(x))
        transitions(x) = 1;
        targets(x,:) = trainData.goals(find(trainData.goals(:,1) == trainData.timeframe(x),1,'first'),2:3);
    end
end

%%separate training data into reaches
startindex = find(transitions);
endindex = [(startindex(2:end) - 1); length(transitions)];

n=0;
for i = 1:length(startindex)
    if (endindex(i) - startindex(i) > 1)
    n=n+1;
    p = trainData.cursorposbin(startindex(i):endindex(i),:);
    v = trainData.velocbin(startindex(i):endindex(i),1:2);
    a = [zeros(1,2); diff(v)];
    targ = repmat(targets(startindex(i),:),length(p),1); % make target new target position
    X{n} = [p v a targ];
    X0{n} = [p v a];
    Z{n} = training_set(startindex(i):endindex(i),:);
    end
end

fprintf('Finished building training set\n')
toc

%%train KF parameters
[A, C, Q, R] = train_kf(X,Z);%%with target
[A0, C0, Q0, R0] = train_kf(X0,Z);%%without target
clear X Z X0 transitions

R = 8.*R;
R0 = 8.*R0;

fprintf('Finished training\n')
toc

%%adjust timing of words and target info to coincide with bins
testData.words(:,1) = ceil(testData.words(:,1)./bin).*bin;
testData.targets.corners(:,1) = ceil(testData.targets.corners(:,1)./bin).*bin;

%%added to compensate for small variations in timestamps
testData.words(:,1) = floor(testData.words(:,1).*100 + 0.1);
testData.targets.corners(:,1) = floor(testData.targets.corners(:,1).*100 + 0.1);
testData.timeframe = floor(testData.timeframe.*100 + 0.1);

%%extract target times and positions for center and outer targets
testData.centergoals = zeros(length(find(testData.words(:,2) == 27)),3); %changed from 48
testData.centergoals(:,1) = testData.words(testData.words(:,2) == 27,1); %changed from 48
testData.centergoals(:,2) = testData.centergoals(:,2) - x_offset;
testData.centergoals(:,3) = testData.centergoals(:,3) - y_offset;
% testData.outergoals = zeros(size(testData.targets.corners,1),3);
testData.outergoals = repmat(testData.words([false; false; (testData.words(3:end-3,2) >= 64 & testData.words(3:end-3,2) < 80)],1),1,3);
for x = 1:length(testData.outergoals)
    testData.outergoals(x,2) = mean(testData.targets.corners(find(testData.targets.corners(:,1) == testData.outergoals(x,1),1,'first'),[2 4]),2) - x_offset;
    testData.outergoals(x,3) = mean(testData.targets.corners(find(testData.targets.corners(:,1) == testData.outergoals(x,1),1,'first'),[3 5]),2) - y_offset; % include offset
end
testData.goals = [testData.centergoals; testData.outergoals];

%%build test set
test_set = zeros(length(testData.timeframe),length(testData.spikeguide));

transitions = zeros(length(testData.timeframe),1);
targets = zeros(length(testData.timeframe),2);

for x = (window_bins + delay_bins):length(testData.timeframe)
    test_set(x,:) = mean(testData.spikeratedata(x-(window_bins + delay_bins-1):x-(delay_bins-1),:));

    if sum(testData.goals(:,1) == testData.timeframe(x))
        transitions(x) = 1;
        targets(x,:) = testData.goals((testData.goals(:,1) == testData.timeframe(x)),2:3);
    end
end

%%separate test data into reaches
startindex = find(transitions);
endindex = [(startindex(2:end) - 1); length(transitions)];

n=0;
for i = 1:length(startindex)
    if (endindex(i) - startindex(i) > 1)
    n=n+1;
    p = testData.cursorposbin(startindex(i):endindex(i),:);
    v = testData.velocbin(startindex(i):endindex(i),1:2);
    a = [zeros(1,2); diff(v)];
    targ = repmat(targets(startindex(i),:),length(p),1); % make target new target position
    X{n} = [p v a targ];
    X0{n} = [p v a];
    Z{n} = test_set(startindex(i):endindex(i),:);
    end
end

fprintf('Finished building test set\n')
toc

%%test KF

priors = [0.125 0.125 0.125 0.125 0.125 0.125 0.125 0.125];

% xpredc=zeros(length(transitions),6);
xpredc=zeros(length(transitions),4); % no accel
xpred0c = xpredc;

clear  xpred Vpred VV loglik weight

for i = 1:length(X)

    if (X{i}(1,7)==-x_offset && X{i}(1,8)==-y_offset)
        target_goals = repmat([-x_offset -y_offset],8,1);
    else
        target_goals = VStargets;
    end
   
    if i == 1
        for j = 1:8
            initx{j} = [X{i}(1,1:6) target_goals(j,:)]'; 
            initV{j} = zeros(length(initx{j}));
        end
        initx0 = X0{i}(1,:)';
        initV0 = zeros(length(initx0));
    else
        for j = 1:8
            initx{j} = [xpred{i-1}(1:end-2,end); target_goals(j,:)'];
            initV{j} = zeros(length(initx{j}));
        end
        initx0 = xpred0{i-1}(:,end);
        initV0 = squeeze(Vpred0{i-1}(:,:,end));
    end
    
    [xpred{i}, Vpred{i}, VV{i}, loglik{i}, weight{i}] = kalman_filter_mix3(Z{i}', A, C, Q, R, initx, initV, priors); %%mixture with target
%     [xpred{i}, Vpred{i}, VV{i}, loglik(i)] = kalman_filter(Z{i}', A, C, Q, R, initx, initV); %%with target
    [xpred0{i}, Vpred0{i}, VV0{i}, loglik0(i)] = kalman_filter(Z{i}', A0, C0, Q0, R0, initx0, initV0); %%without target

%     xpredc(startindex(i):endindex(i),:) = xpred{i}(1:6,:)';
%     xpred0c(startindex(i):endindex(i),:) = xpred0{i}(1:6,:)';
    xpredc(startindex(i):endindex(i),:) = xpred{i}(1:4,:)'; % no accel
    xpred0c(startindex(i):endindex(i),:) = xpred0{i}(1:4,:)'; % no accel
end

fprintf('Finished testing\n')
toc

[r2 vaf mse] = getvaf(testData.cursorposbin([startindex(1):2500 2820:5850],1:2),xpredc([startindex(1):2500 2820:5850],1:2));
[r20 vaf0 mse0] = getvaf(testData.cursorposbin([startindex(1):2500 2820:5850],1:2),xpred0c([startindex(1):2500 2820:5850],1:2));

KF_mVAF = getmvaf(testData.cursorposbin([startindex(1):2500 2820:5850],:),xpred0c([startindex(1):2500 2820:5850],1:2))
KFT_mVAF = getmvaf(testData.cursorposbin([startindex(1):2500 2820:5850],:),xpredc([startindex(1):2500 2820:5850],1:2))

% [r2 vaf mse] = getvaf(testData.cursorposbin(startindex(1):end,1:2),xpredc(startindex(1):end,1:2));
% [r20 vaf0 mse0] = getvaf(testData.cursorposbin(startindex(1):end,1:2),xpred0c(startindex(1):end,1:2));
% 
% KF_mVAF = getmvaf(testData.cursorposbin(startindex(1):end,:),xpred0c(startindex(1):end,1:2))
% KFT_mVAF = getmvaf(testData.cursorposbin(startindex(1):end,:),xpredc(startindex(1):end,1:2))

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
axis([startindex(1)*bin length(testData.cursorposbin)*bin min(xpred0c(startindex(1):end,1)-mean(testData.cursorposbin(startindex(1):end,1))) max(xpred0c(startindex(1):end,1)-mean(testData.cursorposbin(startindex(1):end,1)))])
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
axis([startindex(1)*bin length(testData.cursorposbin)*bin min(xpred0c(startindex(1):end,2)-mean(testData.cursorposbin(startindex(1):end,2))) max(xpred0c(startindex(1):end,2)-mean(testData.cursorposbin(startindex(1):end,2)))])
legend('Real', 'KFT', 'KF', 'Trans')
