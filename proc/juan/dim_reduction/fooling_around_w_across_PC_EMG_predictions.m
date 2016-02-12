%
% Run a decoder in other tasks (across)

clear filter_within pred_data_within


% BDF to build decoder
bdf_for_decoder     = 3; % 1 = iso, 2 = wm, 3 = spr
% nbr PCs to build decoder
nbr_pcs_decoder     = 2;


% build decoder
[filter_within, pred_data_within] = call_BuildModel_dim_red_neurons( binned_data(bdf_for_decoder), dim_red_FR{bdf_for_decoder}, nbr_pcs_decoder );


% The decoder you want to use
filter              = filter_within;

H                   = filter.H;
numlags             = filter.fillen/filter.binsize;

% file to predict
bdf_to_predict      = 2;
% emgs to predict
emgs_to_predict     = [2:5 7 9 10 11];


% ------------------------------------------------------------------------
% plot the raw emgs, somewhat grouped by action
flex_to_predict     = strncmp(binned_data(1).emgguide(emgs_to_predict),'F',1);
ext_to_predict      = strncmp(binned_data(1).emgguide(emgs_to_predict),'E',1);
others_to_predict   = logical(ones(1,length(emgs_to_predict)) - flex_to_predict - ext_to_predict);

t_lim_raw_emgs      = [0 20]; % time axis for the plot
y_lim_emgs          = [0 1.5]; % limit for normalized EMGs

figure('units','normalized','outerposition',[0 0 1 1])
% flexors
subplot(311),
plot(binned_data(bdf_to_predict).timeframe, binned_data(bdf_to_predict).emgdatabin(:,emgs_to_predict(flex_to_predict)),'LineWidth',2 )
set(gca,'Tickdir','out'),set(gca,'FontSize',16)
ylabel('Norm EMG flexors','FontSize',16)
legend(binned_data(bdf_to_predict).emgguide(emgs_to_predict(flex_to_predict)))
ylim(y_lim_emgs),xlim(t_lim_raw_emgs)
title(binned_data(bdf_to_predict).meta.filename,'Interpreter','none')
% extensors
subplot(312),
plot(binned_data(bdf_to_predict).timeframe, binned_data(bdf_to_predict).emgdatabin(:,emgs_to_predict(ext_to_predict)),'LineWidth',2 )
set(gca,'Tickdir','out'),set(gca,'FontSize',16)
ylabel('Norm EMG extensors','FontSize',16)
legend(binned_data(bdf_to_predict).emgguide(emgs_to_predict(ext_to_predict)))
ylim(y_lim_emgs),xlim(t_lim_raw_emgs)
% other muscles
subplot(313),
plot(binned_data(bdf_to_predict).timeframe, binned_data(bdf_to_predict).emgdatabin(:,emgs_to_predict(others_to_predict)),'LineWidth',2 )
set(gca,'Tickdir','out'),set(gca,'FontSize',16)
ylabel('Norm EMG','FontSize',16)
legend(binned_data(bdf_to_predict).emgguide(emgs_to_predict(others_to_predict)))
ylim(y_lim_emgs),xlim(t_lim_raw_emgs)
xlabel('time (s)','FontSize',16)


% ------------------------------------------------------------------------
% Decoder stuff

% assign vars
inputs              = dim_red_FR{bdf_to_predict}.scores(:,1:((size(H,1)-1)/numlags));
Yact                = binned_data(bdf_to_predict).emgdatabin(:,emgs_to_predict);

% do not predict the EMGs we don't want
H                   = H(:,emgs_to_predict);

% decode!
[PredictedData, inputs_new, ActualDataNew] = predMIMO4( inputs, H, 1, 1, Yact );


% return same struct as BuildModel 
OutNames            = binned_data(1).emgguide(emgs_to_predict);

PredData            = struct(   'preddatabin', PredictedData, ...
                                'timeframe', binned_data(1).timeframe(numlags:end),...
                                'spikeratedata',[], ...
                                'outnames',{OutNames},...
                                'neuronIDs',binned_data(1).neuronIDs, ...
                                'vaf',RcoeffDet(PredictedData,ActualDataNew),...
                                'actualData',ActualDataNew);