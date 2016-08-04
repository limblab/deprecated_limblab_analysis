%
% This version of the function only does neural PC decoding with a number
% of dimensions that the user specifies in 'last_neural_pc.'
%
% TODO:
%     - Include increasing numbers of components
%     - Do closest_eigenv symmetric (swapping cols 1 and 2 in lower diag),
%     to predict EMGs from task N using M but also EMGs from task M using N
%     (where M<N)
%

function [pred_data_across, vaf_array, vaf_array_norm, vaf_neurons, binned_data] = ...
            across_EMG_preds_fcn_nbr_neural_comp( bdf, dim_red_FR, labels, ...
            last_neural_pc, varargin )

comb_tasks                  = nchoosek(1:nbr_bdfs,2);
nbr_comb_tasks              = size(comb_tasks,1);
nbr_dims                    = length(dim_red_FR{1}.eigen);        

% read inputs
if nargin >= 5
    if ~isempty(varargin{1})
        emgs_to_predict     = varargin{1};
    else
        emgs_to_predict     = 1:length(length(bdf(1).emg.emgnames));
    end
end

if nargin == 6
    % reorder the eigenvectors based on how similar they are
    closest_eigenv          = varargin{2};
else
    % if not passed, order eigenv according to eigenval ranking
    closest_eigenv          = cell(length(bdf));
    aux_closest_eigenv      = zeros(nbr_dims,2);
    aux_closest_eigenv(:,1) = 1:nbr_dims;
    aux_closest_eigenv(:,2) = 1:nbr_dims;
    for i = 1:nbr_comb_tasks
        closest_eigenv{comb_tasks(i,1),comb_tasks(i,2)} = aux_closest_eigenv;
    end
    clear aux_closest_eigenv;

end

if nargin == 7
    binned_data             = varargin{3};
    bin_data_yn             = false;
else
    bin_data_yn             = true;
end

if ~exist('emgs_to_predict','var')
	emgs_to_predict         = 1:length(bdf(1).emg.emgnames);
end


% Some opts
plot_yn                     = false;


nbr_bdfs                    = length(bdf);
% bdf_nbr                         = 1:nbr_bdfs;

% Options for the decoder
opts_filt.PolynomialOrder   = 0; % polynomial order, if want to use static non-linearity

%% ------------------------------------------------------------------------
% BIN THE DATA -- decide whether they are normalized or not

if bin_data_yn 
    
    if exist('binned_data','var'), clear binned_data, end;
    b2bparams.NormData      = true;

    for i = 1:length(bdf)
        binned_data(i)      = convertBDF2binned(bdf(i),b2bparams);
    end
end


%% ------------------------------------------------------------------------
% REMOVE EMG channels

emgs_to_remove              = setdiff(1:length(binned_data(1).emgguide),...
                                emgs_to_predict);
                            
if ~isempty(emgs_to_remove)
    % only do it if there are more EMGs in the binned data than expected
    % --the EMGs may have been removed in a previous run
    if length(emgs_to_predict) ~= length(binned_data(1).emgguide);
        for i = 1:nbr_bdfs
            binned_data(i).emgdatabin(:,emgs_to_remove) = [];
            binned_data(i).emgguide(:,emgs_to_remove)   = [];
        end
    end
end


%% ------------------------------------------------------------------------
% Build all WITHIN neuron-to-EMG decoders

% Predict using neurons as input, for comparison
options_neuron_filter.PredEMGs  = true;

% Get rid of neurons with very low firing rate
for i = 1:nbr_bdfs
    mean_FR                     = mean(binned_data(i).spikeratedata);
    indx_low_FR                 = find(mean_FR<0.001);
    binned_data(i).spikeratedata(:,indx_low_FR) = [];
    binned_data(i).neuronIDs(indx_low_FR,:)     = [];
end
    
for i = 1:nbr_bdfs
    [aux_filt_neurons, aux_pred_neurons] = BuildModel( binned_data(i), ...
                                            options_neuron_filter );
    
    filter_neurons_within(i)    = aux_filt_neurons;
    pred_neurons_within(i)      = aux_pred_neurons;
    clear aux_filt_neurons aux_pred_neurons
end


%% ------------------------------------------------------------------------
% Do ACROSS Neuron-to-EMG predictions

