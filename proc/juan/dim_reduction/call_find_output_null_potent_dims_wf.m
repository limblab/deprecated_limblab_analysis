%
% Find task-related and null spaces from trial-averaged data. To find these
% spaces, the data are first cut between two words that define a trial and
% averaged by target. Then the model M = W·N is fit, where M is the
% projection onto the first m PCs of the EMG data, N is the projection onto
% the first n PCs of the neural data, and W is the m-by-n regression matrix.
% Different lags are imposed to the data, and the code chooses the value
% that maximizes the R2 of the model fit for the task-related and null
% space calculation. The task-related and null spaces are found by doing
% SVD of the matrix W: the first m columns of matrix V (with SVD, W=USV^*)
% define the task-related space; the remaining the null  space.
%
%   [onp_dim_raw, onp_dim_summary, single_trial_data ] = ...
%       call_find_output_null_potent_dims_wf( data_struct, neural_chs, ...
%                                           chosen_emgs, labels, varargin )
%
% Inputs (opt)          : [default]
%   data_struct         : BDF struct or binned_data struct with smoothed
%                           firing rates (to obtain those use
%                           gaussian_smoothing2.m)  
%   neural_chs          : channels in the Utah array that will be used for
%                           the analysis (array with ch nbrs)
%   chosen_emgs         : EMG channels that will be used in the analysis
%                           (array with ch nbrs)
%   labels              : task labels (cell array with size equal to that
%                           of data_struct)
%   (smoothed_FR)       : ['empty'] smoothed_FR struct (binned smoothed
%                           firing rates) 
%   (ext_plotting_yn)   : [false] plots everything !!! 
%
% Outputs               :
%   onp_dim_raw         : struct with model fits and SVD transformed model
%                           fits for all the neural_to_EMG lags and all
%                           tasks  
%   onp_dim_summary     : summary of model fits in onp_dim_raw, and some
%                           computations for the task-related space
%   single_trial_data   : trial-averaged data for each target
%
%


function [onp_dim_raw, onp_dim_summary, single_trial_data ] = call_find_output_null_potent_dims_wf( data_struct, neural_chs, chosen_emgs, labels, varargin )


% read inputs

% params
neural_dims             = 1:12;
muscle_dims             = 1:numel(chosen_emgs);
w_i                     = 'ot_on';
w_f                     = 'R';


% see if user has passed a BDF or a binned_data struct
if isfield( data_struct, 'timeframe' )
    binned_data         = data_struct;
else
    bdf                 = data_struct;
end

% see if user has passed the smoothed_firing_rates
if nargin >= 5
    smoothed_FR         = varargin{1};
    if isempty(smoothed_FR), clear smoothed_FR; end
end

if nargin == 6
    extensive_plotting_yn = varargin{2};
else
    extensive_plotting_yn = false;
end

% get number of tasks
nbr_bdfs                = length(data_struct);

% and possible combinations
comb_tasks              = nchoosek(1:nbr_bdfs,2);
nbr_comb_tasks          = size(comb_tasks,1);


% ------------------------------------------------------------------------
% 1. Preprocessing of the neural data

% bin and smooth the FRs (if not passed as inputs)
if ~exist('smoothed_FR','var')
    smoothed_FR             = cell(4,1);
    for i = 1:nbr_bdfs
        [smoothed_FR{i},aux_bd] = gaussian_smoothing2( bdf(i) ); 
        binned_data(i)      = aux_bd; 
        clear aux_bd; 
    end
end

% crop the binned_data between the desired words
cropped_binned_data     = call_crop_binned_data_wf( binned_data, w_i, w_f );


% ------------------------------------------------------------------------
% 2. Dimensionality reduction of neural and EMG data

% do PCA of the cropped smoothed firing rates, discarding the specified
% channels
discard_chs             = setdiff(1:size(binned_data(1).neuronIDs,1),neural_chs);
for i = 1:nbr_bdfs
    dim_red_FR{i}       = dim_reduction( cropped_binned_data(i), 'pca', ...
                            discard_chs );
