
% % check crosstalk
% ctlk = crosstalk_analysis(cbdf(2),'spike','do_plots',true);

% Short routine to run a bunch of analyses

clear all;

% start parallel computing
parpool('local')

% % Find plateau in amount of variance explained by the neural PCs
% perc_increase_neural    = zeros(length(cbdf),length(neural_chs)-1);
% for i = 1:length(neural_chs)-2
%     for ii = 1:length(cbdf)
%         perc_increase_neural(ii,i) = (dim_red_FR{ii}.eigen(i+1)-dim_red_FR{ii}.eigen(i))...
%             /sum(dim_red_FR{ii}.eigen)*100;
%     end
% end

aux                     = struct();
aux.tmr                 = tic;
aux.this_dir            = dir;
aux.file_idx            = [];

for i = 1:length(aux.this_dir)
    if strncmp(aux.this_dir(i).name,'all_tasks',9)
       aux.file_idx    = [aux.file_idx, i];
    end
end

% Decide if we want to look at trial-related activity or at the entire
% dataset (including "idle periods"
analysis.dataset        = 'all'; % 'all' 'trial_related_only'
analysis.comp_trial_related_non = false; 

% Set binning and smoothing parameters
analysis.bin_size       = 0.02; % ms
analysis.kernel_SD      = 0.05; % ms

% progress bar
prog_bar                = waitbar(0,'progress');


% run for all the files in the directory
for f = 1:length(aux.file_idx)

filename                = aux.this_dir(aux.file_idx(f)).name;
load(filename);


disp('~-~-~-~-~-~-~-~-~-~-~-~-~')
disp(['analysing file ' filename])
disp('~-~-~-~-~-~-~-~-~-~-~-~-~')


%% ------------------------------------------------------------------------
% -------------------------------------------------------------------------
% 1. Compute the angle between hyperplanes as fcn of the number of
% dimensions, re-ordering the eigenvectors so the angle is minimized
% -------------------------------------------------------------------------

disp('Computing "neural synergies" and comparing neural spaces across tasks')
disp('...')

% will do the analysis for dimensions 1:last_dim
aux.last_dim           = length(neural_chs);

% preallocate struct for results
analysis.neural         = struct();
analysis.emg            = struct();

% ----------------------------------- 
% Bin and smooth the neural data
if ~exist('smoothed_FR','var')
    for i = 1:numel(cbdf)
        [smoothed_FR{i}, binned_data(i)] = gaussian_smoothing2( cbdf(i), ...
                                    'sqrt', analysis.bin_size, analysis.kernel_SD );
    end
    
%     % set flag to store dim_red_FR and smoothed_FR
%     aux.store_dim_red_smoothed_yn   = true;
    aux.store_dim_red_smoothed_yn   = false;
else
    % set flag to not store dim_red_FR and smoothed_FR
    aux.store_dim_red_smoothed_yn   = false;
end

% -----------------------------------
% Analyze 1) the trial-related activity only or 2) the entire task dataset
% (without splitting it into periods of trial-related activity
%   In 1) the code will cut the data based on words; in 2) the data will be
%   the "uncut" data, including the intertrial periods
switch analysis.dataset

    case 'all'
        disp('analysing continuous data (including inter-trial periods)')

    % get rid of inter-trial data
    case 'trial_related_only'
        disp('analysing trial-related activity alone')
        
        % start and end word for cutting the data
        analysis.w_i            = 'ot_on';
        analysis.w_f            = 'R';
        
        % ----------------------------------- 
        % 1. cut each task struct to only keep the trial-related activity 
        for i = 1:length(labels)
            
            % retrieve type of task --necessary because the trial table
            % depends on the task 
            if strncmp(labels(i),'iso',3) || strncmp(labels(i),'wm',2) || ...
                    strncmp(labels(i),'spr',3) % note iso and iso8 both are WF
                aux.tasks{i}    = 'wf';
            elseif strncmp(labels(i),'mg',2)
                aux.tasks{i}    = 'mg'; 
            elseif strncmp(labels(i),'ball',4)
                aux.tasks{i}    = 'ball'; 
            end
            
            % cut the data between the words
            cropped_binned_data(i) = call_crop_binned_data( binned_data(i), ...
                    analysis.w_i, analysis.w_f, aux.tasks(i) );   
            
            % overwrite the smoothed data struct --Take into account that
            % the functions below expect time to be the first column
            smoothed_FR{i}      = zeros(length(cropped_binned_data(i).timeframe),...
                                    size(binned_data(i).spikeratedata,2)+1);
            smoothed_FR{i}(:,1) = cropped_binned_data(i).timeframe;
            smoothed_FR{i}(:,2:end) = cropped_binned_data(i).smoothedspikerate;
            
            % and the dim_red_FR struct
            dim_red_FR{i}       = dim_reduction( smoothed_FR{i}, 'pca', ...
                                        setdiff(1:(size(smoothed_FR{i},2)-1),neural_chs));
            
            
            % ----------------------------------- 
            % 2. take the neural activity that is not related to the trial,
            % to compare the neural spaces with the trial-related activity
            
            % find indexes that are not time related
            [~, indx_no_trial_t] = setdiff(binned_data(i).timeframe,...
                                    cropped_binned_data(i).timeframe);
            
            % get rid of 1-s of data after each trial
            wait_t_after_trial  = 1; % the 1-s wait
            ptr_trial_int_end   = find(diff(indx_no_trial_t)>1);
            intertrial_int_beg  = [1; indx_no_trial_t(ptr_trial_int_end(1:end)+1)]; % the first trial begins at t = 0
            intertrial_int_end  = indx_no_trial_t(ptr_trial_int_end);
            if length(intertrial_int_beg) > length(intertrial_int_end)
                intertrial_int_beg(end) = []; % the monkey didn't complete the last trial
            end
            indx_no_task_t      = [];
            for e = 1:length(intertrial_int_beg)
                indx_no_task_t  = [indx_no_task_t, intertrial_int_beg(e) + ...
                    wait_t_after_trial/mean(diff(binned_data(i).timeframe)):intertrial_int_end(e)];
            end
                                
            % and generate new binned_data struct with those bins only
            cropped_binned_data_no_task(i) = crop_binned_data( binned_data(i), ...
                indx_no_trial_t);
            
            % create smoothed data struct with the non-trial-related
            % activity
            smoothed_FR_no_task{i} = zeros(length(cropped_binned_data_no_task(i).timeframe), ...
                                    size(binned_data(i).spikeratedata,2)+1);
            smoothed_FR_no_task{i}(:,1) = cropped_binned_data_no_task(i).timeframe;
            smoothed_FR_no_task{i}(:,2:end) = cropped_binned_data_no_task(i).smoothedspikerate;
            
            dim_red_FR_no_task{i}  = dim_reduction( smoothed_FR_no_task{i}, 'pca', ...
                                        setdiff(1:(size(smoothed_FR_no_task{i},2)-1),neural_chs));
            
            clear indx_no_trial_t indx_no_task_t intertrial_int_beg intertrial_int_end wait_t_after_trial ptr_trial_int_end
        end
    otherwise
        error('wrong analysis.dataset option!!!');
