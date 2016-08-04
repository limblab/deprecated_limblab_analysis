%
% Build a within decoder for each task using neural PCs as inputs, and
% compare to the performance of a normal decoder that takes neurons as
% inputs
%
%   function [pred_data_within, vaf_array, vaf_array_norm, vaf_neurons, binned_data] = ...
%               within_EMG_preds_fcn_nbr_neural_comp_mfxval( bdf, dim_red_FR, labels, ...
%                                                            max_nbr_comp, varargin )
%
% Inputs (opt)              : [default]
%   bdf                     : BDF struct or array of BDFs, with neural and
%                               EMG data
%   dim_red_FR              : dim_red_FR struct, with "neural synergies"
%                               obtained with PCA or FA
%   labels                  : cell array with labels for each trial, for
%                               plotting
%   max_nbr_comp            : maximum number the "neural synergies"
%                               (components) that will be included in the
%                               decoders (it will be from 1:max_nbr_comp)
%   (emgs_to_predict)       : ['all'] array with EMG channels to predict
%   (binned_data)           : [''] binned_data struct; if empty, the BDF
%                               data will be binned inside this function
%                               using default parameters 
%   (method)                : ['no_xval'] whether we want to do multifold
%                               crossvalidation ('mfxval') of the
%                               predictions or not 
%   (fold_length)           : [60] fold-length if doing mfxval
%   (plot_yn)               : [false] plot summary stats and prediction examples
%   (bin_size)              : [0.05] bin width (s)
%
%
% Outputs                   :
%   pred_data_within        : 
%   vaf_array               :
%   vaf_array_norm          :
%   vaf_neurons
%   binned_data 
%
%
% Note: the mfxval is based on the lab-wide function mfxval
%
%

function [pred_data_within, vaf_array, vaf_array_norm, vaf_neurons, R2_array, R2_neurons, binned_data] = ...
            within_EMG_preds_fcn_nbr_neural_comp_mfxval( bdf, dim_red_FR, labels, max_nbr_comp, varargin )


% -------------------------------------------------------------------------
% read inputs

% EMG channels to predict
if nargin >= 5
    if ~isempty(varargin{1})
        emgs_to_predict         = varargin{1};
    else
        emgs_to_predict         = 1:length(length(bdf(1).emg.emgnames));
    end
end

% Read binned_data, if passed
if nargin >= 6
    binned_data                 = varargin{2};
    bin_data_yn                 = false;
% Otherwise, bin it
else
    bin_data_yn                 = true;
end

% Do multifold cross-validation?
if nargin >= 7
    method                      = varargin{3}; % 'mfxval' or 'no_xval'
else
    method                      = 'no_xval';
end

% Fold length, if doing mfxval
if nargin >= 8
    fold_length                 = varargin{4};
else
    fold_length                 = 60;
end
    
% plot prediction examples and summary stats?
if nargin >= 9
    plot_yn                     = varargin{5};
else
    plot_yn                     = false;
end

% choose bin size, if the data are binned here
if nargin == 10
    bin_size                    = varargin{6};
else
    bin_size                    = 0.05;
end


% -------------------------------------------------------------------------
% Set some other params


switch method 
    case 'mfxval'
        
    case 'no_xval'
        
end

% if not set before, predict all EMG channels
if ~exist('emgs_to_predict','var')
	emgs_to_predict             = 1:length(bdf(1).emg.emgnames);
end


% Options for the decoder
% polynomial order; by default don't use a static non-linearity
opts_filt.PolynomialOrder       = 0; 

% EMG options
%crop_emg_noise                  = false;
%min_perc                        = 5; % EMG values below this will be cut to zero


%% ------------------------------------------------------------------------
% BIN THE DATA


% get nbr of BDFs
bdf_nbr                         = 1:length(bdf);

% bin the data, if not passed
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

% get rid of the neural channels not used in the "neural synergies"
for i = 1:length(bdf)
    
    chs_to_discard          = setdiff(1:size(binned_data(i).neuronIDs,1),...
        dim_red_FR{i}.chs);
    binned_data(i).neuronIDs(chs_to_discard,:) = [];
    binned_data(i).spikeratedata(:,chs_to_discard) = [];
