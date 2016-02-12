%
% Function to plot the firing rate figures for analyze_tDCS_neural_data
%
% function fig_fr_tDCS_exp( neural_activity_bsln, neural_activity_tDCS, ...
%                           neural_activity_post, fig_title, sad_params, varargin )
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
                            binned_data_bsln, binned_data_tDCS, binned_data_post, fig_title, ...
                            sad_params, varargin )


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

nbr_neurons                     = size(mean_fr_bsln,2);


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
switch sad_params.behavior_data 
    case 'word'
        title([fig_title ' - word = ' num2str(hex2dec(num2str(sad_params.word_hex)))],'Interpreter','none')        
    otherwise
        title([fig_title ' - epoch duration = ' num2str(sad_params.win_duration) ' s'],'Interpreter','none')        
end


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
            
            % draw the markers
            plot( 1:nbr_points_bsln, grand_mean_fr_bsln,'ok','markersize',16, 'linewidth',2 )
            if nbr_points_tDCS > 0
                plot( nbr_points_bsln+1:nbr_points_bsln+nbr_points_tDCS, ...
                    grand_mean_fr_tDCS,'or','markersize',16, 'linewidth',2 )
            end
            if nbr_points_post > 0
                plot( nbr_points_bsln+nbr_points_tDCS+1:nbr_points_bsln+nbr_points_tDCS+nbr_points_post, ...
                    grand_mean_fr_post,'ob','markersize',16, 'linewidth',2 )
            end
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
    
%     % draw the markers
%     plot( 1:nbr_points_bsln, grand_mean_fr_bsln,'ok','markersize',12,'linewidth',2  )
%     plot( 1:nbr_points_bsln, grand_mean_fr_bsln+std_mean_fr_bsln,'ok','markersize',12,'linewidth',1  )
%     
%     if nbr_points_tDCS > 0
%         plot( nbr_points_bsln+1:nbr_points_bsln+nbr_points_tDCS, ...
%             grand_mean_fr_tDCS,'or','markersize',12,'linewidth',2 )
%         plot( nbr_points_bsln+1:nbr_points_bsln+nbr_points_tDCS, ...
%             grand_mean_fr_tDCS+std_mean_fr_tDCS,'or','markersize',12,'linewidth',1 )
%     end
%     if nbr_points_post > 0
%         plot( nbr_points_bsln+nbr_points_tDCS+1:nbr_points_bsln+nbr_points_tDCS+nbr_points_post, ...
%             grand_mean_fr_post,'ob','markersize',12,'linewidth',2 )
%         plot( nbr_points_bsln+nbr_points_tDCS+1:nbr_points_bsln+nbr_points_tDCS+nbr_points_post, ...
%             grand_mean_fr_post+std_mean_fr_post,'ob','markersize',12,'linewidth',1 )
%     end
    
% For a 'control' experiment...
else
    plot( mean_fr_bsln,'k','linewidth',1 )
    plot( 1:nbr_points_bsln, grand_mean_fr_bsln,'ok','markersize',12 )
end

% Set title, axes and format
set(gca,'FontSize',14), xlabel('epoch nbr.'), set(gca,'TickDir','out')
xlim([0 nbr_epochs+1]), ylabel(['Grand mean ' fr_ylabel])
switch sad_params.behavior_data 
    case 'word'
        title([fig_title ' - word = ' num2str(hex2dec(num2str(sad_params.word_hex)))],'Interpreter','none')        
    otherwise
        title([fig_title ' - epoch duration = ' num2str(sad_params.win_duration) ' s'],'Interpreter','none')        
end



% ------------------------
% 3. Colored surface plot of the firing rate

