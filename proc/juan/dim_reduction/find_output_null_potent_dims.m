%
% Fits a linear model that regresses neural activity onto muscle activity.
% The model has the form M = W·N, where N is an n-by-t matrix of neural
% dynamics comprising n "neural synergies" (typically obtained with PCA or
% FA), M is an m-by-t matrix of muscle synergies (typically obtained with
% NMF or PCA), and W is an m-by-n matrix; the model. The model uses a
% single bin of neural and muscle activity, imposing an user-defined lag
% between them. 
% Data should be passed as averaged neural and muscle synergies per target
% and/or concatenated for all targets.
%
%
%   function lin_model = find_output_null_potent_dims( single_trial_data, ...
%                           neural_dims, muscle_dims, neural_to_EMG_lag, varargin )
%
%
% Inputs (opt)                  : [default]
%   single_trial_data           : single_trial_data struct
%   neural_dims                 : array with neural synergies; e.g. the
%                                   projections onto neural PCs  
%   muscle_dims                 : array with muscle synergies; e.g. the
%                                   projections onto muscle PCs or NMFs 
%   neural_to_EMG_lag           : lag of EMGs w.r.t. neural activity (s) 
%                                   (> 0 => EMG follows] 
%   (dim_red_emg)               : dim_red_FR struct. To compute metrics
%                                   based on eigenvalues of PC
%                                   decomposition of muscle activity. If
%                                   not passed, it assumes muscle synergies
%                                   were obtained with NMF and these
%                                   normalized metrics are obtained based
%                                   on the weight matrix
%   (plot_yn)                   : [true] display all plots
%   (label)                     : the type of trial, for plotting
%
%
% Ouput:
%   lin_model                   : struct with linear fits of the model M =
%                                   W · N, goodness of fit metrics, and
%                                   singular value decomposition of W
%                                   including the task-relevant and null
%                                   spaces
%
%

function lin_model = find_output_null_potent_dims( single_trial_data, neural_dims, ...
            muscle_dims, neural_to_EMG_lag, varargin )


% get inputs
if nargin >= 5
    dim_red_emg             = varargin{1};
end
if nargin >= 6
    plot_yn                 = varargin{2};
else
    plot_yn                 = true;
end
if nargin == 7
    label                   = varargin{3};
else
    label                   = '';
end


% do you want to normalize the neural and EMG data so they vary between
% -1:1? 
% --> ToDo: see if it makes sense
norm_data                   = false;


nbr_targets                 = length(single_trial_data);
nbr_neural_dims             = length(neural_dims);
nbr_muscle_dims             = length(muscle_dims);


% ------------------------------------------------------------------------
% Multilinear regression of neural PCs into muscle PCs
%
% -- fit a model M = W·N, where M is a matrix with muscle activities, N is
% a matrix with projection onto neural PCs, and W is the linear model that
% relates them
%

