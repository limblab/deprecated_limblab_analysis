function h = un1d_plotNature(monkeyName, brainArea,dateStamp, setRange, targetDir, trialRange)
%UN1D_PLOTNATURE Generates the "Nature" plots a la Kording and Wolpert 2004.
%   Plots of Endpoint versus Shift, separated by likelihood conditions.
%
%   monkeyName = string with ID used in filename, i.e. 'Jaco' or 'MrT'
%   brainArea  = string with ID used in filename, i.e. 'M1' or 'PMd' or
%   'Behavior's
%   dateStamp  = string with datestamp used in filename, i.e. '04052012'
%   setRange   = vector with file numbers, i.e. [1 2 4 5]
%   targetDir  = which direction was the target, i.e. 0, 90, 180, 270
%   trialRange = trials to analyze
%
%   last updated: 09/18/2012 - pwanda
%

%% Initialize
close all;
color_sigs = ['rbgmk'];


% Vectors used to accumulate total data across all sets in the range
pos_x_all = [];         % x hand position all trials
pos_y_all = [];         % y hand position all trials
shift_all = [];         % prior shift all trials
feedback_sig_all = [];  % feedback (dot) condition all trials

% Origin Offsets (from General tab of behavior GUI)

if monkeyName=='Mini'
    
    % Mini Plexon
    x_offset = -5;
    y_offset = 34;
elseif monkeyName=='MrT' || monkeyName=='Mihili'
    % MRT Cerebus Offset
    x_offset = -2;
    y_offset = 32.5;