end


% -------------------------------------
% A) Compute angles between hyperplanes
% -------------------------------------
if exist('dim_red_FR','var')
    
    [analysis.neural.angles, dim_red_FR, smoothed_FR, analysis.neural.empir_angle_dist ] = ...
        comp_neural_spaces_fcn_dim_finding_closest( cbdf, ...
        neural_chs, aux.last_dim, labels, 'pca', smoothed_FR, dim_red_FR );
else
    
    [analysis.neural.angles, dim_red_FR, smoothed_FR ] = comp_neural_spaces_fcn_dim_finding_closest( cbdf, ...
                                        neural_chs, aux.last_dim, labels, 'pca', smoothed_FR );
                                    
    % fix to make the time vector in dim_red_FR match the time vector in
    % binned_data --the problem is that the t in dim_red_FR always starts
    % at t=0, while the time in binned_data doesn't need to
    for i = 1:numel(cbdf)
        dim_red_FR{i}.t = dim_red_FR{i}.t + binned_data(i).timeframe(1);
    end 
end

if aux.store_dim_red_smoothed_yn
    save(filename,'cbdf','neural_chs','chosen_emgs','binned_data','dim_red_FR','smoothed_FR','labels');
    disp(['saving variables to ' filename])
    disp('...')
end


% -------------------------------------
% B) Compare the trial-related and non-trial related activity if we aren't
% analysing each entire task as a whole
% -------------------------------------