end
    
% % If DOING MFXVAL, trim the binned_data so it's a multiple of the number of
% % folds
% 
% % calculate the total number of folds
% nbr_folds               = floor((binned_data(1).timeframe(end)-binned_data(1).timeframe(1))...
%                             /fold_length);
% 
% % find end time so the binned_data struct duration is an exact multiple of
% % fold_length
% t_last_sample_mfxval    = binned_data(1).timeframe(1) + nbr_folds*fold_length;
% % % and get its corresponding index --note that the weird code is to avoid
% % % rounding errors
% % indx_last_sample_mfxval = find( binned_data(1).timeframe > t_last_sample_mfxval,1 ) - 1;
% 
% for i = 1:length(bdf)
%     aux_binned_data(i)  = crop_binned_data(binned_data(i),...
%                             [binned_data(1).timeframe(1),t_last_sample_mfxval]);
% end


%% ------------------------------------------------------------------------
% REMOVE the EMG CHANNELS we don't want

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
% Build "standard" neuron-to-EMG decoders
% -- Predict using neurons as input, for comparison

% set EMG prediction flag, for our lab-wide code
options_neuron_filter.PredEMGs  = true;
% set filter length to our standard 0.5 s
options_neuron_filter.fillen    = 0.5;

% Get rid of neurons with very low firing rate
for i = 1:length(bdf_nbr)
    mean_FR                     = mean(binned_data(i).spikeratedata);
    indx_low_FR                 = find(mean_FR<0.01);
    binned_data(i).spikeratedata(:,indx_low_FR) = [];
    binned_data(i).neuronIDs(indx_low_FR,:)     = [];
end