% fit model for this lag
lin_model                   = cell(1,nbr_targets+1);
for i = 1:nbr_targets+1 % do for all the targets, and the concatenated data
    
    % apply lag to EMGs
    indx_emg                = round(neural_to_EMG_lag/single_trial_data{1}.bin_size);
    
    % get matrices emg_this_lag and neural_this_lag, which have the neural
    % and EMG data with the imposed lag and cut to the same length
    if i <= nbr_targets
        if indx_emg > 0
            emg_this_lag    = single_trial_data{i}.emg_scores.mn(1+indx_emg:end,...
                                muscle_dims);
            neural_this_lag = single_trial_data{i}.neural_scores.mn(1:end-indx_emg,...
                                neural_dims);
        else
            emg_this_lag    = single_trial_data{i}.emg_scores.mn(1:end+indx_emg,...
                                muscle_dims);
            neural_this_lag = single_trial_data{i}.neural_scores.mn(1-indx_emg:end,...
                                neural_dims);
        end
    % for all concatenated trials: align and cut the data from each trial
    % and concatenate them
    else
        emg_this_lag        = [];
        neural_this_lag     = [];
        if indx_emg > 0
            for t = 1:nbr_targets
                emg_this_lag = [emg_this_lag; single_trial_data{t}.emg_scores.mn(1+indx_emg:end,...
                                muscle_dims)];
                neural_this_lag = [neural_this_lag; single_trial_data{t}.neural_scores.mn(1:end-indx_emg,...
                                neural_dims)];
            end
        else
            for t = 1:nbr_targets
                emg_this_lag = [emg_this_lag; single_trial_data{t}.emg_scores.mn(1:end+indx_emg,...
                                muscle_dims)];
                neural_this_lag = [neural_this_lag; single_trial_data{t}.neural_scores.mn(1-indx_emg:end,...
                                neural_dims)];
            end
        end
    end
    
    
    % ---------------------------------------------------------------------
    % Normalize the data, if chosen
    if norm_data
        for ii = 1:nbr_muscle_dims
            emg_this_lag(:,ii)  = emg_this_lag(:,ii)/peak2peak(emg_this_lag(:,ii));
        end
        for ii = 1:nbr_neural_dims
            neural_this_lag(:,ii) = neural_this_lag(:,ii)/peak2peak(neural_this_lag(:,ii));
        end
    end
    
    
    % ---------------------------------------------------------------------
    % Linear model to regress neural "synergies" onto each muscle synergy
    
    W                       = zeros(nbr_muscle_dims,nbr_neural_dims);
    % intercepts
    W_offsets               = zeros(nbr_muscle_dims,1);
    R2                      = zeros(nbr_muscle_dims,1);
    fit_w_interc            = zeros(nbr_muscle_dims,size(emg_this_lag,1));
    
    % fit a single MISO model for each muscle synergy
    for e = 1:nbr_muscle_dims
        aux_lm              = fitlm(neural_this_lag,emg_this_lag(:,e));
        % take the coefficients of the model and store them into matrix W
        W(e,:)              = table2array(aux_lm.Coefficients(2:end,1))';
        % store the intercept
        W_offsets(e)        = table2array(aux_lm.Coefficients(1,1));
        R2(e)               = aux_lm.Rsquared.Ordinary; 
        fit_w_interc(e,:)   = aux_lm.Fitted';
    end
    
    % store values
    lin_model{i}.neural_dims        = neural_dims;
    lin_model{i}.muscle_dims        = muscle_dims;
    lin_model{i}.W                  = W;
    lin_model{i}.W_intercept        = W_offsets;
    lin_model{i}.neural_to_EMG_lag  = neural_to_EMG_lag;
    % compute model fit without intercept
    lin_model{i}.model_fit          = W*neural_this_lag';
    % and with intercept
    lin_model{i}.model_fit_w_interc = fit_w_interc;
    lin_model{i}.R2                 = R2;
    
    % compute weighed R^2
    % -- For PCA of the EMGs: it is the sum of the R^2 of the fit of muscle
    % component 'n' multiplied by its associated eigenvalue, and divided by
    % the sum of the 1:muscle_dims eigenvalues
    % -- For NMF of the EMGs: it is obtained by multiplying by the sum of
    % weights for that 'factor,' and divided by the sum of the weights for
    % all 'factors'  
    if exist('dim_red_emg','var')
        switch dim_red_emg.method
            case 'pca'
                lin_model{i}.weighed_R2     = sum(R2.*dim_red_emg.eigen(muscle_dims)...
                                        /sum(dim_red_emg.eigen(muscle_dims)));
            case 'nnmf'
                lin_model{i}.weighed_R2     = sum(R2'.*sum(dim_red_emg.w')...
                                        /sum(sum(dim_red_emg.w)));
            case 'none'
                lin_model{i}.weighed_R2     = sum(R2'.*sum(dim_red_emg.w')...
                                        /sum(sum(dim_red_emg.w)));
        end
    end
    
    % store raw data
    lin_model{i}.emg_data           = emg_this_lag';
    lin_model{i}.neural_data        = neural_this_lag';
    if i <= nbr_targets
        lin_model{i}.target         = i;
    else
        lin_model{i}.target         = 'all';
    end
end


% ------------------------------------------------------------------------
% Singular Value Decomposition of the model matrices W, to find the output
% null and task-related spaces 

