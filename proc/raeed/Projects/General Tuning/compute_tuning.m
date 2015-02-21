function outstruct = compute_tuning(firing_rates,armdata,model_terms,bootstrap_params,noise_mdl)
%COMPUTE_TUNING computes tuning to covariates designated by mdl, using
% bootstrapping to compute statistics on GLM-fitted parameters, given a
% noise model.
%   

%% Check input validity
num_units = size(firing_rates,2);

%% Set up parameters for bootstrap and GLM
% set boot function by checking stats toolbox version number
if(verLessThan('stats','8.0'))
    error('COMPUTE_TUNING requires Statistics Toolbox version 8.0(R2012a) or higher');
elseif(verLessThan('stats','9.1'))
    bootfunc = @(X,y) GeneralizedLinearModel.fit(X,y,'Distribution',noise_mdl);
else
    bootfunc = @(X,y) fitglm(X,y,'Distribution',noise_mdl);
%     bootfunc = @(X,y) X\y;
end

%% Compose GLM input from armdata struct
% use model_terms to find which terms to include in fitting
% Assume no interaction or quadratic terms for now (model_terms must be vector of ones and zeros)
%   NEED TO CHANGE THIS LATER TO INCLUDE INTERACTION AND QUADRATIC TERMS
%   Might want to consider using some sort of Wilkinson notation...talk to
%   Tucker about this
% Extract the terms we care about
armdata_terms = armdata(logical(model_terms));
% Extract the data from each term into a matrix
armdata_mat = cell2mat(cellfun(@(x) x.data,armdata_terms,'uniformoutput',false));

%% Set up output struct
tuning_init = cell(num_units,length(armdata_terms));
neural_tuning = struct('weights',tuning_init,'CI',tuning_init,'term_signif',tuning_init,'PD',tuning_init,'covar_name',tuning_init);
empty_PD = struct('dir',[],'moddepth',[],'dir_CI',[],'moddepth_CI',[]);

%% Parallelize for speed
if isempty(gcp)
    parpool;
end

%% Bootstrap GLM function for each neuron
for i = 1:num_units
    %bootstrap for firing rates to get output parameters
    boot_tuning = bootstrp(bootstrap_params.num_rep,@(X,y) {bootfunc(X,y)}, armdata_mat, firing_rates(:,i));
    
    %extract coefficiencts from boot_tuning
    boot_coef = cell2mat(cellfun(@(x) x.Coefficients.Estimate',boot_tuning,'uniformoutput',false));
end

%% Find means, Confidence intervals, PDs

%% Delete parallel pool
delete(gcp('nocreate'))

end