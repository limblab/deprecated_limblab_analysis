%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input Variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Monkey = 'MrT';
month = '09';
day   = '24';
year  = '2012';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
curdir = cd;

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Prepare Variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Find directory containing data (defined in prepare_vars4GLM.m) and create
% variables containing kinematic and neural data
fprintf('Preparing data...\n');
[bdf,tt,trials2,trains,ts_low,pva] = prepare_vars4GLM(Monkey,[month day year]);
cd(curdir);
% bdf: containing kinematics (pos, vel, acc)
% tt: the COLUMNS of tt represent:
%    1: Trial Databurst Timestamp
%    2: Trial Prior  Perturbation (shift or rotation)
%    3: Trial Feedback Uncertainty
%    4: Trial Center Timestamp
%    5: Trial Target Timestamp
%    6: Trial Go     Timestamp (i.e. Movement Start)  NaN if not R or F
%    7: Trial End    Timestamp
%    8: Trial End  Result   -- R (32), A (33), F (34), I (35), or NaN
% trials2: simplified trial table, COLUMNS represent:
%    1: Trial Prior  Perturbation (shift or rotation)
%    2: Trial Feedback Uncertainty
%    3: Trial Center Timestamp
%    4: Trial Feedback Timestamp
%    5: Trial Target Timestamp
% trains: cell array of (n,1). For each unit 'n', trains{n}(2:end) contains
%         timestamps of all spike events. trains{n}(1) reports the channel
%         id in the form, channel.unit (e.g. 4.2 --> unit 2 on channel 4)
% ts_low: Timestamps of estimated minimum velocity point after feedback
% pva: simplified bdf, where pva.pos = position, pva.vel = velocity,
%      pva.acc = acceleration

% Create GLM predictors (X) and output (y), along with trial information,
% etc.

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Construct GLM %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc; fprintf('Constructing GLM...\n');
[X,y,feed,trialinds,min_inds,ids] = construct_GLM(trains,trials2,pva,ts_low);
% X: predictor matrix of size (m x n) where 'm' is the number of time bins
%    (ms) and 'n' is the number of predictor variables (defined at very end
%    of construct_GLM.m)
% y: (m x u) array of binary spike trains where 'm' is the number of time
%    bins being predicted and 'u' is the number of sorted units
% trialinds: (m x 1) vector of trial indices for each time bin (e.g.
%    [1;...:1;2;...;2;3;...;3;...]
% min_inds: indices of estimated min velocity points (from ts_low)
% ids: Unit ID information in the form channel.unit (e.g. 4.1 is the first
%      unit of channel 4)

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Run the GLM %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Run the GLM using both predictor sets (defined in run_GLM.m) and obtain p
% values from X^2 test, as well as model information
clc; fprintf('Running GLM...\n');
[X2_p MODEL_1 MODEL_2 preds] = run_GLM(X,y,ids);
% X2_p: cell array of size (u x 1) containing for each unit 'u' the p-value
%       obtained from a X^2 model comparison
% MODEL_1.id    : channel.unit
%        .stats : (:,1) = [0; predictors] *see run_GLM.m
%                 (:,2) = coefficients of predictors (1st is constant term)
%                 (:,3) = p values of coefficients
% MODEL_2 : same as MODEL_1
% preds: *See comments in run_GLM.m

% aligntype = 1 will plot PSTH curves centered on feedback. 
aligntype = 1;

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot the Results %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Display the results of the GLM as PSTH curves. 
clc; fprintf('Plotting GLM output...\n');
plot_GLM(X,y,MODEL_1,MODEL_2,trials2,feed,min_inds,trialinds,aligntype,X2_p);