for i = 1:nbr_targets+1 
    % Do SVD
    [U, S, V]                       = svd(lin_model{i}.W);
    
    % store matrices that define the task-relevant and null spaces
    lin_model{i}.svdec.V_task       = V(:,1:nbr_muscle_dims);
    lin_model{i}.svdec.V_null       = V(:,nbr_muscle_dims+1:end);
    
    % Project the data onto the task relevant space
    lin_model{i}.svdec.task_relev   = V(:,1:nbr_muscle_dims)'*...
                                        lin_model{i}.neural_data;

    % and the null space
    lin_model{i}.svdec.null_space   = V(:,nbr_muscle_dims+1:end)'*...
                                        lin_model{i}.neural_data;
   
    % compute weights of each neural synergy on each of the task-related
    % dimensions and output null dimensions ...
    lin_model{i}.svdec.task_relev_weights   = zeros(nbr_neural_dims,nbr_muscle_dims);
    lin_model{i}.svdec.null_weights         = zeros(nbr_neural_dims,nbr_neural_dims-nbr_muscle_dims);
    for d = 1:nbr_muscle_dims
        lin_model{i}.svdec.task_relev_weights(:,d) = abs(V(:,d))...
                                                        .*peak2peak(lin_model{i}.neural_data,2);
    end
    for d = nbr_muscle_dims+1:nbr_neural_dims
        lin_model{i}.svdec.null_weights(:,d-nbr_muscle_dims) = ...
                                                        abs(V(:,d)).*peak2peak(lin_model{i}.neural_data,2);
    end
    
    % ...and the summed weight for all the task-related and null dimensions
    % respectively
    lin_model{i}.svdec.summed_task_relev_weights = sum(lin_model{i}.svdec.task_relev_weights,2);
    lin_model{i}.svdec.summed_null_space_weights = sum(lin_model{i}.svdec.null_weights,2);
    
                                    
    % store SVD results
    lin_model{i}.svdec.U            = U;
    lin_model{i}.svdec.S            = S;
    lin_model{i}.svdec.V            = V;
end


% ------------------------------------------------------------------------
% PLOTS