if strncmp(analysis.dataset, 'trial_related_only',18) && analysis.comp_trial_related_non
    
    all_smoothed_FRs    = [smoothed_FR, smoothed_FR_no_task];
    all_dim_red_FRs     = [dim_red_FR, dim_red_FR_no_task];         
    all_labels          = repmat(labels,1,2);
    % duplicate BDFs -- this is a track for discarding channels (ToDo:
    % improve this), but is deleted below
    all_bdfs            = repmat(cbdf,1,2);
    for i = 1:length(all_labels)/2
        all_labels{i}   = [all_labels{i} ' trial'];
    end
    for i = length(all_labels)/2+1:length(all_labels)
        all_labels{i}   = [all_labels{i} ' no_trial'];
    end
    angles_task_no      = comp_neural_spaces_fcn_dim_finding_closest( all_bdfs, neural_chs, aux.last_dim, all_labels, 'pca', ...
                            all_smoothed_FRs, all_dim_red_FRs );    
                        
    % do pairwise comparisons
    for i = 1:4%length(labels)
        angles_task_no(i) = comp_neural_spaces_fcn_dim_finding_closest( all_bdfs([i,i+4]), ...
            neural_chs, aux.last_dim, all_labels([i,i+4]), 'pca', all_smoothed_FRs([i,i+4]), ...
            all_dim_red_FRs([i,i+4]) );
    end
    clear all_bdfs
end

close all;


% -------------------------------------
% C) Summary statistics
% -------------------------------------

% 1a) Create an array with the angles to do some basic stats, aux.angles_array,
% which has size comb_of_tasks-by-nbr_dimensions
analysis.comb_tasks    = nchoosek(1:length(cbdf),2);
aux.nbr_comb_tasks     = size(analysis.comb_tasks,1);
analysis.neural.angles_array = zeros(aux.nbr_comb_tasks,aux.last_dim);
for i = 1:aux.last_dim-1
    for ii = 1:aux.nbr_comb_tasks
        analysis.neural.angles_array(ii,i) = analysis.neural.angles.data(analysis.comb_tasks(ii,1),analysis.comb_tasks(ii,2),i);
    end
end

% compute mean angles
analysis.neural.mean_angle_fcn_nbr_dims = rad2deg(mean(analysis.neural.angles_array,1));
analysis.neural.std_angle_fcn_nbr_dims = rad2deg(std(analysis.neural.angles_array,0,1));

% find closest eigenvector for all dimensions
[~, analysis.neural.closest_eigenv]     = find_closest_neural_hyperplane_all( dim_red_FR, 1:length(neural_chs), labels );

