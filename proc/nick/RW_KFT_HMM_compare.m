% load(dataFile);

% delayBins???

% enter handle offsets
x_offset = 5; % double check for mini
y_offset = 33; % double check for mini

% to remove potential small timing discrepencies
binnedData.timeframe = round(binnedData.timeframe.*1000)./1000;
binsize = binnedData.timeframe(2) - binnedData.timeframe(1); % in seconds

pos = binnedData.cursorposbin + repmat([x_offset y_offset],length(binnedData.cursorposbin),1);
vel = [0 0; diff(pos)]/binsize;
acc = [0 0; diff(vel)]/binsize;

%% Convert model outputs to matrices

train = binnedData.models.subset == 'Train';
test = binnedData.models.subset == 'Test';

transitions = zeros(length(binnedData.timeframe),3);
for x = 2:length(binnedData.timeframe)

    if binnedData.models.state(x) == 'Residual' && binnedData.models.state(x-1) ~= 'Residual'
        transitions(x,1) = 1;
    elseif binnedData.models.state(x) == 'Movement' && binnedData.models.state(x-1) ~= 'Movement'
        transitions(x,1) = 2;
    elseif binnedData.models.state(x) == 'Hold' && binnedData.models.state(x-1) ~= 'Hold'
        transitions(x,1) = 3;
    end
    
    if binnedData.models.HMM(x) == 'Residual' && binnedData.models.HMM(x-1) ~= 'Residual'
        transitions(x,2) = 1;
    elseif binnedData.models.HMM(x) == 'Movement' && binnedData.models.HMM(x-1) ~= 'Movement'
        transitions(x,2) = 2;
    elseif binnedData.models.HMM(x) == 'Hold' && binnedData.models.HMM(x-1) ~= 'Hold'
        transitions(x,2) = 3;
    end

    if binnedData.models.LDA(x) == 'Residual' && binnedData.models.LDA(x-1) ~= 'Residual'
        transitions(x,3) = 1;
    elseif binnedData.models.LDA(x) == 'Movement' && binnedData.models.LDA(x-1) ~= 'Movement'
        transitions(x,3) = 2;
    elseif binnedData.models.LDA(x) == 'Hold' && binnedData.models.LDA(x-1) ~= 'Hold'
        transitions(x,3) = 3;
    end

end

%% Build goal matrix

trial = 1;
trial_goal = 0;
current_word = 18;
current_word_ts = 0;

goals = zeros(length(binnedData.timeframe),2);
goal_start = false(length(binnedData.timeframe),1);
goal_end = false(length(binnedData.timeframe),1);

for x = find(binnedData.timeframe > binnedData.targets.centers(1,1),1,'first'):length(binnedData.timeframe)
    
    previous_word = current_word;
    previous_word_ts = current_word_ts;
    current_word = binnedData.words(find(binnedData.words(:,1) < binnedData.timeframe(x),1,'last'),2);
    current_word_ts = binnedData.words(find(binnedData.words(:,1) < binnedData.timeframe(x),1,'last'),1);

    if (current_word == 49 || current_word == 160) && (previous_word == 18 || (previous_word == 160 && current_word_ts - previous_word_ts > 1)) % adjust timing as needed
        goal_start(x) = true;
        trial_goal = trial_goal + 1;
        if previous_word == 160;
            goal_end(x-1) = true;
        end
    elseif current_word == 18 && previous_word ~= 18
        trial = trial + 1;
    elseif current_word == 32 && previous_word ~= 32 % need to make work with fail as well as reward
        goal_end(x-1) = true;
        trial_goal = 0;
    end

    if trial_goal == 0
        goals(x,:) = [0 0];
    else
        goals(x,:) = binnedData.targets.centers(trial,2*trial_goal+1:2*trial_goal+2);
    end

end

training_reach_starts = find(goal_start(train));
training_reach_ends = find(goal_end(train));

%% Train filters

numPCs = 75; % adjust number of PCs as needed
PCcoeffs = princomp(binnedData.spikeratedata(train,:));
spikes = binnedData.spikeratedata*(PCcoeffs(1:numPCs,:))';

% KFTstate = [pos vel acc goals];
% KFstate = [pos vel acc];
KFTstate = [pos vel acc ones(length(pos),1) goals];
KFstate = [pos vel acc ones(length(pos),1)];

KFTreach_state = cell(1,length(training_reach_ends));
KFTreach_spikes = cell(1,length(training_reach_ends));
for reach = 1:length(training_reach_ends)
    KFTreach_state{reach} = KFTstate(training_reach_starts(reach):training_reach_ends(reach),:);
    KFTreach_spikes{reach} = spikes(training_reach_starts(reach):training_reach_ends(reach),:);
end

[A_kft, C_kft, Q_kft, R_kft] = train_kf(KFTreach_state, KFTreach_spikes);
[A_kf, C_kf, Q_kf, R_kf] = train_kf(KFstate(train,:), spikes(train,:));

%% Test filters

% KF
KFinitV = cov(KFstate(train,:));
[KFpred_state, V, VV, loglik] = kalman_filter(spikes(test,:)', A_kf, C_kf, Q_kf, R_kf, KFstate(find(test,1,'first'),:)', KFinitV);

for x = 1:size(KFstate,2)
    [KFr2(x) KFvaf(x) KFmse(x)] = getvaf(KFstate(test,x),KFpred_state(x,:)');
end

% KFT with word transitions
class = 2; % use 1 for words, 2 for HMM
transitions_idx = find(transitions(test,class) == 1 | transitions(test,class) == 2) + find(train,1,'last');
test_transitions = transitions(transitions_idx,class);
transition_ts = binnedData.timeframe(transitions_idx);

test_reach_spikes = cell(1,length(test_transitions)-1);
for reach = 1:length(test_transitions)-1
    test_reach_spikes{reach} = spikes(transitions_idx(reach):transitions_idx(reach+1)-1,:);
end

KFTpred_state = KFTstate(find(binnedData.timeframe >= transitions(1,1),1,'first'),:)';
KFTinitV = cov(KFTstate(train,:));
for x = 1:length(test_reach_spikes)
    if test_transitions(x) == 1
        initState = KFTpred_state(1:end-2,end);
        [reach_pred_state, V, VV, loglik] = kalman_filter(test_reach_spikes{x}(:,:)', A_kf, C_kf, Q_kf, 1*R_kf, initState, KFinitV);
        reach_pred_state = [reach_pred_state; zeros(2,size(reach_pred_state,2))];
    elseif test_transitions(x) == 2
        if isempty(find(transitions(transitions_idx(x):end,class) == 3,1,'first'))
            initState = [KFTpred_state(1:end-2,end); goals(transitions_idx(x),:)'];
        else
            initState = [KFTpred_state(1:end-2,end); goals(transitions_idx(x)+find(transitions(transitions_idx(x):end,class) == 3,1,'first'),:)'];
        end
        [reach_pred_state, V, VV, loglik] = kalman_filter(test_reach_spikes{x}(:,:)', A_kft, C_kft, Q_kft, 8*R_kft, initState, KFTinitV);
    end
    KFTpred_state = [KFTpred_state reach_pred_state];
end
KFTpred_state = KFTpred_state(:,2:end);

for x = 1:size(KFTstate,2)
    [KFTr2(x) KFTvaf(x) KFTmse(x)] = getvaf(KFTstate(transitions_idx(1):transitions_idx(end)-1,x),KFTpred_state(x,:)');
end
