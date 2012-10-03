function kin = un1d_extractKinematics(monkeyName, brainArea,dateStamp, fileID, targetDir, feedbackOn, extrahandleoffset)
%UN1D_EXTRACTKINEMATICS
%
%   Extracts individual movements corresponding to the trial table timing.
%
%   Returns a structure with the parsed kinematics info and other goodies.
%
%   monkeyName = string with ID used in filename, i.e. 'Jaco' or 'MrT'
%   brainArea  = string with ID used in filename, i.e. 'M1' or 'PMd' or
%   'Behavior' or 'M1sorted'
%   dateStamp  = string with datestamp used in filename, i.e. '04052012'
%   fileID     = file number i.e. 1 or 5
%   targetDir  = which direction was the target, i.e. 0, 90, 180, 270
%   feedbackOn = where does the feedback turn on?
%   extrahandleoffset = [x y];
%
%   last updated: 08/28/2012 - pwanda
%


%%
cloud_clr = ['rbgmk'];

% Use the proper offset for the animal/lab
if strcmp(monkeyName,'Mini')
    % Mini Plexon
    x_offset = -5;
    y_offset = 34;
elseif  strcmp(monkeyName,'MrT') ||  strcmp(monkeyName,'Mihili')
    % MRT Cerebus Offset
    x_offset = -2;
    y_offset = 32.5;
end

% additional offset from the uncertainty1d panel
un1d_x_offset = extrahandleoffset(1);
un1d_y_offset = extrahandleoffset(2);

%% operate over each set in the specified range

% Load bdf and trial table
sprintf('Loading bdf and trial table\n');
fn_bdf = ['bdf/bdf_' monkeyName '_' brainArea '_' dateStamp '_UN1D_00' int2str(fileID) '.mat'];
load(fn_bdf);
fn_tt  = ['tt/tt_'   monkeyName '_' brainArea '_' dateStamp '_UN1D_00' int2str(fileID) '.mat'];
load(fn_tt);
sprintf('Loading Completed\n');


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


% Load position data and correct for the offsets
pos_x = bdf.pos(:,2)+x_offset-un1d_x_offset;
pos_y = bdf.pos(:,3)+y_offset-un1d_y_offset;

% Load velocity data
vel_x = bdf.vel(:,2);
vel_y = bdf.vel(:,3);

% Load acceleration data
acc_x = bdf.acc(:,2);
acc_y = bdf.acc(:,3);

% The time stamps for each kinematic sample
kin_ts = bdf.pos(:,1);

%% Pull timing information from the trial table (corresponds to databurst)
trial_shifts       = tt(:,2);    % shift values for each trial
trial_feedback_sig = tt(:,3);    % feedback condition for each trial
center_ts          = tt(:,4);    % timestamp of center target on
outer_ts           = tt(:,5);    % timestamp of center target on
go_ts              = tt(:,6);    % timestamp of go cue
end_ts             = tt(:,7);    % timestamp of trial complete
end_codes          = tt(:,8);    % code for trial complete
% R 32   A 33   F 34   I 35    Other NaN

%% Only process "COMPLETED" trials
% Find the trials where the outcome was REWARD and FAIL
% Abort and Incomplete trials are excluded from this analysis
complete_trials_code_idx = find(end_codes==32 | end_codes == 34);

% information for completed trials
shifts_complete_trials            = trial_shifts(complete_trials_code_idx);
feedback_sigs_complete_trials     = trial_feedback_sig(complete_trials_code_idx);
end_ts_complete_trials            = end_ts(complete_trials_code_idx);
end_codes_complete_trials         = end_codes(complete_trials_code_idx);

% pull out the indices from the trial kinematics that correspond
% to the timestamps for the state codes (only for Completed Trials)
kin_end_complete_trials_idx = [];
for ri=1:length(end_ts_complete_trials)
    kin_end_complete_trials_idx(ri) = find(kin_ts<=end_ts_complete_trials(ri),1,'last');
end

kin_center_complete_trials_idx = [];
for ri=1:length(end_ts_complete_trials)
    center_ts_complete_trials(ri) = center_ts(find(center_ts<=end_ts_complete_trials(ri),1,'last'));
    kin_center_complete_trials_idx(ri) = find(kin_ts<=center_ts_complete_trials(ri),1,'last');
end

kin_outer_complete_trials_idx = [];
for ri=1:length(end_ts_complete_trials)
    outer_ts_complete_trials(ri) = outer_ts(find(outer_ts<=end_ts_complete_trials(ri),1,'last'));
    kin_outer_complete_trials_idx(ri) = find(kin_ts<=outer_ts_complete_trials(ri),1,'last');
end

kin_go_complete_trials_idx=[];
for ri=1:length(end_ts_complete_trials)
    go_ts_complete_trials(ri) = go_ts(find(go_ts<=end_ts_complete_trials(ri),1,'last'));
    kin_go_complete_trials_idx(ri) = find(kin_ts<= go_ts_complete_trials(ri),1,'last');
end

% position at GO
pos_x_go = pos_x(kin_go_complete_trials_idx);
pos_y_go = pos_y(kin_go_complete_trials_idx);

vel_x_go = vel_x(kin_go_complete_trials_idx);
vel_y_go = vel_y(kin_go_complete_trials_idx);

