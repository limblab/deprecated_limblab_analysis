%
% take a binned_data struct that has been cut in intervals between two
% words, and return trial-by-trial results and averages
%


function single_trial_data = single_trial_analysis_dim_red( cropped_binned_data, ...
            dim_red_FR, dim_red_emg, varargin )


if nargin >= 4
    label               = varargin{1};
else
    label               = '';
end

if nargin == 5
    plot_yn             = varargin{2};
else
    plot_yn             = false;
end

% Choose trial normalization method (in the time domain)
% 'min_dur', 'stretch'
trial_norm              = 'stretch';


% get bin size
bin_size                = min(diff(cropped_binned_data.timeframe));

% ------------------------------------------------------------------------
% Get trial info

% retrieve the intervals that correspond to each trial
diff_timeframe          = diff(cropped_binned_data.timeframe);

% get the end of each trial
end_indx                = find(diff_timeframe > 2*bin_size);
% get the beginning of each trial
start_indx              = [1; end_indx(1:end-1)+1];
% get the number of trials
nbr_trials              = length(end_indx);
% and its duration 
trial_dur               = zeros(nbr_trials,1);
trial_dur(1)            = end_indx(1)*bin_size;
trial_dur(2:nbr_trials) = diff(end_indx)*bin_size;


% ------------------------------------------------------------------------
% Create arrays with trials

nbr_neural_dims         = length(dim_red_FR.eigen);
nbr_emg_dims            = size(dim_red_emg.scores,2);

% Plot targets
[nbr_targets, target_coord] = plot_targets(cropped_binned_data, label);

% find what target corresponds to each trial
% -- this is a little bit convoluted because the structure of the trial
% table depends on the task ...
if strncmp(label,'iso',3) || strncmp(label,'spr',3) || strncmp(label,'wm',2)
    cols_tgt_coord      = [2,5];
elseif strncmp(label,'ball',4)
    cols_tgt_coord      = [];
elseif strncmp(label,'mg',2)
    cols_tgt_coord      = [7,10];
end

% ... also for the ball task there is only one target
if ~isempty(cols_tgt_coord)
    target_nbr          = zeros(1,nbr_trials);
    for i = 1:nbr_trials
        [~, target_nbr(i)] = ismember(cropped_binned_data.trialtable(i,cols_tgt_coord),...
                                target_coord(:,1:2),'rows');
    end
    % Quick fix for Theo, since his data don't have target positions
    if max(target_nbr) == 0
        target_nbr      = cropped_binned_data.trialtable(1:nbr_trials,6)+1;
    end
else
    target_nbr          = ones(1,nbr_trials);
end
    
