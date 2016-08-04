
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

% Decide if we want to look at task-related activity or at the entire
% dataset (including "idle periods"
analysis.dataset        = 'task_related_only'; % 'all' 'task_related_only'

% progress bar
prog_bar                = waitbar(0,'progress');


% run for all the files in the directory
for f = 5:length(aux.file_idx)

filename                = aux.this_dir(aux.file_idx(f)).name;
load(filename);


disp('~-~-~-~-~-~-~-~-~-~-~-~-~')
disp(['analysing file ' filename])
disp('~-~-~-~-~-~-~-~-~-~-~-~-~')


%% ------------------------------------------------------------------------
% 1. Compute the angle between hyperplanes as fcn of the number of
% dimensions, re-ordering the eigenvectors so the angle is minimized

disp('Computing "neural synergies" and comparing neural spaces across tasks')
disp('...')

% will do the analysis for dimensions 1:last_dim
aux.last_dim           = length(neural_chs);

% preallocate struct for results
analysis.neural         = struct();
analysis.emg            = struct();


if exist('dim_red_FR','var')
    [analysis.neural.angles, dim_red_FR, smoothed_FR ] = comp_neural_spaces_fcn_dim_finding_closest( cbdf, ...
                                        neural_chs, aux.last_dim, labels, 'pca', smoothed_FR, dim_red_FR );
                                    
    % set flag to not store dim_red_FR and smoothed_FR
    aux.store_dim_red_smoothed_yn   = false;
else
    % smooth the firing rates and bin the data
    for i = 1:numel(cbdf)
        [smoothed_FR{i}, binned_data(i)] = gaussian_smoothing2( cbdf(i) );
    end
    
    [analysis.neural.angles, dim_red_FR, smoothed_FR ] = comp_neural_spaces_fcn_dim_finding_closest( cbdf, ...
                                        neural_chs, aux.last_dim, labels, 'pca', smoothed_FR );
    
    % fix to make the time vector in dim_red_FR match the time vector in
    % binned_data --the problem is that the time in dim_red_FR always start
    % at t=0, while the time in binned_data doesn't need to
    for i = 1:numel(cbdf)
        dim_red_FR{i}.t = dim_red_FR{i}.t + binned_data(i).timeframe(1);
    end 
    
    % set flag to not store dim_red_FR and smoothed_FR
    aux.store_dim_red_smoothed_yn   = true;
end

if aux.store_dim_red_smoothed_yn
    save(filename,'cbdf','neural_chs','chosen_emgs','binned_data','dim_red_FR','smoothed_FR');
    disp(['saving variables to ' filename])
    disp('...')
end


close all;

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
% 2. Compare PC projections in the time domain
%       Project neural data onto the first PC from another task and compare
%       them

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
% 3. Look at neuron contributions to the PCs

disp('Computing neurons'' contribution to the "neural synergies"')
disp('...')

[analysis.neural.pc_weights_across_tasks, analysis.neural.participation_index] = neuron_contribution_to_pcs( dim_red_FR );



%% ------------------------------------------------------------------------
% 4. Build PCprojected to EMG decoders

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
        chosen_emgs, binned_data, 'mfxval', 60, false );
end

% % 3a) paired Wilcoxon signed-rank test to compare VAF of predictions with n
% % and n+1 neural components as inputs 
% h_nbr_comps             = zeros(1,last_dim-1);
% p_nbr_comps             = zeros(1,last_dim-1);
% for i = 1:last_dim-1
%     vaf_n   = reshape(squeeze(vaf_array(i,:,:)),1,length(chosen_emgs)*length(cbdf));
%     vaf_n_1 = reshape(squeeze(vaf_array(i+1,:,:)),1,length(chosen_emgs)*length(cbdf));
%     [p_nbr_comps(i), h_nbr_comps(i)] = ranksum(vaf_n,vaf_n_1);
% end

% % 3b) compute relative difference in normalize VAF. If it's < threshold
% % consider there's no improvement (the VAF has plateaud)
% perc_increase           = zeros(1,last_dim-1);
% for i = 1:last_dim-1
%     vaf_n   = reshape(squeeze(vaf_array(i,:,:)),1,length(chosen_emgs)*length(cbdf));
%     vaf_n_1 = reshape(squeeze(vaf_array(i+1,:,:)),1,length(chosen_emgs)*length(cbdf));
%     perc_increase(i) = (vaf_n_1-vaf_n)/vaf_n_1;
% end
% % plot
% figure,plot(perc_increase,'linewidth',2),set(gca,'TickDir','out'),set(gca,'FontSize',14)
% xlabel('component nbr.','FontSize',14),ylabel('perc. increas in EMG VAF explained','FontSize',14)
% disp(['VAF does not increase more than 5% after n = ' num2str(find(perc_increase<.05,1))]);

% % 3) Compute the derivative of the cumsum of the explained variance
% analysis.emg.cumsum_emg_var = zeros(length(cbdf),aux.last_dim-1);
% for i = 1:length(cbdf)
%     
% end


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
