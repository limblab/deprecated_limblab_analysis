

function tDCS_results = analyze_tDCS_neural_data( tDCS_exp_params )


% If it's a tDCS experiment
if ~isempty( tDCS_exp_params.baseline_files )

    % Define the number of trials of each type, and store that in the
    % trial_type variable, that will be used for the analysis and the plots
    if iscell(tDCS_exp_params.baseline_files)
        nbr_bsln_trials     = numel(tDCS_exp_params.baseline_files);
    elseif tDCS_exp_params.baseline_files ~= 0
        nbr_bsln_trials     = 1;
    else
        nbr_bsln_trials     = 0;
    end
    
    if iscell(tDCS_exp_params.tDCS_files)
        nbr_tDCS_trials     = numel(tDCS_exp_params.tDCS_files);
    elseif tDCS_exp_params.tDCS_files ~= 0
        nbr_tDCS_trials     = 1;
    else
        nbr_tDCS_trials     = 0;
    end
    
    if iscell(tDCS_exp_params.post_tDCS_files)
        nbr_post_trials     = numel(tDCS_exp_params.post_tDCS_files);
    elseif tDCS_exp_params.post_tDCS_files ~= 0
        nbr_post_trials     = 1;
    else
        nbr_post_trials     = 0;
    end
    
    nbr_trials              = nbr_bsln_trials + nbr_tDCS_trials + nbr_post_trials;

     % Fill the 'trial_type' variable
    trial_type              = cell(1,nbr_trials);
    
    for i = 1:nbr_bsln_trials
        trial_type{i}       = 'bsln';
    end
    for i = 1:nbr_tDCS_trials
        trial_type{i+nbr_bsln_trials}                   = 'tDCS';
    end
    for i = 1:nbr_post_trials
        trial_type{i+nbr_bsln_trials+nbr_tDCS_trials}   = 'post';
    end    
    
                            
% For an ICMS-only experiment, define all the trials as 'baseline'
else
    
    bsln                    = what( tDCS_exp_params.exp_folder );
    tDCS_exp_params.baseline_files = bsln.mat;
    clear bsln;
    
    nbr_trials              = numel(tDCS_exp_params.baseline_files);
    nbr_bsln_trials         = nbr_trials; % For consistency
    [nbr_tDCS_trials nbr_post_trials]   = deal(0); % For consistency
    trial_type              = cell(1,nbr_trials);
    for i = 1:nbr_trials
        trial_type{i}       = 'bsln';
    end    
end



% -------------------------------------------------------------------------
% Retrieve each trial and calculate STA_metrics


% For the baseline trials
if nbr_bsln_trials > 0
    neural_activity_bsln    = split_and_analyze_data( tDCS_exp_params.baseline_files, tDCS_exp_params.exp_folder, ...
                                tDCS_exp_params.win_duration, tDCS_exp_params.chosen_neurons );
end


% For the tDCS trials
if nbr_tDCS_trials > 0
    neural_activity_tDCS   	= split_and_analyze_data( tDCS_exp_params.tDCS_files, ...
                                tDCS_exp_params.win_duration, nbr_tDCS_trials );
end

% For the post-tDCS trials
if nbr_post_trials > 0
    neural_activity_post   	= split_and_analyze_data( tDCS_exp_params.post_tDCS_files, ...
                                tDCS_exp_params.win_duration, nbr_post_trials );
end
