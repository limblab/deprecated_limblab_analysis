function allNeurons = separateStimBlocksAndPlot(bdf,stimCycle,show_plot)
% SEPARATESTIMBLOCKSANDPLOT - Return indices covering the stim blocks defined in
% 'stimCycle'. Also plots if you want it to.
%
% INPUT:
%       'stimCycle' - OFF,ON times for stimulation. Time in minutes.
%           ex: [OFF1Start OFF1End ON1Start ON1End OFF2Start OFF2End ...]
%               [0 10 10.5 22.5 23 31.5 31.7 34.2];
%
% OUTPUT:
%
% Created by John W. Miller
% 2014-08-06

% Sorted units (time stamps from bdf)
sorted_units  = get_sorted_units(bdf);
n_neurons     = length(sorted_units);
allNeurons    = cell(n_neurons,1);

% Stimulation states
n_blocks = length(stimCycle)/2;     % OFF or ON blocks

% For each neuron, label spikes to certain stim blocks
for n_neuron = 1:n_neurons
    stimBlockIdxs = cell(2,n_blocks); % Trial ranges for the different blocks
    iNeuron = sorted_units{n_neuron};
    iState = 0; % Stimulation state. OFF=0, ON=1
    iBlock = 1;
    
    if show_plot==1|show_plot==3;figure;ymax=0;end;
    for ii = 1:2:length(stimCycle)
        n_spikes      = 0;
        botEnd = find(iNeuron/60 >= stimCycle(ii),1,'first');
        topEnd = find(stimCycle(ii+1) >= iNeuron/60,1,'last');
        stimBlockIdxs{1,iBlock} = iState;
        stimBlockIdxs{2,iBlock} = [stimBlockIdxs{2,iBlock} botEnd:topEnd];
        n_spikes = length(botEnd:topEnd);
        trains = sorted_units{n_neuron};
        idxs   = stimBlockIdxs{2,iBlock};
        
        % Plot ISI for each stim block
        if show_plot==1|show_plot==3
            edges = [0:.005:1.5];
            N = histc(diff(trains(idxs)),edges);
            N = N/n_spikes;
            if max(N) > ymax
                ymax = max(N);
            end
%             N = (N-min(N))/(max(N-min(N)));
            H(iBlock) = subplot(n_blocks,1,iBlock);
            bar(edges,N,'histc')
            xlim([-0.05 .3]);
        end
        
        
        iState = 1 - iState;
        iBlock = iBlock + 1;
    end
        if show_plot==1|show_plot==3; linkaxes(H);ylim([0 ymax*1.2]);end;
    
        % Plot # of spikes for each stim block
        if show_plot==2|show_plot==3;
            x = 1:n_blocks;
            y=[];
            for iBlock = 1:n_blocks
                durations = diff(stimCycle);
                durations = durations(durations>2);
                normedCount=length(stimBlockIdxs{2,iBlock})./durations(iBlock);
                y = [y normedCount];
            end
            figure
            bar(x,y)  
        end
    
    if show_plot==1|show_plot==2|show_plot==3;pause;end;
    allNeurons{n_neuron} = stimBlockIdxs;
end








