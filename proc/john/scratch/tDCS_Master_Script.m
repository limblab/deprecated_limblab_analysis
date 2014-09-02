function [] = tDCS_Master_Script(bdf,tt,stimCycle,n_neuron)
%% TDCS_MASTER_SCRIPT - Take a bdf from a tDCS session and do a bunch of stuff to it
%
%
% --------------------------------------------- %


% Time stamps of all sorted units in 'bdf'
[sorted_units, channels] = get_sorted_units(bdf);

for n_neuron = 7;

    neuron = sorted_units{n_neuron};

    % Time stamps of all event times during session
    goCues = tt(:,4);
    goodIdxs  = isfinite(goCues); % Remove any NaNs
    goCues    = goCues(goodIdxs,:);
    holdTimes = tt(goodIdxs,3);
    directions = tt(goodIdxs,12);
    dirDegrees = unique(directions)*(180/pi);

    % For a certain neuron, separate its timestamps into stim blocks
    [spikeMask, eventMask] = separateStimBlocks(neuron,goCues,stimCycle);
    n_blocks = size(spikeMask,2);

    % Calculate firing rates (mov. and spont.) for each stim block
    for iBlock = 1:n_blocks
       spikes = neuron(spikeMask(:,iBlock));
       events = goCues(eventMask(:,iBlock));
       dirs   = directions(eventMask(:,iBlock));
       holds  = holdTimes(eventMask(:,iBlock));
       [movFRsByBlock(:,iBlock), spontFRsbyBlock(:,iBlock)] =...
           calcFiringRates(spikes,events,dirs,holds); 
       
       movFRs(:,iBlock)    = movFRsByBlock{1,iBlock};
       movStdErs(:,iBlock) = movFRsByBlock{3,iBlock};
       
       spontFRs(:,iBlock) = spontFRsbyBlock{1,iBlock};
       spontFRs_stdEr(:,iBlock) = spontFRsbyBlock{3,iBlock};

    end


    plotTuningCurve(movFRs,movStdErs,dirDegrees)




    errorBars = spontFRs_stdEr*ones(size(n_blocks));
    figure
    errorbar([45 135 270],spontFRs,errorBars,'-')
    yl = ylim;ymax=yl(2);
    ylim([0 ymax])


    
    
end