end

% do PCA of the EMGs
% dim_red_emg             = dim_reduction_muscles( cropped_binned_data, ...
%             [o                'pca', chosen_emgs, labels );
dim_red_emg             = dim_reduction_muscles( cropped_binned_data, ...
                            'none', chosen_emgs, labels, muscle_dims );
                        
% ------------------------------------------------------------------------
% 3. Find task-related and null spaces for single trial data
% Partly inspired by (Kauffman et al., Nature Neurosci 2014)

% % if you want to compute the angle between hyperplanes for these "cropped"
% % tasks
% [angles, dim_red_FR, smoothed_FR ] = comp_neural_spaces_fcn_dim_finding_closest( bdf, ...
%     neural_chs, 30, labels, 'pca', smoothed_FR, dim_red_FR );


% a) get single trial data per target 
% -- target = nbr_targets + 1 is the data for all concatenated trials,
% ordered as 1:nbr_targets
single_trial_data       = cell(1,nbr_bdfs);
for i = 1:nbr_bdfs
    single_trial_data{i}.target = single_trial_analysis_dim_red( cropped_binned_data(i), dim_red_FR{i}, ...
        dim_red_emg{i}, labels{i}, extensive_plotting_yn );
end

% to prevent Matlab from breaking
if extensive_plotting_yn
    pause
    close all;
end

% b) do the multilinear regression to find the task-related and null spaces

% This will find a model M = W·N, where M is a matrix with m muscle
% synergies, N a matrix with n neural synergies, and W an m-by-n matrix
% neurons-to-muscle model

% -- results are stored in cell array onp_dim, which has size number of
% neural_to_EMG_lags by number of tasks. Each field of this array contains
% the results for one target (or all the concatenated targets, which is the
% last field)
neural_to_EMG_lag       = 0.05*(-4:1:4);
onp_dim                 = cell(nbr_bdfs,length(neural_to_EMG_lag));

for i = 1:nbr_bdfs
    for l = 1:length(neural_to_EMG_lag)

        onp_dim{i,l}.data   = find_output_null_potent_dims( single_trial_data{i}.target, neural_dims, muscle_dims, ...
            neural_to_EMG_lag(l), dim_red_emg{i}, extensive_plotting_yn, labels{i} );
    end
    % to prevent Matlab from breaking
    if extensive_plotting_yn
        pause
        close all;
    end
end


% b1) Summary stats for the model fits
mean_R2_fcn_delay       = zeros(nbr_bdfs,length(neural_to_EMG_lag));
std_R2_fcn_delay        = zeros(nbr_bdfs,length(neural_to_EMG_lag));
weighed_R2_fcn_delay    = zeros(nbr_bdfs,length(neural_to_EMG_lag));
for i = 1:nbr_bdfs
    % do for the fit that comprises all targets
    tgt                 = length(single_trial_data{i}.target)+1;
    for l = 1:length(neural_to_EMG_lag)
        mean_R2_fcn_delay(i,l)  = mean(onp_dim{i,l}.data{tgt}.R2);
        std_R2_fcn_delay(i,l)   = std(onp_dim{i,l}.data{tgt}.R2);
        weighed_R2_fcn_delay(i,l) = onp_dim{i,l}.data{tgt}.weighed_R2;
    end
end

% look for positions of maximum R2 and maximum weighed R2
[max_mean_R2, indx_max_mean_R2]         = max(mean_R2_fcn_delay,[],2);
[max_weighed_R2, indx_max_weighed_R2]   = max(weighed_R2_fcn_delay,[],2);


% store summary statistics model fits
onp_dim_summary.R2_fcn_delay.mn         = mean_R2_fcn_delay;
onp_dim_summary.R2_fcn_delay.sd         = std_R2_fcn_delay;
onp_dim_summary.R2_fcn_delay.mx         = max_mean_R2;
onp_dim_summary.R2_fcn_delay.lag_mx     = neural_to_EMG_lag(indx_max_mean_R2)';

