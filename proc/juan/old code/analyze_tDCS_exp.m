% Function that loads all the files of an ICMS experiment (with or without
% tDCS), and plots a series of metrics that summarize the experiment
%
%   function tDCS_results = analyze_tDCS_exp( tDCS_exp )
%


function tDCS_results = analyze_tDCS_exp( tDCS_exp )


% If it's a tDCS experiment
if ~isempty( tDCS_exp.baseline_files )
    
    % Define the number of trials of each type, and store that in the
    % trial_type variable, that will be used for the analysis and the plots
    if iscell(tDCS_exp.baseline_files)
        nbr_bsln_trials     = numel(tDCS_exp.baseline_files);
    else
        nbr_bsln_trials     = 1;
    end
    
    if iscell(tDCS_exp.tDCS_files)
        nbr_tDCS_trials     = numel(tDCS_exp.tDCS_files);
    else
        nbr_tDCS_trials     = 1;
    end
    
    if iscell(tDCS_exp.post_tDCS_files)
        nbr_post_trials     = numel(tDCS_exp.post_tDCS_files);
    else
        nbr_post_trials     = 1;
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
    for i = 1:nbr_tDCS_trials
        trial_type{i+nbr_bsln_trials+nbr_tDCS_trials}   = 'post';
    end    
    
                            
% For an ICMS-only experiment, define all the trials as 'baseline'
else
    
    bsln                    = what( tDCS_exp.exp_folder );
    tDCS_exp.baseline_files = bsln.mat;
    clear bsln;
    
    nbr_trials              = numel(tDCS_exp.baseline_files);
    trial_type              = cell(1,nbr_trials);
    for i = 1:nbr_trials
        trial_type{i}       = 'bsln';
    end
end



% -------------------------------------------------------------------------
% Retrieve each trial and calculate STA_metrics

time_axis                   = [];


% For the baseline trials
sta_metrics_bsln            = split_and_calc_sta_metrics( tDCS_exp.baseline_files, tDCS_exp.resp_per_win, nbr_bsln_trials );


% For the tDCS trials
if ~isempty( tDCS_exp.tDCS_files )
    sta_metrics_tDCS        = split_and_calc_sta_metrics( tDCS_exp.tDCS_files, tDCS_exp.resp_per_win, nbr_tDCS_trials );
end

% For the post-tDCS trials
if ~isempty( tDCS_exp.post_tDCS_files )
    sta_metrics_post        = split_and_calc_sta_metrics( tDCS_exp.post_tDCS_files, tDCS_exp.resp_per_win, nbr_post_trials );
end



% -------------------------------------------------------------------------
% Look at the data you want


% Look for the specified muscles, if any. Otherwise, initialize a 'dummy'
% array of muscles positions in 'sta_metrics_XXXX'
if ~isempty(tDCS_exp.muscles)
    
    nbr_muscles             = numel(tDCS_exp.muscles);
    pos_muscles             = zeros(1,nbr_muscles);
    for i = 1:numel(pos_muscles)
        pos_muscles(i)      = find( strncmp( sta_metrics_bsln(i).emg.labels, tDCS_exp.muscles{i}, ...
                                length(tDCS_exp.muscles{i}) ) );
    end
else
    pos_muscles             = 1:numel(sta_metrics_bsln(1).emg.labels);
    nbr_muscles             = numel(pos_muscles);
end


% -------------------------------------------------------------------------
% 1. Plot the MPSF for the specified muscles (or all of them)

% See how many MPSF 'points' (epochs) we have
nbr_points_bsln             = numel(sta_metrics_bsln);

if exist('nbr_tDCS_trials','var')
    nbr_points_tDCS         = numel(sta_metrics_tDCS);
    nbr_points_post         = numel(sta_metrics_post);
    nbr_MPSF_points         = nbr_points_bsln + nbr_points_tDCS + nbr_points_post;
else
    nbr_MPSF_points         = nbr_points_bsln;
end

% Fill the MPSF array
MPSF_array                  = zeros(nbr_MPSF_points,nbr_muscles);
for i = 1:numel(pos_muscles)
    MPSF_array(1:nbr_points_bsln,i)     = arrayfun( @(x) x.emg.MPSF(pos_muscles(i)), sta_metrics_bsln )';
end

if exist('nbr_tDCS_trials','var')
    for i = 1:numel(pos_muscles)
        MPSF_array(nbr_points_bsln+1:nbr_points_bsln+nbr_points_tDCS,i)     = arrayfun( @(x) ...
                                            x.emg.MPSF(pos_muscles(i)), sta_metrics_tDCS )';
        MPSF_array(nbr_points_bsln+nbr_points_tDCS+1:end,i)                 = arrayfun( @(x) ...
                                            x.emg.MPSF(pos_muscles(i)), sta_metrics_post )';
    end
end

% Normalize the MPSF to the mean during the baseline, and compute SD
mean_MPSF_bsln              = mean(MPSF_array(1:nbr_points_bsln,:),1);
std_MPSF_bsln               = std(MPSF_array(1:nbr_points_bsln,:),1);

norm_MPSF_array             = MPSF_array / mean_MPSF_bsln;
norm_std_MPSF_bsln          = std_MPSF_bsln / mean_MPSF_bsln;


% -> Plot the MPSF

% Retrieve monkey, electrode and date information for figure title
if ~iscell(tDCS_exp.baseline_files)
    fig_title               = tDCS_exp(1).baseline_files(1:18);
else
    fig_title               = tDCS_exp(1).baseline_files{1}(1:18);
end

