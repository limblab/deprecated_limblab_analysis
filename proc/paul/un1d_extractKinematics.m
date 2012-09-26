function traj = un1d_extractKinematics(monkeyName, brainArea,dateStamp, setR, targetDir, midMove)
%UN1D_PULLKINEMATICS
%
%   extracts individual movements corresponding to the trial table timing
%   returns a .mat with the individual trajectories, velocities,
%   acceleration data, and a combined trial table for all the files
%
%   monkeyName = string with ID used in filename, i.e. 'Jaco' or 'MrT'
%   brainArea  = string with ID used in filename, i.e. 'M1' or 'PMd' or
%   'Behavior'
%   dateStamp  = string with datestamp used in filename, i.e. '04052012'
%   setRange   = vector with file numbers, i.e. [1 2 4 5]
%   targetDir  = which direction was the target, i.e. 0, 90, 180, 270
%
%   last updated: 08/14/2012 - pwanda
%

%% Initialize
close all;
color_sigs = ['rbgmk'];

% Vectors used to accumulate total data across all sets in the range
pos_x_all = [];         % x position all trials
pos_y_all = [];         % y position all trials
shift_all = [];         % prior shift all trials
feedback_sig_all = [];  % feedback (dot) condition all trials

% % Mini Plexon Offsets
% x_offset = -5;
% y_offset = 34;

% MRT Cerebus Offset
x_offset = -2;
y_offset = 32.5;

other_x_offset = 0;
other_y_offset = 7;

%% operate over each set in the specified range

% Load bdf and trial table for first set
fn_bdf = ['bdf/bdf_' monkeyName '_' brainArea '_' dateStamp '_UN1D_00' int2str(setR) '.mat'];
fn_tt  = ['tt/tt_'   monkeyName '_' brainArea '_' dateStamp '_UN1D_00' int2str(setR) '.mat'];
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



%
%%Load data
%
% Load position data and correct for center offset
pos_x = bdf.pos(:,2)+x_offset+other_x_offset;
pos_y = bdf.pos(:,3)+y_offset+other_y_offset;

% Load velocity data
vel_x = bdf.vel(:,2);
vel_y = bdf.vel(:,3);

% Load acceleration data
acc_x = bdf.acc(:,2);
acc_y = bdf.acc(:,3);

% The timer for each kinematic sample
kin_ts = bdf.pos(:,1);

%% Pull timing information from the trial table (corresponds to databurst)

trial_dtb_ts       = tt(:,1);    % databurst timestamps
trial_shifts       = tt(:,2);    % shift values for each trial
trial_feedback_sig = tt(:,3);    % feedback condition for each trial
center_ts          = tt(:,4);    % timestamp of center target on
targ_ts            = tt(:,5);    % timestamp of outer target on
go_ts              = tt(:,6);    % timestamp of go cue
end_ts             = tt(:,7);    % timestamp of trial complete
end_codes          = tt(:,8);    % code for trial complete
% R 32   A 33   F 34   I 35    Other NaN

% Extract the unique feedback conditions (cloud sizes)
feedback_sig_conditions = unique(trial_feedback_sig(find(isnan(trial_feedback_sig)==0)));


%% Only process "COMPLETED" trials
% Find the trials where the outcome was REWARD and FAIL
% Abort and Incomplete trials are excluded from this analysis
complete_trials_code_idx = find(end_codes==32 | end_codes == 34);

% information for completed trials
shifts_complete_trials            = trial_shifts(complete_trials_code_idx);
feedback_sigs_complete_trials     = trial_feedback_sig(complete_trials_code_idx);
end_ts_complete_trials            = end_ts(complete_trials_code_idx);
end_codes_complete_trials         = end_codes(complete_trials_code_idx);

% pull out the indices for the kinematics vectors that correspond
% to the timestamps for the state codes
kin_center_idx = [];
for ri=1:length(center_ts)
    kin_center_idx(ri) = find(kin_ts<center_ts(ri),1,'last');
end

moved_ts = go_ts(~isnan(go_ts)); % make sure the go cue was given (bug)
kin_go_idx=[];
for ri=1:length(moved_ts)
    kin_go_idx(ri) = find(kin_ts<moved_ts(ri),1,'last');
end