switch method
    % ---------------------------------------------------------------------
    % DO NOT CROSSVALIDATE
    case 'no_xval'
        
        % build a decoder for each BDF (task)
        for i = 1:length(bdf_nbr)
            [aux_filt_neurons, aux_pred_neurons] = BuildModel( binned_data(bdf_nbr(i)), ...
                                                    options_neuron_filter );

            filter_neurons_within(i)    = aux_filt_neurons;
            pred_neurons_within(i)      = aux_pred_neurons;
            clear aux_filt_neurons aux_pred_neurons
        end
    % ---------------------------------------------------------------------
    % MULTIFOLD CROSSVALIDATION
    case 'mfxval'
        
        disp('Doing crossvalidation of neuron to EMG decoders');
        disp('...')
        
        % to avoid having problems with crop_binned_data...
        % ToDo: do this in a more elegant way...
        t_start                     = max(bin_size,binned_data(1).timeframe(1));
        
        nbr_folds                   = floor((binned_data(1).timeframe(end)-t_start)...
                                    /fold_length);
                                
        % crop binned_data so we are only crossvalidating in n-folds (cut
        % data that "exceeds" a fold
        for b = 1:length(bdf)
            binned_data(b)        = crop_binned_data( binned_data(b), [t_start ...
                                        t_start+nbr_folds*fold_length] ); 
        end
                                
        
        % build a decoder for each BDF (task)
        for i = 1:length(bdf_nbr)
        
            R2_neurons_mfxval       = zeros(numel(emgs_to_predict),nbr_folds);
            vaf_neurons_mfxval      = zeros(numel(emgs_to_predict),nbr_folds);
            
            % do for each fold
            for f = 0:nbr_folds-1
                test_data_start     = f*fold_length + binned_data(i).timeframe(1);
                test_data_end       = test_data_start + fold_length;
                
                % Split the data into train data (for building the
                % decoder), and test_data (for testing it).
                [train_data, test_data] = splitBinnedData(binned_data(i),...
                                            test_data_start, test_data_end);
                
                % build model for this segment, and make predictions
                model               = BuildModel( train_data, options_neuron_filter );
                pred_data           = predictSignals( model, test_data );
                
                            
                % compute figures of merit
                R2_neurons_mfxval(:,f+1) = CalculateR2(pred_data.preddatabin, ...
                                        test_data.emgdatabin(options_neuron_filter.fillen...
                                        /bin_size:end,:));

                vaf_neurons_mfxval(:,f+1) = calc_vaf(pred_data.preddatabin, ...
                                        test_data.emgdatabin(options_neuron_filter.fillen...
                                        /bin_size:end,:));                
                                    
                % concatenate predicted data, if we want to plot it later
                if f == 0
                    conc_pred_data  = pred_data;
                else
                    conc_pred_data.timeframe = [conc_pred_data.timeframe; pred_data.timeframe];
                    conc_pred_data.preddatabin = [conc_pred_data.preddatabin; pred_data.preddatabin];
                end
            end
            
            % store results for this BDF
            pred_neurons_within_mfxval(i).R2 = R2_neurons_mfxval;
            pred_neurons_within_mfxval(i).vaf = vaf_neurons_mfxval;
            pred_neurons_within_mfxval(i).conc_pred_data = conc_pred_data;
            % remove some fields we don't need
            pred_neurons_within_mfxval(i).conc_pred_data = ...
                rmfield(pred_neurons_within_mfxval(i).conc_pred_data,'spikeratedata');
            pred_neurons_within_mfxval(i).conc_pred_data = ...
                rmfield(pred_neurons_within_mfxval(i).conc_pred_data,'spikeguide');
        end
        
        clear conc_pred_data R2_neurons_mfxval vaf_neurons_mfxval test_data train_data pred_data
end
    

%% ------------------------------------------------------------------------
% Build the neural PC to EMG decoders


switch method
    % ---------------------------------------------------------------------
    % DO NOT CROSSVALIDATE
    case 'no_xval'

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

    % ---------------------------------------------------------------------
    % MULTIFOLD CROSSVALIDATION
    case 'mfxval'
        
        for j = 1:max_nbr_comp
        
            disp(['Doing crossvalidation of neural synergy to EMG decoders for n = ' num2str(j)]);
            disp('...')

            % build a decoder for each BDF (task)
            for i = 1:length(bdf_nbr)

                R2_synergies_mfxval     = zeros(numel(emgs_to_predict),nbr_folds);
                vaf_synergies_mfxval    = zeros(numel(emgs_to_predict),nbr_folds);
        
                % do for each fold
                for f = 0:nbr_folds-1
                    test_data_start     = f*fold_length + binned_data(i).timeframe(1);
                    test_data_end       = test_data_start + fold_length;
                    
                    % Split the data into train data (for building the
                    % decoder), and test_data (for testing it). 
                    % a) for the binned_data (EMGs)
                    [train_data, test_data] = splitBinnedData(binned_data(i),...
                        test_data_start, test_data_end);
                    % b) for the "neural synergies," get the indexes that
                    % correspond to the binned data and take the
                    % corresponding portion of dim_red_FR
                    indx_train_data         = round( ( train_data.timeframe-binned_data(i).timeframe(1) )...
                                                /bin_size + 1 );
                    train_dim_red_FR.scores = dim_red_FR{i}.scores(indx_train_data,:);
                    train_dim_red_FR.t = dim_red_FR{i}.t(indx_train_data);
                    
                    indx_test_data          = round((test_data.timeframe-binned_data(i).timeframe(1))/bin_size+1);
                    test_neural_data        = dim_red_FR{i}.scores(indx_test_data,1:j);

%                     % TEST!!!
%                     test_neural_data_t      = dim_red_FR{i}.t(indx_test_data,1:j);
%                     figure,plot(test_neural_data_t-test_data.timeframe);hold on, plot(train_dim_red_FR.t-train_data.timeframe,'.-r')

                    % build the model for this segment
                    [aux_filter, ~]         = call_BuildModel_dim_red_neurons( ...
                                                    train_data, train_dim_red_FR, j, opts_filt );
                    % and make predictions
                    [pred_data,~,~]         = predMIMO4(test_neural_data,aux_filter.H,1,...
                                                    1,test_data.emgdatabin); % 1/bin_size,test_data.emgdatabin);

