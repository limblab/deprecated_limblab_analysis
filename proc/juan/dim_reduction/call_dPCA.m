%
%
%

function call_dPCA( single_trial_data, neural_chs, labels, binned_data )



% check if the dimensions in single_trial_data are consistent
if size(single_trial_data{1}.target{1}.neural_scores.smoothed_fr,2) ~= numel(neural_chs)
    error('single trial data does not contained all the neural channels')
end

% make the target averaged responses for each task have equal length.
% This is not done in single_trial_analysis_dim_red.m, where single trial
% duration is only equalized for each task
single_trial_data   = equalize_single_trial_dur( single_trial_data );

% ------------------------------------------------------------------------
% 1. arrange the data (as described in dpca_demo)

% N is the number of neurons
% S is the number of conditions --> tasks in our case
% D is the number of decisions --> targets in our case
%       ToDo: see if it can be different for each task
% T is the number of time points --each trial should have the same duration
% in time !!!
N                   = numel(neural_chs);
S                   = numel(single_trial_data);
D                   = numel(single_trial_data{1}.target);
T                   = size(single_trial_data{1}.target{1}.neural_scores.data,1);
% max number of repetitions
max_trial_num       = 0;
for i = 1:S
    if max(cellfun(@(x) size(x.neural_scores.data,3), single_trial_data{1}.target )) > max_trial_num;
        max_trial_num = max(cellfun(@(x) size(x.neural_scores.data,3), single_trial_data{1}.target ));
    end
end


% trial_num: N x S x D
trial_num           = zeros(N,S,D);

% firing_rates: N x S x D x T x max_trial_num -- populated with our
% single_trial_data
firing_rates        = nan(N,S,D,T,max_trial_num);
for n = 1:N
    for s = 1:S
        for d = 1:D
            % AQUI
            trials_this = size(single_trial_data{s}.target{d}.neural_scores.smoothed_fr(:,n,:),3);
            firing_rates(n,s,d,:,1:trials_this) = ...
                squeeze(single_trial_data{s}.target{d}.neural_scores.smoothed_fr(:,n,:));
        end
    end
end


% firing_rates_average: N x S x D x T -- these are PSTHs
firing_rates_avg    = nanmean(firing_rates, 5);

% ------------------------------------------------------------------------
% 2. Define parameters

% 1 - task
% 2 - target
% 3 - time
% [1 3] - task/time interaction
% [2 3] - target/time interaction
% [1 2] - task/target interaction
% [1 2 3] - rest

combined_params     = { {1,[1 3]}, {2,[2,3]}, {3}, {[1 2],[1 2 3]} };
marg_names          = {'task','target','time','task/target interaction'};
marg_colors         = [23 100 171; 187 20 25; 150 150 150; 114 97 171]/256;

time                = (1:T)*single_trial_data{1}.target{1}.bin_size;
time_events         = 1;

% ------------------------------------------------------------------------
% 2. Do dPCA without regularization
num_comps           = 20;

[W, V, which_marg]  = dpca( firing_rates_avg, num_comps, 'combinedParams', combined_params );

expl_var            = dpca_explainedVariance(firing_rates_avg, W, V, ...
                        'combinedParams', combined_params);
                    
dpca_plot(firing_rates_avg, W, V, @dpca_plot_default, ...
    'explainedVar', expl_var, ...
    'marginalizationNames', marg_names, ...
    'marginalizationColours', marg_colors, ...
    'whichMarg', which_marg,                 ...
    'time', time,                        ...
    'timeEvents', time_events,               ...
    'timeMarginalization', 3, ...
    'legendSubplot', 16);                

------------------------------------------------------------------------
% 2. Do dPCA in each marginalization separately 

dpca_perMarginalization(firing_rates_avg, @dpca_plot_default, ...
   'combinedParams', combined_params);