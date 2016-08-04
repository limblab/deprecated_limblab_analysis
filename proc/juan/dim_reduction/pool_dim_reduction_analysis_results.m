%
% Script to pool data from different sessions for the dimensionality
% reduciton study. The script assumes you have loaded an array of
% analysis (analysis_pooled) and aux (aux_pooled) structs, generated with
% run_dim_reduction_analysis.m
%


%monkey_color            = [0 0 0];
monkey_color            = [0 0 0];

% -------------------------------------------------------------------------
% GET SOME BASIC INFORMATION

% 1. get number of tasks per session, and total numbers
nbr_tasks_per_session   = arrayfun(@(x) size(x.var_fcn_eigen,2),aux_pooled);
nbr_sessions            = numel(nbr_tasks_per_session);
nbr_tasks_total         = sum(nbr_tasks_per_session);


% 2. create a vector with task types
task_type               = zeros(1,nbr_tasks_total);
% this is the legend with the task types
task_legend             = {'iso','wm','spr','iso8','kluver','iso_x','wm_x'}; % wm_x and iso_x are for a day in Kevin; we consider them the same
% since strncmp won't differentiate 'iso' from 'iso8'/'iso_x', or 'wm' from
% 'wm_x'; do a dirty fix: 
pos_iso8                = find(strncmp('iso8',task_legend,length('iso8')));
pos_iso_x               = find(strncmp('iso_x',task_legend,length('iso_x')));
pos_wm_x                = find(strncmp('wm_x',task_legend,length('wm_x')));
pos_iso                 = setdiff(find(strncmp('iso',task_legend,length('iso'))),[pos_iso8 pos_iso_x]);
pos_wm                  = setdiff(find(strncmp('wm',task_legend,length('wm'))),pos_wm_x);

% here we fill a vector with task numbers
for s = 1:nbr_sessions
    for t = 1:nbr_tasks_per_session(s)
        aux_task        = find(strncmp(aux_pooled(s).tasks{t},task_legend,length(aux_pooled(s).tasks{t})));
        % strncmp won't work for iso vs. iso8/iso_x so fix it here ...
        if ( length(aux_task) > 1 ) && ( aux_task(1) == pos_iso || ...
                        aux_task(1) == pos_iso8 || aux_task(1) == pos_iso_x )
            if length(aux_pooled(s).tasks{t}) == length('iso8')
                aux_task = pos_iso8;
            elseif length(aux_pooled(s).tasks{t}) == length('iso_x')
                aux_task = pos_iso_x;
            else
                aux_task = pos_iso;
            end
        end
        % same for wm vs. wm_x ...
        if ( length(aux_task) > 1 ) && ( aux_task(1) == pos_wm || ...
                        aux_task(1) == pos_wm_x )
            if length(aux_pooled(s).tasks{t}) == length('wm_x')
                aux_task = pos_wm_x;
            else
                aux_task = pos_wm;
            end
        end

        % store task type ...
        task_type(sum(nbr_tasks_per_session(1:s-1))+t) = aux_task;
    end
end

% --ToDo: See if we want to change this in the future:
% convert iso_x and wm_x to iso and wm
if find(task_type==pos_iso_x)
    task_type(task_type==pos_iso_x) = pos_iso;
end
if find(task_type==pos_wm_x)
    task_type(task_type==pos_wm_x) = pos_wm;
end


% get nbr of different tasks in the dataset
tasks_in_dataset        = unique(task_type);
nbr_diff_tasks          = size(tasks_in_dataset,2);

% create var with colors for each task
colors_per_task         = parula(nbr_diff_tasks);


%% -------------------------------------------------------------------------
%% SUMMARY PCA OF NEURAL ACTIVTY

% store nbr neurons per session
nbr_neural_chs_per_session = arrayfun(@(x) x.last_dim,aux_pooled);

