function [allFR,allSpikes,allEvents] = plotAlignedFR(spikes,events,window,binsize,doPlot)
% PLOTPETH  Plots a firing rate aligned on some events. Kinda like PETH
%
% INPUTS
%   spikes: array of spike times for a neuron
%   events: array of event times on which to align spikes (if size is nx2, treats first index as start and last index as stop, with window relative to those
%   window: [time_pre, time_post], 1x2 array of how much time before and after event to plot (in sec)
%   binsize: size of histogram bins in sec
%   doPlot: (boolean) whether to actually plot histogram. Use false if you just want to the values to use for other reasons
%
% OUTPUTS
%   allSpikes: vector of spike times relative to each event

if nargin < 5
    doPlot = false;
    if nargin < 4
        binsize = 0.05;
        if nargin < 3
            window = [0.3,0.3];
        end
    end
end

% we want spikes to be a row vector
if size(spikes,1) > size(spikes,2)
    spikes = spikes';
end

% get vector of all spike differences relative to events
allFR = cell(length(events),1);
allSpikes = cell(1,length(events));
allEvents = zeros(length(events),2);
for i = 1:length(events)
    % get indices of spikes that are within the pre/post window
    idx = spikes >= events(i,1)-window(1) & spikes < events(i,end)+window(2);
    
    bins = (events(i,1)-window(1)+binsize/2:binsize:events(i,end)+window(2)) - events(i,1);
    [f,~]=hist(spikes(idx)-events(i,1),bins);
    allFR{i} = [bins; f./binsize];
    allSpikes{i} = spikes(idx)-events(i,1);
    allEvents(i,:) = events(i,:) - events(i,1);
end


if doPlot
    figure;
    hold all;
    m = mean(allFR,1);
    s = std(allFR,1)./sqrt(size(allFR,1));
    plot(bins,m,'k','LineWidth',3);
    plot(bins,m+s,'k--','LineWidth',1);
    plot(bins,m-s,'k--','LineWidth',1);
    V = axis;
    plot([0 0],[V(3) V(4)],'k--','LineWidth',1);
    set(gca,'TickDir','out','Box','off','FontSize',14);
    axis('tight');
    xlabel('Time (sec)','FontSize',14);
    ylabel('Firing Rate (Hz)','FontSize',14);
end

