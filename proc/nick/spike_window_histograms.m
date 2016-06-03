% start by loading a binnedData file into the workspace

win_start = -0.3; % lag in sec
win_length = 0.2; % in sec

win_start = round(win_start/-(binnedData.timeframe(2)-binnedData.timeframe(1))); % convert to bins
win_length = round(win_length/(binnedData.timeframe(2)-binnedData.timeframe(1))); % convert to bins

spike_wins = zeros(size(binnedData.spikeratedata));
spike_wins2 = zeros(size(binnedData.spikeratedata));
spike_wins3 = zeros(size(binnedData.spikeratedata));

% count spikes in designated window for each channel
for x = win_start+1:length(spike_wins)
    spike_wins(x,:) = sum(binnedData.spikeratedata(x-win_start:x-win_start+win_length-1,:),1);
end

for x = win_start+1:length(spike_wins)
    spike_wins2(x,:) = sum(binnedData.spikeratedata(x-win_start:x-win_start+win_length,:),1);
end

for x = win_start+1:length(spike_wins)
    spike_wins3(x,:) = sum(binnedData.spikeratedata(x-win_start:x-win_start+win_length+1,:),1);
end

% plot spike histograms for each channel
for x=1:size(spike_wins,2)
    figure
    
    subplot(2,3,1)
    hist(spike_wins(binnedData.states(:,1),x),0:20:400)
    axis([-50 500 0 sum(binnedData.states(:,1))/3])
    title(binnedData.spikeguide(x,:))
    ylabel('movement')
    
    subplot(2,3,4)
    hist(spike_wins(~binnedData.states(:,1),x),0:20:400)
    axis([-50 500 0 (length(binnedData.states(:,1))-sum(binnedData.states(:,1)))/3])
    ylabel('posture')
    xlabel('windowed spike counts')
    
    
    subplot(2,3,2)
    hist(spike_wins2(binnedData.states(:,1),x),0:20:400)
    axis([-50 500 0 sum(binnedData.states(:,1))/3])
    title(binnedData.spikeguide(x,:))
    ylabel('movement')
    
    subplot(2,3,5)
    hist(spike_wins2(~binnedData.states(:,1),x),0:20:400)
    axis([-50 500 0 (length(binnedData.states(:,1))-sum(binnedData.states(:,1)))/3])
    ylabel('posture')
    xlabel('windowed spike counts')
    
    
    subplot(2,3,3)
    hist(spike_wins3(binnedData.states(:,1),x),0:20:400)
    axis([-50 500 0 sum(binnedData.states(:,1))/3])
    title(binnedData.spikeguide(x,:))
    ylabel('movement')
    
    subplot(2,3,6)
    hist(spike_wins3(~binnedData.states(:,1),x),0:20:400)
    axis([-50 500 0 (length(binnedData.states(:,1))-sum(binnedData.states(:,1)))/3])
    ylabel('posture')
    xlabel('windowed spike counts')

end