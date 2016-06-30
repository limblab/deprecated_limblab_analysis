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
    
    [w_emg, scores_emg, eigen_emg] = pca(binned_emg(i).data);
    
    % temporarily store results
    pca_m(i).w          = w_emg;
    pca_m(i).scores     = scores_emg;
    pca_m(i).eigen      = eigen_emg;
    clear w_emg scores_emg eigen_emg
    
    % plots
    figure(f1h), subplot(rows_plot,cols_plot,i)
    bar(pca_m(i).eigen/sum(pca_m(i).eigen)),set(gca,'TickDir','out'),set(gca,'FontSize',14)
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
    bar(cumsum(pca_m(i).eigen)/sum(pca_m(i).eigen))
    set(gca,'TickDir','out'),set(gca,'FontSize',14)
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
clear rows_plot cols_plot

%% ------------------------
% 3. Relationship between "neural components" and "muscle components"

% BDF to look at
bdf_nbr                 = [1 2 3];

% neural components (PCAs) to look at
neural_comp             = [1, 2, 3, 4];
% muscle components (PCAs) to look at
muscle_comp             = [1, 2, 3];

% min_t and max_t for the plot
t_lims                  = [0 30];

nbr_bdfs                = length(bdf_nbr);

% plot raw data in the interval defined in t_lims
for i = 1:nbr_bdfs
    figure,
    subplot(311)
    plot(bdf(bdf_nbr(i)).pos(:,1),bdf(bdf_nbr(i)).pos(:,2),'k','LineWidth',2);
    set(gca,'TickDir','out'),set(gca,'FontSize',14),ylabel('position')
    xlim(t_lims)
    %plot(bdf(bdf_nbr).force.data(:,1),bdf(bdf_nbr).force.data(:,2));
    %set(gca,'TickDir','out'),set(gca,'FontSize',14),ylabel('force')
    subplot(312)
    plot(binned_emg(bdf_nbr(i)).t, pca_m(bdf_nbr(i)).scores(:,muscle_comp),'LineWidth',2);
    set(gca,'TickDir','out'),set(gca,'FontSize',14),ylabel('muscle PCs')
    for ii = 1:length(muscle_comp), 
        legend_muscle{ii}    = ['comp ' num2str(muscle_comp(ii))];
    end
    legend(legend_muscle)
    xlim(t_lims)
    subplot(313)
    plot(dim_red_FR{bdf_nbr(i)}.t, dim_red_FR{bdf_nbr(i)}.scores(:,neural_comp),'LineWidth',2);
    set(gca,'TickDir','out'),set(gca,'FontSize',14),ylabel('neural PCs')
    for ii = 1:length(neural_comp), 
        legend_neural{ii}    = ['comp ' num2str(neural_comp(ii))];
    end
    legend(legend_neural)
    xlim(t_lims)
    xlabel('time (s)','FontSize',14)
end

    
%% ------------
% Xcorr between neural components and muscle components
int_xcorr               = 30; % the interval for the xcorr will be -int_xcorr bins : + int_xcorr bins

% time axis for xcorr
t_axis_xcorr            = bin_width_neurons*(-int_xcorr:1:int_xcorr);

% set different colors for each neural comp
colors_xcorr            = winter(nbr_bdfs);

rows_plot               = length(neural_comp);
cols_plot               = length(muscle_comp);

xcorr_npca_mpca         = zeros(length(t_axis_xcorr),rows_plot,cols_plot,nbr_bdfs); 

% cross-correlation
xcf                     = figure('units','normalized','outerposition',[0 0 1 1]);
for k = 1:length(bdf_nbr)
    for i = 1:rows_plot
        for j = 1:cols_plot
            xcorr_npca_mpca(:,i,j,k) = xcorr(dim_red_FR{bdf_nbr(k)}.scores(:,neural_comp(i)), ...
                pca_m(k).scores(:,muscle_comp(j)), int_xcorr);

            subplot(rows_plot,cols_plot,(i-1)*length(muscle_comp)+j),
            if k > 1, hold on, end
            plot(t_axis_xcorr,xcorr_npca_mpca(:,i,j,k),'LineWidth',2,'color',colors_xcorr(k,:))
            %set(gcf,'Colormap',colors_xcorr)
            set(gca,'TickDir','out'),set(gca,'FontSize',14),grid on
            title(['neural PC ' num2str(i) ' muscle PC ' num2str(muscle_comp(j))],'Fontsize',14)
            legend(labels(bdf_nbr))
            if k > 1
                if j == 1, ylabel('cross-correlation','FontSize',14), end
                if i == rows_plot, xlabel('time (s)','FontSize',14), end
            end
        end
    end
end

% normalized cross-correlation
nxcf                    = figure('units','normalized','outerposition',[0 0 1 1]);
for k = 1:length(bdf_nbr)
    for i = 1:rows_plot
        for j = 1:cols_plot
            xcorr_npca_mpca(:,i,j,k) = xcorr(dim_red_FR{bdf_nbr(k)}.scores(:,neural_comp(i)), ...
                pca_m(k).scores(:,muscle_comp(j)), int_xcorr);

            subplot(rows_plot,cols_plot,(i-1)*length(muscle_comp)+j),
            if k > 1, hold on, end
            plot(t_axis_xcorr,xcorr_npca_mpca(:,i,j,k)/peak2peak(xcorr_npca_mpca(:,i,j,k)),...
                'LineWidth',2,'color',colors_xcorr(k,:))
            %set(gcf,'Colormap',colors_xcorr)
            set(gca,'TickDir','out'),set(gca,'FontSize',14),grid on
            title(['neural PC ' num2str(i) ' muscle PC ' num2str(muscle_comp(j))],'Fontsize',14)
            if k == nbr_bdfs, legend(labels(bdf_nbr)), end
            if k > 1
                if j == 1, ylabel('norm. cross-correlation','FontSize',14), end
                if i == rows_plot, xlabel('time (s)','FontSize',14), end
            end
        end
    end
