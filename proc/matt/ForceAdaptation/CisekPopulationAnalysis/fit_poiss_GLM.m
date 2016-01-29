function [ predictions, fit_parameters, fit_info, pseudo_R2] = fit_poiss_GLM( X_data, y_data, num_CV, dt, reg_strength, alpha, type, bins_per_trial )
% Fit functional connectivity for Associative Learning data


%% Initialize

if nargin < 7
    bins_per_trial = 700;
    alpha = 1;
    disp('Using L1 regularization')
elseif nargin < 6
    % Set regularization strength
    alpha = 1;
    bins_per_trial = 700;
    disp('Using L1 regularization')
elseif nargin < 5
    reg_strength = false;
    bins_per_trial = 700;
    disp('Fitting regularization parameter')
elseif nargin < 4
    dt = .01;
    bins_per_trial = 700;
    disp('dt not supplied, using dt = .01 (10 ms)')
elseif nargin < 3
    num_CV = 10;
    bins_per_trial = 700;
    disp('Using 10 cross validation folds')
elseif nargin < 2
    bins_per_trial = 700;
    error('You must provide X and y data')
end

fit_info = cell(1,num_CV);
fit_parameters = cell(1,num_CV);
predictions = repmat({nan(1,length(y_data))},num_CV,1); % One cell for each CV, each cell initialized with NaN
pseudo_R2 = nan(num_CV,3);
X_data = full(X_data);

%% User inputs

old_format = (length(bins_per_trial)==1);

if old_format
    num_trials = length(y_data)/bins_per_trial;
    trial_numbers = reshape(repmat((1:num_trials),[bins_per_trial 1]),[],1);
else
    num_trials = length(bins_per_trial);
    trial_numbers = [];
    for tr = 1:num_trials
        trial_numbers = [trial_numbers; repmat(tr,bins_per_trial(tr),1)];
    end
%     trial_numbers = bins_per_trial;
end

use_par_bootci = 0;
num_BS = 1000;
num_lambda = 200;
num_internal_CV = 10;

% For Poisson
% link_f = 'log';
% prob_family = 'poisson';

% For Bernoulli
link_f = 'logit';
prob_family = 'binomial';

if strcmp(prob_family,'binomial')
    y_data = logical(y_data>0);
end

if use_par_bootci
    bootci_options = statset('UseParallel',true);
else
    bootci_options = statset('UseParallel',false);
end

%% Initialize cross-validation

% cv_partition = cvpartition(y_data,'k',num_CV);      % Data structure that keeps track of training/testing indices
cv_partition = cvpartition_trialwise(trial_numbers,num_CV);

% This is a catch; glmnet doesn't always work when firing rates are low
if strcmp(type,'glmnet') && (mean(y_data) < .04)
    type = 'lassoglm';
end

% If glmnet, initialize some stuff
if strmatch(type,'glmnet')
    opt.alpha = alpha;
    opt.intr = true;
    
    % Auto determination of lambda or not
    if reg_strength == false
        opt.nlambda = num_lambda;
        opt.lambda = logspace(-2,0,num_lambda);
    else
        opt.lambda = reg_strength;
    end
    options = glmnetSet(opt);
end

%% Fit

for CV = 1:num_CV
    % Get indices
%     idx_train = cv_partition.training(CV);
%     idx_test = cv_partition.test(CV);
    idx_train = cv_partition(CV).training;
    idx_test = cv_partition(CV).test;
    
    % Fit
    switch type
        case 'lassoglm'
            % Fit using LassoGLM; cross validate to find optimal penalty param
            [fit_temp, fit_info{CV}] = lassoglm(...
                X_data(idx_train,:),y_data(idx_train),...
                prob_family, ...           % Link function
                'offset', repmat(log(dt),size(y_data(idx_train))), ...
                'CV', 10, ...             % Number of CVs to determine regularization parameter
                'Alpha', alpha, ...          % Type of regularization (L2 = small; L1 = 1)
                'Lambda', reg_strength ...
                );

            % Append intercept
            idx_min_dev = fit_info{CV}.IndexMinDeviance;
            fit_parameters{CV} = [fit_info{CV}.Intercept(idx_min_dev); fit_temp(:,idx_min_dev)];

        case 'lassoglm_auto'
            
            % For first CV, find best lambda
            if (CV == 1) && (reg_strength == false)
