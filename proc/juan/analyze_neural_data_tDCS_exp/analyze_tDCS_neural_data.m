

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
% Retrieve each trial and calculate the variables we're interested in


% For the baseline trials
if nbr_bsln_trials > 0
    neural_activity_bsln    = split_and_analyze_data( tDCS_exp_params.baseline_files, tDCS_exp_params.exp_folder, ...
                                tDCS_exp_params.win_duration, tDCS_exp_params.chosen_neurons );
end


% For the tDCS trials
if nbr_tDCS_trials > 0
    neural_activity_tDCS   	= split_and_analyze_data( tDCS_exp_params.tDCS_files, tDCS_exp_params.exp_folder, ...
                                tDCS_exp_params.win_duration, tDCS_exp_params.chosen_neurons );
end

% For the post-tDCS trials
if nbr_post_trials > 0
    neural_activity_post   	= split_and_analyze_data( tDCS_exp_params.post_tDCS_files, tDCS_exp_params.exp_folder, ...
                                tDCS_exp_params.win_duration, tDCS_exp_params.chosen_neurons );
end



% Retrieve how many 'points' (epochs) per condition (pre-, during and
% post-tDCS) we have

if nbr_bsln_trials > 0
    nbr_points_bsln         = size(neural_activity_bsln.mean_firing_rate,1);
else
    nbr_points_bsln         = 0;
end

if nbr_tDCS_trials > 0
    nbr_points_tDCS         = size(neural_activity_tDCS.mean_firing_rate,1);
else
    nbr_points_tDCS         = 0;
end

if nbr_post_trials > 0
    nbr_points_post         = size(neural_activity_post.mean_firing_rate,1);
else
    nbr_points_post         = 0;
end

nbr_epochs                  = nbr_points_bsln + nbr_points_tDCS + nbr_points_post;


tDCS_exp_params.nbr_neurons = numel(tDCS_exp_params.chosen_neurons);



% Normalize the firing rates by the mean firing rate during baseline
if nbr_bsln_trials > 0
    % calculate the mean firing rate during the whole baseline, which will
    % be the denominator for normalizing firing rates
    neural_activity_bsln.mean_firing_rate_whole_bsln    = mean(neural_activity_bsln.mean_firing_rate,1);

    % normalize the firing rate for each baseline epoch
    neural_activity_bsln.norm_firing_rate               = zeros(nbr_points_bsln,tDCS_exp_params.nbr_neurons);
    for i = 1:nbr_points_bsln
        neural_activity_bsln.norm_firing_rate(i,:)      = neural_activity_bsln.mean_firing_rate(i,:) ...
                                                            ./neural_activity_bsln.mean_firing_rate_whole_bsln;
    end
end

if nbr_tDCS_trials > 0;
    neural_activity_tDCS.norm_firing_rate               = zeros(nbr_points_tDCS,tDCS_exp_params.nbr_neurons);
    for i = 1:nbr_points_bsln
        neural_activity_tDCS.norm_firing_rate(i,:)      = neural_activity_tDCS.mean_firing_rate(i,:) ...
                                                            ./neural_activity_bsln.mean_firing_rate_whole_bsln;
    end
end

if nbr_post_trials > 0;
    neural_activity_post.norm_firing_rate               = zeros(nbr_points_post,tDCS_exp_params.nbr_neurons);
    for i = 1:nbr_points_bsln
        neural_activity_post.norm_firing_rate(i,:)      = neural_activity_post.mean_firing_rate(i,:) ...
                                                            ./neural_activity_bsln.mean_firing_rate_whole_bsln;
    end
end


% -------------------------------------------------------------------------
% Some preliminary stuff


% Retrieve monkey, and date information for figure title
if nbr_bsln_trials > 0
   if iscell(tDCS_exp_params.baseline_files)
       file_name_4_metadata = tDCS_exp_params.baseline_files{1};
   else
       file_name_4_metadata = tDCS_exp_params.baseline_files;
   end 
elseif nbr_tDCS_trials
    if iscell(tDCS_exp_params.tDCS_files)
        file_name_4_metadata = tDCS_exp_params.tDCS_files{1};
    else
        file_name_4_metadata = tDCS_exp_params.tDCS_files;
    end
end

last_pos_title              = find( file_name_4_metadata =='_', 3 );
fig_title                   = file_name_4_metadata(1:last_pos_title(end)-1);


% -------------------------------------------------------------------------
% Plots

% -> Plot the raw firing rate
fig_fr_tDCS_exp( neural_activity_bsln, neural_activity_tDCS, neural_activity_post, ...
    fig_title, tDCS_exp_params.win_duration, nbr_points_bsln, nbr_points_tDCS, nbr_points_post, 'not' );

% -> Plot the normalized firing rate
fig_fr_tDCS_exp( neural_activity_bsln, neural_activity_tDCS, neural_activity_post, ...
    fig_title, tDCS_exp_params.win_duration, nbr_points_bsln, nbr_points_tDCS, nbr_points_post, 'norm' );
