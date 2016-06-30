% Time bin size (in seconds)
dt = binSize;

% Type of fitting (regularization, etc.)
fit_method = 'glmfit'; % glmfit is vanilla and what I'd recommend, lassoglm is regularized
num_CV = 2; % Number of cross-validations. I'd use 2 (most conservative), 5, or 10.

alpha = false; % If you use glmfit, these need to be false
lambda = false;

% alpha = .01; % If you try lassoglm, uncomment these
% lambda = .05;

glmResults = repmat(struct(),[size(blockFR,1),size(blockFR,2)]);
for iFile = 1:size(blockFR,1)
    for iBlock = 1:size(blockFR,2)
        
        fr_all = squeeze(blockFR(iFile,iBlock,:,:));
        event1 = squeeze(blockEvent1(iFile,iBlock,:));
        event2 = squeeze(blockEvent2(iFile,iBlock,:));
        
        % because not all files/blocks have the same number of neurons/trials,
        % there will be some empty cells. Please note this implementation is pure
        % crap and is highly inefficient. Someday I will fix.
        whichExist = cellfun(@(x) isempty(x),fr_all);
        
        num_neurons_total = size(fr_all,2);
        num_trials_total = size(fr_all,1);
        
        % User inputs
        % Data selection
        neurons = 1:sum(~all(whichExist,1));
        trials = 1:sum(~all(whichExist,2));
        
        % Initialize
        spikes = fr_all(trials,neurons);
        
        num_trials = length(trials);
        num_nrn = length(neurons);
        
        X_cell = cell(num_trials,1);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Pre-process
        % Generate temporal basis functions
        filt_struct = VMR_define_filters();
        
        % Filter covariates
        bins_per_trial = zeros(1,length(trials));
        for idx_trial = 1:length(trials)
            % Filter movement data with temporal basis function
            x1 = full(filter_and_insert(event1{idx_trial},filt_struct(9)));
            x2 = full(filter_and_insert(event2{idx_trial},filt_struct(7)));
            
            X_cell{idx_trial,1} = [x1 x2];
            bins_per_trial(idx_trial) = size(X_cell{idx_trial},1);
            
            % for sanity checks
            %             figure; subplot1(1,3);
            %             subplot1(1); imagesc(spikes{idx_trial});
            %             subplot1(2); imagesc(x1);
            %             subplot1(3); imagesc(x2);
            %             pause; close all;
        end
        clear x1 x2;
        
        x_all = cell2mat(X_cell); % Covariate matrix for all trials
        y_all = cell2mat(spikes); % Spiking for all neurons across all trials
        
        figure
        imagesc([y_all x_all.*max(4.*mean(y_all))]) % Usually good to check that these make sense
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Fit
        % For each neuron, fit GLM
        predictions_combined = cell(length(neurons),1);
        fit_parameters = cell(length(neurons),1);
        fit_info = cell(length(neurons),1);
        pseudo_R2 = cell(length(neurons),1);
        
        parfor nrn_idx = 1:length(neurons) % Parallel
            % for nrn_idx = 1:length(neurons)
            nrn_num = neurons(nrn_idx); % I just do this in case you specify that neurons = [1 5 7] etc.
            
            disp(['Now fitting neuron: ' num2str(nrn_num)])
            [predictions_combined{nrn_idx,1}, ...
                fit_parameters{nrn_idx,1}, ...
                fit_info{nrn_idx,1}, ...
                pseudo_R2{nrn_idx,1}] = ...
                fit_poiss_GLM( x_all, y_all(:,nrn_num), ...
                num_CV, ...
                dt, ...
                lambda, ...
                alpha, ...
                fit_method, ...
                bins_per_trial);
        end
        glmResults(iFile,iBlock).predictions_combined = predictions_combined;
        glmResults(iFile,iBlock).fit_parameters = fit_parameters;
        glmResults(iFile,iBlock).fit_info = fit_info;
        glmResults(iFile,iBlock).pseudo_R2 = pseudo_R2;
        
        close all;
    end
end
clear iFile idx_trial iBlock fr_all event1 event2 whichExist predictions_combined fit_parameters fit_info psuedo_R2 nrn_idx nrn_num x_all y_all unit;

% save for safekeeping
save(fullfile(saveDir,[useArray '_glmResults_' datestr('now','yy-mm-dd-hh-mm') '.mat']),'-v7.3')