onp_dim_summary.weighed_R2_fcn_delay.data   = weighed_R2_fcn_delay;
onp_dim_summary.weighed_R2_fcn_delay.mx = max_weighed_R2;
onp_dim_summary.weighed_R2_fcn_delay.lag_mx = neural_to_EMG_lag(indx_max_weighed_R2)';


% ------------------------------------------------------------------------
% 4. Compare task related spaces across tasks


% a) compute angles between the hyperplanes that define the task-related
% space, for the all the lags that maximize the R2 (for each task)

% find lags that maximize the R2 of the model fit
lags_best_fit               = unique(onp_dim_summary.R2_fcn_delay.lag_mx);
nbr_lags_best_fit           = numel(lags_best_fit);
dimensional                 = cell(numel(muscle_dims),1);
for m = 1:numel(muscle_dims)
    dimensional{m}.angles   = zeros(nbr_bdfs);
    dimensional{m}.dim_min_angle = zeros(nbr_bdfs);
end
V_task_comp                 = cell(nbr_lags_best_fit,1);

for l = 1:nbr_lags_best_fit
    indx_this_lag           = find(neural_to_EMG_lag==lags_best_fit(l));
    for i = 1:nbr_comb_tasks
        % compute angles between task-relevant spaces
        [ang, dim_min_ang]  = comp_hyperplanes_fcn_dim_finding_closest( ...
                            onp_dim{comb_tasks(i,1),indx_this_lag}.data{end}.svdec.V_task, ...
                            onp_dim{comb_tasks(i,2),indx_this_lag}.data{end}.svdec.V_task, ...
                                muscle_dims ); 
        % store results for each dimensions and this pair of tasks
        for m = 1:numel(muscle_dims)
            dimensional{m}.angles(comb_tasks(i,1),comb_tasks(i,2)) = ang(m);
            dimensional{m}.dim_min_angle(comb_tasks(i,1),comb_tasks(i,2)) = dim_min_ang(m);
        end
    end
    
    % make angle matrix symmetric
    for m = 1:numel(muscle_dims)
        dimensional{m}.angles   = dimensional{m}.angles + dimensional{m}.angles';
    end
    % store results for this lag
    V_task_comp{l}.dimensional  = dimensional;
    V_task_comp{l}.lag          = lags_best_fit(l);
end

% b) get some summary statistics
angle_btw_V_tasks_fcn_dims      = zeros(nbr_comb_tasks,numel(muscle_dims),nbr_lags_best_fit);
for c = 1:nbr_comb_tasks
    for m = 1:numel(muscle_dims)
        for l = 1:nbr_lags_best_fit
            % make the angles be between 0-pi/2
            if V_task_comp{l}.dimensional{m}.angles(comb_tasks(c,1),comb_tasks(c,2)) > pi/2
                temp_angle  = V_task_comp{l}.dimensional{m}.angles(comb_tasks(c,1),comb_tasks(c,2))-pi/2;
            else
                temp_angle  = V_task_comp{l}.dimensional{m}.angles(comb_tasks(c,1),comb_tasks(c,2));
            end
            angle_btw_V_tasks_fcn_dims(c,m,l) = temp_angle;
        end
    end
end

% store them in the 'onp_dim_summary' struct
onp_dim_summary.angle_btw_V_tasks_fcn_dims = angle_btw_V_tasks_fcn_dims;

comb_task_labels                = cell(nbr_comb_tasks,1);
for i = 1:nbr_comb_tasks
    comb_task_labels{i}         = [labels{comb_tasks(i,1)} ' vs. ' ...
                                labels{comb_tasks(i,2)}];
end
onp_dim_summary.lags            = lags_best_fit;
onp_dim_summary.comb_tasks      = comb_task_labels;
onp_dim_summary.V_task_comp     = V_task_comp;


% c) Project the data onto the within-task and cross-task spaces and
% compare the fits

R2_within_across                = comp_within_cross_W_task_comp( onp_dim, neural_to_EMG_lag, lags_best_fit );
 
