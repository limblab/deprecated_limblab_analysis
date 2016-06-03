% start by loading a classified binnedData file AND classified BCbinnedData file into the workspace

win_start_sec = -0.3; % lag in sec
win_length_sec = 0.3; % in sec
% win_start_sec = -0.5; % lag in sec
% win_length_sec = 0.5; % in sec

win_start = round(win_start_sec/-(binnedData.timeframe(2)-binnedData.timeframe(1))); % convert to bins
win_length = round(win_length_sec/(binnedData.timeframe(2)-binnedData.timeframe(1))); % convert to bins

BCwin_start = round(win_start_sec/-(BCbinnedData.timeframe(2)-BCbinnedData.timeframe(1))); % convert to bins
BCwin_length = round(win_length_sec/(BCbinnedData.timeframe(2)-BCbinnedData.timeframe(1))); % convert to bins

spike_wins = zeros(size(binnedData.spikeratedata));
BCspike_wins = zeros(size(BCbinnedData.spikeratedata));

% count spikes in designated window for each channel
for x = win_start+1:length(spike_wins)
    spike_wins(x,:) = mean(binnedData.spikeratedata(x-win_start:x-win_start+win_length-1,:),1);
end

for x = BCwin_start+1:length(BCspike_wins)
    BCspike_wins(x,:) = mean(BCbinnedData.spikeratedata(x-BCwin_start:x-BCwin_start+BCwin_length-1,:),1);
end

% plot spike histograms for each channel
for x=1:size(spike_wins,2)
    figure
    
    subplot(2,2,1)
    hist(spike_wins(binnedData.states(:,1),x),0:20/win_length:100)
    axis([0 100 0 sum(binnedData.states(:,1))/3])
    title(binnedData.spikeguide(x,:))
    ylabel('normal movement')
    legend(['mean = ' num2str(round(mean(spike_wins(binnedData.states(:,1),x))))])
    
    subplot(2,2,3)
    hist(spike_wins(~binnedData.states(:,1),x),0:20/win_length:100)
    axis([0 100 0 sum(~binnedData.states(:,1))/3])
    ylabel('normal posture')
    xlabel('mean spike rate')
    legend(['mean = ' num2str(round(mean(spike_wins(~binnedData.states(:,1),x))))])

    subplot(2,2,2)
    hist(BCspike_wins(BCbinnedData.states(:,1)==1,x),0:20/BCwin_length:100)
    axis([0 100 0 sum(BCbinnedData.states(:,1)==1)/3])
    title(BCbinnedData.spikeguide(x,:))
    ylabel('BC movement')
    legend(['mean = ' num2str(round(mean(BCspike_wins(BCbinnedData.states(:,1)==1,x))))])

    subplot(2,2,4)
    hist(BCspike_wins(BCbinnedData.states(:,1)==0,x),0:20/BCwin_length:100)
    axis([0 100 0 sum(BCbinnedData.states(:,1)==0)/3])
    ylabel('BC posture')
    xlabel('mean spike rate')
    legend(['mean = ' num2str(round(mean(BCspike_wins(BCbinnedData.states(:,1)==0,x))))])
        
end