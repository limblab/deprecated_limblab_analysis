function[X2_p MODEL_1 MODEL_2 preds] = run_GLM(X,y,ids,PREDICTOR_INDS,varargin)

% run_GLM(X,y) applies a GLM with predictors of X on y twice to compare two
% different models, one with predictors that are a subset of the other. 
% X and y can be obtained from Construct_GLM. X is an nxm array, with n 
% samples of m different predictors. Predictors can be passed as input 
% (PREDICTOR_INDS) however run_GLM(X,y) will run using the default values 
% shown below

if nargin > 3  
    preds = PREDICTOR_INDS;
else
    
% preds defines which predictors are included in the first and second
% models:
%   0: Do not include parameter in either model
%   12: Include parameter in both models
%   1: Include parameter only in first model (SEE NOTE BELOW BEFORE USING)
%   2: Include parameter only in second model
% *NOTE* In order to compare two models using a X^2 test, one model must be
% a subset of the other. Therefore, parameters should only be removed from
% the second model if including it would create a matrix without full rank.
%
% For Example: Assume H is a predictor in model_1 and J and K are
% additional predictors for model_2. Then H can only be removed from
% model_2 if it is a linear combination of J and K. 
    
preds = [...
12 ... % Cosine of movement angle
12 ... % Sine of movement angle
12 ... % Hand Speed
0  ... % Vx
0  ... % Vy
1  ... % Any Feedback
2  ... % High variance feedback
2  ... % Low variance feedback
0  ... % X position
0  ... % Y position
0  ... % Trial by Trial cursor offset
];

end

MODEL1_preds = find(preds==12|preds==1);
MODEL2_preds = find(preds==12|preds==2);

X2_p = cell(size(y,2),1);
MODEL_1 = cell(size(y,2),1);
MODEL_2 = cell(size(y,2),1);

% Include all neurons in default case
%NEURONS_OF_INTEREST = 1:size(y,2);

% Include only a small number of neurons
NEURONS_OF_INTEREST = [3 6 9 11 13 14 29 30];
clc;
for n=NEURONS_OF_INTEREST
    fprintf('Running GLM... Unit %d (%d/%d)\n',n,...
        find(NEURONS_OF_INTEREST==n),length(NEURONS_OF_INTEREST));
    text(0,0,sprintf('Neuron: %d',n));
    [Bhat_mod1, dev1, stats1] = glmfit(X(:,MODEL1_preds),y(:,n),'poisson');
    [Bhat_mod2, dev2, stats2] = glmfit(X(:,MODEL2_preds),y(:,n),'poisson');
    
    X2_p{n} = 1 - chi2cdf(dev1 - dev2,1);
    MODEL_1{n}.stats = [[0; MODEL1_preds'], Bhat_mod1, stats1.p];    
    MODEL_2{n}.stats = [[0; MODEL2_preds'], Bhat_mod2, stats2.p];
    
    MODEL_1{n}.id = ids(n);
    
    clc;

end
