%
% Build a within decoder for each BDF

% BDFs
bdf_nbr                         = 1:3;
% Number PCs
nbr_pcs_decoder                 = 3;
% emgs to predict
emgs_to_predict                 = [2:5 7 9 10 11];
% polynomial order, if want to use static non-linearity after linear
% decoder
opts_filt.PolynomialOrder       = 2;

for i = 1:length(bdf_nbr)
        
    [aux_filter, aux_pred_data] = call_BuildModel_dim_red_neurons( ...
        binned_data(bdf_nbr(i)), dim_red_FR{bdf_nbr(i)}, nbr_pcs_decoder, opts_filt );
    
    filter_within(i)            = aux_filter;
    pred_data_within(i)         = aux_pred_data;
    clear aux_filter aux_pred_data
end


% average VAF per task
mean_vaf                        = zeros(1,length(bdf_nbr));
for i = 1:length(bdf_nbr)
   mean_vaf(i)                  = mean(pred_data_within(i).vaf(emgs_to_predict));  
end
% and sort them to plot the highest vaf first
[~, indx_sorted_vafs] = sort(mean_vaf);


% Predict using neurons as input, for comparison
options_neuron_filter.PredEMGs  = true;
for i = 1:length(bdf_nbr)
    [aux_filt_neurons, aux_pred_neurons] = BuildModel( binned_data(bdf_nbr(i)), ...
                                            options_neuron_filter );
    
    filter_neurons_within(i)    = aux_filt_neurons;
    pred_neurons_within(i)      = aux_pred_neurons;
    clear aux_filt_neurons aux_pred_neurons
end
    

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
end
title(['within predictions using ' num2str(nbr_pcs_decoder) ' PCs'],'FontSize',14)
set(gca,'Tickdir','out'),set(gca,'FontSize',14)
xlim([0 length(emgs_to_predict)+1])
set(gca,'Xtick',1:length(emgs_to_predict))
set(gca,'XTickLabel',binned_data(1).emgguide(emgs_to_predict))
ylabel('VAF','FontSize',14)
legend(labels(fliplr(indx_sorted_vafs)))


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
end
title('within predictions using firing rates','FontSize',14)
set(gca,'Tickdir','out'),set(gca,'FontSize',14)
xlim([0 length(emgs_to_predict)+1])
set(gca,'Xtick',1:length(emgs_to_predict))
set(gca,'XTickLabel',binned_data(1).emgguide(emgs_to_predict))
ylabel('VAF','FontSize',14)
legend(labels(fliplr(indx_sorted_vafs)))



% Plot an example of the predictions
emgs_plot                   = [emgs_to_predict(1) emgs_to_predict(end)]; % currently only 2
t_lim_emg_preds             = [1 21];
y_lim_emg_preds             = [-.2 1.8];

figure('units','normalized','outerposition',[0 0 1 1])
for i = 1:length(bdf_nbr)
    subplot(length(bdf_nbr),1,i),hold on
    plot(pred_data_within(i).timeframe,pred_data_within(bdf_nbr(i)).actualData(:,emgs_plot(1)),'color',[0.6 0.6 0.6],'LineWidth',3);
    plot(pred_data_within(i).timeframe,pred_data_within(bdf_nbr(i)).preddatabin(:,emgs_plot(1)),'color','k','LineWidth',2);
    plot(pred_data_within(i).timeframe,pred_data_within(bdf_nbr(i)).actualData(:,emgs_plot(2)),'color',[1 0.8 0],'LineWidth',3);
    plot(pred_data_within(i).timeframe,pred_data_within(bdf_nbr(i)).preddatabin(:,emgs_plot(2)),'color','r','LineWidth',2);
    set(gca,'Tickdir','out'),set(gca,'FontSize',16)
    ylabel(['Norm EMG --' labels(i)],'FontSize',16)
    xlim(t_lim_emg_preds), ylim(y_lim_emg_preds)
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