acc_x_go = acc_x(kin_go_complete_trials_idx);
acc_y_go = acc_y(kin_go_complete_trials_idx);


% position at REWARD OR FAIL
pos_x_comp = pos_x(kin_end_complete_trials_idx);
pos_y_comp = pos_y(kin_end_complete_trials_idx);

vel_x_comp = vel_x(kin_end_complete_trials_idx);
vel_y_comp = vel_y(kin_end_complete_trials_idx);

acc_x_comp = acc_x(kin_end_complete_trials_idx);
acc_y_comp = acc_y(kin_end_complete_trials_idx);


MAXSAMPLES = 5000;


ts_kin   =NaN*ones(length(kin_go_complete_trials_idx),MAXSAMPLES);
pos_kin_x=NaN*ones(length(kin_go_complete_trials_idx),MAXSAMPLES);
pos_kin_y=NaN*ones(length(kin_go_complete_trials_idx),MAXSAMPLES);
vel_kin_x=NaN*ones(length(kin_go_complete_trials_idx),MAXSAMPLES);
vel_kin_y=NaN*ones(length(kin_go_complete_trials_idx),MAXSAMPLES);
speed_kin=NaN*ones(length(kin_go_complete_trials_idx),MAXSAMPLES);
acc_kin_x=NaN*ones(length(kin_go_complete_trials_idx),MAXSAMPLES);
acc_kin_y=NaN*ones(length(kin_go_complete_trials_idx),MAXSAMPLES);

% pull out kinectories
for ri=1:length(kin_end_complete_trials_idx)
    tlength=kin_end_complete_trials_idx(ri)-kin_outer_complete_trials_idx(ri)+1;
    if(tlength<=MAXSAMPLES)
        ts_kin(ri,1:tlength)    = kin_ts(kin_outer_complete_trials_idx(ri):kin_end_complete_trials_idx(ri));
        pos_kin_x(ri,1:tlength) = pos_x(kin_outer_complete_trials_idx(ri):kin_end_complete_trials_idx(ri));
        pos_kin_y(ri,1:tlength) = pos_y(kin_outer_complete_trials_idx(ri):kin_end_complete_trials_idx(ri));
        vel_kin_x(ri,1:tlength) = vel_x(kin_outer_complete_trials_idx(ri):kin_end_complete_trials_idx(ri));
        vel_kin_y(ri,1:tlength) = vel_y(kin_outer_complete_trials_idx(ri):kin_end_complete_trials_idx(ri));
        acc_kin_x(ri,1:tlength) = acc_x(kin_outer_complete_trials_idx(ri):kin_end_complete_trials_idx(ri));
        acc_kin_y(ri,1:tlength) = acc_y(kin_outer_complete_trials_idx(ri):kin_end_complete_trials_idx(ri));
    end
    clear tlength;
end

speed_kin = sqrt(vel_kin_x.^2+vel_kin_y.^2);

for ri=1:length(kin_end_complete_trials_idx)
    tlength=kin_end_complete_trials_idx(ri)-kin_outer_complete_trials_idx(ri)+1;

    if(tlength<=MAXSAMPLES)
        z = find(pos_kin_y(ri,1:tlength)<= feedbackOn, 1, 'last');
        if ~isempty(z)
            cloud_idx(ri) = z;
            pos_x_cloud(ri) = pos_kin_x(ri,cloud_idx(ri));
            pos_y_cloud(ri) = pos_kin_y(ri,cloud_idx(ri));
            ts_cloud(ri)    = ts_kin(ri,cloud_idx(ri));
            
        else
            cloud_idx(ri) = NaN;
            pos_x_cloud(ri) = NaN;
            pos_y_cloud(ri) = NaN;
            ts_cloud(ri) = NaN;
        end
    end
    clear tlength;
end


kin.meta.monkeyName = monkeyName;
kin.meta.brainArea = brainArea;
kin.meta.dateStamp = dateStamp;
kin.meta.fileID = fileID;
kin.meta.un1d_origin_offset = extrahandleoffset;

kin.targetDirection = targetDir;
kin.cloudPosition = feedbackOn;
kin.ts = ts_kin;
kin.pos_x = pos_kin_x;
kin.pos_y = pos_kin_y;
kin.vel_x = vel_kin_x;
kin.vel_y = vel_kin_y;
kin.acc_x = acc_kin_x;
kin.acc_y = acc_kin_y;
kin.speed = speed_kin;
kin.pos_x_go = pos_x_go;
kin.pos_y_go = pos_y_go;
kin.pos_x_cloud = pos_x_cloud';
kin.pos_y_cloud = pos_y_cloud';
kin.pos_x_end = pos_x_comp;
kin.pos_y_end = pos_y_comp;

kin.center_ts       = center_ts_complete_trials';
kin.outer_ts        = outer_ts_complete_trials';
kin.go_ts           = go_ts_complete_trials';
kin.cloud_on_ts     = ts_cloud';
kin.endpoint_ts     = end_ts_complete_trials;
kin.endcode_by_trial= end_codes_complete_trials;
kin.visualShift     = shifts_complete_trials;
kin.cloudVar  = feedback_sigs_complete_trials;


return;
