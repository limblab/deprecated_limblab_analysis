function KF_KFT_build_compare(dataFile)
% function build_KFT_cellarray(dataFile)
%
% Builds a Kalman Filter and a KFT from a CENTER OUT data file specified in
% DATAFILE.
%
% DATAFILE should be a binnedData file with models field for classification

tic;

% set paths to include necessary functions
if isempty(strfind(path,'Kalman'))
    addpath('Kalman'); % for kalman_filter
    addpath('KPMstats'); % for gaussian_prob in kalman_filter
    addpath('KPMtools'); % for cell2num in kalman_filter_mix
end
if (exist('BMI_analysis','dir') ~= 7)
    load_paths; % for s1_analysis functions
end

numPCs = 75;

% enter handle offsets
x_offset = 0;
y_offset = 33.5;

load(dataFile);

binnedData.transitions = zeros(length(binnedData.timeframe),4);
if binnedData.models.subset(1) == 'Train'
    binnedData.transitions(1,1) = 1;
end

for x = 2:length(binnedData.timeframe)
    if binnedData.models.subset(x) == 'Train'
        binnedData.transitions(x,1) = 1;
    end

    if binnedData.models.state(x) == 'Residual' && binnedData.models.state(x-1) ~= 'Residual'
%         binnedData.transitions(x,2) = 1;
    elseif binnedData.models.state(x) == 'Center target appears--target onset' && binnedData.models.state(x-1) ~= 'Center target appears--target onset'
        binnedData.transitions(x,2) = 2;
    elseif (binnedData.models.state(x) == 'Target onset-cursor moved into outer target' || binnedData.models.state(x) == 'Cursor moved into outer target-Reward') && binnedData.models.state(x-1) ~= 'Target onset-cursor moved into outer target' && binnedData.models.state(x) ~= 'Cursor moved into outer target-Reward'
        binnedData.transitions(x,2) = 3;
    end
    
    if binnedData.models.HMM(x) == 'Residual' && binnedData.models.HMM(x-1) ~= 'Residual'
%         binnedData.transitions(x,3) = 1;
    elseif binnedData.models.HMM(x) == 'Center target appears--target onset' && binnedData.models.HMM(x-1) ~= 'Center target appears--target onset'
        binnedData.transitions(x,3) = 2;
    elseif (binnedData.models.state(x) == 'Target onset-cursor moved into outer target' || binnedData.models.state(x) == 'Cursor moved into outer target-Reward') && binnedData.models.state(x-1) ~= 'Target onset-cursor moved into outer target' && binnedData.models.state(x) ~= 'Cursor moved into outer target-Reward'
        binnedData.transitions(x,3) = 3;
    end
    
    if binnedData.models.LDA(x) == 'Residual' && binnedData.models.LDA(x-1) ~= 'Residual'
%         binnedData.transitions(x,4) = 1;
    elseif binnedData.models.LDA(x) == 'Center target appears--target onset' && binnedData.models.LDA(x-1) ~= 'Center target appears--target onset'
        binnedData.transitions(x,4) = 2;
    elseif (binnedData.models.state(x) == 'Target onset-cursor moved into outer target' || binnedData.models.state(x) == 'Cursor moved into outer target-Reward') && binnedData.models.state(x-1) ~= 'Target onset-cursor moved into outer target' && binnedData.models.state(x) ~= 'Cursor moved into outer target-Reward'
        binnedData.transitions(x,4) = 3;
    end
end

% to remove potential small timing discrepencies
binnedData.timeframe = round(binnedData.timeframe.*1000)./1000;
binsize = binnedData.timeframe(2) - binnedData.timeframe(1); % in seconds

% training data
pos = binnedData.cursorposbin(binnedData.transitions(:,1) == 1,:) + repmat([x_offset y_offset],sum(binnedData.transitions(:,1)),1);
vel = [0 0; diff(pos)]/binsize;
acc = [0 0; diff(vel)]/binsize;
% spikes = sqrt(binnedData.spikeratedata);
% spikes = binnedData.spikeratedata;
% use principal components
PCcoeffs = princomp(binnedData.spikeratedata(binnedData.transitions(:,1) == 1,:));
spikes = binnedData.spikeratedata(binnedData.transitions(:,1) == 1,:)*(PCcoeffs(1:numPCs,:))'; % adjust number of PCs as needed

if isempty(binnedData.targets.corners)
    binnedData.targets.corners = VS_corners(binnedData, 8, 8, 2); % 8 targets, radius = 8, size = 2
end

% adjust timing of words and target info to coincide with bins
binnedData.words(:,1) = round((ceil(binnedData.words(:,1)./binsize).*binsize).*100)./100;
binnedData.targets.corners(:,1) = round((ceil(binnedData.targets.corners(:,1)./binsize).*binsize).*100)./100;

% extract target times and positions for center and outer targets
centergoals = zeros(length(find(binnedData.words(:,2) == 48)),3);
centergoals(:,1) = binnedData.words(binnedData.words(:,2) == 48,1);

