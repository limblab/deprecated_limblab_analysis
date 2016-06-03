%
% Build a within decoder for each task using neural PCs as inputs, and
% compare to the performance of a normal decoder
%
% TODO: CLEAN + IMPROVE

function [pred_data_within, vaf_array, vaf_array_norm, vaf_neurons, binned_data] = within_EMG_preds_fcn_nbr_neural_comp( bdf, ...
                                                        dim_red_FR, labels, max_nbr_comp, varargin )


% read inputs
if nargin >= 5
    if ~isempty(varargin{1})
        emgs_to_predict         = varargin{1};
    else
        emgs_to_predict         = 1:length(length(bdf(1).emg.emgnames));
    end
end

if nargin == 6
    binned_data                 = varargin{2};
    bin_data_yn                 = false;
else
    bin_data_yn                 = true;
end

if ~exist('emgs_to_predict','var')
	emgs_to_predict             = 1:length(bdf(1).emg.emgnames);
end

% Some opts
plot_yn                         = false;
bin_size                        = 0.05; % TODO: Make into a parameter

bdf_nbr                         = 1:length(bdf);
% EMG options
%crop_emg_noise                  = false;
%min_perc                        = 5; % EMG values below this will be cut to zero

% TODO: move this as param???
emgs_plot                   = [emgs_to_predict(3) emgs_to_predict(end-2)]; % currently only 2


% Options for the decoder
opts_filt.PolynomialOrder       = 0; % polynomial order, if want to use static non-linearity

%% ------------------------------------------------------------------------
% BIN THE DATA -- decide whether they are normalized or not

if bin_data_yn 
    
    if exist('binned_data','var'), clear binned_data, end;
    b2bparams.NormData          = true;
    b2bparams.binsize           = bin_size;
    
    for i = 1:length(bdf)
        % bin between the first and last position readings, for consistency
        b2bparams.starttime     = ceil(bdf(i).pos(1,1)/b2bparams.binsize)*...
                                    b2bparams.binsize;
        b2bparams.stoptime      = floor(bdf(i).pos(end,1)/b2bparams.binsize)*...
                                    b2bparams.binsize;
        binned_data(i)          = convertBDF2binned(bdf(i),b2bparams);
    end
end


%% ------------------------------------------------------------------------
% REMOVE EMG channels

emgs_to_remove                  = setdiff(1:length(binned_data(1).emgguide),...
                                emgs_to_predict);
                            
if ~isempty(emgs_to_remove)
    % only do it if there are more EMGs in the binned data than expected
    % --the EMGs may have been removed in a previous run
    if length(emgs_to_predict) ~= length(binned_data(1).emgguide);
        for i = 1:length(bdf_nbr)
            binned_data(i).emgdatabin(:,emgs_to_remove) = [];
            binned_data(i).emgguide(:,emgs_to_remove)   = [];
        end
    end
end

%% ------------------------------------------------------------------------
% REMOVE EMG NOISE-- decide whether to remove EMGs with amplitude < 0.05 %
% of the peak to peak amplitude

% if crop_emg_noise
%     for i = 1:length(binned_data(1).emgguide)
%         % ToDo
%     end
% end


%% ------------------------------------------------------------------------
% Build neuron-to-EMG decoders

% Predict using neurons as input, for comparison
options_neuron_filter.PredEMGs  = true;

% Get rid of neurons with very low firing rate
for i = 1:length(bdf_nbr)
    mean_FR                     = mean(binned_data(i).spikeratedata);
    indx_low_FR                 = find(mean_FR<0.01);
    binned_data(i).spikeratedata(:,indx_low_FR) = [];
    binned_data(i).neuronIDs(indx_low_FR,:)     = [];
end
    
for i = 1:length(bdf_nbr)
    [aux_filt_neurons, aux_pred_neurons] = BuildModel( binned_data(bdf_nbr(i)), ...
                                            options_neuron_filter );
    
    filter_neurons_within(i)    = aux_filt_neurons;
    pred_neurons_within(i)      = aux_pred_neurons;
    clear aux_filt_neurons aux_pred_neurons
end


%% ------------------------------------------------------------------------
% Build the neural PC to EMG decoders

for j = 1:max_nbr_comp
    % Build decoders taking neural PCs as inputs
    for i = 1:length(bdf_nbr)

        [aux_filter, aux_pred_data] = call_BuildModel_dim_red_neurons( ...
            binned_data(bdf_nbr(i)), dim_red_FR{bdf_nbr(i)}, j, opts_filt );

        filter_within(j,i)            = aux_filter;
        pred_data_within(j,i)         = aux_pred_data;
        clear aux_filter aux_pred_data
    end