% create a cell array that contains the dim_red_emg and dim_red_FR for each
% target
single_trial_data       = cell(1,nbr_targets);
for i = 1:nbr_targets
    trials_this_target  = find(target_nbr == i);
    nbr_trials_this_target = length(trials_this_target);
    
    switch trial_norm
        % only take the data from t = 0 : min(duration_all_trials_this_target)
        case 'min_dur'
            st_dur      = min(trial_dur(trials_this_target));
        % 'stretch' all trials in the time domain, so they last the same as
        % the shortest trial
        case 'stretch'
            % st_dur      = ceil(max((trial_dur(trials_this_target)))/bin_size)*bin_size;
            st_dur      = ceil(min(trial_dur)/bin_size)*bin_size;
    end
    
    % preallocate matrices
    single_trial_data{i}.neural_scores.data = zeros( st_dur/bin_size,...
                            nbr_neural_dims, nbr_trials_this_target );
    single_trial_data{i}.neural_scores.smoothed_fr = zeros( st_dur/bin_size,...
                            nbr_neural_dims, nbr_trials_this_target );
    single_trial_data{i}.emg_scores.data = zeros( st_dur/bin_size,...
                            nbr_emg_dims, nbr_trials_this_target );
	if ~isempty(cropped_binned_data.cursorposbin)
        single_trial_data{i}.pos.data = zeros( st_dur/bin_size,...
                                2, nbr_trials_this_target );
        single_trial_data{i}.vel.data = zeros( st_dur/bin_size,...
                                3, nbr_trials_this_target );
    end
    
    single_trial_data{i}.neural_scores.mn = zeros( st_dur/bin_size,...
                            nbr_neural_dims );
    single_trial_data{i}.emg_scores.mn = zeros( st_dur/bin_size,...
                            nbr_emg_dims );
    if ~isempty(cropped_binned_data.cursorposbin)
        single_trial_data{i}.pos.mn = zeros( st_dur/bin_size, 2 );
        single_trial_data{i}.vel.mn = zeros( st_dur/bin_size, 3 );
    end
    
    single_trial_data{i}.neural_scores.sd = zeros( st_dur/bin_size,...
                            nbr_neural_dims );
    single_trial_data{i}.emg_scores.sd = zeros( st_dur/bin_size,...
                            nbr_emg_dims );
    if ~isempty(cropped_binned_data.cursorposbin)            
        single_trial_data{i}.pos.sd = zeros( st_dur/bin_size, 2 );
        single_trial_data{i}.vel.sd = zeros( st_dur/bin_size, 3 );
    end
    
                        
    % fill values
    for t = 1:nbr_trials_this_target
        % find trial start
        aux_start       = start_indx(trials_this_target(t));
        
        switch trial_norm
            case 'min_dur' 
                % find trial end: for 'min_dur' happens at the end of the
                % shortest trial for this target
                aux_end         = aux_start + st_dur/bin_size - 1;
                
                single_trial_data{i}.neural_scores.data(:,:,t) = dim_red_FR.scores(...
                                aux_start:aux_end,:);
                single_trial_data{i}.neural_scores.smoothed_fr(:,:,t) = dim_red_FR.scores(...
                                aux_start:aux_end,:);            
                single_trial_data{i}.emg_scores.data(:,:,t) = cropped_binned_data.smoothedspikerate(...
                                aux_start:aux_end,:);
                if ~isempty(cropped_binned_data.cursorposbin)
                    single_trial_data{i}.pos.data(:,:,t) = ...
                                    cropped_binned_data.cursorposbin(aux_start:aux_end,:);
                    single_trial_data{i}.vel.data(:,:,t) = ...
                                    cropped_binned_data.velocbin(aux_start:aux_end,:);
                end
            case 'stretch'
                % find trial end: for 'stretch is the real end of the
                % trial; afterwards the code will make all the trials equal
                % length
                aux_end         = aux_start + trial_dur(trials_this_target(t))/bin_size - 1;
                
                % for interpolating, define time axis of the data
                t_orig          = 1:trial_dur(trials_this_target(t))/bin_size;
                t_new           = 1:st_dur/bin_size;
                neural_scores_orig  = dim_red_FR.scores(aux_start:aux_end,:);
                smoothed_fr_orig    = cropped_binned_data.smoothedspikerate(aux_start:aux_end,dim_red_FR.chs);
                emg_scores_orig     = dim_red_emg.scores(aux_start:aux_end,:);
                if ~isempty(cropped_binned_data.cursorposbin)
                    pos_data_orig   = cropped_binned_data.cursorposbin(aux_start:aux_end,:);
                    vel_data_orig   = cropped_binned_data.velocbin(aux_start:aux_end,:);
                end
                
                neural_scores_new   = interp1(t_orig,neural_scores_orig,t_new,'linear','extrap');
                smoothed_fr_new     = interp1(t_orig,smoothed_fr_orig,t_new,'linear','extrap');
                emg_scores_new      = interp1(t_orig,emg_scores_orig,t_new,'linear','extrap');
                if ~isempty(cropped_binned_data.cursorposbin)
                    pos_data_new    = interp1(t_orig,pos_data_orig,t_new,'linear','extrap');
                    vel_data_new    = interp1(t_orig,vel_data_orig,t_new,'linear','extrap');
                end
                
                % store values in single_trial_data struct
                single_trial_data{i}.neural_scores.data(:,:,t) = neural_scores_new;
                single_trial_data{i}.neural_scores.smoothed_fr(:,:,t) = smoothed_fr_new;
                single_trial_data{i}.emg_scores.data(:,:,t) = emg_scores_new;
                if ~isempty(cropped_binned_data.cursorposbin)
                    single_trial_data{i}.pos.data(:,:,t) = pos_data_new;
                    single_trial_data{i}.vel.data(:,:,t) = vel_data_new;
                end
        end
    end
    
    % calculate mean and SD
    single_trial_data{i}.neural_scores.mn = mean(single_trial_data{i}.neural_scores.data,3);
    single_trial_data{i}.neural_scores.sd = std(single_trial_data{i}.neural_scores.data,0,3);
    
    single_trial_data{i}.emg_scores.mn = mean(single_trial_data{i}.emg_scores.data,3);
    single_trial_data{i}.emg_scores.sd = std(single_trial_data{i}.emg_scores.data,0,3);
    
    if ~isempty(cropped_binned_data.cursorposbin)
        single_trial_data{i}.pos.mn = mean(single_trial_data{i}.pos.data,3);
        single_trial_data{i}.pos.sd = std(single_trial_data{i}.pos.data,0,3);

        single_trial_data{i}.vel.mn = mean(single_trial_data{i}.vel.data,3);
        single_trial_data{i}.vel.sd = std(single_trial_data{i}.vel.data,0,3);
    end
    
    % add bin size
    single_trial_data{i}.bin_size = bin_size;
    % add trial time averaging method
    single_trial_data{i}.avg_method = trial_norm; 