if plot_yn

    % plot model fits
    length_lm                   = length(lin_model);
    colors_targets              = parula(nbr_targets);
    colors_targets              = [colors_targets; 0 0 0];    
    nbr_rows                    = floor(sqrt(length_lm));
    nbr_cols                    = ceil(length_lm/nbr_rows);
    % create cell w legends
    lgnd                        = cell(1,nbr_muscle_dims*2);
    for i = 1:nbr_muscle_dims
        lgnd{i}                 = ['proj. muscle comp. ' num2str(i)];
        lgnd{i+nbr_muscle_dims} = ['model fit proj. comp. ' num2str(i)];
    end
    % create cell w titles
    ttls                        = cell(1,nbr_targets+1);
    for t = 1:nbr_targets+1
        if t <= nbr_targets
            ttls{t}             = ['target ' num2str(t)'];
        else
            ttls{t}             = 'all targets';
        end
    end

    figure('units','normalized','outerposition',[0 0 1 1])
    for t = 1:length_lm
        % create time vector -length may be different depending on trial
        t_plot                  = 0:single_trial_data{1}.bin_size:...
                                    single_trial_data{1}.bin_size*...
                                    (size(lin_model{t}.emg_data,2)-1);
        subplot(nbr_rows,nbr_cols,t), hold on
        plot(t_plot,[lin_model{t}.emg_data; lin_model{t}.model_fit_w_interc]',...
            'linewidth',3)
        set(gca,'TickDir','out'),set(gca,'FontSize',16);
        title(ttls{t},'color',colors_targets(t,:))
        if t >= nbr_cols*(nbr_rows-1)
            xlabel('time (s)')
        end
        if t == 1 || rem(t,nbr_cols+1) == 0
            ylabel('actual vs. predicted EMG')
        end
        if t == length_lm
            legend(lgnd,'Location','southeast','FontSize',16)
        end
    end


    % ------------------------------
    % plot R^2 fits

    % get mean and SD fits per target and for all targets
    mean_R2                     = zeros(1,length_lm);
    std_R2                      = zeros(1,length_lm);
    for i = 1:length_lm
        mean_R2(i)              = mean(lin_model{i}.R2);
        std_R2(i)               = std(lin_model{i}.R2);
    end

    figure,hold on
    for i = 1:nbr_targets+1
        errorbar(i,mean_R2(i),std_R2(i),'color',colors_targets(i,:),...
            'marker','o','markersize',14,'linewidth',4)
    end
    set(gca,'TickDir','out'),set(gca,'FontSize',14),xlim([0 nbr_targets+2])
    set(gca,'XTick',1:length_lm),
    set(gca,'XTickLabel',ttls),set(gca,'XTickLabelRotation',45)
    ylabel('R^2 model fit'),ylim([0 1])

    % get weighed R^2 per task -- weighed R^2 is obtained as the sum of the
    % R^2 of the fit of muscle component 'n' multiplied by the eigenvalue
    % associated with muscle component 'n', and divided by the sum of the
    % eigenvalues associated with all the muscle components included in the
    % analysis
    if exist('dim_red_emg','var')
        figure,hold on
        for i = 1:length_lm
            bar(i,lin_model{i}.weighed_R2,'facecolor',colors_targets(i,:))
        end
        set(gca,'TickDir','out'),set(gca,'FontSize',14),xlim([0 nbr_targets+2])
        set(gca,'XTick',1:length_lm),
        set(gca,'XTickLabel',ttls),set(gca,'XTickLabelRotation',45)
        xlim([0 nbr_targets+2])
        ylabel('weighed R^2 model fit'),ylim([0 1])
    end

    
    % plots for testing -- plot fits for lag == 0
    % task relevant and output null space
    if dim_red_emg.method ~= 'none'
        figure,
        subplot(321),plot(lin_model{nbr_targets+1 }.emg_data(1:nbr_muscle_dims,:)','linewidth',2)
        ylabel('muscle synergies')
        set(gca,'TickDir','out'),set(gca,'FontSize',14)
        title(label)
        subplot(323),plot(-lin_model{nbr_targets+1 }.svdec.task_relev(1:nbr_muscle_dims,:)','linewidth',2)
        ylabel('task-relevant space')
        set(gca,'TickDir','out'),set(gca,'FontSize',14)
        subplot(325),plot(lin_model{nbr_targets+1 }.svdec.null_space(1:nbr_muscle_dims,:)','linewidth',2)
        ylabel('null space'), xlabel('sample nbr')
        set(gca,'TickDir','out'),set(gca,'FontSize',14)
        subplot(222),plot(lin_model{nbr_targets+1 }.svdec.task_relev(1:nbr_muscle_dims,:)',...
            lin_model{nbr_targets+1}.emg_data(1:nbr_muscle_dims,:)','marker','.','linestyle','none')
        ylabel('muscle synergies'),xlabel('task-relevant space')
        set(gca,'TickDir','out'),set(gca,'FontSize',14)
        subplot(224),plot(lin_model{nbr_targets+1 }.svdec.null_space(1:nbr_muscle_dims,:)',...
            lin_model{nbr_targets+1}.emg_data(1:nbr_muscle_dims,:)','marker','.','linestyle','none')
        ylabel('muscle synergies'),xlabel('null space')
        set(gca,'TickDir','out'),set(gca,'FontSize',14)
    end
    
    % plot  weights for ouput null and potent spaces
    for i = 1:nbr_targets
        cur_tgt = i;
        figure,
        subplot(221),imagesc(lin_model{cur_tgt}.svdec.task_relev_weights),colorbar
        set(gca,'TickDir','out'),set(gca,'FontSize',14),set(gca,'XTick',[])
        ylabel('neural synergy'),xlabel('weights task-related space'),title(label)
        subplot(222),imagesc(lin_model{cur_tgt}.svdec.null_weights),colorbar
        set(gca,'TickDir','out'),set(gca,'FontSize',14)
        set(gca,'XTick',1:(nbr_neural_dims-nbr_muscle_dims))
        xlabel('weights null space')

        subplot(223),imagesc(lin_model{cur_tgt}.svdec.summed_task_relev_weights),colorbar
        set(gca,'TickDir','out'),set(gca,'FontSize',14)
        set(gca,'XTick',[]), ylabel('neural synergy'),xlabel('muscle synergy weights'),title(label)
        subplot(224),imagesc(lin_model{cur_tgt}.svdec.summed_null_space_weights),colorbar
        set(gca,'TickDir','out'),set(gca,'FontSize',14),xlabel('output null weights')
        set(gca,'XTick',[])
    end
end