% summarize R2_within_across --one field per best neural_to_EMG_lag
% R2_within_across_summary        = cell(nbr_comb_tasks,nbr_lags_best_fit);
% for l = 1:nbr_lags_best_fit
%     for c = 1:nbr_comb_tasks
%         for d = 1:numel(muscle_dims)
%             R2_within_across_summary{c,l}.dimensional(d) = R2_within_across{c,l}.data(d);
%         end
%     end
% end

% summarize R2_within_across --one field per best neural_to_EMG_lag
R2_within_across_summary        = zeros(nbr_comb_tasks,nbr_lags_best_fit,numel(muscle_dims));
for l = 1:nbr_lags_best_fit
    for c = 1:nbr_comb_tasks
        for d = 1:numel(muscle_dims)
            R2_within_across_summary(c,l,d) = R2_within_across{c,l}.data(d);
        end
    end
end

% plot
figure
for i = 1:nbr_lags_best_fit
    subplot(1,nbr_lags_best_fit,i)
    plot(squeeze(R2_within_across_summary(:,i,:))','linewidth',2)
    ylim([0 1]),xlim([0 numel(muscle_dims)+1])
    xlabel('nbr. dims.'), title(['neural to EMG lag: ' num2str(V_task_comp{i}.lag) ' s'])
    set(gca,'TickDir','out'),set(gca,'FontSize',14)
    set(gca,'XTick',1:numel(muscle_dims));
    if i == 1
        ylabel('R2 within across proj W_task')
        legend(comb_task_labels,'Location','southeast')
    end
end



% ------------------------------------------------------------------------
% RETURN 

onp_dim_raw                     = onp_dim;

% ------------------------------------------------------------------------
% FIGURES


% Plot angles for each combination of tasks
figure
for i = 1:nbr_lags_best_fit
    subplot(1,nbr_lags_best_fit,i)
    plot(rad2deg(squeeze(angle_btw_V_tasks_fcn_dims(:,:,i)')),'linewidth',2)
    ylim([0 90]),xlim([0 numel(muscle_dims)+1])
    xlabel('nbr. dims.'), title(['neural to EMG lag: ' num2str(V_task_comp{i}.lag) ' s'])
    set(gca,'TickDir','out'),set(gca,'FontSize',14)
    set(gca,'XTick',1:numel(muscle_dims));
    if i == 1
        ylabel('angle (deg)')
        legend(comb_task_labels,'Location','southeast')
    end
end


% color per target
colors_delays                   = parula(nbr_bdfs);

% plot fit per task as function of the delay

% mean +/- SD R2
figure,hold on
for i = 1:nbr_bdfs
    hp(i) = plot(neural_to_EMG_lag,mean_R2_fcn_delay(i,:),...
        'color',colors_delays(i,:),'linewidth',4);
    plot(neural_to_EMG_lag,mean_R2_fcn_delay(i,:)+std_R2_fcn_delay(i,:),...
        'color',colors_delays(i,:),'linewidth',1,'linestyle','-.')
    plot(neural_to_EMG_lag,mean_R2_fcn_delay(i,:)-std_R2_fcn_delay(i,:),...
        'color',colors_delays(i,:),'linewidth',1,'linestyle','-.')
end
legend(hp, labels); clear hp
ylim([0 1.1]),xlim([neural_to_EMG_lag(1)-mean(diff(neural_to_EMG_lag)),neural_to_EMG_lag(end)+mean(diff(neural_to_EMG_lag))])
set(gca,'XTick',neural_to_EMG_lag),set(gca,'TickDir','out'),set(gca,'FontSize',14)
xlabel('neural to EMG delay (ms)'),ylabel('R^2 of model fit')

% weighed R2
figure,hold on
for i = 1:nbr_bdfs
    plot(neural_to_EMG_lag,weighed_R2_fcn_delay(i,:),'color',colors_delays(i,:),'linewidth',2)
end    
ylim([0 1.1]),xlim([neural_to_EMG_lag(1)-mean(diff(neural_to_EMG_lag)),neural_to_EMG_lag(end)+mean(diff(neural_to_EMG_lag))])
set(gca,'XTick',neural_to_EMG_lag),set(gca,'TickDir','out'),set(gca,'FontSize',14)
xlabel('neural to EMG delay (ms)'),ylabel('weighed R^2 of model fit')
legend(labels,'Location','southeast')
% 
% 
% % ---------------------
% % OUTPUT POTENT / NULL PLOTS
% 
% % Plot matrix V for each task
% tgt                     = 7;
% bdf_nbr                 = 2;
% lag_nbr                 = 5;
% 
% % title --add colors
% if tgt <= length(single_trial_data{bdf_nbr})
%     ttl                 = ['output-potent model ' labels{i} ' target ' num2str(tgt)];
% else
%     ttl                 = ['output-potent model ' labels{i} ' all targets'];
% end
% figure,
% subplot(121),imagesc(abs(onp_dim{bdf_nbr}.data{tgt}.svdec.V(:,1:3)))
% set(gca,'TickDir','out'),set(gca,'FontSize',14)
% set(gca,'XTick',1:length(muscle_dims)),set(gca,'XTick',1:length(neural_dims))
% xlabel('muscle comp.'),ylabel('neural comp.')
% title(['output-potent model ' labels{bdf_nbr} ' target ' num2str(tgt)])
% subplot(122),imagesc(sum(abs(onp_dim{bdf_nbr}.data{tgt}.svdec.V(:,1:3)),2)),colorbar
% set(gca,'TickDir','out'),set(gca,'FontSize',14)
% set(gca,'XTick',1),set(gca,'XTick',1:length(neural_dims)),set(gca,'XTickLabel',[])
% title('sum for all muscle comp')
% 
% % Plot output potent null dimensions
% 
% % normalize (to peak2peak value) the data
% norm_emg_data           = zeros(size(onp_dim{bdf_nbr,lag_nbr}.data{tgt}.emg_data,2),size(onp_dim{bdf_nbr,lag_nbr}.data{tgt}.emg_data,1));
% norm_potent             = zeros(size(onp_dim{bdf_nbr,lag_nbr}.data{tgt}.emg_data,2),size(onp_dim{bdf_nbr,lag_nbr}.data{tgt}.emg_data,1));
% norm_null               = zeros(size(onp_dim{bdf_nbr,lag_nbr}.data{tgt}.emg_data,2),size(onp_dim{bdf_nbr,lag_nbr}.data{tgt}.emg_data,1));
% for i = 1:size(onp_dim{1,5}.data{7}.emg_data,1)
%     norm_emg_data(:,i)  = onp_dim{bdf_nbr,lag_nbr}.data{tgt}.emg_data(i,:)/...
%         peak2peak(onp_dim{bdf_nbr,lag_nbr}.data{tgt}.emg_data(i,:));
%     norm_potent(:,i)    = onp_dim{bdf_nbr,lag_nbr}.data{tgt}.svdec.task_relev(:,i)/...
%         peak2peak(onp_dim{bdf_nbr,lag_nbr}.data{tgt}.svdec.task_relev(:,i));
%     norm_null(:,i)      = onp_dim{bdf_nbr,lag_nbr}.data{tgt}.svdec.null_space(:,i)/...
%         peak2peak(onp_dim{bdf_nbr,lag_nbr}.data{tgt}.svdec.null_space(:,i));    
% end
% t_plot                  = single_trial_data{1}{1}.bin_size*(0:(size(onp_dim{bdf_nbr,lag_nbr}.data{tgt}.emg_data,2)-1));
% 
% figure,
% subplot(311),plot(t_plot,norm_emg_data,'linewidth',3)
% set(gca,'TickDir','out'),set(gca,'FontSize',14)
% subplot(312),plot(t_plot,norm_potent,'linewidth',3)
% set(gca,'TickDir','out'),set(gca,'FontSize',14)
% subplot(313),plot(t_plot,norm_null,'linewidth',3)
% set(gca,'TickDir','out'),set(gca,'FontSize',14)