end




% ------------------------------------------------------------------------
% Plots

if plot_yn

% move these above!!!
neural_PCs              = 1:6;
neural_PCs_vs_muscles   = 1:3;
muscle_PCs              = 1:min(3,size(dim_red_emg.scores,2));

plot_all                = false; % plot all or just mean +/- SD

colors                  = parula(nbr_targets);

% neural PCs only
nbr_rows                = floor(sqrt(length(neural_PCs)));
nbr_cols                = ceil(length(neural_PCs)/nbr_rows);
max_score               = max(cell2mat(cellfun(@(x) max(max(max(abs(x.neural_scores.data(:,neural_PCs,:))))),...
                            single_trial_data,'UniformOutput',false))); % improve coding !!
figure('units','normalized','outerposition',[0 0 1 1])
for i = 1:length(neural_PCs)
   subplot(nbr_rows,nbr_cols,i), hold on
   for t = 1:nbr_targets
        t_axis           = 0:bin_size:(size(single_trial_data{t}.neural_scores.data,1)...
                            -1)*bin_size;
        if plot_all
            plot(t_axis,squeeze(single_trial_data{t}.neural_scores.data(:,neural_PCs(i),:)),...
                'color',colors(t,:));
        else
            plot(t_axis,single_trial_data{t}.neural_scores.mn(:,neural_PCs(i)),...
                            'color',colors(t,:),'linewidth',6);
            plot(t_axis,single_trial_data{t}.neural_scores.mn(:,neural_PCs(i)) + ...
                single_trial_data{t}.neural_scores.sd(:,neural_PCs(i)), ...
                'color',colors(t,:),'linewidth',2,'linestyle','-.');
            plot(t_axis,single_trial_data{t}.neural_scores.mn(:,neural_PCs(i)) - ...
                single_trial_data{t}.neural_scores.sd(:,neural_PCs(i)), ...
                'color',colors(t,:),'linewidth',2,'linestyle','-.');
        end
        clear t_axis;
        ylim([-max_score, max_score])
   end
   set(gca,'TickDir','out'),set(gca,'FontSize',14); 
   title(['neural comp ' num2str(neural_PCs(i))]);
   if i == 1 || rem(i-1,nbr_cols) == 0
       ylabel('a.u.','FontSize',14)
   end
   if i > nbr_cols*(nbr_rows-1)
       xlabel('time (s)','FontSize',14)
   end
end



% neural PCs vs muscles
nbr_rows                = floor(sqrt(length([neural_PCs_vs_muscles, muscle_PCs])));
nbr_cols                = ceil(length([neural_PCs_vs_muscles, muscle_PCs])/nbr_rows);

max_score               = max(cell2mat(cellfun(@(x) max(max(max(abs(x.neural_scores.data(:,neural_PCs,:))))),...
                            single_trial_data,'UniformOutput',false))); % improve coding !!

figure('units','normalized','outerposition',[0 0 1 1])
for i = 1:length(neural_PCs_vs_muscles)
   subplot(nbr_rows,nbr_cols,i), hold on
   for t = 1:nbr_targets
        t_axis           = 0:bin_size:(size(single_trial_data{t}.neural_scores.data,1)...
                            -1)*bin_size;
        if plot_all
            plot(t_axis,squeeze(single_trial_data{t}.neural_scores.data(:,neural_PCs_vs_muscles(i),:)),...
                'color',colors(t,:));
        else
            plot(t_axis,single_trial_data{t}.neural_scores.mn(:,neural_PCs_vs_muscles(i)),...
                            'color',colors(t,:),'linewidth',6);
            plot(t_axis,single_trial_data{t}.neural_scores.mn(:,neural_PCs_vs_muscles(i)) + ...
                single_trial_data{t}.neural_scores.sd(:,neural_PCs_vs_muscles(i)), ...
                'color',colors(t,:),'linewidth',2,'linestyle','-.');
            plot(t_axis,single_trial_data{t}.neural_scores.mn(:,neural_PCs_vs_muscles(i)) - ...
                single_trial_data{t}.neural_scores.sd(:,neural_PCs_vs_muscles(i)), ...
                'color',colors(t,:),'linewidth',2,'linestyle','-.');
        end
        clear t_axis;
        ylim([-max_score, max_score])
   end
   set(gca,'TickDir','out'),set(gca,'FontSize',14); 
   title(['neural comp ' num2str(neural_PCs_vs_muscles(i))]);
   if i == 1 || rem(i-1,nbr_cols) == 0
       ylabel('a.u.','FontSize',14)
   end
