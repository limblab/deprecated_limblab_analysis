function outstruct = compute_tuning(firing_rates,armdata,model_terms,bootstrap_params,noise_mdl)
%COMPUTE_TUNING computes tuning to covariates designated by mdl, using
% bootstrapping to compute statistics on GLM-fitted parameters, given a
% noise model.
%   

%% Check input validity

%% Set up parameters for bootstrap and GLM
% set boot function by checking stats toolbox version number
if(verLessThan('stats','8.0'))
    error('COMPUTE_TUNING requires Statistics Toolbox version 8.0(R2012a) or higher');
elseif(verLessThan('stats','9.1'))
    bootfunc = @GeneralizedLinearModel.fit;
else
    bootfunc = @(X,y) fitglm(X,y,;
end

%% Compose GLM input from armdata struct
% use model_terms to find which terms to include in fitting
% Assume no interaction or quadratic terms for now (model_terms must be vector of ones and zeros)
%   NEED TO CHANGE THIS LATER TO INCLUDE INTERACTION AND QUADRATIC TERMS
% Extract the terms we care about
armdata_tems = armdata{model_terms};
% Extract the data from each term into a matrix
armdata_mat = cell2mat(cellfun(@(x) x.data,armdata_terms,'uniformoutput',false));

%% Set up output struct


%% Parallelize for speed
if ~isempty(gcp)
    parpool;
end

%% Bootstrap GLM function for each neuron
for i = 1:size(firing_rates,2)
    %bootstrap for firing rates to get output parameters
    boot_tuning = bootstrp(bootstrap_params.num_rep, {bootfunc}, armdata_mat, firing_rates(:,i));
    
end

%% Find means, Confidence intervals, PDs

%% Delete parallel pool
delete(gcp('nocreate'))

end

function covariate_data = extract_data(covariate_struct)
% to be applied to a single covariate from armdata
    covariate_data = covariate_struct.data