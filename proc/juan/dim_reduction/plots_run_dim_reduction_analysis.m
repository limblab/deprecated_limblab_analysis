
% save figs yes/no
save_figs                   = true;


% create a vector to give each trace a different color
aux.cols_plot               = jet(size(analysis.comb_tasks,1));
% cell with legend
aux.legends_plot            = cell(size(analysis.comb_tasks,1),1);
for i = 1:size(analysis.comb_tasks,1)
    aux.legends_plot{i}     = [labels{analysis.comb_tasks(i,1)} ' vs. ' ...
                                labels{analysis.comb_tasks(i,2)}];
end


% *** Neural data: 

% -------------------------------------------------------------------------
% Plot eigenvalue distribution
nbr_comps_max               = aux.last_dim;
figs.eigenval = figure('units','normalized','outerposition',[0 0 1 1]);
for i = 1:length(dim_red_FR)
    subplot(2,length(dim_red_FR),i),bar(dim_red_FR{i}.eigen/sum(dim_red_FR{i}.eigen),...
        'FaceColor','c')
    set(gca,'TickDir','out'),set(gca,'FontSize',18),xlim([0 nbr_comps_max+1]),
    title(labels{i}), ylim([0 0.25])
    
    subplot(2,length(dim_red_FR),i+length(dim_red_FR)),bar(cumsum(dim_red_FR{i}.eigen)/...
        sum(dim_red_FR{i}.eigen),'FaceColor','c')
    set(gca,'TickDir','out'),set(gca,'FontSize',18),xlabel('comp. nbr.'),xlim([0 nbr_comps_max+1]),
    title(labels{i}), ylim([0 1])
    if i == 1
        subplot(2,length(dim_red_FR),i), ylabel('% norm. variance per comp.')
        subplot(2,length(dim_red_FR),i+length(dim_red_FR)), ylabel('% cum. explained norm. variance')
    end
end

% -------------------------------------------------------------------------
% Plot angle as fcn number comps
figs.angle_comps = figure; 
hold on
plot(90*analysis.neural.mean_var_fcn_eigen,'color',[.8 .8 .8],'linewidth',6)
for i = 1:size(analysis.comb_tasks,1)
    plot(rad2deg(squeeze(analysis.neural.angles_array(i,:))),'linewidth',2,'color',aux.cols_plot(i,:))
end
plot(analysis.neural.mean_angle_fcn_nbr_dims,'linewidth',4,'color','k')
set(gca,'TickDir','out'),set(gca,'FontSize',14)
legend(['90*cum var eigen'; aux.legends_plot; 'mean'],'Location','SouthEast','FontSize',14)
plot(analysis.neural.mean_angle_fcn_nbr_dims+analysis.neural.std_angle_fcn_nbr_dims,'--k','linewidth',2)
plot(analysis.neural.mean_angle_fcn_nbr_dims-analysis.neural.std_angle_fcn_nbr_dims,'--k','linewidth',2)
xlabel('nbr. dimensions'),ylabel('angle (deg)'),ylim([0 90]),xlim([0 length(neural_chs)+1])

% -------------------------------------------------------------------------
% Plot cum distance to most similar eigenvector as function nbr cmponents
figs.cum_dist_eigenv = figure; 
hold on
for i = 1:size(analysis.comb_tasks,1)
    plot(analysis.neural.cum_dist_eigenv(:,i),'color',aux.cols_plot(i,:),'linewidth',2)
end
plot(analysis.neural.mean_cum_dist_eigenv,'k','linewidth',4)
plot(1:length(neural_chs)+1,1:length(neural_chs)+1,'color',[0.6 0.6 0.6],'linewidth',2)
set(gca,'TickDir','out'),set(gca,'FontSize',14)
legend([aux.legends_plot; 'mean'; 'identical'],'Location','NorthWest','FontSize',14)
plot(analysis.neural.mean_cum_dist_eigenv+analysis.neural.std_cum_dist_eigenv,'--k','linewidth',2)
plot(analysis.neural.mean_cum_dist_eigenv-analysis.neural.std_cum_dist_eigenv,'--k','linewidth',2)
xlim([0 length(neural_chs)+1]),ylim([0 ceil(max(max(analysis.neural.cum_dist_eigenv))/10)*10])
xlabel('nbr. dimensions'),ylabel('cumulative distance between eigenvectors')