kin_complete_trials_idx = [];
for ri=1:length(end_ts_complete_trials)
    kin_complete_trials_idx(ri) = find(kin_ts<end_ts_complete_trials(ri),1,'last');
end

% position at GO
pos_x_go = pos_x(kin_go_idx);
pos_y_go = pos_y(kin_go_idx);

vel_x_go = vel_x(kin_go_idx);
vel_y_go = vel_y(kin_go_idx);

acc_x_go = acc_x(kin_go_idx);
acc_y_go = acc_y(kin_go_idx);


% position at REWARD OR FAIL
pos_x_comp = pos_x(kin_complete_trials_idx);
pos_y_comp = pos_y(kin_complete_trials_idx);

vel_x_comp = vel_x(kin_complete_trials_idx);
vel_y_comp = vel_y(kin_complete_trials_idx);

acc_x_comp = acc_x(kin_complete_trials_idx);
acc_y_comp = acc_y(kin_complete_trials_idx);



% pull out trajectories
ts_traj = NaN*ones(length(kin_go_idx),4000);
pos_traj_x=NaN*ones(length(kin_go_idx),4000);
pos_traj_y=NaN*ones(length(kin_go_idx),4000);
vel_traj_x=NaN*ones(length(kin_go_idx),4000);
vel_traj_y=NaN*ones(length(kin_go_idx),4000);
acc_traj_x=NaN*ones(length(kin_go_idx),4000);
acc_traj_y=NaN*ones(length(kin_go_idx),4000);
for ri=1:length(kin_go_idx)
    if((1+kin_complete_trials_idx(ri)-kin_go_idx(ri))<4000)
        ts_traj(ri,1:(1+kin_complete_trials_idx(ri)-kin_go_idx(ri)))=kin_ts(kin_go_idx(ri):kin_complete_trials_idx(ri));
        pos_traj_x(ri,1:(1+kin_complete_trials_idx(ri)-kin_go_idx(ri)))=pos_x(kin_go_idx(ri):kin_complete_trials_idx(ri));
        pos_traj_y(ri,1:(1+kin_complete_trials_idx(ri)-kin_go_idx(ri)))=pos_y(kin_go_idx(ri):kin_complete_trials_idx(ri));
        vel_traj_x(ri,1:(1+kin_complete_trials_idx(ri)-kin_go_idx(ri)))=vel_x(kin_go_idx(ri):kin_complete_trials_idx(ri));
        vel_traj_y(ri,1:(1+kin_complete_trials_idx(ri)-kin_go_idx(ri)))=vel_y(kin_go_idx(ri):kin_complete_trials_idx(ri));
        acc_traj_x(ri,1:(1+kin_complete_trials_idx(ri)-kin_go_idx(ri)))=acc_x(kin_go_idx(ri):kin_complete_trials_idx(ri));
        acc_traj_y(ri,1:(1+kin_complete_trials_idx(ri)-kin_go_idx(ri)))=acc_y(kin_go_idx(ri):kin_complete_trials_idx(ri));
        
    end
end

for ri=1:length(kin_go_idx)
    z = find(pos_traj_y(ri,:)< pos_y_comp(ri)-midMove,1,'last');
    if ~isempty(z)
        mid_idx(ri) = z;
        pos_x_mid(ri) = pos_traj_x(ri,mid_idx(ri));
        pos_y_mid(ri) = pos_traj_y(ri,mid_idx(ri));
        
    else
        mid_idx(ri) = NaN;
        pos_x_mid(ri) = NaN;
        pos_y_mid(ri) = NaN;
        
    end
end

traj.ts = ts_traj;
traj.pos_x = pos_traj_x;
traj.pos_y = pos_traj_y;
traj.vel_x = vel_traj_x;
traj.vel_y = vel_traj_y;
traj.acc_x = acc_traj_x;
traj.acc_y = acc_traj_y;
traj.pos_x_comp = pos_x_comp;
traj.pos_y_comp = pos_y_comp;
traj.pos_x_mid = pos_x_mid';
traj.pos_y_mid = pos_y_mid';
traj.pos_x_go = pos_x_go;
traj.pos_y_go = pos_y_go;

traj.go_ts = moved_ts;
traj.end_ts = end_ts_complete_trials;
traj.shifts = shifts_complete_trials;
traj.feedback = feedback_sigs_complete_trials;


return;
