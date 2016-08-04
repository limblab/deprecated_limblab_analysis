%
% Do crossvalidation of PCs. The code works both cross-validating across
% time and neural channels.
%
%   stats = mfxval_pcs( bdf, neural_chs, xval_mode, xval_param, varargin )
%
% Inputs (opt)          : [default]
%   bdf                 : bdf struct 
%   neural_chs          : neural channels that define the complete data (in
%                           case the user wants to discard some)
%   xval_mode           : 'time' will do multifold cross-validation by
%                           dividing the data into n folds, then computing
%                           ..................; 'channels' will
%                           cross-validate by computing PC using m
%                           channels, projecting the data onto the time
%                           domain, and comparing these projections to
%                           those obtained with the PCs computed using all
%                           the electrodes. This is repeated 'nbr_reps'
%                           times 
%   xval_param          : if 'xval_mode' = 'time', length of the folds (s),
%                           if 'xval_mode' = 'channels', percentage of
%                           channels that will be used (0:1)
%   (nbr_reps)          : [100] nbr_repetitions for xval_mode = 'channels', 
%                           
% Outputs:
%   stats               : canonical correlations and statistics comparing
%                           the PC projections with the complete set of
%                           electrodes vs. the subsampled sets
%
%

function stats = mfxval_pcs( bdf, neural_chs, xval_mode, xval_param, varargin )


% number of PCs that will be compared across the total and subsampled
% datasets 
nbr_pcs_comp                = 20;

% read input parameters
switch xval_mode
    case 'time'
        fold_length         = xval_param;
        if nargin == 5
            warning('input arg 4 will be ignored in time mode');
        end
    case 'channels'
        perc_chs            = xval_param;
        all_chs             = double(arrayfun(@(x) x.id(1), bdf.units));
        discard_chs         = setdiff(all_chs, neural_chs);
        if nargin == 5
            nbr_reps        = varargin{1};
        else
            nbr_reps        = 100;
        end
end

nbr_neural_chs              = numel(neural_chs);


% -------------------------------------------------------------------------
% do
switch xval_mode
    % --------------------------------------------------
    case 'time'
        error('not implemented yet')
    % --------------------------------------------------
    case 'channels'
        % preallocate matrix for storing random channels
        chs                 = zeros(nbr_reps,...
                                round(nbr_neural_chs*perc_chs));
        % preallocate matrix for storing CC correlations
        R_CC                = zeros(nbr_pcs_comp,nbr_reps);
        R2_CC               = zeros(nbr_pcs_comp,nbr_reps);
%         % preallocate matrix for storing corr with Procrustes 
%         R2_Proc             = zeros(nbr_pcs_comp,nbr_reps);
%         % stats_Proc          = zeros(nbr_pcs_comp,nbr_reps);

                        
        % smooth the FRs
        smoothed_FR         = gaussian_smoothing2(bdf,'sqrt',0.02,0.05); %#ok<AGROW>                       
        % do PCA of all the selected channels
        dim_red_FR          = dim_reduction(smoothed_FR,'pca',discard_chs);
                        
        for i = 1:nbr_reps
            % randomly choose a subset of perc_chs
            chs(i,:)        = datasample(1:nbr_neural_chs,...
                            round(nbr_neural_chs*perc_chs),'Replace',false);
            discard_chs_this = setdiff(all_chs,sort(chs(i,:)));
            % and do pca
            dim_red_FR_xval = dim_reduction(smoothed_FR,'pca',discard_chs_this);
            % compare the dynamics of the projections using all the
            % channels, and the randonmly chosen subset of percentage of channels
            [~,~,R_CC(:,i),U,V,stats_CC{i}] = canoncorr(dim_red_FR.scores(:,1:nbr_pcs_comp),...
                            dim_red_FR_xval.scores(:,1:nbr_pcs_comp)); %#ok<AGROW>
            R2_CC(:,i)      = CalculateR2(U,V);
%             % run Procrustes algorithm 
%             [~,Z,transf]    = procrustes(dim_red_FR.scores(:,1:nbr_pcs_comp),...
%                                 dim_red_FR_xval.scores(:,1:nbr_pcs_comp));
%             R2_Proc(:,i)    = CalculateR2(dim_red_FR.scores(:,1:nbr_pcs_comp),Z);
%             % stats_Proc      = diag(P_mtrx_Proc);
            
        end
        
        % append statistics
        stats.R_CC          = R_CC;
        stats.mean_R_CC     = mean(R_CC,2);
        stats.std_R_CC      = std(R_CC,0,2);
        stats.stats_CC      = stats_CC;
        stats.R2_CC         = R2_CC;
        stats.mean_R2_CC    = mean(R2_CC,2);
        stats.std_R2_CC     = std(R2_CC,0,2);
        
%         stats.R_Proc        = R2_Proc;
%         % stats.stats_Proc    = stats_Proc;
%         stats.mean_R2_Proc  = mean(R2_Proc,2);
%         stats.std_R2_Proc   = std(R2_Proc,0,2);
end

% -------------------------------------------------------------------------
% plot
switch xval_mode
    case 'time'
        error('not implemented yet')        
    case 'channels'
        % CCs of Canonical correlation
        figure,plot(R_CC,'color',[.6 .6 .6]), hold on
%         % R2 CCs
%         plot(R2_CC,'color',[1 .6 0]), hold on
        plot(stats.mean_R_CC,'linewidth',4,'color','k')
        plot(stats.mean_R_CC+stats.std_R_CC,'linewidth',4,'color','k','linestyle','-.')
        plot(stats.mean_R_CC-stats.std_R_CC,'linewidth',4,'color','k','linestyle','-.')
        
%         plot(stats.mean_R2_CC,'linewidth',4,'color','r')
%         plot(stats.mean_R2_CC+stats.std_R2_CC,'linewidth',4,'color','r','linestyle','-.')
%         plot(stats.mean_R2_CC-stats.std_R2_CC,'linewidth',4,'color','r','linestyle','-.')
        
        set(gca,'TickDir','out'),set(gca,'FontSize',14), ylim([0 1])
        xlabel('projection nbr.'),ylabel('canonical correlation')
        
%         % R2 Procrustes vs R2 CC
%         figure,plot(R2_Proc,'color',[.6 .6 .6]), hold on
%         plot(R2_CC,'color',[1 .6 0]), hold on
% 
%         plot(stats.mean_R2_Proc,'linewidth',4,'color','k')
%         plot(stats.mean_R2_Proc+stats.std_R2_Proc,'linewidth',4,'color','k','linestyle','-.')
%         plot(stats.mean_R2_Proc-stats.std_R2_Proc,'linewidth',4,'color','k','linestyle','-.')
%         
%         plot(stats.mean_R2_CC,'linewidth',4,'color','r')
%         plot(stats.mean_R2_CC+stats.std_R2_CC,'linewidth',4,'color','r','linestyle','-.')
%         plot(stats.mean_R2_CC-stats.std_R2_CC,'linewidth',4,'color','r','linestyle','-.')
%         
%         set(gca,'TickDir','out'),set(gca,'FontSize',14), ylim([0 1])
%         xlabel('projection nbr.'),ylabel('R2 after Procrustes (black) vs. CC (red)')
%         title(['preservation of neural projections after loosing ' num2str((1-perc_chs)*100) ...
%             ' % of the channels'])
end