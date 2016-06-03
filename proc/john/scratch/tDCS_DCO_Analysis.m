% 7/8/14
% Make some plots of firing rates and stuff during tDCS
%
% Specific to the DCO struct and bdf that Ricardo generates with
% DCO_wrapper

%% Load the data
% DCO
load('/Users/john/Research/NU_LimbLab/Animals/Chewie_8I2/Data/tDCS/Chewie_2014-06-30_DCO_tDCS/Output_Data/\Output_Data\DCO.mat')
% bdf
load('/Users/john/Research/NU_LimbLab/Animals/Chewie_8I2/Data/tDCS/Chewie_2014-06-30_DCO_tDCS/Output_Data/\Output_Data\bdf.mat')

%%
%  PST Histogram

trains = get_sorted_units(bdf); % Timestamps
one_neuron = trains{8};         % Timestamps of just one neuron

n_trials = size(DCO.trial_table,1);
cue_times = DCO.trial_table(:,DCO.table_columns.t_go_cue);
bin = .1; % Time bin in seconds
edges = -1:bin:1;   % Time range, seconds
psth = zeros(length(edges),1);

for iTrial = 10:n_trials
    t_cue = cue_times(iTrial);              % Time of GO_CUE, seconds
    
    % Add current trial's spike times
    N = histc(one_neuron(iSpikes) - t_cue, edges);
    if size(N) == size(psth)
        psth = psth + N;
    end
end

%%

bin = .1; % Time bin in seconds
edges = -1:bin:1;   % Time range, seconds
psth = zeros(length(edges),1);
for iTrial = 10:n_trials
    t_cue = cue_times(iTrial);              % Time of GO_CUE, seconds
    iSpikes = spikesInWindow(:,iTrial);     % Spikes within window of cue for the current trial
    n_Spikes = length(iSpikes(iSpikes==1)); % Total number of spikes for current trial
    
    
    % Add current trial's spike times
    N = histc(one_neuron(iSpikes) - t_cue, edges);
    if size(N) == size(psth)
        psth = psth + N;
    end
end

figure
bar(edges,psth, 'histc');
xlim([-1.1 1])
fs = 20;
xlabel('Time (sec)')
ylabel('# of spikes')
plot_title = sprintf('Peri-Stimulus Time Histogram - \n %s, neuron #%d ', brainRegion, n_neuron);
title(plot_title,'FontSize',fs + 2)