end



%% ------------------------------------------------------------------------
% Return computations

% Create variable to return VAF of EMG predictions using neurons
for i = 1:length(bdf)
    vaf_neurons(:,i)                = pred_neurons_within(i).vaf;
end

% create an array with VAFs per BDF
for i = 1:length(bdf)
    for ii = 1:max_nbr_comp 
        vaf_array(ii,:,i) = pred_data_within(ii,i).vaf; 
    end
end

% create an array with VAFs per BDF, divided by the VAF for the same muscle
% with the neuron decoder 
for i = 1:length(bdf)
     for ii = 1:max_nbr_comp 
%         vaf_array_norm(ii,:,i) = pred_data_within(ii,i).vaf./pred_neurons_within(i).vaf; 
         vaf_array_norm(ii,1:length(emgs_to_predict),i) = pred_data_within(ii,i).vaf./pred_neurons_within(i).vaf; 
     end
end


%% ------------------------------------------------------------------------
% Some summary calcualtions and plots

% for j = 1:max_nbr_comp
%     % 1. average VAF per task ...
%     mean_vaf                        = zeros(1,length(bdf_nbr));
%     for i = 1:length(bdf_nbr)
%        mean_vaf(j,i)                = mean(pred_data_within(j,i).vaf);  
%     end
%     % ... and sort them to plot the highest vaf first
%     [~, indx_sorted_vafs] = sort(mean_vaf);
% 
%     % 2. Linear fit between the actual and predicted EMG
%     for i = 1:length(bdf_nbr)
%         for ii = 1:length(binned_data(1).emgguide)
%             data_to_fit             = pred_data_within(j,1).preddatabin(:,ii);
%             pred_data_within(j,i).linear_fit(:,ii) = [ones(length(data_to_fit),1) data_to_fit]\...
%                                             pred_data_within(j,1).actualData(:,ii);
%         end
%     end
% end


% -------------------------------------------------------------------------
%% Plot that summarizes VAF as fcn components

nbr_rows            = floor(sqrt(length(bdf)));
nbr_cols            = ceil(length(bdf)/nbr_rows);

for i = 1:length(emgs_to_predict)
    muscle_names{i} = bdf(bdf_nbr(1)).emg.emgnames{emgs_to_predict(i)}(5:end);
end


% VAF as fcn muber PC projections
figure('units','normalized','outerposition',[0 0 1 1])
for i = 1:length(bdf)
    subplot(nbr_rows,nbr_cols,i)
    plot(1:max_nbr_comp,squeeze(vaf_array(:,:,i)),'linewidth',2);
    set(gca,'TickDir','out'),set(gca,'FontSize',14)
    
    if i > nbr_rows*(nbr_cols-1)
        xlabel('nbr neural components as inputs','FontSize',14)
    end
    if ( rem(i,nbr_cols+1) == 0 ) || i == 1
        ylabel('VAF')
    end
    legend(muscle_names,'FontSize',14,'Location','NorthWest')
    title(labels(i))
end


% Norm VAF as fcn muber PC projections
figure('units','normalized','outerposition',[0 0 1 1])
for i = 1:length(bdf)
    subplot(nbr_rows,nbr_cols,i)
    plot(1:max_nbr_comp,squeeze(vaf_array_norm(:,:,i)),'linewidth',2);
    set(gca,'TickDir','out'),set(gca,'FontSize',14)
    ylim([0 1])
    if i > nbr_rows*(nbr_cols-1)
        xlabel('nbr neural components as inputs','FontSize',14)
    end
    if ( rem(i,nbr_cols+1) == 0 ) || i == 1
        ylabel('norm. VAF')
    end
    legend(muscle_names,'FontSize',14,'Location','NorthWest')
    title(labels(i))
end

%% ------------------------------------------------------------------------

% OTHER PLOTS