%                     % ANOTHER TEST!!!   
%                     [pred_data2,~,~]        = predMIMO4(train_dim_red_FR.scores(:,1),aux_filter.H,1,...
%                                                     1,train_data.emgdatabin);
                                              

                    % compute figures of merit
                    R2_synergies_mfxval(:,f+1) = CalculateR2(pred_data, ...
                                        test_data.emgdatabin(options_neuron_filter.fillen...
                                        /bin_size:end,:));

                    vaf_synergies_mfxval(:,f+1) = calc_vaf(pred_data, ...
                                        test_data.emgdatabin(options_neuron_filter.fillen...
                                        /bin_size:end,:));
                    
                     
                    % concatenate predicted data, if we want to plot it later
                    % -- ToDo: fix so it's a structure with a timeframe and databin
                    % fields -- like for the neurons
                    if f == 0
                        conc_pred_data  = pred_data;
                    else
                        conc_pred_data  = [conc_pred_data; pred_data];
                    end
                    
                    clear train* test* pred_data
                end
                
                % store results for this BDF
                pred_within_mfxval{i}.dims{j}.R2    = R2_synergies_mfxval;
                pred_within_mfxval{i}.dims{j}.vaf   = vaf_synergies_mfxval;
                pred_within_mfxval{i}.dims{j}.conc_pred_data = conc_pred_data;
%                 % remove some fields we don't need
%                 pred_within_mfxval(i).conc_pred_data = ...
%                     rmfield(pred_neurons_within_mfxval(i).conc_pred_data,'spikeratedata');
%                 pred_within_mfxval(i).conc_pred_data = ...
%                     rmfield(pred_neurons_within_mfxval(i).conc_pred_data,'spikeguide');
                clear conc_pred_data
            end
        end
end

%% ------------------------------------------------------------------------
% Return calculations

% Create variable to return VAF of EMG predictions using neurons
for i = 1:length(bdf)
    switch method
        case 'no_xval' 
            vaf_neurons(:,i)                = pred_neurons_within(i).vaf;
            R2_neurons(:,i)                 = pred_neurons_within(i).R2;
        case 'mfxval'
            vaf_neurons(:,i)                = mean(pred_neurons_within_mfxval(i).vaf,2);
            R2_neurons(:,i)                 = mean(pred_neurons_within_mfxval(i).R2,2);
    end
end

% create an array with VAFs per BDF
for i = 1:length(bdf)
    switch method
        case 'no_xval' 
            for ii = 1:max_nbr_comp 
                vaf_array(ii,:,i) = pred_data_within(ii,i).vaf; 
                R2_array(ii,:,i) = pred_data_within(ii,i).R2;
            end
        case 'mfxval'
            for ii = 1:max_nbr_comp 
                vaf_array(ii,:,i) = mean(pred_within_mfxval{i}.dims{ii}.vaf,2); 
                R2_array(ii,:,i) = mean(pred_within_mfxval{i}.dims{ii}.R2,2); 
            end
    end
end

% create an array with VAFs per BDF, divided by the VAF for the same muscle
% with the neuron decoder 
for i = 1:length(bdf)
    switch method
        case 'no_xval'     
             for ii = 1:max_nbr_comp 
        %         vaf_array_norm(ii,:,i) = pred_data_within(ii,i).vaf./pred_neurons_within(i).vaf; 
                 vaf_array_norm(ii,1:length(emgs_to_predict),i) = pred_data_within(ii,i).vaf./pred_neurons_within(i).vaf; 
             end
        case 'mfxval'
            for ii = 1:max_nbr_comp 
                vaf_array_norm(ii,1:length(emgs_to_predict),i) = vaf_array(ii,:,i)./vaf_neurons(:,i)'; 
            end
    end
end

% rename the return var for mfxval
if method == 'mfxval'
    pred_data_within    = pred_within_mfxval;
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
    legend(muscle_names,'FontSize',14,'Location','SouthEast')
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
    legend(muscle_names,'FontSize',14,'Location','SouthEast')
    title(labels(i))
end

%% ------------------------------------------------------------------------

% Plot an example of the predictions
if plot_yn 
    
    % TODO: move this as param???
    emgs_plot                       = [emgs_to_predict(3) emgs_to_predict(end-2)]; % currently only 2

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


%% ------------------------------------------------------------------------
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

%% ------------------------------------------------------------------------------------
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

