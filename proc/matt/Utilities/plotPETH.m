function allSpikes = plotPETH(spikes,events,window,binsize,doPlot)
% PLOTPETH  Plots a peri-event timing histogram for neural data
%
% INPUTS
%   spikes: array of spike times for a neuron
%   events: array of event times on which to align spikes
%   window: [time_pre, time_post], 1x2 array of how much time before and after event to plot (in sec)
%   binsize: size of histogram bins in sec
%   doPlot: (boolean) whether to actually plot histogram. Use false if you just want to the values to use for other reasons
%
% OUTPUTS
%   allSpikes: vector of spike times relative to each event

if nargin < 5
    doPlot = true;
    if nargin < 4
        binsize = 0.02;
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
allSpikes = [];
for i = 1:length(events)
    % get indices of spikes that are within the pre/post window
    idx = spikes >= events(i)-window(1) & spikes < events(i)+window(2);
    
    allSpikes = [allSpikes, spikes(idx)-events(i)];
end

% now plot histogram
bins = -window(1)+binsize/2:binsize:window(2)-binsize/2;

if doPlot
    figure;
    hold all;
    [f,x]=hist(allSpikes,bins);
    % plot(x,100.*f/sum(f),'r','LineWidth',2);
    bar(x,100.*f/sum(f));
    V = axis;
    plot([0 0],[V(3) V(4)],'k--','LineWidth',1);
    set(gca,'TickDir','out','Box','off','FontSize',14);
    axis('tight');
end

