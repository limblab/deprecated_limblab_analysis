%
% Function to plot the firing rate figures for analyze_tDCS_neural_data
%
% function fig_fr_tDCS_exp( neural_activity_bsln, neural_activity_tDCS, ...
%                           neural_activity_post, fig_title, win_duration, varargin )
%
%       The number of epochs for each 'block' (bsln, tDCS, post) can be
%       passed as arguments 6-8
%           varargin{1}:        nbr_points_bsln
%           varargin{2}:        nbr_points_tDCS
%           varargin{3}:        nbr_points_post
%
%       Optional argument 9 tells the function if we also want to print the
%       normalized firing rate
%           varargin{4}:        'norm' or 'not'

function fig_fr_tDCS_exp( neural_activity_bsln, neural_activity_tDCS, neural_activity_post, ...
                            fig_title, win_duration, varargin )


% Read or compute the number of 'epochs' (of duration win_duration) in each
% of the blocks of the experiment
if nargin >= 8
    nbr_points_bsln             = varargin{1};
    nbr_points_tDCS             = varargin{2};
    nbr_points_post             = varargin{3};
else
    
    if ~isempty(neural_activity_bsln)
        nbr_points_bsln         = size(neural_activity_bsln.mean_firing_rate,1);
    else
        nbr_points_bsln         = 0;
    end
    
    if ~isempty(neural_activity_tDCS)
        nbr_points_tDCS         = size(neural_activity_tDCS.mean_firing_rate,1);
    else
        nbr_points_tDCS         = 0;
    end
    
    if ~isempty(neural_activity_post)
        nbr_points_post         = size(neural_activity_post.mean_firing_rate,1);
    else
        nbr_points_post         = 0;
    end
end

nbr_epochs                      = nbr_points_bsln + nbr_points_tDCS + nbr_points_post;


% -------------------------------------------------------------------------
% Create the plots - the function will plot the raw, or normalized
% quantities


% This will assign the raw or normalized firing rates, depending on what we
% want to plot 
if nargin < 9
    
    mean_fr_bsln                = neural_activity_bsln.mean_firing_rate;
    mean_fr_tDCS                = neural_activity_tDCS.mean_firing_rate;
    mean_fr_post                = neural_activity_post.mean_firing_rate;
    
    fr_ylabel                   = 'firing rate (Hz)';
elseif strncmp(varargin{4},'norm',length(varargin{4}))
    
    mean_fr_bsln                = neural_activity_bsln.norm_firing_rate;
    mean_fr_tDCS                = neural_activity_tDCS.norm_firing_rate;
    mean_fr_post                = neural_activity_post.norm_firing_rate;
    
    fr_ylabel                   = 'normalized firing rate (Hz)';
else
    mean_fr_bsln                = neural_activity_bsln.mean_firing_rate;
    mean_fr_tDCS                = neural_activity_tDCS.mean_firing_rate;
    mean_fr_post                = neural_activity_post.mean_firing_rate;
    
    fr_ylabel                   = 'firing rate (Hz)';    
end


% 1. Mean firing rate vs. epoch number plot 

% For a tDCS experiment ...
figure, hold on;
if ( nbr_epochs ~= nbr_points_bsln ) && ( nbr_points_bsln > 0 )
    
    % draw the lines for the plot
    plot( 1:nbr_points_bsln+1, [mean_fr_bsln; ...
        mean_fr_tDCS(1,:)],'k','linewidth',1 )
    
    if nbr_points_tDCS > 0
        if nbr_points_post > 0
            plot( nbr_points_bsln+1:nbr_points_bsln+nbr_points_tDCS+1, ...
                [mean_fr_tDCS; mean_fr_post(1,:)],...
                'r','linewidth',1 )
            plot( nbr_points_bsln+nbr_points_tDCS+1:nbr_epochs, ...
                mean_fr_post,'b','linewidth',1 )
        else
            plot( nbr_points_bsln+1:nbr_points_bsln+nbr_points_tDCS, ...
                mean_fr_tDCS,'r','linewidth',1 )
        end
    elseif nbr_points_post > 0
        plot( nbr_points_bsln+1:nbr_points_bsln+nbr_points_post, mean_fr_post,...
            'b','linewidth',1 )
    end
    
    % draw the markers
    plot( 1:nbr_points_bsln, mean_fr_bsln,'ok','markersize',12 )
    
    if nbr_points_tDCS > 0
        plot( nbr_points_bsln+1:nbr_points_bsln+nbr_points_tDCS, ...
            mean_fr_tDCS,'or','markersize',12 )
    end
    if nbr_points_post > 0
        plot( nbr_points_bsln+nbr_points_tDCS+1:nbr_points_bsln+nbr_points_tDCS+nbr_points_post, ...
            mean_fr_post,'ob','markersize',12 )
    end
    
% For a 'control' experiment...
else
    plot( mean_fr_bsln,'k','linewidth',1 )
    plot( 1:nbr_points_bsln, mean_fr_bsln,'ok','markersize',12 )
end

