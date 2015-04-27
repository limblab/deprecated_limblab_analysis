function [neural_tuning,pd_table] = compute_tuning_from_bin(binnedData,covariate,offset,num_rep,noise_mdl)
%COMPUTE_TUNING computes tuning to covariates designated by mdl, using
% bootstrapping to compute statistics on GLM-fitted parameters, given a
% noise model.
%   
% e.g. unit_tuning_stats = compute_tuning(binnedData,'pos',0.2,10,'poisson');
%
%   covariate       : string to identify the covariate.
%                     Either 'emg', 'pos', 'force', 'vel' or 'acc'
%   offset          : offset (in number of bins) between FR and covariate.
%                     positive values assume covariate to occur after spikes (motor),
%                     and negative values before (sensory).
%   num_rep         : number of bootstrap repetitions
%   noise_mdl       : noise model. Either 'poisson',
%
%   neural_tuning   : structure with neural tuning stats


%% Check input validity
num_units = size(binnedData.spikeratedata,2);

%% Set up parameters for bootstrap and GLM
% set boot function by checking stats toolbox version number
if(verLessThan('stats','8.0'))
    error('COMPUTE_TUNING requires Statistics Toolbox version 8.0(R2012a) or higher');
elseif(verLessThan('stats','9.1'))
    bootfunc = @(X,y) GeneralizedLinearModel.fit(X,y,'Distribution',noise_mdl);
else
    bootfunc = @(X,y) fitglm(X,y,'Distribution',noise_mdl);
end

%% Compose GLM input from armdata struct
% use model_terms to find which terms to include in fitting
% Assume no interaction or quadratic terms for now (model_terms must be vector of ones and zeros)
%   NEED TO CHANGE THIS LATER TO INCLUDE INTERACTION AND QUADRATIC TERMS
%   Might want to consider using some sort of Wilkinson notation...talk to
%   Tucker about this

% Extract the terms we care about
switch covariate
    case 'pos'
        cov_data = binnedData.cursorposbin;
    case 'vel'
        cov_data = binnedData.velocbin;
    case 'force'
        cov_data = binnedData.forcedatabin;
    case 'emg'
        cov_data = binnedData.emgdatabin;
    case 'acc'
        cov_data = binnedData.accelbin;
    otherwise
        error('covariate must be either ''emg'',''pos'',''vel'',''acc'', or ''force''');
end

% num_cov = size(cov_data,2);

% apply offset
if offset < 0
    binnedData.spikeratedata = binnedData.spikeratedata(offset+1:end,:);
    binnedData.timeframe     = binnedData.timeframe(offset+1:end,:);
    cov_data                 = cov_data(1:end-offset,:);
elseif offset > 0
    binnedData.spikeratedata = binnedData.spikeratedata(1:end-offset,:);
    binnedData.timeframe     = binnedData.timeframe(1:end-offset,:);
    cov_data                 = cov_data(offset+1:end,:);
end

%% Set up output struct
tuning_init = cell(num_units,1);
neural_tuning = struct('weights',tuning_init,'weight_cov',tuning_init,'CI',tuning_init,'term_signif',tuning_init,'PD',tuning_init,'unit_id',tuning_init,'name',tuning_init);
PD = struct('dir',[],'moddepth',[],'dir_CI',[],'moddepth_CI',[]);
opt = statset('UseParallel','never');
%% Bootstrap GLM function for each neuron
tic
for i = 1:num_units
    %Compose glm input dataset
%     glm_data = dataset(

    %Full GLM
%     whole_tuning = bootfunc(cov_data,binnedData.spikeratedata(:,i));
    
    %bootstrap for firing rates to get output parameters
    boot_tuning = bootstrp(num_rep,@(X,y) {bootfunc(X,y)}, cov_data, binnedData.spikeratedata(:,i),'Options',opt);
    
    %Display verbose information
    disp(['Processed Unit ' num2str(i) ' (Time: ' num2str(toc) ')']);
    
    %extract coefficiencts from boot_tuning
    boot_coef = cell2mat(cellfun(@(x) x.Coefficients.Estimate',boot_tuning,'uniformoutput',false));
    
    %coefficient covariance
    coef_cov = cov(boot_coef);
    
    %get coefficient means
    weights = mean(boot_coef);
    
    %get 95% CIs for coefficients
    coef_CIs = prctile(boot_coef,[2.5 97.5]);
    
    %term significance using likelihood ratio test and alpha=0.05
    term_signif = 1;
%     no_tuning = bootfunc(ones(size(binnedData.spikeratedata,1),2),binnedData.spikeratedata(:,i));
%     log_LR = 2*(whole_tuning.LogLikelihood-no_tuning.LogLikelihood);
%     df_partial = whole_tuning.NumCoefficients-no_tuning.NumCoefficients;
%     term_signif = chi2cdf(log_LR,df_partial,'upper')<0.05;
        
    %PD
    % bootstrap directions
    boot_dirs = atan2(boot_coef(:,2),boot_coef(:,1));
    % recenter boot_dirs
    mean_dir = atan2(weights(2),weights(1));
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
    PD.dir = mean_dir;
    PD.dir_CI = dir_CI;
    % bootstrap moddepth
    boot_moddepth = sum(boot_coef.^2,2);
    PD.moddepth = mean(boot_moddepth);
    PD.moddepth_CI = prctile(boot_moddepth,[2.5 97.5]);
        
    neural_tuning(i).name       = covariate;
    neural_tuning(i).weights    = weights;
    neural_tuning(i).weights_cov= coef_cov;
    neural_tuning(i).CI         = coef_CIs;
    neural_tuning(i).term_signif= term_signif;
    neural_tuning(i).PD         = PD;
    neural_tuning(i).unit_id    = binnedData.neuronIDs(i,:);
    
end