% calculate difference in eigenvector ranking as function of the number of
% dimensions
analysis.neural.cum_dist_eigenv         = zeros(length(neural_chs),aux.nbr_comb_tasks);
for i = 1:aux.nbr_comb_tasks
    analysis.neural.cum_dist_eigenv(:,i) = cumsum(abs(analysis.neural.closest_eigenv{analysis.comb_tasks(i,1),...
                                            analysis.comb_tasks(i,2)}(:,2)'-[1:length(neural_chs)]));
end
analysis.neural.mean_cum_dist_eigenv    = mean(analysis.neural.cum_dist_eigenv,2);
analysis.neural.std_cum_dist_eigenv     = std(analysis.neural.cum_dist_eigenv,0,2);


%% ------------------------------------------------------------------------
% ------------------------------------------------------------------------
% 2. Compare PC projections in the time domain
%       Project neural data onto the first PC from another task and compare
%       them
% ------------------------------------------------------------------------

disp('Computing within and across projections onto PCs')
disp('...')

analysis.neural.pc_proj_across_tasks = transform_and_compare_dim_red_data_all_tasks( dim_red_FR, ...
                    smoothed_FR, labels, neural_chs, aux.last_dim, 'min_angle', false );
    
% 2a) pool R^2
aux.aux_R2_array = zeros(aux.nbr_comb_tasks,aux.last_dim);
for i = 1:aux.nbr_comb_tasks
    aux.aux_R2_array(i,:) = analysis.neural.pc_proj_across_tasks(i).R2';
end
analysis.neural.R2_pc_proj_across_tasks = aux.aux_R2_array;

% 2b) compute weighed R^2 (weighed by the ratio of the corresponding
% eigenvalue ('n') in the cross-task, and divided by the cumsum of the
% eigenvalues 1:n
aux.aux_weighed_R2_array = zeros(aux.nbr_comb_tasks,aux.last_dim);
for i = 1:aux.nbr_comb_tasks
    aux.aux_weighed_R2_array(i,:) = analysis.neural.R2_pc_proj_across_tasks(i,:).*...
        dim_red_FR{analysis.comb_tasks(i,2)}.eigen'./...
        cumsum(dim_red_FR{analysis.comb_tasks(i,2)}.eigen)';
end    
analysis.neural.weighed_R2_pc_proj_across_tasks = aux.aux_weighed_R2_array;


%% ------------------------------------------------------------------------
% -------------------------------------------------------------------------
% 3. Look at neuron contributions to the PCs
% -------------------------------------------------------------------------

disp('Computing neurons'' contribution to the "neural synergies"')
disp('...')

[analysis.neural.pc_weights_across_tasks, analysis.neural.participation_index] = ...
                    neuron_contribution_to_pcs( dim_red_FR );


%% ------------------------------------------------------------------------
% -------------------------------------------------------------------------
% 4. Build PC projections to EMG decoders
% -------------------------------------------------------------------------

disp('Building EMG decoders')
disp('...')

if ~exist('chosen_emgs','var')
    chosen_emgs    = 1:length(cbdf(1).emg.emgnames);
end

% increase the nbr of dimensions for this analysis
aux.last_dim_emg = aux.last_dim;

if ~exist('binned_data','var')
    [~, analysis.emg.vaf_array, analysis.emg.vaf_array_norm, ...
        analysis.emg.vaf_neurons, binned_data]      = within_EMG_preds_fcn_nbr_neural_comp( ...
        cbdf, dim_red_FR, labels, aux.last_dim_emg, chosen_emgs );
else
%     [analysis.emg.pred_data_within, analysis.emg.vaf_array, analysis.emg.vaf_array_norm, ...
%         analysis.emg.vaf_neurons, binned_data]      = within_EMG_preds_fcn_nbr_neural_comp( ...
%         cbdf, dim_red_FR, labels, aux.last_dim_emg, chosen_emgs, binned_data );
    [~, analysis.emg.vaf_array, analysis.emg.vaf_array_norm, ...
        analysis.emg.vaf_neurons, analysis.emg.R2_array, analysis.emg.R2_neurons, binned_data] = ...
        within_EMG_preds_fcn_nbr_neural_comp_mfxval( cbdf, dim_red_FR, labels, aux.last_dim_emg, ...
        chosen_emgs, binned_data, 'mfxval', 60, false, analysis.bin_size );
end


%% ------------------------------------------------------------------------
% 5. Find task-related and null spaces 
% --so far only for the 1D and 2D tasks

% [onp_dim_raw, onp_dim_summary, single_trial_data ] = call_find_output_null_potent_dims_wf( cbdf, neural_chs, chosen_emgs, labels, [], true);

if isempty(find(strncmp(labels,'kluver',6),1)) && isempty(find(strncmp(labels,'ball',4),1))
    
    [analysis.onp.dim_raw, analysis.onp.dim_summary, analysis.onp.single_trial_data ] = call_find_output_null_potent_dims_wf( ...
                                                    binned_data, neural_chs, chosen_emgs, labels, smoothed_FR, false);
end

%% ------------------------------------------------------------------------
% 6. Summary stats:

% *** Neurons

% Mean variance explained by n components as function 
aux.var_fcn_eigen                   = zeros(length(neural_chs),length(cbdf));
for i = 1:length(cbdf)
    aux.var_fcn_eigen(:,i)          = cumsum(dim_red_FR{i}.eigen)/sum(dim_red_FR{i}.eigen);
end
analysis.neural.mean_var_fcn_eigen  = mean(aux.var_fcn_eigen,2);
analysis.neural.std_var_fcn_eigen   = std(aux.var_fcn_eigen,0,2);

% *** EMG

% Mean VAF of EMG predictions as function of number of neural inputs
analysis.emg.mean_emg_vaf   = zeros(aux.last_dim_emg,length(chosen_emgs));
analysis.emg.std_emg_vaf    = zeros(aux.last_dim_emg,length(chosen_emgs));
for i = 1:length(chosen_emgs)
    analysis.emg.mean_emg_vaf(:,i)  = mean(squeeze(analysis.emg.vaf_array(:,i,:))');
    analysis.emg.std_emg_vaf(:,i)   = std(squeeze(analysis.emg.vaf_array(:,i,:))');
end

% Mean VAF of EMG predictions using neurons
for i = 1:length(chosen_emgs)
    analysis.emg.mean_vaf_neurons   = mean(analysis.emg.vaf_neurons,2);
    analysis.emg.std_vaf_neurons    = std(analysis.emg.vaf_neurons,0,2);
end


% Mean VAF of EMG predictions as function of number of neural inputs
% normalized by the VAF of the EMG predictions using neurons
analysis.emg.mean_emg_vaf_norm = zeros(aux.last_dim_emg,length(chosen_emgs));
analysis.emg.std_emg_vaf_norm = zeros(aux.last_dim_emg,length(chosen_emgs));
for i = 1:length(chosen_emgs)
    analysis.emg.mean_emg_vaf_norm(:,i)  = mean(squeeze(analysis.emg.vaf_array_norm(:,i,:)),2);
    analysis.emg.std_emg_vaf_norm(:,i)   = std(squeeze(analysis.emg.vaf_array_norm(:,i,:)),0,2);
end



clear i;


%% ------------------------------------------------------------------------
%% ------------------------------------------------------------------------
% 6. Summary plots

plots_run_dim_reduction_analysis;
drawnow;


%% ------------------------------------------------------------------------
% Clear some things for saving the data

% clear the across and within projections onto PCs
analysis.neural.pc_proj_across_tasks = rmfield(analysis.neural.pc_proj_across_tasks,{'scores_within','scores_across', ...
                                        'within_task','across_task'});
% analysis.emg = rmfield(analysis.emg,'pred_data_within');


clear i*

%% ------------------------------------------------------------------------
% Save results
cur_dir                 = pwd;
cd ('results')
save([filename(1:end-4) '_results'],'chosen_emgs','analysis','aux','filename')
cd(cur_dir);

pause(2);
close all; 
drawnow;



disp('~-~-~-~-~-~-~-~-~-~-~-~-~')
disp(['finished analysing file ' num2str(f) ' of ' num2str(length(aux.file_idx))])
disp('~-~-~-~-~-~-~-~-~-~-~-~-~')

disp(' ')
disp(['elapsed time: ' num2str(toc(aux.tmr))]);
disp(' ')

% clear some vars
clearvars -except f aux prog_bar aux

% update progress bar
waitbar(f/length(aux.file_idx));
end


delete(prog_bar);

% stop parallel computing
delete(gcp);
clear all;
