function [] = crossCorrelogram(bdf,tt,stimCycle)
% crossCorrelogram -
%
% INPUT:
%
% OUTPUT:
%
% Created by John W. Miller
% 2014-09-04
%
%%

[sorted_units,chans] = get_sorted_units(bdf);
% find((chans(:,1)==28)==1)

% for n_neuron = 1:length(sorted_units)
for n_neuron = 11
    
    spikes = sorted_units{n_neuron};
        % Separate spikes and events into stimulation blocks
    [spikeMask,n_blocks] = separateStimBlocks_2(spikes,stimCycle);
    
    yMax = 0;
    colors = [1 0 0; 0 1 0; 0 0 1];
    figure
    for iBlock = 1:n_blocks
        color = colors(iBlock,:);
        % Spikes and events for current block
        spikesInBlock = spikes(spikeMask(:,iBlock));
        
        ISIs = diff(spikesInBlock); % Interspike intervals
        [xc, lags] = xcorr(ISIs,'coeff');        
        subplot(1,n_blocks,iBlock)
        bar(lags,xc);axis([-100 100 .2 .3])               
    end
%     pause
end