end

    
%% ------------
% Coherence 


% coherence
nfft_coh                = 1024/2+1;
coh_npca_mpca           = zeros(nfft_coh,rows_plot,cols_plot,nbr_bdfs); 

cf                      = figure('units','normalized','outerposition',[0 0 1 1]);
for k = 1:length(bdf_nbr)
    for i = 1:rows_plot
        for j = 1:cols_plot
            [coh_npca_mpca(:,i,j,k) f_coh] = mscohere( dim_red_FR{bdf_nbr(k)}.scores(:,neural_comp(i)),...
                pca_m(k).scores(:,muscle_comp(j)), 20, 16, 1024, 20 );

            subplot(rows_plot,cols_plot,(i-1)*length(muscle_comp)+j),
            if k > 1, hold on, end
            plot(f_coh,coh_npca_mpca(:,i,j,k),'LineWidth',2,'color',colors_xcorr(k,:))
            %set(gcf,'Colormap',colors_xcorr)
            set(gca,'TickDir','out'),set(gca,'FontSize',14),grid on
            title(['neural PC ' num2str(i) ' muscle PC ' num2str(muscle_comp(j))],'Fontsize',14)
            if k == nbr_bdfs, legend(labels(bdf_nbr)), end
            if k > 1
                if j == 1, ylabel('coherence','FontSize',14), end
                if i == rows_plot, xlabel('frequency (Hz)','FontSize',14), end
            end
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



%% ----------------------
% Use the combined transformation to transform each condition

% Transform only 1 D
this_bdf                = 1;
other_bdf               = 3;

comp_nbr                = 1:5;


for i = 1:length(comp_nbr)
    % Apply rotation matrix and delete mean
    pca_comb = (smoothed_FR{this_bdf}(:,neural_chs+1))*dim_red_FR{other_bdf}.w(:,comp_nbr(i))...
        -mean(smoothed_FR{this_bdf}(:,neural_chs+1))*dim_red_FR{other_bdf}.w(:,comp_nbr(i));

    % compute cross-correlation
    xcorr_this_comb         = xcorr( dim_red_FR{this_bdf}.scores(:,comp_nbr(i)), ...
                                pca_comb, int_xcorr);

    % compute coherence
    coh_this_comb           = mscohere( dim_red_FR{this_bdf}.scores(:,comp_nbr(i)),...
                                pca_comb, 20, 16, 1024, 20 );

    figure,
    subplot(211),hold on
    plot(dim_red_FR{this_bdf}.t,[ pca_comb, dim_red_FR{this_bdf}.scores(:,comp_nbr(i)) ],...
        'LineWidth',2)
    %plot(dim_red_FR{this_bdf}.t,dim_red_FR{this_bdf}.scores(:,comp_nbr(i)),'LineWidth',2)
    legend(labels{this_bdf},labels{other_bdf})
    set(gca,'Tickdir','out'),set(gca,'FontSize',14)
    ylabel(['neural comp.' num2str(comp_nbr(i))]),xlabel('time (s)'), xlim(t_lims)
    subplot(223)
    plot(t_axis_xcorr,xcorr_this_comb,'LineWidth',2)
    set(gca,'Tickdir','out'),set(gca,'FontSize',14)
    ylabel('crosscorrelation'), xlabel('time (s)')
    subplot(224)
    plot(f_coh,coh_this_comb,'LineWidth',2)
    set(gca,'Tickdir','out'),set(gca,'FontSize',14)
    ylabel('coherence'), xlabel('frequency (Hz)'), ylim([0 1])
    set(gcf,'Colormap',winter)
%     
%     % inverted
%     figure,
%     subplot(211),hold on
%     plot(dim_red_FR{this_bdf}.t,[ pca_comb, -dim_red_FR{this_bdf}.scores(:,comp_nbr(i)) ],...
%         'LineWidth',2)
%     %plot(dim_red_FR{this_bdf}.t,dim_red_FR{this_bdf}.scores(:,comp_nbr(i)),'LineWidth',2)
%     legend(labels{this_bdf},labels{other_bdf})
%     set(gca,'Tickdir','out'),set(gca,'FontSize',14)
%     ylabel(['neural comp.' num2str(comp_nbr(i))]),xlabel('time (s)'), xlim(t_lims)
%     title('inverted neural data')
%     subplot(223)
%     plot(t_axis_xcorr,-xcorr_this_comb,'LineWidth',2)
%     set(gca,'Tickdir','out'),set(gca,'FontSize',14)
%     ylabel('crosscorrelation'), xlabel('time (s)')
%     subplot(224)
%     plot(f_coh,coh_this_comb,'LineWidth',2)
%     set(gca,'Tickdir','out'),set(gca,'FontSize',14)
%     ylabel('coherence'), xlabel('frequency (Hz)'), ylim([0 1])
%     set(gcf,'Colormap',winter)
%     
end