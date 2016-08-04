

function [filter, varargout] = call_BuildModel_dim_red_neurons( binned_data, dim_red_FR, nbr_dims, model_opts )


% check bin width PC firing rates and EMGs is the same
% --take the 99 percentile, because when doing mfxval there may be one or a
% big jump 
bin_size_red_FR             = mean(prctile(diff(dim_red_FR.t),99)); 
bin_size_EMGs               = mean(prctile(diff(binned_data.timeframe),99));

if abs( bin_size_red_FR - bin_size_EMGs ) > 1E-6
    error('bin size neurons and EMG data has to be the same');
end

% Parameters to build the decoder -- add as optional parameters
options                     = ModelBuilding_dim_red_neurons_Default();
% decode EMGs
options.PredEMGs            = true;
% use nbr_dims PCs in neural space
options.numPCs              = nbr_dims;
% overwrite other params, if passed
if nargin == 4
    if isfield(model_opts,'fillen')
        options.fillen      = model_opts.fillen;
    end
    if isfield(model_opts,'PolynomialOrder')
        options.PolynomialOrder     = model_opts.PolynomialOrder;
    end
end


% add the PC transformed neural data that will be used for building the
% decoder in binned_data
binned_data.pca_transf_spikerate = dim_red_FR.scores;


% build filter
[filter, pred_data]         = BuildModel_dim_red_neurons( binned_data, options );

if nargout == 2
    varargout{1}            = pred_data;
end