outergoals = repmat(binnedData.words([false; false; (binnedData.words(3:end-3,2) >= 64 & binnedData.words(3:end-3,2) < 80)],1),1,3);
for x = 1:length(outergoals)
    outergoals(x,2) = mean(binnedData.targets.corners(find(binnedData.targets.corners(:,1) >= outergoals(x,1),1,'first'),[2 4]),2);
    outergoals(x,3) = mean(binnedData.targets.corners(find(binnedData.targets.corners(:,1) >= outergoals(x,1),1,'first'),[3 5]),2);
end
allgoals = sortrows([centergoals; outergoals],1);
goals = allgoals(allgoals(:,1) < binnedData.timeframe(find(binnedData.transitions(:,1) == 1,1,'last')),:);
startindex = find(binnedData.timeframe == goals(1,1));

targets = zeros(length(pos),2);
goal_index = 0;
for x = startindex:sum(binnedData.transitions(:,1))
    if goal_index < length(goals)
        if binnedData.timeframe(x) == goals(goal_index + 1,1)
            goal_index = goal_index + 1;
        end
    end
    targets(x,:) = goals(goal_index,2:3);
end

% state = [pos vel acc targets];
% kf_state = [pos vel acc];
state = [pos vel acc ones(length(pos),1) targets];
kf_state = [pos vel acc ones(length(pos),1)];

for reach = 1:length(goals)-1
    reach_state{reach} = state((binnedData.timeframe >= goals(reach,1) & binnedData.timeframe < goals(reach+1,1)),:);
    kf_reach_state{reach} = kf_state((binnedData.timeframe >= goals(reach,1) & binnedData.timeframe < goals(reach+1,1)),:);
    reach_spikes{reach} = spikes((binnedData.timeframe >= goals(reach,1) & binnedData.timeframe < goals(reach+1,1)),:);
end

[A_kft, C_kft, Q_kft, R_kft] = train_kf(reach_state, reach_spikes);
[A_kf, C_kf, Q_kf, R_kf] = train_kf(kf_reach_state, reach_spikes);

%% Test and plot predictions

startindex = find(binnedData.transitions(:,1) == 0,1,'first');

pos = binnedData.cursorposbin + repmat([x_offset y_offset],length(binnedData.cursorposbin),1);
vel = [0 0; diff(pos)]/binsize;
acc = [0 0; diff(vel)]/binsize;
% spikes = sqrt(binnedData.spikeratedata);
% spikes = binnedData.spikeratedata;
% use principal components
spikes = binnedData.spikeratedata*(PCcoeffs(1:numPCs,:))'; % same PCs as training
test_state = [pos vel acc];

transitions = [binnedData.timeframe(binnedData.transitions(:,2) ~= 0) binnedData.transitions(binnedData.transitions(:,2) ~= 0,2)]; % column 2 is words
% transitions = [binnedData.timeframe(binnedData.transitions(:,3) ~= 0) binnedData.transitions(binnedData.transitions(:,3) ~= 0,3)]; % column 3 is HMM
transitions = transitions(transitions(:,1) >= binnedData.timeframe(startindex), :);
keep_transition = true(length(transitions),1);
for x = 2:length(transitions)
    if transitions(x,2) == transitions(x-1,2)
        keep_transition(x) = false;
    end
end
transitions = transitions(keep_transition,:);

reach_spikes = cell(1,length(transitions)-1);
for reach = 1:length(transitions)-1
%     reach_state{reach} = state((binnedData.timeframe >= transitions(reach,1) & binnedData.timeframe < transitions(reach+1,1)),:);
    reach_spikes{reach} = spikes((binnedData.timeframe >= transitions(reach,1) & binnedData.timeframe < transitions(reach+1,1)),:);
end

kf_initV = cov(kf_state);
[kf_pred_state, V, VV, loglik] = kalman_filter(spikes(startindex:end,:)', A_kf, C_kf, Q_kf, 1*R_kf, [test_state(startindex,:) 1]', kf_initV);