for c = 1:nbr_comb_tasks
    
    % get tasks
    t_1                 = comb_tasks(c,1);
    t_2                 = comb_tasks(c,2);
        
    % get the filter we'll use to predict (the filter from t_1)
    H                   = filter_neurons_within(t_1).H;
    numlags             = filter_neurons_within(t_1).fillen/...
                            filter_neurons_within(t_1).binsize;
    
    % get the EMGs we want to decode
    Yact                = binned_data(t_2).emgdatabin;
    
    % and the spikes for that
    inputs              = binned_data(t_2).spikeratedata;
    
    % decode
    [aux_pred_data, aux_input_new, aux_actual_data_new] = predMIMO4( inputs, H, 1, 1, Yact );

    % to return same struct as BuildModel 
    OutNames            = binned_data(1).emgguide;

    pred_neurons_across(c) = struct('preddatabin', aux_pred_data, ...
                                    'timeframe', binned_data(1).timeframe(numlags:end),...
                                    'spikeratedata',[], ...
                                    'outnames',{OutNames},...
                                    'neuronIDs',binned_data(1).neuronIDs, ...
                                    'vaf',RcoeffDet(aux_pred_data,aux_actual_data_new),...
                                    'actualData',aux_actual_data_new,...
                                    'combTasks',[t_1 t_2]);
                                
    clear aux_pred_data aux_actual_data_new;
end


%% ------------------------------------------------------------------------
% Build all WITHIN neural PC-to-EMG decoders

for i = 1:nbr_bdfs
    
    [aux_filt_within, aux_pred_within] = call_BuildModel_dim_red_neurons( ...
        binned_data(i), dim_red_FR{i}, last_neural_pc );
    
    filter_within(i)    = aux_filt_within;
    pred_within(i)      = aux_pred_within;
end


%% ------------------------------------------------------------------------
% Do ACROSS PC-to-EMG predictions

% Predict the EMGs from task t_2 using the decoder from task t_1 (and the
% neural data from t_2)

for c = 1:nbr_comb_tasks
    
    % get tasks
    t_1                 = comb_tasks(c,1);
    t_2                 = comb_tasks(c,2);
    
    % get corresponding eigenvectors (the eigenvectors of t_2 that are
    % closest to the first 1:last_neural_pc eigenvectors in t_1)
    eigenv_t2           = closest_eigenv{t_1,t_2}(1:last_neural_pc,2);
    
    % get the filter we'll use to predict (the filter from t_1)
    H                   = filter_within(t_1).H;
    numlags             = filter_within(t_1).fillen/filter_within(t_1).binsize;
    
    % get the inputs, which are the scores that correspond to the
    % 1:last_neural_pc first eigenvalues in the first task of the pair in
    % comb_tasks(c,:)
    inputs              = dim_red_FR{t_2}.scores(:,eigenv_t2);
    
    % get the EMGs we want to decode
    Yact                = binned_data(t_2).emgdatabin;
    
    % decode
    [aux_pred_data, ~, aux_actual_data_new] = predMIMO4( inputs, H, 1, 1, Yact );

    % to return same struct as BuildModel 
    OutNames            = binned_data(1).emgguide;

    pred_across(c)      = struct(   'preddatabin', aux_pred_data, ...
                                    'timeframe', binned_data(1).timeframe(numlags:end),...
                                    'spikeratedata',[], ...
                                    'outnames',{OutNames},...
                                    'neuronIDs',binned_data(1).neuronIDs, ...
                                    'vaf',RcoeffDet(aux_pred_data,aux_actual_data_new),...
                                    'actualData',aux_actual_data_new,...
                                    'combTasks',[t_1 t_2]);
end


emgs_to_plot = [2 6];
t_w = 2;
t_a = 3; % this wil be the row in comb_tasks)
xlp = [300 330];
cols = ['r','m'];
cols2 = ['b','g'];
figure('units','normalized','outerposition',[0 0 1 1])
for i = 1:length(emgs_to_plot)
    % neural PCs
    subplot(2,2,i*2-1), hold on
    plot(pred_within(t_w).timeframe, pred_within(t_w).actualData(:,emgs_to_plot(i)),...
        'linewidth',2,'color',[.6 .6 .6])
    plot(pred_within(t_w).timeframe, pred_within(t_w).preddatabin(:,emgs_to_plot(i)),...
        'linewidth',2,'color',cols(i))
    plot(pred_across(t_w).timeframe, pred_across(t_w).preddatabin(:,emgs_to_plot(i)),...
        '--','linewidth',3,'color',cols2(i)) 
    legend('actual','within','across')
    set(gca,'TickDir','out'),set(gca,'FontSize',14)
    if i == 1
        title('projections onto neural PCs as inputs','fontsize',14)
    end
    xlim(xlp)
    % spikes
    subplot(2,2,i*2), hold on
    plot(pred_within(t_w).timeframe, pred_within(t_w).actualData(:,emgs_to_plot(i)),...
        'linewidth',2,'color',[.6 .6 .6])
    plot(pred_neurons_within(t_w).timeframe, pred_neurons_within(t_w).preddatabin(:,emgs_to_plot(i)),...
    'linewidth',2,'color',cols(i))
    plot(pred_neurons_across(t_w).timeframe, pred_neurons_across(t_w).preddatabin(:,emgs_to_plot(i)),...
    '--','linewidth',3,'color',cols2(i)) 
    legend('actual','within','across')
    set(gca,'TickDir','out'),set(gca,'FontSize',14)
    if i == 1
        title('spikes as inputs','fontsize',14)
    end
    xlim(xlp)
end