% Plot the raw MPSF 
for i = 1:nbr_muscles  
f_M                         = figure;
hold on;
plot( MPSF_array(1:nbr_points_bsln+1,i),'k','linewidth',2,'markersize',12)

if exist('nbr_tDCS_trials','var')
    plot( nbr_points_bsln+1:nbr_points_bsln+nbr_points_tDCS+1, MPSF_array(nbr_points_bsln+1:nbr_points_bsln+nbr_points_tDCS+1,i), 'r','linewidth',2 )
    plot( nbr_points_bsln+nbr_points_tDCS+1:size(MPSF_array,1), MPSF_array(nbr_points_bsln+nbr_points_tDCS+1:end,i),'b','linewidth',2 )

    plot( nbr_points_bsln+1:nbr_points_bsln+nbr_points_tDCS, MPSF_array(nbr_points_bsln+1:nbr_points_bsln+nbr_points_tDCS,i), ...
                                    'or','linewidth',2,'markersize',12)
    plot( nbr_points_bsln+nbr_points_tDCS+1:size(MPSF_array,1), MPSF_array(nbr_points_bsln+nbr_points_tDCS+1:end,i),...
                                    'ob','linewidth',2,'markersize',12)
end

plot( MPSF_array(1:nbr_points_bsln,i),'ok','linewidth',2,'markersize',12)

plot( [0 size(MPSF_array,1)+1], ones(1,2).*mean_MPSF_bsln(i), '.-', 'color', [.5 .5 .5], 'linewidth', 2 )
plot( [0 size(MPSF_array,1)+1], ones(1,2).*(std_MPSF_bsln(i)+mean_MPSF_bsln(i)),':', 'color', [.5 .5 .5], 'linewidth', 2 )
plot( [0 size(MPSF_array,1)+1], ones(1,2).*(-std_MPSF_bsln(i)+mean_MPSF_bsln(i)),':', 'color', [.5 .5 .5], 'linewidth', 2 )

set(gca,'FontSize',14), ylabel(['MPSF ' sta_metrics_bsln(1).emg.labels{pos_muscles(i)}(5:end)],'FontSize',14), xlabel('epoch nbr.'), set(gca,'TickDir','out')
xlim([0 nbr_MPSF_points+1]), ylim([0 ceil(max(MPSF_array(:,i)))+1])
title([fig_title ' - n = ' num2str(tDCS_exp.resp_per_win) ' resp/epoch'],'Interpreter', 'none')
legend('baseline','tDCS on','tDCS off','Location','northwest')
end

% Plot the normalized MPSF
for i = 1:size(norm_MPSF_array,2)  
f_nM                        = figure;
hold on;
plot( norm_MPSF_array(1:nbr_points_bsln+1,i),'k','linewidth',2,'markersize',12)

if exist('nbr_tDCS_trials','var')
    plot( nbr_points_bsln+1:nbr_points_bsln+nbr_points_tDCS+1, norm_MPSF_array(nbr_points_bsln+1:nbr_points_bsln+nbr_points_tDCS+1,i), 'r','linewidth',2 )
    plot( nbr_points_bsln+nbr_points_tDCS+1:size(norm_MPSF_array,1), norm_MPSF_array(nbr_points_bsln+nbr_points_tDCS+1:end,i),'b','linewidth',2 )

    plot( nbr_points_bsln+1:nbr_points_bsln+nbr_points_tDCS, norm_MPSF_array(nbr_points_bsln+1:nbr_points_bsln+nbr_points_tDCS,i), ...
                                    'or','linewidth',2,'markersize',12)
    plot( nbr_points_bsln+nbr_points_tDCS+1:size(norm_MPSF_array,1), norm_MPSF_array(nbr_points_bsln+nbr_points_tDCS+1:end,i),...
                                    'ob','linewidth',2,'markersize',12)
end

plot( norm_MPSF_array(1:nbr_points_bsln,i),'ok','linewidth',2,'markersize',12)

plot( [0 size(norm_MPSF_array,1)+1], ones(1,2), '.-', 'color', [.5 .5 .5], 'linewidth', 2 )
plot( [0 size(norm_MPSF_array,1)+1], ones(1,2).*(norm_std_MPSF_bsln(i)+1),':', 'color', [.5 .5 .5], 'linewidth', 2 )
plot( [0 size(norm_MPSF_array,1)+1], ones(1,2).*(-norm_std_MPSF_bsln(i)+1),':', 'color', [.5 .5 .5], 'linewidth', 2 )

set(gca,'FontSize',14), ylabel(['Normalized MPSF ' sta_metrics_bsln(1).emg.labels{pos_muscles(i)}(5:end)],'FontSize',14), xlabel('epoch nbr.'), set(gca,'TickDir','out')
xlim([0 nbr_MPSF_points+1]), ylim([0 ceil(max(norm_MPSF_array(:,i)))])
title([fig_title ' - n = ' num2str(tDCS_exp.resp_per_win) ' resp/epoch'],'Interpreter', 'none')
legend('baseline','tDCS on','tDCS off','Location','northwest')
end




% -------------------------------------------------------------------------
% 2. Plot the Evoked responses
for i = 1:nbr_muscles  
f_r                         = figure;
hold on

    
end



% Return variables
tDCS_results.baseline       = sta_metrics_bsln;
if exist('nbr_tDCS_trials','var')
    tDCS_results.tDCS       = sta_metrics_tDCS;
    tDCS_results.post       = sta_metrics_post;
end

% Add some meta information to the results
tDCS_results.meta.monkey    = 'A';


end
