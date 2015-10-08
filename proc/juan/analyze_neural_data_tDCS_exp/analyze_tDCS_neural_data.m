

function tDCS_results = analyze_tDCS_neural_data( atp )


% If it's a tDCS experiment
if ~isempty( atp.baseline_files )

    % Define the number of trials of each type, and store that in the
    % trial_type variable, that will be used for the analysis and the plots
    if iscell(atp.baseline_files)
        nbr_bsln_trials     = numel(atp.baseline_files);
    elseif atp.baseline_files ~= 0
        nbr_bsln_trials     = 1;
    else
        nbr_bsln_trials     = 0;
    end
    
    if iscell(atp.tDCS_files)
        nbr_tDCS_trials     = numel(atp.tDCS_files);
    elseif atp.tDCS_files ~= 0
        nbr_tDCS_trials     = 1;
    else
        nbr_tDCS_trials     = 0;
    end
    
    if iscell(atp.post_tDCS_files)
        nbr_post_trials     = numel(atp.post_tDCS_files);
    elseif atp.post_tDCS_files ~= 0
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
    
                            
% For a control experiment, define all the trials as 'baseline'
else
    
    bsln                    = what( atp.exp_folder );
    atp.baseline_files = bsln.mat;
    clear bsln;
    
    nbr_trials              = numel(atp.baseline_files);
    nbr_bsln_trials         = nbr_trials; % For consistency
    [nbr_tDCS_trials, nbr_post_trials]   = deal(0); % For consistency
    trial_type              = cell(1,nbr_trials);
    for i = 1:nbr_trials
        trial_type{i}       = 'bsln';
    end    
end



% -------------------------------------------------------------------------
% Some preliminary stuff


% Retrieve monkey, and date information for figure title
if nbr_bsln_trials > 0
   if iscell(atp.baseline_files)
       file_name_4_metadata = atp.baseline_files{1};
   else
       file_name_4_metadata = atp.baseline_files;
   end 
elseif nbr_tDCS_trials
    if iscell(atp.tDCS_files)
        file_name_4_metadata = atp.tDCS_files{1};
    else
        file_name_4_metadata = atp.tDCS_files;
    end
end

last_pos_title              = find( file_name_4_metadata =='_', 3 );
fig_title                   = file_name_4_metadata(1:last_pos_title(end)-1);



% -------------------------------------------------------------------------
% Retrieve each trial and calculate the variables we're interested in


% -----------------
% 1. Calculate the mean and SD firing rate of the neural activity in each
% channel, in epochs of duration atp.win_duration seconds.
% Also, return the binned data (typically in 50 ms bins) used for all the
% calculations (that is, without the bins rejected based in the criteria
% chosen in 'atp.sad_param'). The binned_data also contains the
% behavior data



% For the baseline trials
if nbr_bsln_trials > 0
    [neural_activity_bsln, binned_data_bsln] = split_and_analyze_data( atp.baseline_files, ...
                                atp.exp_folder, atp.sad_params );
end


% For the tDCS trials
if nbr_tDCS_trials > 0
    [neural_activity_tDCS, binned_data_tDCS] = split_and_analyze_data( atp.tDCS_files, ...
                                atp.exp_folder, atp.sad_params );
end

% For the post-tDCS trials
if nbr_post_trials > 0
    [neural_activity_post, binned_data_post] = split_and_analyze_data( atp.post_tDCS_files, ...
                                atp.exp_folder, atp.sad_params );
end


% Retrieve how many 'points' (epochs) per condition (pre-, during and
% post-tDCS) we have -used later

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


atp.nbr_neurons = numel(atp.sad_params.chosen_neurons);



% -----------------
% 2. Normalize the firing rates by the mean firing rate during baseline


if nbr_bsln_trials > 0
    % calculate the mean and SD firing rate during the whole baseline,
    % which will be used to normalize the firing rates using the Z score
    neural_activity_bsln.mean_firing_rate_whole_bsln    = mean(neural_activity_bsln.mean_firing_rate,1);
    neural_activity_bsln.std_firing_rate_whole_bsln     = std(neural_activity_bsln.mean_firing_rate,1);

    % normalize the firing rate according to the chosen method
    neural_activity_bsln.norm_firing_rate               = zeros(nbr_points_bsln,atp.nbr_neurons);
    for i = 1:nbr_points_bsln
        switch atp.sad_params.normalization
            case 'mean_only'
                neural_activity_bsln.norm_firing_rate(i,:) = neural_activity_bsln.mean_firing_rate(i,:) ...
                                                             ./neural_activity_bsln.mean_firing_rate_whole_bsln;
            case 'Z-score'
                neural_activity_bsln.norm_firing_rate(i,:) = ( neural_activity_bsln.mean_firing_rate(i,:) ...
                                                            - neural_activity_bsln.mean_firing_rate_whole_bsln )...
                                                            ./neural_activity_bsln.std_firing_rate_whole_bsln;
        end
    end
end

