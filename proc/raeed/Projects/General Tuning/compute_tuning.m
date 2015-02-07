function outstruct = compute_tuning(firing_rates,armdata,mdl,bootstrap_params,noise_mdl)
%COMPUTE_TUNING computes tuning to covariates designated by mdl, using
% bootstrapping to compute statistics on GLM-fitted parameters, given a
% noise model.
%   

% Check input validity

% Set up parameters for bootstrap and GLM


% Compose GLM input from armdata struct

% Parallelize for speed
if ~isempty(gcp)
    parpool;
end

% Bootstrap GLM function

% Find means, Confidence intervals, PDs

% Delete parallel pool
delete(gcp('nocreate'))