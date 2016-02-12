function [] = spontFRscript(bdf,tt,stimCycle)
bdfname = inputname(1);
% Prepare neurons and hold/cue times
sorted_units = get_sorted_units(bdf);
holdTimes = tt(:,3)-1; % 1 sec. diference between analog and cue_times
[~,n_blocks] = separateStimBlocks_2(sorted_units{1},stimCycle,'warn',0);


%% -------------------- %% One Neuron %% -------------------- %

if 0
% Select a neuron and its spikes
n_neuron = 4;
spikes = sorted_units{n_neuron};

% Separate spikes and events into stimulation blocks
[spikeMask,n_blocks] = separateStimBlocks_2(spikes,stimCycle);
eventMask            = separateStimBlocks_2(holdTimes,stimCycle);
colors = [1 0 0; 0 1 0; 0 0 1];
% Scatterplot
if 1
figure;hold on
for iBlock = 1:n_blocks
    color = colors(iBlock,:);
        % Spikes and events for current block
    spikesInBlock = spikes(spikeMask(:,iBlock));
    eventsInBlock = holdTimes(eventMask(:,iBlock));
        % Calculate spontaneous firing rate
        % for each trial contained within current block
    spontRatePerTrial = spontFiringRates(spikesInBlock,eventsInBlock);
    
    n_trials = length(spontRatePerTrial);
    
    
    
    X = iBlock:(1)/n_trials:((iBlock+1)-1/n_trials);
    plot(X,spontRatePerTrial,'o-','Color',color)
    yVal = mean(spontRatePerTrial);
    line('XData',[min(X) max(X)], 'YData',[yVal yVal],'LineStyle', '-','Color','k')
    ylim([0 max(spontRatePerTrial)*1.2])
end
end

% Histogram
if 0
    figure
for iBlock = 1:n_blocks
    color = colors(iBlock,:);
        % Spikes and events for current block
    spikesInBlock = spikes(spikeMask(:,iBlock));
    eventsInBlock = holdTimes(eventMask(:,iBlock));
        % Calculate spontaneous firing rate
        % for each trial contained within current block
    spontRatePerTrial = spontFiringRates(spikesInBlock,eventsInBlock);
    n_trials = length(spontRatePerTrial);
        % Histogram
%     figure
    subplot(1,n_blocks,iBlock);
    edges = [0:.5:30];
    N = histc(spontRatePerTrial,edges)/n_trials;
    bar(edges,N,'histc');
    ylim([0 0.3])
    
%     hist(spontRatePerTrial,50)
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor',color)
%     ylim([0 70])
end
end
end

%% -------------------- %% All Neurons %% -------------------- %

% Calculate and compare spont. FRs for all neurons
if 1
    
n_neurons   = length(sorted_units);
allSpontFRs = zeros(n_neurons,n_blocks);


colors = [1 0 0; 0 1 0; 0 0 1];
for n_neuron = 1:n_neurons
        % Current neuron's spike train
    spikes = sorted_units{n_neuron};
        % Separate spikes and events into stimulation blocks
    [spikeMask,n_blocks] = separateStimBlocks_2(spikes,stimCycle,'warn',0);
    eventMask            = separateStimBlocks_2(holdTimes,stimCycle,'warn',0);
    
    for iBlock = 1:n_blocks
            % Spikes and events for current block
        spikesInBlock = spikes(spikeMask(:,iBlock));
        eventsInBlock = holdTimes(eventMask(:,iBlock));
            % Calculate spontaneous firing rate
            % for each trial contained within current block
        spontRatePerTrial = spontFiringRates(spikesInBlock,eventsInBlock);
        allSpontFRs(n_neuron,iBlock) = mean(spontRatePerTrial); % [n_neuron x iBlock]
    end
end

if 1
% Plotting
fs = 20;
yMax = max(max(allSpontFRs))*1.1;
xMax = n_blocks+1;
    % Each neuron's mean FR during all blocks
figure
subplot(1,2,1)
X = 1:n_blocks;
plot(X,allSpontFRs,'-o')
axis([0 xMax 0 yMax]); set(gca,'XTick',[0:xMax]);
xlabel('Stimulation Block #','FontSize',fs)
ylabel('Mean Spont. FR (Hz)','FontSize',fs)
plot_title = sprintf('Mean Spontaneous FR for All Neurons\n Day:%s  --- %d neurons',bdfname(4:end),n_neurons);
title(plot_title,'FontSize',fs+2);

    % Set each neuron's 1st block to same mean
adjFirstBlock(:,1) = allSpontFRs(:,1)-allSpontFRs(:,1);
adjFirstBlock(:,2) = allSpontFRs(:,2)-allSpontFRs(:,1);
adjFirstBlock(:,3) = allSpontFRs(:,3)-allSpontFRs(:,1);

% figure
subplot(1,2,2)
plot(X,adjFirstBlock,'-o')
yMax = max(max(abs(adjFirstBlock)))*1.2;
axis([0 xMax -yMax yMax]); set(gca,'XTick',[0:xMax]);
xlabel('Stimulation Block #','FontSize',fs)
% ylabel('Mean Spont. FR (Hz)','FontSize',fs)
plot_title = sprintf('Mean Spontaneous FR for All Neurons -- 1st Block Adj. \n Day:%s --- %d neurons',bdfname(4:end),n_neurons);
title(plot_title,'FontSize',fs+2);
end


%% T-tests
if 1  
    x = allSpontFRs(:,1);
    y = allSpontFRs(:,2);
    [h,p] = ttest(x,y)
    
    
    x = allSpontFRs(:,1);
    y = allSpontFRs(:,3);
    [h,p] = ttest(x,y)

    
    x = allSpontFRs(:,2);
    y = allSpontFRs(:,3);
    [h,p] = ttest(x,y)
    

end
end

end