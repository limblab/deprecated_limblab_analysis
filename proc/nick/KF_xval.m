addpath('Kalman');
addpath('KPMstats');
addpath('KPMtools');

% Load a binnedData file

cutoff = round(length(binnedData.timeframe)*.8); % determine cutoff point for train and test sets
binsize = binnedData.timeframe(2) - binnedData.timeframe(1);

train_pos = binnedData.cursorposbin(1:cutoff,:);
train_vel = [0 0; diff(train_pos)]/binsize;
train_acc = [0 0; diff(train_vel)]/binsize;
train_spikes = binnedData.spikeratedata(1:cutoff,:);

test_pos = binnedData.cursorposbin(cutoff+1:end,:);
test_vel = [0 0; diff(test_pos)]/binsize;
test_acc = [0 0; diff(test_vel)]/binsize;
test_spikes = binnedData.spikeratedata(cutoff+1:end,:);

state = [train_pos train_vel train_acc ones(length(train_pos),1)];

for delay = 0:5

[A, C, Q, R] = train_kf(state(delay+1:end,:), train_spikes(1:end-delay,:));

% test predictions

[pred_state, V, VV, loglik] = kalman_filter(test_spikes(1:end-delay,:)', A, C, Q, R, zeros(size(state,2),1), zeros(size(state,2)));

[xr2 xvaf xmse] = getvaf(test_vel(delay+1:end,1),pred_state(3,:)');
[yr2 yvaf ymse] = getvaf(test_vel(delay+1:end,2),pred_state(4,:)');

figure; plot(binsize:binsize:binsize*length(pred_state),test_vel(delay+1:end,1),'k'); hold on; plot(binsize:binsize:binsize*length(pred_state),pred_state(3,:),'r')
title(['x velocity prediction, delay = ' num2str(delay) ' vaf = ' num2str(xvaf)])
xlabel('time (s)')
ylabel('velocity (cm/s)')

figure; plot(binsize:binsize:binsize*length(pred_state),test_vel(delay+1:end,2),'k'); hold on; plot(binsize:binsize:binsize*length(pred_state),pred_state(4,:),'r')
title(['y velocity prediction, delay = ' num2str(delay) ' vaf = ' num2str(yvaf)])
xlabel('time (s)')
ylabel('velocity (cm/s)')

end

% clear pos vel acc state H P T patch filter x V VV loglik xr2 xvaf xmse yr2 yvaf ymse;

% save 'filter_name';