end

for i = 1:length(muscle_PCs)
   subplot(nbr_rows,nbr_cols,i+length(neural_PCs_vs_muscles)), hold on
   for t = 1:nbr_targets
        t_axis           = 0:bin_size:(size(single_trial_data{t}.emg_scores.data,1)...
                            -1)*bin_size;
        if plot_all
            plot(t_axis,squeeze(single_trial_data{t}.emg_scores.data(:,muscle_PCs(i),:)),...
                'color',colors(t,:));
        else
            plot(t_axis,single_trial_data{t}.emg_scores.mn(:,muscle_PCs(i)),...
                            'color',colors(t,:),'linewidth',6);
            plot(t_axis,single_trial_data{t}.emg_scores.mn(:,muscle_PCs(i)) + ...
                single_trial_data{t}.emg_scores.sd(:,muscle_PCs(i)), ...
                'color',colors(t,:),'linewidth',2,'linestyle','-.');
            plot(t_axis,single_trial_data{t}.emg_scores.mn(:,muscle_PCs(i)) - ...
                single_trial_data{t}.emg_scores.sd(:,muscle_PCs(i)), ...
                'color',colors(t,:),'linewidth',2,'linestyle','-.');
        end
        clear t_axis;
   end
   set(gca,'TickDir','out'),set(gca,'FontSize',14); 
   title(['muscle comp ' num2str(muscle_PCs(i))]);
   if i == 1 || rem(i-1,nbr_cols) == 0
       ylabel('a.u.','FontSize',14)
   end
   xlabel('time (s)','FontSize',14)
end