for x = 1:size(test_state,2)
[kf_r2(x) kf_vaf(x) kf_mse(x)] = getvaf(test_state(startindex:end,x),kf_pred_state(x,:)');
end
kf_vaf

pred_state = [test_state(find(binnedData.timeframe >= transitions(1,1),1,'first'),:) 1 0 0]';
initV = cov(state);

% initV = cov(state(binnedData.transitions(:,1) == 1,:));
% kf_initV = cov(kf_state(binnedData.transitions(:,1) == 1,:));
for x = 1:length(reach_spikes)
    if transitions(x,2) == 1
        initState = pred_state(1:end-2,end);
        [reach_pred_state, V, VV, loglik] = kalman_filter(reach_spikes{x}(:,:)', A_kf, C_kf, Q_kf, 1*R_kf, initState, kf_initV);
        reach_pred_state = [reach_pred_state; zeros(2,size(reach_pred_state,2))];
    elseif transitions(x,2) == 2
        initState = [pred_state(1:end-2,end); 0; 0];
        [reach_pred_state, V, VV, loglik] = kalman_filter(reach_spikes{x}(:,:)', A_kft, C_kft, Q_kft, 1*R_kft, initState, initV);
    elseif transitions(x,2) == 3
        initState = cell(1,8);
        initVcell = cell(1,8);
        for y = 1:8
            initState{y} = [pred_state(1:end-2,end); 8*cos(2*pi/8*y); 8*sin(2*pi/8*y)];
            initVcell{y} = initV;
        end
        [reach_pred_state, V, VV, loglik] = kalman_filter_mix3(reach_spikes{x}(:,:)', A_kft, C_kft, Q_kft, 8*R_kft, initState, initVcell, repmat(1/8,8,1));
    end
    pred_state = [pred_state reach_pred_state];
end
pred_state = pred_state(:,2:end);

for x = 1:size(test_state,2)
    [kft_r2(x) kft_vaf(x) kft_mse(x)] = getvaf(test_state((binnedData.timeframe >= transitions(1,1) & binnedData.timeframe < transitions(end,1)),x),pred_state(x,:)');
end
kft_vaf
[xpr2 xpvaf xpmse] = getvaf(pos((binnedData.timeframe >= transitions(1,1) & binnedData.timeframe < transitions(end,1)),1),pred_state(1,:)');
[ypr2 ypvaf ypmse] = getvaf(pos((binnedData.timeframe >= transitions(1,1) & binnedData.timeframe < transitions(end,1)),2),pred_state(2,:)');
[xvr2 xvvaf xvmse] = getvaf(vel((binnedData.timeframe >= transitions(1,1) & binnedData.timeframe < transitions(end,1)),1),pred_state(3,:)');
[yvr2 yvvaf yvmse] = getvaf(vel((binnedData.timeframe >= transitions(1,1) & binnedData.timeframe < transitions(end,1)),2),pred_state(4,:)');

figure; plot(binsize:binsize:binsize*length(pred_state),vel(startindex:startindex+length(pred_state)-1,1),'k'); hold on; plot(binsize:binsize:binsize*length(pred_state),pred_state(3,:),'r')
title(['x velocity prediction, vaf = ' num2str(xvvaf)])
xlabel('time (s)')
ylabel('velocity (cm/s)')

figure; plot(binsize:binsize:binsize*length(pred_state),vel(startindex:startindex+length(pred_state)-1,2),'k'); hold on; plot(binsize:binsize:binsize*length(pred_state),pred_state(4,:),'r')
title(['y velocity prediction, vaf = ' num2str(yvvaf)])
xlabel('time (s)')
ylabel('velocity (cm/s)')

% figure; plot(binsize:binsize:binsize*length(pred_state),targets(startindex:startindex+length(pred_state)-1,1),'b'); hold on; plot(binsize:binsize:binsize*length(pred_state),pos(startindex:startindex+length(pred_state)-1,1),'k'); plot(binsize:binsize:binsize*length(pred_state),pred_state(1,:),'r');
figure; plot(binsize:binsize:binsize*length(pred_state),pos(startindex:startindex+length(pred_state)-1,1),'k'); hold on; plot(binsize:binsize:binsize*length(pred_state),pred_state(1,:),'r');
title(['x position prediction, vaf = ' num2str(xpvaf)])
xlabel('time (s)')
ylabel('position (cm)')

% figure; plot(binsize:binsize:binsize*length(pred_state),targets(startindex:startindex+length(pred_state)-1,2),'b'); hold on; plot(binsize:binsize:binsize*length(pred_state),pos(startindex:startindex+length(pred_state)-1,2),'k'); plot(binsize:binsize:binsize*length(pred_state),pred_state(2,:),'r')
figure; plot(binsize:binsize:binsize*length(pred_state),pos(startindex:startindex+length(pred_state)-1,2),'k'); hold on; plot(binsize:binsize:binsize*length(pred_state),pred_state(2,:),'r')
title(['y position prediction, vaf = ' num2str(ypvaf)])
xlabel('time (s)')
ylabel('position (cm)')

targets = zeros(length(pos),2);
goal_index = 0;
for x = find(binnedData.timeframe == allgoals(1,1)):length(binnedData.transitions(:,1))
    if goal_index < length(allgoals)
        if binnedData.timeframe(x) == allgoals(goal_index + 1,1)
            goal_index = goal_index + 1;
        end
    end
    targets(x,:) = allgoals(goal_index,2:3);
end

figure; plot(binsize:binsize:binsize*length(pred_state),targets(startindex:startindex+length(pred_state)-1,1),'b'); hold on; plot(binsize:binsize:binsize*length(pred_state),pred_state(8,:),'r');
title('x target estimate')
xlabel('time (s)')
ylabel('position (cm)')

figure; plot(binsize:binsize:binsize*length(pred_state),targets(startindex:startindex+length(pred_state)-1,2),'b'); hold on; plot(binsize:binsize:binsize*length(pred_state),pred_state(9,:),'r')
title('y target estimate')
xlabel('time (s)')
ylabel('position (cm)')