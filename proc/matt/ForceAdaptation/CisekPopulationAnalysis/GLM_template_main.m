%% Load scripts

addpath(genpath('C:\Users\pnlawlor\GoogleDrive\Research\Scripts\Pat'))
addpath(genpath('C:\Users\pnlawlor\GoogleDrive\Research\Projects\VMR\Scripts_VMR'))

%% Load data

fpath = 'C:\Users\pnlawlor\GoogleDrive\Research\Projects\Time_warping\Source_data\Miller_lab\Processed\Brian_uncertainty\Windowed\';
fname = 'BUCO_PMd_cue_on.mat';

load([fpath fname])

spikes_all = Data_win.spikes_M1;
movement_data_all = Data_win.movement_cov;
outer_target_on = Data_win.outer_target;
num_neurons_total = size(spikes_all,2);
num_trials_total = size(spikes_all,1);



%% User inputs

% Data selection
neurons = 1:num_neurons_total;
trials = 1:num_trials_total;

% Time bin size (in seconds)
dt = .01;

% Type of fitting (regularization, etc.)
fit_method = 'glmfit'; % glmfit is vanilla and what I'd recommend, lassoglm is regularized
num_CV = 2; % Number of cross-validations. I'd use 2 (most conservative), 5, or 10.

alpha = false; % If you use glmfit, these need to be false
lambda = false;

% alpha = .01; % If you try lassoglm, uncomment these
% lambda = .05; 


%% Initialize

spikes = spikes_all(trials,neurons);
movement_data = movement_data_all(trials);

num_trials = length(trials);
num_nrn = length(neurons);

spikes_warped(:,:,1) = spikes;
X_cell = cell(num_trials,1);

predictions_combined = cell(num_nrn,1);
predictions =  cell(num_trials,num_nrn,1);
predictions_temp =  cell(num_trials,num_nrn);
fit_parameters = cell(num_nrn,1);
fit_info = cell(num_nrn,1);
fit_info_temp = cell(num_nrn,1);
pseudo_R2 = cell(num_nrn,1);

%% Pre-process

% Generate temporal basis functions
filt_struct = VMR_define_filters();

% Filter covariates
for idx_trial = 1:length(trials)
    % Filter movement data with temporal basis function
    
    X_cell{idx_trial,1} = full(filter_and_insert(outer_target_on{idx_trial},filt_struct));
    
    bins_per_trial(idx_trial) = size(X_cell{idx_trial},1);
end

X_all = cell2mat(X_cell); % Covariate matrix for all trials
y_all = cell2mat(spikes); % Spiking for all neurons across all trials

figure
imagesc([y_all X_all]) % Usually good to check that these make sense

%% Fit

% For each neuron, fit GLM

parfor nrn_idx = 1:length(neurons) % Parallel
% for nrn_idx = 1:length(neurons)
    nrn_num = neurons(nrn_idx); % I just do this in case you specify that neurons = [1 5 7] etc.
    
    disp(['Now fitting neuron: ' num2str(nrn_num)])
    [predictions_combined{nrn_idx,1}, ...
        fit_parameters{nrn_idx,1}, ...
        fit_info{nrn_idx,1}, ...
        pseudo_R2{nrn_idx,1}] = ...
                                fit_poiss_GLM( X_all, y_all(:,nrn_num), ...
                                        num_CV, ...
                                        dt, ...
                                        lambda, ... % lambda
                                        alpha, ... % alpha
                                        fit_method, ...
                                        bins_per_trial);
      
end