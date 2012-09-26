function h = un1d_adaptAngles(mode, monkeyName, brainArea, dateStamp, setRange, targetDir, startTrial, cutoff)
%UN1D_ADAPTANGLES Generates Nature 2004-style plots a la Kording and Wolpert.
%   Plots of Angle of Adaptation versus Shift, separated by likelihood conditions.
%   Loads a .bdf file from a directory named 'bdf'
%   and corresponding trial table .mat file from directory named 'tt'
%   Requires proper naming convention to work. (use getBDF and getTT)
%   Note: If file is plotting trajectories, search for 'DEBUG' and comment out
%   the plotting loop.
%
%
%   INPUTS (all required):
%   mode =  0 --> constant time cutoff before endpoint
%           1 --> constant distance cutoff before endpoint
%           2 --> (not yet implemented) use peak-speed based metric to 
%                 calculate angle
%   monkeyName = string with ID used in filename, i.e. 'Jaco' or 'MrT'
%   brainArea  = string with ID used in filename, i.e. 'M1' or 'PMd' or
%                                                      'Behavior'
%   dateStamp  = string with datestamp used in filename, i.e. '04052012'
%   setRange   = sets/file numbers to operate on, i.e. [2 4 5]
%   targetDir  = deg direction in which the outer target drawn, i.e. 90
%   startTrial = trial number in the set from which to begin analysis
%                 (set value to 1 to use whole set of movements)
%   cutoff = (mode 0) time prior to movement end time from which to
%               calculate the angle of adaptation
%            (mode 1) distance prior to end position from which to
%               calculate the angle of adaptation
%            (mode 2) this value is ignored
%
%   last updated: 09/17/2012 - pwanda
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
% % Mini Plexon
% x_offset = -5;
% y_offset = 34;

% Mr. T Cerebus Offset
x_offset = -2;
y_offset = 32.5;

%% Operate over each set in the specified range
for si=1:length(setRange)

    % Load bdf and trial table for first set
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
    dtb_ts =  tt(startTrial:end,1);    % databurst timestamps
    dtb_shifts =  tt(startTrial:end,2);    % shift values for each trial
    dtb_feedback_sig =  tt(startTrial:end,3);    % feedback condition for each trial
    dtb_centeron_ts =     tt(startTrial:end,4);    % timestamp of center target
    dtb_outeron_ts = tt(startTrial:end,5);          % timestamp of target drawn
    dtb_gocue_ts = tt(startTrial:end,6);            % timestamp of go cue
    dtb_endcode_ts = tt(startTrial:end,7);           % timestamp of trial complete
    dtb_end_codes = tt(startTrial:end,8);        % code for trial complete
 
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
    
    kin_ang_completed_idx = [];
    for ri=1:length(dtb_endcode_ts_completed_trials)   
        % if using a preceding time from endpoint...
        if mode ==0
            kin_ang_completed_idx(ri) = find(kin_ts<dtb_endcode_ts_completed_trials(ri)-cutoff,1,'last');
        % if using a preceding distance from endpoint
        elseif mode ==1
            if targetDir==90
                tmp(ri) = find(pos_y(kin_go_completed_idx(ri):kin_end_completed_idx(ri))< (pos_y(kin_end_completed_idx(ri))-cutoff),1,'last');
                kin_ang_completed_idx(ri) = kin_go_completed_idx(ri)+tmp(ri)-1;
            elseif targetDir==270
                tmp(ri) = find(pos_y(kin_go_completed_idx(ri):kin_end_completed_idx(ri))< (pos_y(kin_end_completed_idx(ri))+cutoff),1,'last');
                kin_ang_completed_idx(ri) = kin_go_completed_idx(ri)+tmp(ri)-1;
            elseif targetDir==0
                tmp(ri) = find(pos_x(kin_go_completed_idx(ri):kin_end_completed_idx(ri))< (pos_x(kin_end_completed_idx(ri))-cutoff),1,'last');
                kin_ang_completed_idx(ri) = kin_go_completed_idx(ri)+tmp(ri)-1;
            elseif targetDir==180
                tmp(ri) = find(pos_x(kin_go_completed_idx(ri):kin_end_completed_idx(ri))< (pos_x(kin_end_completed_idx(ri))+cutoff),1,'last');
                kin_ang_completed_idx(ri) = kin_go_completed_idx(ri)+tmp(ri)-1;                
            end
        end
	end

    % position at GO
    pos_x_go = pos_x(kin_go_completed_idx);
    pos_y_go = pos_y(kin_go_completed_idx);
    
    % position at REWARD OR FAIL    
    pos_x_end = pos_x(kin_end_completed_idx);
    pos_y_end = pos_y(kin_end_completed_idx);
 
    % position used for calculating adaptation angle
    pos_x_ang = pos_x(kin_ang_completed_idx);
    pos_y_ang = pos_y(kin_ang_completed_idx);
    
    % DEBUG: plot trajectory with angles and positions used for calc.
    for ri=1:length(kin_go_completed_idx)
        figure(1000);        
        plot(pos_x(kin_go_completed_idx(ri):kin_end_completed_idx(ri)),pos_y(kin_go_completed_idx(ri):kin_end_completed_idx(ri)));
        hold on;
        plot(pos_x_go(ri),pos_y_go(ri),'rs');
        plot(pos_x_ang(ri),pos_y_ang(ri),'bo');
        plot(pos_x_end(ri),pos_y_end(ri),'gs');
        hold off;
        axis([-8 8 -8 8]);
        theta_tmp = targetDir/180*pi-atan2(pos_y_end(ri)-pos_y_ang(ri), pos_x_end(ri)-pos_x_ang(ri));
        title(['adaptation angle (wrto 90deg): ' num2str(theta_tmp/pi*180)]);
        pause;
    end

    %% Plots
    % Angle of Adaptation vs Shift
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
        theta_displacements = targetDir-180*atan2(pos_y_end(current_cloud_idx)-pos_y_ang(current_cloud_idx), pos_x_end(current_cloud_idx)-pos_x_ang(current_cloud_idx))/pi;

        % Plot displacement versus shift
        plot(shifts_completed_trials(current_cloud_idx),theta_displacements,[color_sigs(si) '.']);

        % Fit a first-order (i.e. linear) polynomial to the data
        b = polyfit(shifts_completed_trials(current_cloud_idx),theta_displacements,1);
        % Plot the fit over the range of shifts
        fitrange = [min(shifts_completed_trials(current_cloud_idx)) max(shifts_completed_trials(current_cloud_idx))];
        plot(fitrange,b(1)*fitrange+b(2),[color_sigs(si) '--']);
        
        % Create the legend and place the slope information in the legend
        lgnd{si*2-1,1}=num2str(feedback_sig_conditions(si));
        lgnd{si*2,1}=[num2str(feedback_sig_conditions(si)) ' slope: ' num2str(b(1))];
    end
    legend(lgnd);
    xlabel('Prior Lateral Shift (cm)');
    ylabel('Angle of Adaptation (rad)');
    figtitle = [fn_prefix 'Adaptive Angle vs Shift.fig'];
    title(figtitle);
    hgsave(figtitle);
 
    clear acc_x acc_y pos_x pos_y vel_x vel_y bdf; 
    
        % Update the 'global' vectors
    pos_x_all = [pos_x_all pos_x_end'];
    pos_y_all = [pos_y_all pos_y_end'];
    shift_all = [shift_all shifts_completed_trials'];
    feedback_sig_all = [feedback_sig_all feedback_sigs_completed_trials'];
end

return;