% neural PCs vs position
if ~isempty(cropped_binned_data.cursorposbin)
                    
    nbr_rows                = floor(sqrt(length([neural_PCs_vs_muscles, muscle_PCs])));
    nbr_cols                = ceil(length([neural_PCs_vs_muscles, muscle_PCs])/nbr_rows);

    max_score               = max(cell2mat(cellfun(@(x) max(max(max(abs(x.neural_scores.data(:,neural_PCs,:))))),...
                                single_trial_data,'UniformOutput',false))); % improve coding !!

    figure('units','normalized','outerposition',[0 0 1 1])
    for i = 1:length(neural_PCs_vs_muscles)
       subplot(nbr_rows,nbr_cols,i), hold on
       for t = 1:nbr_targets
            t_axis           = 0:bin_size:(size(single_trial_data{t}.neural_scores.data,1)...
                                -1)*bin_size;
            if plot_all
                plot(t_axis,squeeze(single_trial_data{t}.neural_scores.data(:,neural_PCs_vs_muscles(i),:)),...
                    'color',colors(t,:));
            else
                plot(t_axis,single_trial_data{t}.neural_scores.mn(:,neural_PCs_vs_muscles(i)),...
                                'color',colors(t,:),'linewidth',6);
                plot(t_axis,single_trial_data{t}.neural_scores.mn(:,neural_PCs_vs_muscles(i)) + ...
                    single_trial_data{t}.neural_scores.sd(:,neural_PCs_vs_muscles(i)), ...
                    'color',colors(t,:),'linewidth',2,'linestyle','-.');
                plot(t_axis,single_trial_data{t}.neural_scores.mn(:,neural_PCs_vs_muscles(i)) - ...
                    single_trial_data{t}.neural_scores.sd(:,neural_PCs_vs_muscles(i)), ...
                    'color',colors(t,:),'linewidth',2,'linestyle','-.');
            end
            clear t_axis;
            ylim([-max_score, max_score])
       end
       set(gca,'TickDir','out'),set(gca,'FontSize',14); 
       title(['neural comp ' num2str(neural_PCs_vs_muscles(i))]);
       if i == 1 || rem(i-1,nbr_cols) == 0
           ylabel('a.u.','FontSize',14)
       end
    end

    for i = 1:size(single_trial_data{1}.pos.data,2)
       subplot(nbr_rows,nbr_cols,i+length(neural_PCs_vs_muscles)), hold on
       for t = 1:nbr_targets
            t_axis           = 0:bin_size:(size(single_trial_data{t}.pos.data,1)...
                                -1)*bin_size;
            if plot_all
                plot(t_axis,squeeze(single_trial_data{t}.pos.data(:,i,:)),...
                    'color',colors(t,:));
            else
                plot(t_axis,single_trial_data{t}.pos.mn(:,i),...
                                'color',colors(t,:),'linewidth',6);
                plot(t_axis,single_trial_data{t}.pos.mn(:,i) + ...
                    single_trial_data{t}.pos.sd(:,muscle_PCs(i)), ...
                    'color',colors(t,:),'linewidth',2,'linestyle','-.');
                plot(t_axis,single_trial_data{t}.pos.mn(:,i) - ...
                    single_trial_data{t}.pos.sd(:,i), ...
                    'color',colors(t,:),'linewidth',2,'linestyle','-.');
            end
            clear t_axis;
       end
       set(gca,'TickDir','out'),set(gca,'FontSize',14); 
       title(['pos/force ' num2str(i)]);
       if i == 1 || rem(i-1,nbr_cols) == 0
           ylabel('a.u.','FontSize',14)
       end
       xlabel('time (s)','FontSize',14)
    end


    % neural PCs vs velocity
    nbr_rows                = floor(sqrt(length([neural_PCs_vs_muscles, muscle_PCs])));
    nbr_cols                = ceil(length([neural_PCs_vs_muscles, muscle_PCs])/nbr_rows);

    max_score               = max(cell2mat(cellfun(@(x) max(max(max(abs(x.neural_scores.data(:,neural_PCs,:))))),...
                                single_trial_data,'UniformOutput',false))); % improve coding !!

    figure('units','normalized','outerposition',[0 0 1 1])
    for i = 1:length(neural_PCs_vs_muscles)
       subplot(nbr_rows,nbr_cols,i), hold on
       for t = 1:nbr_targets
            t_axis           = 0:bin_size:(size(single_trial_data{t}.neural_scores.data,1)...
                                -1)*bin_size;
            if plot_all
                plot(t_axis,squeeze(single_trial_data{t}.neural_scores.data(:,neural_PCs_vs_muscles(i),:)),...
                    'color',colors(t,:));
            else
                plot(t_axis,single_trial_data{t}.neural_scores.mn(:,neural_PCs_vs_muscles(i)),...
                                'color',colors(t,:),'linewidth',6);
                plot(t_axis,single_trial_data{t}.neural_scores.mn(:,neural_PCs_vs_muscles(i)) + ...
                    single_trial_data{t}.neural_scores.sd(:,neural_PCs_vs_muscles(i)), ...
                    'color',colors(t,:),'linewidth',2,'linestyle','-.');
                plot(t_axis,single_trial_data{t}.neural_scores.mn(:,neural_PCs_vs_muscles(i)) - ...
                    single_trial_data{t}.neural_scores.sd(:,neural_PCs_vs_muscles(i)), ...
                    'color',colors(t,:),'linewidth',2,'linestyle','-.');
            end
            clear t_axis;
            ylim([-max_score, max_score])
       end
       set(gca,'TickDir','out'),set(gca,'FontSize',14); 
       title(['neural comp ' num2str(neural_PCs_vs_muscles(i))]);
       if i == 1 || rem(i-1,nbr_cols) == 0
           ylabel('a.u.','FontSize',14)
       end
    end

    for i = 1:size(single_trial_data{1}.vel.data,2)
       subplot(nbr_rows,nbr_cols,i+length(neural_PCs_vs_muscles)), hold on
       for t = 1:nbr_targets
            t_axis           = 0:bin_size:(size(single_trial_data{t}.vel.data,1)...
                                -1)*bin_size;
            if plot_all
                plot(t_axis,squeeze(single_trial_data{t}.vel.data(:,i,:)),...
                    'color',colors(t,:));
            else
                plot(t_axis,single_trial_data{t}.vel.mn(:,i),...
                                'color',colors(t,:),'linewidth',6);
                plot(t_axis,single_trial_data{t}.vel.mn(:,i) + ...
                    single_trial_data{t}.vel.sd(:,i), ...
                    'color',colors(t,:),'linewidth',2,'linestyle','-.');
                plot(t_axis,single_trial_data{t}.vel.mn(:,i) - ...
                    single_trial_data{t}.vel.sd(:,i), ...
                    'color',colors(t,:),'linewidth',2,'linestyle','-.');
            end
            clear t_axis;
       end
       set(gca,'TickDir','out'),set(gca,'FontSize',14); 
       title(['velocity ' num2str(i)]);
       if i == 1 || rem(i-1,nbr_cols) == 0
           ylabel('a.u.','FontSize',14)
       end
       xlabel('time (s)','FontSize',14)
    end