end
%% operate over each set in the specified range
for si=1:length(setRange)
    
    %    load bdf and trial table for first set
    fn_bdf = ['bdf/bdf_' monkeyName '_' brainArea '_' dateStamp '_UN1D_00' int2str(setRange(si)) '.mat'];
    fn_tt  = ['tt/tt_'  monkeyName '_' brainArea '_' dateStamp '_UN1D_00' int2str(setRange(si)) '.mat'];
    load(fn_bdf);
    load(fn_tt);
    
    % This chunk of code extracts filename prefix
    %  (used for figure titles and saving new figures)
    tmp = bdf.meta.filename; % extract only the filename from the full path
    while ~isempty(tmp)
        [tok tmp]=strtok(tmp,'\\');
    end
    tmp=strtok(tok,'.');  % remove the .nev suffix
    % replace the underscores with hyphens (for matlab compatibility)
    tmp(find(tmp=='_'))='-';
    fn_prefix = [tmp '- '];  % the function tag to prefix the titles
    clear tmp tok;
    
    % Load hand position and correct for the general tab center offset
    pos_x = bdf.pos(:,2)+x_offset;
    pos_y = bdf.pos(:,3)+y_offset;
    
    % Load rest of kinematics
    vel_x = bdf.vel(:,2);
    vel_y = bdf.vel(:,3);
    acc_x = bdf.acc(:,2);
    acc_y = bdf.acc(:,3);
    
    % The timer for each kinematic sample
    kin_ts = bdf.pos(:,1);
    
    %% Pull information from the trial table
    dtb_ts =  tt(trialRange,1);    % databurst timestamps
    dtb_shifts =  tt(trialRange,2);    % shift values for each trial
    dtb_feedback_sig =  tt(trialRange,3);    % feedback condition for each trial
    dtb_centeron_ts =     tt(trialRange,4);    % timestamp of center target
    dtb_outeron_ts = tt(trialRange,5);          % timestamp of target drawn
    dtb_gocue_ts = tt(trialRange,6);            % timestamp of go cue
    dtb_endcode_ts = tt(trialRange,7);           % timestamp of trial complete
    dtb_end_codes = tt(trialRange,8);        % code for trial complete
    
    % Find the unique feedback conditions
    feedback_sig_conditions = unique(dtb_feedback_sig(find(isnan(dtb_feedback_sig)==0)));
    
    % R 32   A 33   F 34   I 35    Other NaN
    
    %% Process Completed Trials
    % Find the trials where the outcome was either a REWARD and FAIL
    % abort and incomplete trials are excluded from this analysis
    tmp = find(dtb_end_codes==32 | dtb_end_codes == 34);
    completed_trials_code_idx = [];
    
    for i=1:length(tmp)
        % on occasion the databurst may fail to include the shift for a
        % trial: exclude these from analysis.
        if ~isnan(dtb_shifts(tmp(i)))
            completed_trials_code_idx = [completed_trials_code_idx tmp(i)];
        end
    end
    clear tmp;
    
    % vectors containing the information just for completed trials
    shifts_completed_trials            = dtb_shifts(completed_trials_code_idx);
    feedback_sigs_completed_trials     = dtb_feedback_sig(completed_trials_code_idx);
    dtb_gocue_ts_completed_trials             = dtb_gocue_ts(completed_trials_code_idx);
    dtb_endcode_ts_completed_trials            = dtb_endcode_ts(completed_trials_code_idx);
    dtb_end_codes_completed_trials         = dtb_end_codes(completed_trials_code_idx);
    
    % pull out the indices for the kinematics vectors that correspond
    % to the timestamps for the state codes
    kin_go_completed_idx=[];
    for ri=1:length(dtb_gocue_ts_completed_trials)
        kin_go_completed_idx(ri) = find(kin_ts<dtb_gocue_ts_completed_trials(ri),1,'last');
    end
    
    kin_end_completed_idx = [];
    for ri=1:length(dtb_endcode_ts_completed_trials)
        kin_end_completed_idx(ri) = find(kin_ts<dtb_endcode_ts_completed_trials(ri),1,'last');
    end
    
    % position at GO
    pos_x_go = pos_x(kin_go_completed_idx);
    pos_y_go = pos_y(kin_go_completed_idx);
    
    % position at REWARD OR FAIL
    pos_x_end = pos_x(kin_end_completed_idx);
    pos_y_end = pos_y(kin_end_completed_idx);
    
    
    %% Plots
    % Endpoint vs Shift
    figure;hold on;
    lgnd={};
    % For each feedback cloud size
    for si=1:length(feedback_sig_conditions)
        % current cloud condition value
        current_cloud_condition = feedback_sig_conditions(si);
        % pull out the trial indices for this current cloud value
        current_cloud_idx = find(feedback_sigs_completed_trials==current_cloud_condition);
        
        % endpoint displacement is going to differ depending on the target
        % x-axis for 90 and 270
        % y-axis for  0 and 180
        ep_displacements = [];
        if (targetDir == 90 || targetDir == 270)
            ep_displacements = pos_x_end(current_cloud_idx);
        elseif (targetDir == 0 || targetDir == 180)
            ep_displacements = pos_y_end(current_cloud_idx);
        else
            error('ERROR: Invalid target direction.  Must be 0, 90, 180, or 270');
            return;
        end
        % Plot displacement versus shift
        plot(shifts_completed_trials(current_cloud_idx),ep_displacements,[color_sigs(si) '.']);
        
        % Fit a first-order (i.e. linear) polynomial to the data
        b = polyfit(shifts_completed_trials(current_cloud_idx),ep_displacements,1);
        % Plot the fit over the range of shifts
        fitrange = [min(shifts_completed_trials(current_cloud_idx)) max(shifts_completed_trials(current_cloud_idx))];
        plot(fitrange,b(1)*fitrange+b(2),[color_sigs(si) '--']);
        
        % Create the legend and place the slope information in the legend
        lgnd{si*2-1,1}=num2str(feedback_sig_conditions(si));
        lgnd{si*2,1}=[num2str(feedback_sig_conditions(si)) ' slope: ' num2str(b(1))];
    end
    legend(lgnd);
    xlabel('Prior Lateral Shift (cm)');
    ylabel('Hand Endpoint Lateral Error (cm)');
    figtitle = [fn_prefix 'Hand Endpoint vs Shift.fig'];
    title(figtitle);
    hgsave(figtitle);
    
    
    
    % Cursor vs Shift
    figure;hold on;
    lgnd={};
    % For each feedback cloud size
    for si=1:length(feedback_sig_conditions)
        % current cloud condition value
        current_cloud_condition = feedback_sig_conditions(si);
        % pull out the trial indices for this current cloud value
        current_cloud_idx = find(feedback_sigs_completed_trials==current_cloud_condition);
        
        ep_displacements = [];
        if (targetDir == 90 || targetDir == 270)
            ep_displacements = pos_x_end(current_cloud_idx);
        elseif (targetDir == 0 || targetDir == 180)
            ep_displacements = pos_y_end(current_cloud_idx);
        else
            error('ERROR: Invalid target direction.  Must be 0, 90, 180, or 270');
            return;
        end
        % Plot displacement versus shift
        plot(shifts_completed_trials(current_cloud_idx),ep_displacements+shifts_completed_trials(current_cloud_idx),[color_sigs(si) '.']);
        
        % Fit a first-order (i.e. linear) polynomial to the data
        b = polyfit(shifts_completed_trials(current_cloud_idx),ep_displacements+shifts_completed_trials(current_cloud_idx),1);
        % Plot the fit over the range of shifts
        fitrange = [min(shifts_completed_trials(current_cloud_idx)) max(shifts_completed_trials(current_cloud_idx))];
        plot(fitrange,b(1)*fitrange+b(2),[color_sigs(si) '--']);
        
        % Create the legend and place the slope information in the legend
        lgnd{si*2-1,1}=num2str(feedback_sig_conditions(si));
        lgnd{si*2,1}=[num2str(feedback_sig_conditions(si)) ' slope: ' num2str(b(1))];
    end
    legend(lgnd);
    xlabel('Prior Lateral Shift (cm)');
    ylabel('Cursor Endpoint Lateral Error (cm)');
    figtitle = ['figs/' fn_prefix 'Cursor Endpoint vs Shift.fig'];
    title(figtitle);
    hgsave(figtitle);
    
    clear acc_x acc_y pos_x pos_y vel_x vel_y bdf;
    
    % Update the 'global' vectors
    pos_x_all = [pos_x_all pos_x_end'];
    pos_y_all = [pos_y_all pos_y_end'];
    shift_all = [shift_all shifts_completed_trials'];
    feedback_sig_all = [feedback_sig_all feedback_sigs_completed_trials'];
end

%% Global Plots (i.e. all sets)

% Endpoint vs Shift
figure;hold on;
lgnd={};
% For each feedback cloud size
for si=1:length(feedback_sig_conditions)
    % current cloud condition value
    current_cloud_condition = feedback_sig_conditions(si);
    % pull out the trial indices for this current cloud value
    current_cloud_idx = find(feedback_sig_all==current_cloud_condition);
    
    ep_displacements = [];
    if (targetDir == 90 || targetDir == 270)
        ep_displacements = pos_x_all(current_cloud_idx);
    elseif (targetDir == 0 || targetDir == 180)
        ep_displacements = pos_y_all(current_cloud_idx);
    else
        error('ERROR: Invalid target direction.  Must be 0, 90, 180, or 270');
        return;
    end
    % Plot displacement versus shift
    plot(shift_all(current_cloud_idx),ep_displacements,[color_sigs(si) '.']);
    
    % Fit a first-order (i.e. linear) polynomial to the data
    b = polyfit(shift_all(current_cloud_idx),ep_displacements,1);
    % Plot the fit over the range of shifts
    fitrange = [min(shift_all(current_cloud_idx)) max(shift_all(current_cloud_idx))];
    plot(fitrange,b(1)*fitrange+b(2),[color_sigs(si) '--']);
    
    % Create the legend and place the slope information in the legend
    lgnd{si*2-1,1}=num2str(feedback_sig_conditions(si));
    lgnd{si*2,1}=[num2str(feedback_sig_conditions(si)) ' slope: ' num2str(b(1))];
end
legend(lgnd);
xlabel('Prior Lateral Shift (cm)');
ylabel('Hand Endpoint Lateral Error (cm)');
figtitle = [fn_prefix(1:end-5) 'Hand Endpoint vs Shift.fig'];
title(figtitle);
hgsave(figtitle);



% Cursor vs Shift
figure;hold on;
lgnd={};
% For each feedback cloud size
for si=1:length(feedback_sig_conditions)
    
    % current cloud condition value
    current_cloud_condition = feedback_sig_conditions(si);
    
    % pull out the trial indices for this current cloud value
    current_cloud_idx = find(feedback_sig_all==current_cloud_condition);
    
    ep_displacements = [];
    if (targetDir == 90 || targetDir == 270)
        ep_displacements = pos_x_all(current_cloud_idx);
    elseif (targetDir == 0 || targetDir == 180)
        ep_displacements = pos_y_all(current_cloud_idx);
    else
        error('ERROR: Invalid target direction.  Must be 0, 90, 180, or 270');
        return;
    end
    % Plot displacement versus shift
    plot(shift_all(current_cloud_idx),ep_displacements+shift_all(current_cloud_idx),[color_sigs(si) '.']);
    
    % Fit a first-order (i.e. linear) polynomial to the data
    b = polyfit(shift_all(current_cloud_idx),ep_displacements+shift_all(current_cloud_idx),1);
    % Plot the fit over the range of shifts
    fitrange = [min(shift_all(current_cloud_idx)) max(shift_all(current_cloud_idx))]
    plot(fitrange,b(1)*fitrange+b(2),[color_sigs(si) '--']);
    
    % Create the legend and place the slope information in the legend
    lgnd{si*2-1,1}=num2str(feedback_sig_conditions(si));
    lgnd{si*2,1}=[num2str(feedback_sig_conditions(si)) ' slope: ' num2str(b(1))];
end
legend(lgnd);
xlabel('Prior Lateral Shift (cm)');
ylabel('Cursor Endpoint Lateral Error (cm)');
figtitle = ['figs/' fn_prefix(1:end-5) 'Cursor Endpoint vs Shift.fig'];
title(figtitle);
hgsave(figtitle);

return;