% Plot an example of the predictions
if plot_yn 
    t_lim_emg_preds             = [1 21];
    y_lim_emg_preds             = [-.2 1.8];

    figure('units','normalized','outerposition',[0 0 1 1])
    for i = 1:length(bdf_nbr)
        subplot(length(bdf_nbr),1,i),hold on
        plot(pred_data_within(i).timeframe,pred_data_within(i).actualData(:,emgs_plot(1)),'color',[0.6 0.6 0.6],'LineWidth',3);
        plot(pred_data_within(i).timeframe,pred_data_within(i).preddatabin(:,emgs_plot(1)),'color','k','LineWidth',2);
        plot(pred_data_within(i).timeframe,pred_data_within(i).actualData(:,emgs_plot(2)),'color',[1 0.8 0],'LineWidth',3);
        plot(pred_data_within(i).timeframe,pred_data_within(i).preddatabin(:,emgs_plot(2)),'color','r','LineWidth',2);
        set(gca,'Tickdir','out'),set(gca,'FontSize',16)
        ylabel(['Norm EMG --' labels{i}],'FontSize',16)
        xlim(t_lim_emg_preds)
    %    ylim(y_lim_emg_preds)
        legend([binned_data(i).emgguide{emgs_plot(1)} ' actual'], ...
                [binned_data(i).emgguide{emgs_plot(1)} ' pred'], ...
                [binned_data(i).emgguide{emgs_plot(2)} ' actual'], ...
                [binned_data(i).emgguide{emgs_plot(2)} ' pred']);
        if i == 1
            if opts_filt.PolynomialOrder == 0
                title(['within predictions using ' num2str(nbr_pcs_decoder) ' PCs'],'FontSize',16)
            else
                title(['within predictions using ' num2str(nbr_pcs_decoder) ' PCs, and static non-linearity'],'FontSize',16)
            end
        end
        if i == length(bdf_nbr), 
           xlabel('time (s)','FontSize',16) 
        end
    end
    end

    % ------------------------------------------
    % SUMMARY PLOTS

    if plot_yn

    % Bar plot VAFs of EMG predictions using PCs
    figure,hold on
    for i = length(bdf_nbr):-1:1
        if i == 1
            bar((1:length(emgs_to_predict))-.4,pred_data_within(indx_sorted_vafs(i)).vaf(emgs_to_predict),0.2,'b');
        elseif i == 2
            bar((1:length(emgs_to_predict))-.15,pred_data_within(indx_sorted_vafs(i)).vaf(emgs_to_predict),0.2,'r');
        elseif i == 3
            bar((1:length(emgs_to_predict))+.15,pred_data_within(indx_sorted_vafs(i)).vaf(emgs_to_predict),0.2,'g');
        elseif i == 4
            bar((1:length(emgs_to_predict))+.4, pred_data_within(indx_sorted_vafs(i)).vaf(emgs_to_predict),0.2,'k');
        end
        ylim([0 1])
    end
    if opts_filt.PolynomialOrder == 0
        title(['within predictions using ' num2str(nbr_pcs_decoder) ' PCs'],'FontSize',14)
    else
        title(['within predictions using ' num2str(nbr_pcs_decoder) ' PCs, and static non-linearity'],'FontSize',14)
    end
    set(gca,'Tickdir','out'),set(gca,'FontSize',14)
    xlim([0 length(emgs_to_predict)+1])
    set(gca,'Xtick',1:length(emgs_to_predict))
    set(gca,'XTickLabel',binned_data(1).emgguide(emgs_to_predict))
    ylabel('VAF','FontSize',14)
    legend(labels(bdf_nbr(fliplr(indx_sorted_vafs))))

    % Bar plot VAFs of EMG predictions using spike trains
    figure,hold on
    for i = length(bdf_nbr):-1:1
        if i == 1
            bar((1:length(emgs_to_predict))-.4,pred_neurons_within(indx_sorted_vafs(i)).vaf(emgs_to_predict),0.2,'c');
        elseif i == 2
            bar((1:length(emgs_to_predict))-.15,pred_neurons_within(indx_sorted_vafs(i)).vaf(emgs_to_predict),0.2,'m');
        elseif i == 3
            bar((1:length(emgs_to_predict))+.15,pred_neurons_within(indx_sorted_vafs(i)).vaf(emgs_to_predict),0.2,'y');
        elseif i == 4
            bar((1:length(emgs_to_predict))+.4, pred_neurons_within(indx_sorted_vafs(i)).vaf(emgs_to_predict),0.2,'k');
        end
        ylim([0 1])
    end
    title('within predictions using firing rates','FontSize',14)
    set(gca,'Tickdir','out'),set(gca,'FontSize',14)
    xlim([0 length(emgs_to_predict)+1])
    set(gca,'Xtick',1:length(emgs_to_predict))
    set(gca,'XTickLabel',binned_data(1).emgguide(emgs_to_predict))
    ylabel('VAF','FontSize',14)
    legend(labels(bdf_nbr(fliplr(indx_sorted_vafs))))