%                 [~, fit_info_temp] = lassoglm(...
%                                                 X_data(idx_train,:),y_data(idx_train),...
%                                                 'poisson', ...           % Link function
%                                                 'offset', repmat(log(dt),size(y_data(idx_train))), ...
%                                                 'CV', 5, ...             % Number of CVs to determine regularization parameter
%                                                 'Alpha', alpha, ...          % Type of regularization (L2 = small; L1 = 1)
%                                                 'NumLambda', 2 ...
%                                                 );
%                 idx_min_dev = fit_info_temp.IndexMinDeviance;
%                 best_lambda = fit_info_temp.Lambda(idx_min_dev);
                
                best_lambda = AL_find_best_lambda(X_data(idx_train,:),y_data(idx_train), ...
                                                    alpha, 3, 10, dt);
                
            else
                best_lambda = reg_strength;
            end
            
            % Fit using best lambda
            tic
            [fit_temp, fit_info{CV}] = lassoglm(...
                X_data(idx_train,:),y_data(idx_train),...
                prob_family, ...           % Link function
                'offset', repmat(log(dt),size(y_data(idx_train))), ...
                'Alpha', alpha, ...          % Type of regularization (L2 = small; L1 = 1)
                'Lambda', best_lambda ...
                );
            toc

            % Append intercept
            fit_parameters{CV} = [fit_info{CV}.Intercept; fit_temp];
        
        case 'glmfit'
            % Fit using GLMFit, no regularization
            [fit_parameters{CV}, ~, fit_info{CV}] = glmfit(...
                                                         X_data(idx_train,:), y_data(idx_train), ...
                                                         prob_family, ...
                                                         'offset', repmat(log(dt),size(y_data(idx_train))) ...
                                                         );
                                                     
        case 'glmnet'
            % Set size of offset correctly
            opt.offset = repmat(log(dt),size(y_data(idx_train)));
            
            % If first CV fold, find best lambda if not supplied
            if (reg_strength == false)
                % Cross validate (automatically) to find best lambda. This
                % uses only data from first fold. Reasonable to think
                % lambda should be similar for other folds.
                opt.nlambda = num_lambda;
                opt.lambda = logspace(-2,0,num_lambda);
%                 opt.lambda = [];
                options = glmnetSet(opt);
                tic
                cv_fit = cvglmnet(...
                                    X_data(idx_train), y_data(idx_train), ...
                                    prob_family, options,[],num_internal_CV);
                toc
                best_lambda = cv_fit.lambda_min; % lambda of min deviance
%                 best_lambda = cv_fit.lambda_1se; % lambda within 1se of min deviance lambda. to avoid overfitting, more conservative
                opt.lambda = best_lambda;
                opt.nlambda = [];
            end
            
            % Set options (single lambda)
            options = glmnetSet(opt);
            
            % Then do regular train/test fitting
            tic
            fit_info{CV} = glmnet(X_data(idx_train,:),y_data(idx_train),prob_family,options);
            toc
            fit_parameters{CV} = glmnetCoef(fit_info{CV});
    end

    % Predict on test data
    predictions{CV}(idx_test) = glmval(...
        fit_parameters{CV},...
        X_data(idx_test,:),...
        link_f,...
        'constant','on',...
        'offset', repmat(log(dt),size(y_data(idx_test))) ...
        );
    
    % Calculate pseudo R2
    pseudo_R2(CV,1) = compute_pseudo_R2(...
                                    y_data(idx_test),...        % actual y values
                                    predictions{CV}(idx_test)',...         % y predictions
                                    mean(y_data(idx_train))...  % mean of training set y values
                                    );
                                
    
    if isinf(pseudo_R2(CV,1)) || isnan(pseudo_R2(CV,1))
        pseudo_R2(CV,2:3) = pseudo_R2(CV,1)*[1 1];
    else
        pseudo_R2(CV,2:3) = bootci(num_BS, ...
                            {@compute_pseudo_R2, ...
                            y_data(idx_test), ...
                            predictions{CV}(idx_test)', ...
                            mean(y_data(idx_train))}, ...
                            'Options',bootci_options);
    end
                                
    disp(['CV ' num2str(CV) ' completed. Pseudo R2 value: ' num2str(pseudo_R2(CV,1)) ' [' num2str(pseudo_R2(CV,2:3)) ']'])
end


end