% Set title, axes and format
set(gca,'FontSize',14), xlabel('epoch nbr.'), set(gca,'TickDir','out')
xlim([0 nbr_epochs+1]), ylabel(fr_ylabel)
title([fig_title ' - epoch duration = ' num2str(win_duration) ' s'],'Interpreter','none')



% ------------------------
% 2. Plot the mean change in firing rate

% Compute the 'grand' mean and SD firing rate per epoch
grand_mean_fr_bsln              = mean(mean_fr_bsln,2);
std_mean_fr_bsln                = std(mean_fr_bsln,0,2);
if nbr_points_tDCS > 0
    grand_mean_fr_tDCS          = mean(mean_fr_tDCS,2);
    std_mean_fr_tDCS            = std(mean_fr_tDCS,0,2);
end
if nbr_points_post > 0
    grand_mean_fr_post          = mean(mean_fr_post,2);
    std_mean_fr_post            = std(mean_fr_post,0,2);
end

figure, hold on;
if ( nbr_epochs ~= nbr_points_bsln ) && ( nbr_points_bsln > 0 )
    
    % draw the lines for the plot
    plot( 1:nbr_points_bsln+1, [grand_mean_fr_bsln; ...
        grand_mean_fr_tDCS(1,:)],'k','linewidth',2 )
    plot( 1:nbr_points_bsln+1, [grand_mean_fr_bsln+std_mean_fr_bsln; ...
        grand_mean_fr_tDCS(1,:)+std_mean_fr_tDCS(1,:)],'-.k','linewidth',1 )
    
    if nbr_points_tDCS > 0
        if nbr_points_post > 0
            plot( nbr_points_bsln+1:nbr_points_bsln+nbr_points_tDCS+1, ...
                [grand_mean_fr_tDCS; grand_mean_fr_post(1,:)],...
                'r','linewidth',2 )
            plot( nbr_points_bsln+1:nbr_points_bsln+nbr_points_tDCS+1, ...
                [grand_mean_fr_tDCS+std_mean_fr_tDCS; grand_mean_fr_post(1,:)+...
                std_mean_fr_post(1,:)],'-.r','linewidth',1 )
            
            plot( nbr_points_bsln+nbr_points_tDCS+1:nbr_epochs, ...
                grand_mean_fr_post,'b','linewidth',2 )
            plot( nbr_points_bsln+nbr_points_tDCS+1:nbr_epochs, ...
                grand_mean_fr_post+std_mean_fr_post,'-.b','linewidth',1 )
        else
            plot( nbr_points_bsln+1:nbr_points_bsln+nbr_points_tDCS, ...
                grand_mean_fr_tDCS,'r','linewidth',2 )
            plot( nbr_points_bsln+1:nbr_points_bsln+nbr_points_tDCS, ...
                grand_mean_fr_tDCS+std_mean_fr_tDCS,'-.r','linewidth',1 )
        end
    elseif nbr_points_post > 0
        plot( nbr_points_bsln+1:nbr_points_bsln+nbr_points_post,...
            grand_mean_fr_post,'b','linewidth',1 )
        plot( nbr_points_bsln+1:nbr_points_bsln+nbr_points_post,...
            grand_mean_fr_post+std_mean_fr_post,'-.b','linewidth',1 )
    end
    
    % draw the markers
    plot( 1:nbr_points_bsln, grand_mean_fr_bsln,'ok','markersize',12,'linewidth',2  )
    plot( 1:nbr_points_bsln, grand_mean_fr_bsln+std_mean_fr_bsln,'ok','markersize',12,'linewidth',1  )
    
    if nbr_points_tDCS > 0
        plot( nbr_points_bsln+1:nbr_points_bsln+nbr_points_tDCS, ...
            grand_mean_fr_tDCS,'or','markersize',12,'linewidth',2 )
        plot( nbr_points_bsln+1:nbr_points_bsln+nbr_points_tDCS, ...
            grand_mean_fr_tDCS+std_mean_fr_tDCS,'or','markersize',12,'linewidth',1 )
    end
    if nbr_points_post > 0
        plot( nbr_points_bsln+nbr_points_tDCS+1:nbr_points_bsln+nbr_points_tDCS+nbr_points_post, ...
            grand_mean_fr_post,'ob','markersize',12,'linewidth',2 )
        plot( nbr_points_bsln+nbr_points_tDCS+1:nbr_points_bsln+nbr_points_tDCS+nbr_points_post, ...
            grand_mean_fr_post+std_mean_fr_post,'ob','markersize',12,'linewidth',1 )
    end
    
% For a 'control' experiment...
else
    plot( mean_fr_bsln,'k','linewidth',1 )
    plot( 1:nbr_points_bsln, grand_mean_fr_bsln,'ok','markersize',12 )
end

% Set title, axes and format
set(gca,'FontSize',14), xlabel('epoch nbr.'), set(gca,'TickDir','out')
xlim([0 nbr_epochs+1]), ylabel(['Grand mean ' fr_ylabel])
title([fig_title ' - epoch duration = ' num2str(win_duration) ' s'],'Interpreter','none')



% ------------------------
% 3. Plot that represents the relative change in firing rate