end

% ------------------------------------------
% COMPARE PREDICTED AND ACTUAL EMGS

if plot_yn 
    
% Scatter plot of actual vs. predicted EMG for the two example EMGs chosen
% above
    for i = 1:length(bdf_nbr)

        % Calculate linear fits for plotting
        y_regress1 = pred_data_within(i).actualData(:,emgs_plot(1))*pred_data_within(i).linear_fit(2,emgs_plot(1)) +...
                        pred_data_within(i).linear_fit(1,emgs_plot(1))';
        y_regress2 = pred_data_within(i).actualData(:,emgs_plot(2))*pred_data_within(i).linear_fit(2,emgs_plot(2)) +...
                        pred_data_within(i).linear_fit(1,emgs_plot(2))';

        figure('units','normalized','outerposition',[1/4 1/4 1/2 1/2])
        subplot(121), hold on
        plot(pred_data_within(i).actualData(:,emgs_plot(1)),...
            pred_data_within(i).preddatabin(:,emgs_plot(1)),'.k','markersize',8)
        set(gca,'Tickdir','out'),set(gca,'FontSize',14)
        xlabel('actual EMG'),ylabel('pred EMG'),legend(binned_data(i).emgguide{emgs_plot(1)})
        xl = get(gca,'Xlim'); yl = get(gca,'Ylim');
        xlim([0 xl(2)]),ylim([-.1 yl(2)])
        plot(pred_data_within(i).actualData(:,emgs_plot(1)),y_regress1,'linewidth',2,'color',[0.6 0.6 0.6])
        plot([1 1],[0 1],'k'),plot([0 1],[1 1],'k')
        subplot(122),hold on
        plot(pred_data_within(i).actualData(:,emgs_plot(2)),...
            pred_data_within(i).preddatabin(:,emgs_plot(2)),'.r','markersize',8)
        set(gca,'Tickdir','out'),set(gca,'FontSize',14)
        xlabel('actual EMG'),ylabel('pred EMG'),legend(binned_data(i).emgguide{emgs_plot(2)})
        xl = get(gca,'Xlim'); yl = get(gca,'Ylim');
        xlim([0 xl(2)]),ylim([-.1 yl(2)])
        plot(pred_data_within(i).actualData(:,emgs_plot(2)),y_regress2,'linewidth',2,'color',[1 0.8 0])
        plot([1 1],[0 1],'color',[1 0.8 0]),plot([0 1],[1 1],'color',[1 0.8 0])
    end

end

% ------------------------------------------
% PLOT DECODER WEIGHTS

if plot_yn

    nbr_lags = filter_within(1).fillen/filter_within(1).binsize;

    for i = 1:length(bdf_nbr)

        figure('units','normalized','outerposition',[1/4 1/4 1/2 2/3])

        for ii = 1:nbr_pcs_decoder
            indx_first_lag_this = 2 + (ii-1)*nbr_lags;

            subplot(nbr_pcs_decoder,2,(ii*2)-1)
            imagesc(filter_within(i).H(indx_first_lag_this:...
                indx_first_lag_this+nbr_lags-1,emgs_to_predict(1))');
            colorbar;
            ylabel(['PC ' num2str(ii)],'FontSize',14)
            if ii == nbr_pcs_decoder
                xlabel('lag nbr','FontSize',14)
            elseif ii == 1
                title([binned_data(1).emgguide{emgs_plot(1)} ' decoder --' labels{bdf_nbr(i)}],'FontSize',14)
            end
            if ii ~= nbr_pcs_decoder, set(gca,'xticklabel',[]), end
            set(gca,'Tickdir','out'),set(gca,'FontSize',14)
            set(gca,'yticklabel',[])

            subplot(nbr_pcs_decoder,2,ii*2)
            imagesc(filter_within(i).H(indx_first_lag_this:...
                indx_first_lag_this+nbr_lags-1,emgs_to_predict(2))');
            colorbar;
            if ii == nbr_pcs_decoder
                xlabel('lag nbr','FontSize',14)
            elseif ii == 1
                title([binned_data(1).emgguide{emgs_plot(2)} ' decoder --' labels{bdf_nbr(i)}],'FontSize',14)
            end
            if ii ~= nbr_pcs_decoder, set(gca,'xticklabel',[]), end
            set(gca,'Tickdir','out'),set(gca,'FontSize',14)
            set(gca,'yticklabel',[])
        end
        colormap('winter')
    end

end

