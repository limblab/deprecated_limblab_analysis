function neural_tuning = compute_tuning(firing_rates,armdata,model_terms,bootstrap_params,noise_mdl)
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
neural_tuning = struct('weights',tuning_init,'weight_cov',tuning_init,'CI',tuning_init,'term_signif',tuning_init,'PD',tuning_init,'name',tuning_init);
empty_PD = struct('dir',[],'moddepth',[],'dir_CI',[],'moddepth_CI',[]);

%% Parallelize for speed
if isempty(gcp)
    parpool;
end

%% Bootstrap GLM function for each neuron
tic
for i = 1:num_units
    %bootstrap for firing rates to get output parameters
    boot_tuning = bootstrp(bootstrap_params.num_rep,@(X,y) {bootfunc(X,y)}, armdata_mat, firing_rates(:,i));
    
    %Display verbose information
    disp(['Processed Unit ' num2str(i) ' (Time: ' num2str(toc) ')']);
    
    %extract coefficiencts from boot_tuning
    boot_coef = cell2mat(cellfun(@(x) x.Coefficients.Estimate',boot_tuning,'uniformoutput',false));
    
    %coefficient covariance
    coef_cov = cov(boot_coef);
    
    %get coefficient means
    coef_means = mean(boot_coef);
    
    %get 95% CIs for coefficients
    coef_CIs = prctile(boot_coef,[2.5 97.5]);
    
    %iterate through covariates
    column_ctr = 0;
    for covar_ctr = 1:length(armdata_terms)
        %find number of columns
        num_covar_col = armdata_terms{covar_ctr}.num_base_cols*(armdata_terms{covar_ctr}.num_lags+1);
        
        %put name into outstruct
        neural_tuning(i,covar_ctr).name = armdata_terms{covar_ctr}.name;
        
        %put coefficients into outstruct
        neural_tuning(i,covar_ctr).weights = coef_means(column_ctr+1:column_ctr+num_covar_col);
        
        %put covariance into outstruct
        neural_tuning(i,covar_ctr).weight_cov = coef_cov(column_ctr+1:column_ctr+num_covar_col,column_ctr+1:column_ctr+num_covar_col);
        
        %put CIs into outstruct
        neural_tuning(i,covar_ctr).CI = coef_CIs(:,column_ctr+1:num_covar_col);
        
        %term significance
        neural_tuning(i,covar_ctr).term_signif = '?';
        
        %PD
        if(armdata_terms{covar_ctr}.doPD)
            neural_tuning(i,covar_ctr).PD = empty_PD;
            
            % bootstrap directions
            boot_dirs = atan2(boot_coef(:,column_ctr+2),boot_coef(:,column_ctr+1));
            % recenter boot_dirs
            mean_dir = atan2(neural_tuning(i,covar_ctr).weights(2),neural_tuning(i,covar_ctr).weights(1));
            centered_boot_dirs = boot_dirs-mean_dir;
            while(sum(centered_boot_dirs<-pi))
                centered_boot_dirs(centered_boot_dirs<-pi) = centered_boot_dirs(centered_boot_dirs<-pi)+2*pi;
            end
            while(sum(centered_boot_dirs>pi))
                centered_boot_dirs(centered_boot_dirs>pi) = centered_boot_dirs(centered_boot_dirs>pi)-2*pi;
            end
            
            % Calculate dir CI
            dir_CI = prctile(centered_boot_dirs,[2.5 97.5]);
            
            % uncenter CI
            dir_CI = dir_CI+mean_dir;
            
            neural_tuning(i,covar_ctr).PD.dir = mean_dir;
            neural_tuning(i,covar_ctr).PD.dir_CI = dir_CI;
            
            % bootstrap moddepth
            boot_moddepth = sum(boot_coef(:,column_ctr+1:column_ctr+2).^2,2);
            moddepth_mean = mean(boot_moddepth);
            moddepth_CI = prctile(boot_moddepth,[2.5 97.5]);
            neural_tuning(i,covar_ctr).PD.moddepth = moddepth_mean;
            neural_tuning(i,covar_ctr).PD.moddepth_CI = moddepth_CI;
        end
        
        column_ctr = column_ctr+num_covar_col;
    end
end

%% Find means, Confidence intervals, PDs

%% Delete parallel pool
delete(gcp('nocreate'))

end