figure, hold on;
if ( nbr_epochs ~= nbr_points_bsln ) && ( nbr_points_bsln > 0 )

    aux_matrix_cp               = mean_fr_bsln';
    
    if nbr_points_tDCS > 0
        aux_matrix_cp           = [aux_matrix_cp, mean_fr_tDCS'];
    end
    if nbr_points_post > 0
        aux_matrix_cp           = [aux_matrix_cp, mean_fr_post'];
    end
    
    imagesc(aux_matrix_cp), colormap(jet), colorbar
    xlim([0.5 nbr_epochs+.5]), ylim([1 nbr_neurons]);
    set(gca,'FontSize',14), set(gca,'TickDir','out')
    xlabel('epoch nbr.'), ylabel('neuron')
    title([fig_title ' ' fr_ylabel],'Interpreter','none')

    % Add lines that separate blocks
    plot([nbr_points_bsln+.5 nbr_points_bsln+.5],[1 nbr_neurons-.5],'w','linewidth',2)
    plot([nbr_points_bsln+nbr_points_tDCS+.5 nbr_points_bsln+nbr_points_tDCS+.5],....
        [1 nbr_neurons-.5],'w','linewidth',2)
    
    % And add text to these lines
    if nbr_epochs ~= nbr_points_bsln
        text(1.5,nbr_neurons-3,'baseline','color','w')
    else
        text(1.5,nbr_neurons-3,'control exp.','color','w')
    end
    if nbr_points_tDCS > 0
        text(nbr_points_bsln+1,nbr_neurons-3,'tDCS on','color','w')
    end
    if nbr_points_post > 0
        text(nbr_points_bsln+nbr_points_tDCS+1,nbr_neurons-3,'tDCS off','color','w')
    end
end



% ------------------------
% 4. If the behavior is a word, plot the mean+SD firing rate in the
% specified window for each block 

if strcmp(sad_params.behavior_data,'word')

    % retrieve number of bins for each occurrence of the selected word, and
    % the number of times that word occurred
    bins_per_word           = size(neural_activity_bsln.analysis_windows,2);
    num_words               = size(neural_activity_bsln.analysis_windows,1);

    x_ax                    = linspace(sad_params.win_word(1),sad_params.win_word(2),bins_per_word);
    
    if ~strcmp(fr_ylabel(1:4),'norm')
    
        figure,hold on
        if nbr_points_bsln > 0
            plot(x_ax,mean(neural_activity_bsln.mean_firing_rate_in_win,2),'k','linewidth',2)
            plot(x_ax,mean(neural_activity_bsln.mean_firing_rate_in_win,2) + ...
                std(neural_activity_bsln.mean_firing_rate_in_win,0,2),'-.k','linewidth',1)
        end
        if nbr_points_tDCS > 0
            plot(x_ax,mean(neural_activity_tDCS.mean_firing_rate_in_win,2),'r','linewidth',2)
            plot(x_ax,mean(neural_activity_tDCS.mean_firing_rate_in_win,2) + ...
                std(neural_activity_tDCS.mean_firing_rate_in_win,0,2),'-.r','linewidth',1)
        end
        if nbr_points_post > 0
            plot(x_ax,mean(neural_activity_post.mean_firing_rate_in_win,2),'b','linewidth',2)
            plot(x_ax,mean(neural_activity_post.mean_firing_rate_in_win,2) + ...
                std(neural_activity_post.mean_firing_rate_in_win,0,2),'-.b','linewidth',1)
        end
        ylabel('firing rate (Hz)')    
        set(gca,'FontSize',14), xlabel('time around word (ms)'), set(gca,'TickDir','out')
        xlim([x_ax(1), x_ax(end)]),
        title([fig_title ' - neural activity around word = ' num2str(hex2dec(num2str(sad_params.word_hex)))],...
            'Interpreter','none')
    else
%         figure,hold on
%         if nbr_points_bsln > 0
%             plot(x_ax,mean(neural_activity_bsln.mean_firing_rate_in_win,2),'k','linewidth',2)
%             plot(x_ax,mean(neural_activity_bsln.mean_firing_rate_in_win,2) + ...
%                 std(neural_activity_bsln.mean_firing_rate_in_win,0,2),'-.k','linewidth',1)
%         end
%         if nbr_points_tDCS > 0
%             switch sad_params.normalization
%                 case 'mean_only'
%                     plot(x_ax,mean(neural_activity_tDCS.mean_firing_rate_in_win,2)/,'r','linewidth',2)
%                     plot(x_ax,mean(neural_activity_tDCS.mean_firing_rate_in_win,2) + ...
%                         std(neural_activity_tDCS.mean_firing_rate_in_win,0,2),'-.r','linewidth',1)
%                 case 'Z-score'
%                     
%             end
%         end
%         if nbr_points_post > 0
%             plot(x_ax,mean(neural_activity_post.mean_firing_rate_in_win,2),'b','linewidth',2)
%             plot(x_ax,mean(neural_activity_post.mean_firing_rate_in_win,2) + ...
%                 std(neural_activity_post.mean_firing_rate_in_win,0,2),'-.b','linewidth',1)
%         end
%         ylabel('normalized firing rate (Hz)')
%         set(gca,'FontSize',14), xlabel('time around word (ms)'), set(gca,'TickDir','out')
%         xlim([x_ax(1), x_ax(end)]),
%         title([fig_title ' - neural activity around word = ' num2str(hex2dec(num2str(sad_params.word_hex)))],...
%             'Interpreter','none')
    end
end


