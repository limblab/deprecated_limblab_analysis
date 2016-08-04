% 
% Take an array of target averaged responses for several tasks obtained
% with single_trial_analysis_dim_red and make them all have the same
% duration (number of bins)
%
%   function single_trial_data   = equalize_single_trial_dur( single_trial_data )
%
%

function single_trial_data   = equalize_single_trial_dur( single_trial_data )


% get number of samples of the average responses for each dataset
bins_dataset        = cellfun(@(x) size(x.target{1}.neural_scores.data,1),single_trial_data);

% resample everything to the duration of the longest
new_nbr_bins        = max(bins_dataset);
t_new               = 0:single_trial_data{1}.target{1}.bin_size:...
                        single_trial_data{1}.target{1}.bin_size*(new_nbr_bins-1);
                    
% get field names, for resampling
neural_names        = fieldnames(single_trial_data{1}.target{1}.neural_scores);
emg_names           = fieldnames(single_trial_data{1}.target{1}.emg_scores);
pos_names           = fieldnames(single_trial_data{1}.target{1}.emg_scores);
vel_names           = fieldnames(single_trial_data{1}.target{1}.emg_scores);
    
                    
% do for each task
for i = 1:numel(single_trial_data)
    
    % create time vector for the original data
    t_orig          = 0:single_trial_data{i}.target{1}.bin_size:...
                        single_trial_data{i}.target{1}.bin_size*(bins_dataset(i)-1);
    
                    % resample the data for each target
    for t = 1:numel(single_trial_data{i}.target)
        % for the neural data
        for f = 1:numel(neural_names)
            data_orig   = single_trial_data{i}.target{t}.neural_scores.(neural_names{f});
            data_new    = interp1(t_orig,data_orig,t_new,'linear','extrap');
            single_trial_data{i}.target{t}.neural_scores.(neural_names{f}) = ...
                data_new;
        end
        % for the EMG data
        for f = 1:numel(emg_names)
            data_orig   = single_trial_data{i}.target{t}.emg_scores.(emg_names{f});
            data_new    = interp1(t_orig,data_orig,t_new,'linear','extrap');
            single_trial_data{i}.target{t}.emg_scores.(emg_names{f}) = ...
                data_new;
        end
        % for the Pos data
        for f = 1:numel(pos_names)
            data_orig   = single_trial_data{i}.target{t}.pos.(pos_names{f});
            data_new    = interp1(t_orig,data_orig,t_new,'linear','extrap');
            single_trial_data{i}.target{t}.pos.(pos_names{f}) = ...
                data_new;
        end
        % for the Vel data
        for f = 1:numel(vel_names)
            data_orig   = single_trial_data{i}.target{t}.vel.(vel_names{f});
            data_new    = interp1(t_orig,data_orig,t_new,'linear','extrap');
            single_trial_data{i}.target{t}.pos.(vel_names{f}) = ...
                data_new;
        end
    end
end

