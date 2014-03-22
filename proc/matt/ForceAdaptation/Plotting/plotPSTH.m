function [peak,snr] = plotPSTH(spikes,events,winSize,doPlots)
%   spikes: array of time stamps of spikes
%   events: array of time stamps of trial events
%   winSize: 1x2 array, [time before event, time after event]

if size(spikes,2) == 1
    spikes = spikes';
end

ts = [];
for i = 1:length(events)
    % get relevant spike times
    ts = [ts spikes(spikes >= events(i)-winSize(1) & spikes <= events(i)+winSize(2)) - events(i)];
end

[n,x]=hist(ts,100);

if doPlots
    figure;
    hist(ts,100);
end

% get the peak bin
peak = x(find(n==max(n),1,'first'));

snr = (max(n)-mean(n))/std(n);
% 
% if peak < 0
%     
%     hist(ts,100);
%     pause
% end