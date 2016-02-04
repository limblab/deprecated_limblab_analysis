%
% 
% Some code to play around with the data


%% ------------------------
% 1. Bin EMGs activity

% By default, normalize the EMG
params.NormData         = true;
% bin to the same width as the neurons
if iscell(dim_red_FR)
    bin_width_neurons   = mean(diff(dim_red_FR{1}.t));
else
    bin_width_neurons   = mean(diff(dim_red_FR.t));
end
params.binsize          = bin_width_neurons;

for i = 1:length(bdf)
    binned_emg(i)       = convertEMG_BDF2binned( bdf(i), params );
end

nbr_emgs                = length(binned_emg(1).labels);

%% ------------------------
% 2. PCA of the muscle activity
rows_plot               = floor(sqrt(length(bdf)));
cols_plot               = ceil(sqrt(length(bdf)));

var_th_pca              = 0.8; % explained variance threshold for PCA

f1h                     = figure;
f2h                     = figure;

% WARNING: this code overwrites the PCA results; PCAs are re-calcualted for
% the desired BDF below
for i = 1:length(bdf)
    [w, scores_emg, eigen]  = pca(binned_emg(i).data);
    figure(f1h), subplot(rows_plot,cols_plot,i)
    bar(eigen/sum(eigen)),set(gca,'TickDir','out'),set(gca,'FontSize',14)
    xlim([0 nbr_emgs+1])
    title(labels{i})
    if rem(i-1,cols_plot) == 0
        ylabel('norm. explained variance','FontSize',14)
    end
    if i >= ( (rows_plot-1)*cols_plot + 1 )
        xlabel('component nbr.','FontSize',14)
    end

    subplot(rows_plot,cols_plot,i)
    figure(f2h), subplot(rows_plot,cols_plot,i)
    bar(cumsum(eigen)/sum(eigen)),set(gca,'TickDir','out'),set(gca,'FontSize',14)
    hold on, plot([0 nbr_emgs],[var_th_pca var_th_pca],'r','LineWidth',2)
    xlim([0 nbr_emgs+1])
    title(labels{i})
    if rem(i-1,cols_plot) == 0
        ylabel('% norm. explained variance','FontSize',14)
    end
    if i >= ( (rows_plot-1)*cols_plot + 1 )
        xlabel('component nbr.','FontSize',14)
    end
end
clear w scores_emg eigen rows_plot cols_plot

%% ------------------------
% 3. Relationship between "neural components" and "muscle components"

% BDF to look at
bdf_nbr                 = 2;

% neural components (PCAs) to look at
neural_comp             = [1, 2];
% muscle components (PCAs) to look at
muscle_comp             = [1, 2];

% do PCA of the muscles
[w_emg, scores_emg, eigen_emg] = pca(binned_emg(bdf_nbr).data);

% min_t and max_t for the plot
t_lims                  = [500 530];

figure,
subplot(311)
plot(bdf(bdf_nbr).pos(:,1),bdf(bdf_nbr).pos(:,2),'k','LineWidth',2);
set(gca,'TickDir','out'),set(gca,'FontSize',14),ylabel('position')
xlim(t_lims)
%plot(bdf(bdf_nbr).force.data(:,1),bdf(bdf_nbr).force.data(:,2));
%set(gca,'TickDir','out'),set(gca,'FontSize',14),ylabel('force')
subplot(312)
plot(binned_emg(bdf_nbr).t, scores_emg(:,muscle_comp),'LineWidth',2);
set(gca,'TickDir','out'),set(gca,'FontSize',14),ylabel('muscle PCs')
for i = 1:length(muscle_comp), 
    legend_muscle{i}    = ['comp ' num2str(muscle_comp(i))];
end
legend(legend_muscle)
xlim(t_lims)
subplot(313)
plot(dim_red_FR{bdf_nbr}.t, dim_red_FR{bdf_nbr}.scores(:,neural_comp),'LineWidth',2);
set(gca,'TickDir','out'),set(gca,'FontSize',14),ylabel('neural PCs')
for i = 1:length(neural_comp), 
    legend_neural{i}    = ['comp ' num2str(neural_comp(i))];
end
legend(legend_neural)
xlim(t_lims)


% ------------
% Xcorr between neural components and muscle components
int_xcorr               = 30; % the interval for the xcorr will be -int_xcorr bins : + int_xcorr bins

% set different colors for each neural comp
colors_xcorr            = winter(length(neural_comp));
% set different symbols for each muscle comp
linestyles_xcorr        = {'-','-.','-x'};
linestyles_xcorr        = linestyles_xcorr(1:length(muscle_comp)); % crop

rows_plot               = length(neural_comp);
cols_plot               = length(muscle_comp);

figure,
for i = 1:rows_plot
    for j = 1:cols_plot
        [xcorr_npca_mpca(:,i,j), lags_npca_mpca] = xcorr(dim_red_FR{bdf_nbr}.scores(:,neural_comp(i)), ...
            scores_emg(:,muscle_comp(j)), int_xcorr);
        
        subplot(rows_plot,cols_plot,(i-1)*length(neural_comp)+j),
        plot(lags_npca_mpca,xcorr_npca_mpca(:,i,j),'LineWidth',2,'color',colors_xcorr(i,:),...
            'LineStyle',linestyles_xcorr{j})
        set(gca,'TickDir','out'),set(gca,'FontSize',14),grid on
        legend(['neural PC ' num2str(i) ' muscle PC ' num2str(muscle_comp)])
        
        if j == 1
            ylabel('cross-correlation','FontSize',14)
        end
        if i == rows_plot
            xlabel('time (s)','FontSize',14)
        end
    end
end



%% ------------------------
% 4. Relationship between "neural components" and "EMGs"

% % BDF to look at
% bdf_nbr                 = 1;
% 
% % neural components (PCAs) to look at
% neural_comp             = [1, 2];
% muscles to look at
muscles                 = [4 12 11];

% min_t and max_t for the plot
t_lims                  = [0 30];

figure,
subplot(311)
plot(bdf(bdf_nbr).pos(:,1),bdf(bdf_nbr).pos(:,2),'k','LineWidth',2);
set(gca,'TickDir','out'),set(gca,'FontSize',14),ylabel('position')
xlim(t_lims)
%plot(bdf(bdf_nbr).force.data(:,1),bdf(bdf_nbr).force.data(:,2));
%set(gca,'TickDir','out'),set(gca,'FontSize',14),ylabel('force')
subplot(312)
plot(binned_emg(bdf_nbr).t, binned_emg(bdf_nbr).data(:,muscles),'LineWidth',2);
set(gca,'TickDir','out'),set(gca,'FontSize',14),ylabel('muscle PCs')
legend(binned_emg(bdf_nbr).labels(muscles))
xlim(t_lims)
subplot(313)
plot(dim_red_FR{bdf_nbr}.t, dim_red_FR{bdf_nbr}.scores(:,neural_comp),'LineWidth',2);
set(gca,'TickDir','out'),set(gca,'FontSize',14),ylabel('neural PCs')
for i = 1:length(neural_comp), 
    legend_neural{i}    = ['comp ' num2str(neural_comp(i))];
end
legend(legend_neural)
xlim(t_lims)
xlabel('time (s)')