% -------------------------------------------------------------------------
% Plot R^2 of within vs. across projections onto PCs --eigenvectors are
% ordered by similarity (minimum angle cross-tasks)
figs.R2across_PCs = figure;
hold on
plot(analysis.neural.mean_var_fcn_eigen,'color',[.8 .8 .8],'linewidth',6)
for i = 1:size(analysis.comb_tasks,1)
    plot(analysis.neural.R2_pc_proj_across_tasks(i,:)','color',aux.cols_plot(i,:),'linewidth',2)
end
plot(mean(analysis.neural.R2_pc_proj_across_tasks),'color','k','linewidth',4)
plot(mean(analysis.neural.R2_pc_proj_across_tasks) + ...
    std(analysis.neural.R2_pc_proj_across_tasks),'color','k','linewidth',4,'LineStyle','--')
plot(mean(analysis.neural.R2_pc_proj_across_tasks) - ...
    std(analysis.neural.R2_pc_proj_across_tasks),'color','k','linewidth',4,'LineStyle','--')
set(gca,'TickDir','out'),set(gca,'FontSize',14)
legend(['cum var eigen'; aux.legends_plot;'mean'],'Location','NorthEast','FontSize',14)
xlabel('comp. nbr.','FontSize',14),ylabel('R^2 square')
xlim([0 aux.last_dim+1]),ylim([0 1])
title('Projections onto within- and across- PC matrices')

% same plot, 'zoomed' to first 30 components --eigenvectors are ordered by
% similarity (minimum angle cross-tasks) 
figs.R2across_PCs_zoom = figure;
hold on
plot(analysis.neural.mean_var_fcn_eigen,'color',[.8 .8 .8],'linewidth',6)
for i = 1:size(analysis.comb_tasks,1)
    plot(analysis.neural.R2_pc_proj_across_tasks(i,:)','color',aux.cols_plot(i,:),'linewidth',2)
end
plot(mean(analysis.neural.R2_pc_proj_across_tasks),'color','k','linewidth',4)
plot(mean(analysis.neural.R2_pc_proj_across_tasks) + ...
    std(analysis.neural.R2_pc_proj_across_tasks),'color','k','linewidth',4,'LineStyle','--')
plot(mean(analysis.neural.R2_pc_proj_across_tasks) - ...
    std(analysis.neural.R2_pc_proj_across_tasks),'color','k','linewidth',4,'LineStyle','--')
set(gca,'TickDir','out'),set(gca,'FontSize',14)
legend(['cum var eigen'; aux.legends_plot;'mean'],'Location','NorthEast','FontSize',14)
xlabel('comp. nbr.','FontSize',14),ylabel('R^2 square')
xlim([0 30]),ylim([0 1])
title('Projections onto within- and across- PC matrices')

% weighed R^2 v.1 --eigenvectors are ordered by similarity (minimum angle
% cross-tasks)  
% -> weighs the R^2 by the eigenvalue of each dimension 'n' divided by the
% cumsum of the eigenvalues 1:'n'. Eigenvalues are cross-task
figs.weighed_R2across_PCs = figure;
hold on
for i = 1:size(analysis.comb_tasks,1)
    plot(analysis.neural.weighed_R2_pc_proj_across_tasks(i,:),...
        'color',aux.cols_plot(i,:),'linewidth',4)
end
plot(mean(analysis.neural.weighed_R2_pc_proj_across_tasks),...
    'color','k','linewidth',4)
for i = 1:length(dim_red_FR)
    plot(dim_red_FR{i}.eigen/sum(dim_red_FR{i}.eigen),'color',[0.8 0.8 0.8],...
        'linewidth',2)
end
plot(mean(analysis.neural.weighed_R2_pc_proj_across_tasks) + ...
    std(analysis.neural.weighed_R2_pc_proj_across_tasks),'color','k','linewidth',4,'LineStyle','--')
plot(mean(analysis.neural.weighed_R2_pc_proj_across_tasks) - ...
    std(analysis.neural.weighed_R2_pc_proj_across_tasks),'color','k','linewidth',4,'LineStyle','--')
set(gca,'TickDir','out'),set(gca,'FontSize',14)
legend([aux.legends_plot; 'mean';'eigenvals'],'Location','NorthEast','FontSize',14)
xlabel('comp. nbr.','FontSize',14),ylabel('weighed R^2 square')
xlim([0 10]),ylim([0 1])
title('Weighed projections onto within- and across- PC matrices')


% -------------------------------------------------------------------------
% Weight of each neuron to each PC

% plot eigenv weights for each task
aux.nbr_rows                = floor(sqrt(length(dim_red_FR)));
aux.nbr_cols                = ceil(length(dim_red_FR)/aux.nbr_rows);
aux.max_eigenv_weight       = max(cellfun(@(x) max(max(abs(x.w))), dim_red_FR));
figs.weights_p_task = figure('units','normalized','outerposition',[0 0 1 1]);
for i = 1:length(dim_red_FR)
    subplot(aux.nbr_rows,aux.nbr_cols,i)
    imagesc(1:aux.last_dim,1:aux.last_dim,abs(dim_red_FR{i}.w))
    set(gca,'TickDir','out'),set(gca,'FontSize',14)
    caxis([0 aux.max_eigenv_weight]), colorbar
    title(labels{i},'FontSize',14)
    if i >= aux.nbr_cols*(aux.nbr_rows-1)
        xlabel('eigenv nbr','FontSize',14)
    end
    if i == 1 || rem(i,aux.nbr_cols+1) == 0
        ylabel('neural ch','FontSize',14)
    end
end

% plot mean and SD of the eigenv weights across all tasks in the same
% session
figs.weights = figure('units','normalized','outerposition',[0 1/6 1 2/3]);
subplot(121),
imagesc(1:aux.last_dim,1:aux.last_dim,analysis.neural.pc_weights_across_tasks.mean_eigenv_weights)
set(gca,'TickDir','out'),set(gca,'FontSize',14)
ylabel('neural ch','FontSize',14)
xlabel('eigenv nbr','FontSize',14)
title('mean weight')
colorbar;
subplot(122),
imagesc(1:aux.last_dim,1:aux.last_dim,analysis.neural.pc_weights_across_tasks.std_eigenv_weights)
set(gca,'TickDir','out'),set(gca,'FontSize',14)
ylabel('neural ch','FontSize',14)
xlabel('eigenv nbr','FontSize',14)
title('SD weight')
colorbar;

% "Participation index"
aux.max_particip_index      = max(cellfun(@(x) max(max(abs(x.data))), ...
                                analysis.neural.participation_index));
figs.particip_index = figure('units','normalized','outerposition',[0 0 1 1]);
for i = 1:length(dim_red_FR)
    subplot(aux.nbr_rows,aux.nbr_cols,i)
    imagesc(1:aux.last_dim,1:aux.last_dim,abs(analysis.neural.participation_index{i}.data))
    set(gca,'TickDir','out'),set(gca,'FontSize',14)
    caxis([0 aux.max_particip_index]), colorbar
    title(labels{i},'FontSize',14)
    if i > aux.nbr_cols*(aux.nbr_rows-1)
        xlabel('dimension','FontSize',14)
    end
    if i == 1 || rem(i,aux.nbr_cols+1) == 0
        ylabel('neural ch','FontSize',14)
    end
end

% Summed "participation index" -> one single number that summarizes the
% contribution of each channel to all the eigenvectors that define the
% neural space of the task
aux.cols_per_task           = lines(length(dim_red_FR));
aux.mean_summed_particip    = mean(cell2mat(cellfun(@(x) mean(x.summed), ...
            analysis.neural.participation_index,'UniformOutput',false)));
aux.std_summed_particip     = std(cell2mat(cellfun(@(x) mean(x.summed), ...
            analysis.neural.participation_index,'UniformOutput',false)));

figs.summed_particip_index = figure;
hold on
for i = 1:length(dim_red_FR)
    plot(analysis.neural.participation_index{i}.summed,'linewidth',2,...
        'color',aux.cols_per_task(i,:)); 
end
plot([1,length(dim_red_FR{1}.eigen)],aux.mean_summed_particip*ones(1,2),...
    'color',[.8 .8 .8],'linewidth',2);
plot([1,length(dim_red_FR{1}.eigen)],aux.mean_summed_particip*ones(1,2)...
    +aux.mean_summed_particip*ones(1,2),'color',[.8 .8 .8],'linewidth',2,...
    'linestyle','-.');
plot([1,length(dim_red_FR{1}.eigen)],aux.mean_summed_particip*ones(1,2)...
    -aux.mean_summed_particip*ones(1,2),'color',[.8 .8 .8],'linewidth',2,...
    'linestyle','-.');
set(gca,'TickDir','out'),set(gca,'FontSize',14)
ylabel('summed participation index'), xlabel('neural ch nbr')
legend([labels,'mean']);


% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% *** EMGs: 

aux.cols_emg_plot           = parula(length(chosen_emgs));

% Plot VAF
figs.emg_vaf = figure;
hold on
for i = 1:length(chosen_emgs)
    plot(analysis.emg.mean_emg_vaf(:,i),'color',aux.cols_emg_plot(i,:),'LineWidth',4);
end
% Add trend of explained variance as number of the number of components for neurons
plot(1:aux.last_dim_emg,analysis.neural.mean_var_fcn_eigen(1:aux.last_dim_emg),'k','linewidth',4);
plot(1:aux.last_dim_emg,analysis.neural.mean_var_fcn_eigen(1:aux.last_dim_emg)-...
    analysis.neural.std_var_fcn_eigen(1:aux.last_dim_emg),'k','linewidth',2,'linestyle','--');
plot(1:aux.last_dim_emg,analysis.neural.mean_var_fcn_eigen(1:aux.last_dim_emg)+...
    analysis.neural.std_var_fcn_eigen(1:aux.last_dim_emg),'k','linewidth',2,'linestyle','--');
set(gca,'TickDir','out'),set(gca,'FontSize',14)
legend([cbdf(1).emg.emgnames(chosen_emgs), 'neurons'],'Location','SouthEast','FontSize',14,'Interpreter','none')
xlabel('comp. nbr.','FontSize',14),ylabel('mean VAF (no xval)')
xlim([0 aux.last_dim_emg+3]),ylim([0 1])
for i = 1:length(chosen_emgs)
    plot(analysis.emg.mean_emg_vaf(:,i)+analysis.emg.std_emg_vaf(:,i),...
            'color',aux.cols_emg_plot(i,:),'LineWidth',1,'Linestyle','--');
    plot(analysis.emg.mean_emg_vaf(:,i)-analysis.emg.std_emg_vaf(:,i),...
            'color',aux.cols_emg_plot(i,:),'LineWidth',1,'Linestyle','--');
end
title('EMG Predictions with neural data projected onto PCs')
% add the VAF of predictions with neurons
for i = 1:length(chosen_emgs)
    plot(aux.last_dim_emg+2,analysis.emg.mean_vaf_neurons(i),...
        'marker','o','linewidth',3,'markersize',14,'color',aux.cols_emg_plot(i,:));
    plot(repmat(aux.last_dim_emg+2,1,2),[analysis.emg.mean_vaf_neurons(i)+analysis.emg.std_vaf_neurons(i),...
        analysis.emg.mean_vaf_neurons(i)-analysis.emg.std_vaf_neurons(i)],'linewidth',2,...
        'color',aux.cols_emg_plot(i,:));
end


% --- to save the figs
if save_figs
    curr_dir                = pwd; 
    % go to the results folder if you aren't there
    if ~strncmp(curr_dir(end-11:end),'results/figs',12)
        cd('/Users/juangallego/Documents/NeuroPlast/Data/_Dimensionality reduction/results/figs');
    end
    % save figs in PNG
    fig_handles             = fieldnames(figs);
    for i = 1:length(fig_handles)
        print(figs.(fig_handles{i}),[filename(1:end-4) '_fig_' num2str(i)],'-dpng')
    end
    cd(curr_dir)
end