end

% % neural PCs vs some EMGs
% emgs_to_plot            = 10:12;
% nbr_rows                = floor(sqrt(length([neural_PCs_vs_muscles, emgs_to_plot])));
% nbr_cols                = ceil(length([neural_PCs_vs_muscles, emgs_to_plot])/nbr_rows);
% 
% max_score               = max(cell2mat(cellfun(@(x) max(max(max(abs(x.neural_scores.data(:,neural_PCs,:))))),...
%                             single_trial_data,'UniformOutput',false))); % improve coding !!
% 
% figure('units','normalized','outerposition',[0 0 1 1])
% for i = 1:length(neural_PCs_vs_muscles)
%    subplot(nbr_rows,nbr_cols,i), hold on
%    for t = 1:nbr_targets
%         t_axis           = 0:bin_size:(size(single_trial_data{t}.neural_scores.data,1)...
%                             -1)*bin_size;
%         if plot_all
%             plot(t_axis,squeeze(single_trial_data{t}.neural_scores.data(:,neural_PCs_vs_muscles(i),:)),...
%                 'color',colors(t,:));
%         else
%             plot(t_axis,single_trial_data{t}.neural_scores.mn(:,neural_PCs_vs_muscles(i)),...
%                             'color',colors(t,:),'linewidth',6);
%             plot(t_axis,single_trial_data{t}.neural_scores.mn(:,neural_PCs_vs_muscles(i)) + ...
%                 single_trial_data{t}.neural_scores.sd(:,neural_PCs_vs_muscles(i)), ...
%                 'color',colors(t,:),'linewidth',2,'linestyle','-.');
%             plot(t_axis,single_trial_data{t}.neural_scores.mn(:,neural_PCs_vs_muscles(i)) - ...
%                 single_trial_data{t}.neural_scores.sd(:,neural_PCs_vs_muscles(i)), ...
%                 'color',colors(t,:),'linewidth',2,'linestyle','-.');
%         end
%         clear t_axis;
%         ylim([-max_score, max_score])
%    end
%    set(gca,'TickDir','out'),set(gca,'FontSize',14); 
%    title(['neural comp ' num2str(neural_PCs_vs_muscles(i))]);
%    if i == 1 || rem(i-1,nbr_cols) == 0
%        ylabel('a.u.','FontSize',14)
%    end
% end
% 
% for i = 1:numel(emgs_to_plot)
%    subplot(nbr_rows,nbr_cols,i+length(neural_PCs_vs_muscles)), hold on
%    for t = 1:nbr_targets
%         t_axis           = 0:bin_size:(size(single_trial_data{t}.vel.data,1)...
%                             -1)*bin_size;
%         if plot_all
%             plot(t_axis,squeeze(single_trial_data{t}.vel.data(:,i,:)),...
%                 'color',colors(t,:));
%         else
%             plot(t_axis,single_trial_data{t}.vel.mn(:,i),...
%                             'color',colors(t,:),'linewidth',6);
%             plot(t_axis,single_trial_data{t}.vel.mn(:,i) + ...
%                 single_trial_data{t}.vel.sd(:,muscle_PCs(i)), ...
%                 'color',colors(t,:),'linewidth',2,'linestyle','-.');
%             plot(t_axis,single_trial_data{t}.vel.mn(:,i) - ...
%                 single_trial_data{t}.vel.sd(:,i), ...
%                 'color',colors(t,:),'linewidth',2,'linestyle','-.');
%         end
%         clear t_axis;
%    end
%    set(gca,'TickDir','out'),set(gca,'FontSize',14); 
%    title(['velocity ' num2str(i)]);
%    if i == 1 || rem(i-1,nbr_cols) == 0
%        ylabel('a.u.','FontSize',14)
%    end
%    xlabel('time (s)','FontSize',14)
% end

end