% store the variance explained by PCA of the spikes, after the nbr of
% dimensions has been upsampled to 100 (to do stats)
var_neural_pca      = zeros(100,nbr_tasks_total);
for s = 1:nbr_sessions
    for t = 1:nbr_tasks_per_session(s)
        orig_var    = aux_pooled(s).var_fcn_eigen(:,t);
        orig_x      = 1:100/length(orig_var):100;
        new_x       = 1:100;
        rsmpld_var  = interp1(orig_x,orig_var,new_x,'linear','extrap');
        % store results in summary matrix
        var_neural_pca(:,sum(nbr_tasks_per_session(1:s-1))+t) = rsmpld_var;
    end
end
clear ctr orig_var orig_x new_x rsmpld_var
% compute mean and SD
mean_var_neural_pca             = mean(var_neural_pca,2);
std_var_neural_pca              = std(var_neural_pca,0,2);

% compute mean and SD per task
mean_var_neural_pca_per_task    = zeros(100,nbr_diff_tasks);
std_var_neural_pca_per_task     = zeros(100,nbr_diff_tasks);
for t = 1:nbr_diff_tasks
    mean_var_neural_pca_per_task(:,t)   = mean(var_neural_pca(:,task_type==t),2);
    std_var_neural_pca_per_task(:,t)    = std(var_neural_pca(:,task_type==t),0,2);
end


% -------------------------------------------------------------------------
% PLOTS
% plot mean +/-SD across all tasks

x_sd        = [1:100,100:-1:1];
y_sd        = [mean_var_neural_pca+std_var_neural_pca]';
y_sd        = [y_sd,fliplr([mean_var_neural_pca-std_var_neural_pca]')];

figs.neural_var_all_tasks = figure; hold on
plot(mean_var_neural_pca,'color',monkey_color,'linewidth',2)
f_h = fill(x_sd,y_sd,monkey_color);
set(f_h,'EdgeColor','None');alpha(f_h,.2);
set(gca,'TickDir','out'),set(gca,'FontSize',18)
ylabel('variance accounted for'),ylim([0 1.1])
xlabel(['percentage of extracted neural dimensions n = ' num2str(min(nbr_neural_chs_per_session)) ...
    ' to ' num2str(max(nbr_neural_chs_per_session))])

% plot mean +/- SD per task
figs.neural_var_p_task = figure; hold on
for t = 1:nbr_diff_tasks
    plot(mean_var_neural_pca_per_task(:,t),'color',colors_per_task(t,:),'linewidth',4)
end
legend(task_legend(unique(task_type)),'Location','SouthEast'),legend boxoff
for t = 1:nbr_diff_tasks
    if numel(find(task_type==t))>1
        y_sd        = [mean_var_neural_pca_per_task(:,t)+std_var_neural_pca_per_task(:,t)]';
        y_sd        = [y_sd,fliplr([mean_var_neural_pca_per_task(:,t)-std_var_neural_pca_per_task(:,t)]')];
        f_h = fill(x_sd,y_sd,colors_per_task(t,:));
        set(f_h,'EdgeColor','None');alpha(f_h,.2);
    end
end
for t = 1:nbr_diff_tasks
    plot(mean_var_neural_pca_per_task(:,t),'color',colors_per_task(t,:),'linewidth',4)
end
set(gca,'TickDir','out'),set(gca,'FontSize',18)
ylabel('variance accounted for'),ylim([0 1.1])
xlabel(['percentage of extracted neural dimensions n = ' num2str(min(nbr_neural_chs_per_session)) ...
    ' to ' num2str(max(nbr_neural_chs_per_session))])

% % plot each trial
% for i = 1:4
%     plot(var_neural_pca(:,task_type==i),'color',colors_per_task(i,:))
% end
% set(gca,'TickDir','out'),set(gca,'FontSize',18)
% ylabel('variance accounted for'),ylim([0 1.1])
% xlabel(['percentage of extracted neural dimensions n = ' num2str(min(nbr_neural_chs_per_session)) ...
%     ' to ' num2str(max(nbr_neural_chs_per_session))])

% -------------------------------------------------------------------------
% ANGLES BETWEEN HYPERPLANES