if nbr_tDCS_trials > 0;
    neural_activity_tDCS.norm_firing_rate               = zeros(nbr_points_tDCS,atp.nbr_neurons);
    for i = 1:nbr_points_tDCS
        switch atp.sad_params.normalization
            case 'mean_only'
                neural_activity_tDCS.norm_firing_rate(i,:) = neural_activity_tDCS.mean_firing_rate(i,:) ...
                                                            ./neural_activity_bsln.mean_firing_rate_whole_bsln;
            case 'Z-score'
                neural_activity_tDCS.norm_firing_rate(i,:) = ( neural_activity_tDCS.mean_firing_rate(i,:) ...
                                                            - neural_activity_bsln.mean_firing_rate_whole_bsln )...
                                                            ./neural_activity_bsln.std_firing_rate_whole_bsln;
        end
    end
end

if nbr_post_trials > 0;
    neural_activity_post.norm_firing_rate               = zeros(nbr_points_post,atp.nbr_neurons);
    for i = 1:nbr_points_post
        switch atp.sad_params.normalization
            case 'mean_only'
                neural_activity_post.norm_firing_rate(i,:) = neural_activity_post.mean_firing_rate(i,:) ...
                                                             ./neural_activity_bsln.mean_firing_rate_whole_bsln;
            case 'Z-score'
                neural_activity_post.norm_firing_rate(i,:) = ( neural_activity_post.mean_firing_rate(i,:) ...
                                                            - neural_activity_bsln.mean_firing_rate_whole_bsln )...
                                                            ./neural_activity_bsln.std_firing_rate_whole_bsln;
        end
    end
end


% -----------------
% 3. Calculate the relative changes in firing rate between blocks and see
% if they are statistically significant

if nbr_bsln_trials > 0 && nbr_tDCS_trials > 0  && nbr_post_trials > 0
    [neural_activity_bsln, neural_activity_tDCS, neural_activity_post] = ...
        calc_stats_firing_rate_btw_blocks( neural_activity_bsln, neural_activity_tDCS, neural_activity_post );
elseif nbr_post_trials == 0 && nbr_tDCS_trials == 0
    
elseif nbr_post_trials == 0 && nbr_tDCS_trials > 0
    [neural_activity_bsln, neural_activity_tDCS] = ...
        calc_stats_firing_rate_btw_blocks( neural_activity_bsln, neural_activity_tDCS, [] );
end

% -----------------
% 4. Calculate changes in the LFPs across blocks




                                                        
% -------------------------------------------------------------------------
% Plots

% -> Plot the raw firing rate
fig_fr_tDCS_exp( neural_activity_bsln, neural_activity_tDCS, neural_activity_post, ...
    binned_data_bsln, binned_data_tDCS, binned_data_post, fig_title, ...
    atp.sad_params, nbr_points_bsln, nbr_points_tDCS, nbr_points_post, 'not' );

% -> Plot the normalized firing rate
fig_fr_tDCS_exp( neural_activity_bsln, neural_activity_tDCS, neural_activity_post, ...
    binned_data_bsln, binned_data_tDCS, binned_data_post, fig_title, ...
    atp.sad_params, nbr_points_bsln, nbr_points_tDCS, nbr_points_post, 'norm' );


% Histograms showing the change in firing rate across blocks
fig_fr_change_hist( neural_activity_tDCS.change_firing_rate, ...
    [fig_title ' -- tDCS - baseline (P = ' num2str(neural_activity_tDCS.wilcox,3) ')'] )
fig_fr_change_hist( neural_activity_post.change_firing_rate, ...
    [fig_title ' -- post-tDCS - tDCS (P = ' num2str(neural_activity_post.wilcox,3) ')'] )
if nbr_post_trials > 0
    fig_fr_change_hist( neural_activity_post.change_firing_rate_bsln, ...
        [fig_title ' -- post-tDCS - baseline (P = ' num2str(neural_activity_post.wilcox_bsln,3) ')'] )
end

fig_fr_change_hist( neural_activity_tDCS.change_norm_firing_rate, ...
    [fig_title ' -- tDCS - baseline (P = ' num2str(neural_activity_tDCS.wilcox_norm,3) ')'], 'norm' )
fig_fr_change_hist( neural_activity_post.change_norm_firing_rate, ...
    [fig_title ' -- post-tDCS - tDCS (P = ' num2str(neural_activity_post.wilcox_norm,3) ')'], 'norm' )
if nbr_post_trials > 0
    fig_fr_change_hist( neural_activity_post.change_norm_firing_rate_bsln, ...
        [fig_title ' -- post-tDCS - baseline (P = ' num2str(neural_activity_post.wilcox_norm_bsln,3) ')'], 'norm' )
end


% Behavior data
plot_behavior_tDCS_exp( binned_data_bsln, binned_data_tDCS, binned_data_post, atp.sad_params )


% -------------------------------------------------------------------------
% Return variables
tDCS_results.binned_data_bsln       = binned_data_bsln;
tDCS_results.binned_data_tDCS       = binned_data_tDCS;
tDCS_results.binned_data_post       = binned_data_post;

tDCS_results.neural_activity_bsln   = neural_activity_bsln;
tDCS_results.neural_activity_tDCS   = neural_activity_tDCS;
tDCS_results.neural_activity_post   = neural_activity_post;