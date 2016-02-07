

function [filter, varargout] = BuildModel_dim_red_neurons( binned_data, dim_red_FR, nbr_dims )


% check bin width PC firing rates and EMGs is the same
bin_size_red_FR             = mean(diff(dim_red_FR.t)); 
bin_size_EMGs               = mean(diff(binned_data.timeframe));

if abs( bin_size_red_FR - bin_size_EMGs ) > 1E-6
    error('bin size neurons and EMG data has to be the same');
end

% Parameters to build the decoder
options                     = ModelBuilding_dim_red_neurons_Default();
% decode EMGs
options.PredEMGs            = true;
% use nbr_dims PCs in neural space
options.numPCs              = nbr_dims;


% add the PC transformed neural data that will be used for building the
% decoder in binned_data
binned_data.pca_transf_spikerate = dim_red_FR.scores;


% build filter
[filter, pred_data]         = BuildModel_dim_red_neurons( binned_data, options );

if nargout == 2
    varargout{1}            = pred_data;
end