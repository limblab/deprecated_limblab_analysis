function kin = un1d_extractKinematics(bdf,tt, targetDir, feedbackOn, extrahandleoffset)
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
%   feedbackOn = where does the feedback turn on? (i.e. 4cm)
%   extrahandleoffset = [x y]; from the uncertainty panel
%
%   last updated: 10/15/2012 - pwanda
%


%%

% Time in seconds to buffer kinematics data on either side of the trial
timebuffer = 0.500;

% Extract just the filename from a bdf
filename=filenameFromBDF(bdf);

% Extract other information from the filename
[monkeyName rm] = strtok(filename,'_');
[brainArea  rm] = strtok(rm,'_');
[dateStamp   rm] = strtok(rm,'_');
[taskCode   rm] = strtok(rm,'_');

% Use the proper offset for the animal/lab
if strcmp(monkeyName,'Mini')
    % Mini Plexon
    x_offset = -5;
    y_offset = 34;
    [fileID rm] = str2num(strtok(rm(2:end),'.plx'));
elseif  strcmp(monkeyName,'MrT') ||  strcmp(monkeyName,'Mihili')
    % MRT Cerebus Offset
    x_offset = -2;
    y_offset = 32.5;
    [fileID rm] = str2num(strtok(rm(2:end),'.nev'));
end

% additional offset from the uncertainty1d panel
un1d_x_offset = extrahandleoffset(1);
un1d_y_offset = extrahandleoffset(2);

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
trial_feedback_var = tt(:,3);    % feedback condition for each trial
center_ts          = tt(:,4);    % timestamp of center target on
outer_ts           = tt(:,5);    % timestamp of center target on
go_ts              = tt(:,6);    % timestamp of go cue
end_ts             = tt(:,7);    % timestamp of trial complete
end_codes          = tt(:,8);    % code for trial complete
% R 32   A 33   F 34   I 35    Other NaN

%% Only process "COMPLETED" trials
% Find the trials where the outcome was REWARD and FAIL
% Abort and Incomplete trials are excluded from this analysis
completed_trials_code_idx = find(end_codes==32 | end_codes == 34);

% information for completed trials
shifts_completed_trials            = trial_shifts(completed_trials_code_idx);
feedback_var_completed_trials     = trial_feedback_var(completed_trials_code_idx);
end_ts_completed_trials            = end_ts(completed_trials_code_idx);
end_codes_completed_trials         = end_codes(completed_trials_code_idx);

% pull out the indices from the trial kinematics that correspond
% to the timestamps for the state codes (only for Completed Trials)
kin_end_completed_trials_idx      = [];
kin_endbuffer_completed_trials_idx = [];
for ri=1:length(end_ts_completed_trials)
    kin_end_completed_trials_idx(ri) = find(kin_ts<=end_ts_completed_trials(ri),1,'last');
    kin_endbuffer_completed_trials_idx(ri) = find(kin_ts<=(end_ts_completed_trials(ri)+timebuffer),1,'last');
end

kin_center_completed_trials_idx = [];
for ri=1:length(end_ts_completed_trials)
    center_ts_completed_trials(ri) = center_ts(find(center_ts<=end_ts_completed_trials(ri),1,'last'));
    kin_center_completed_trials_idx(ri) = find(kin_ts<=center_ts_completed_trials(ri),1,'last');
end

kin_outer_completed_trials_idx = [];
kin_outerbuffer_completed_trials_idx = [];
for ri=1:length(end_ts_completed_trials)
    outer_ts_completed_trials(ri) = outer_ts(find(outer_ts<=end_ts_completed_trials(ri),1,'last'));
    kin_outer_completed_trials_idx(ri) = find(kin_ts<=outer_ts_completed_trials(ri),1,'last');
    kin_outerbuffer_completed_trials_idx(ri) = find(kin_ts<=(outer_ts_completed_trials(ri)-timebuffer),1,'last');
end

kin_go_completed_trials_idx=[];
for ri=1:length(end_ts_completed_trials)
    go_ts_completed_trials(ri) = go_ts(find(go_ts<=end_ts_completed_trials(ri),1,'last'));
    kin_go_completed_trials_idx(ri) = find(kin_ts<= go_ts_completed_trials(ri),1,'last');
end

% position at GO
pos_x_go = pos_x(kin_go_completed_trials_idx);
pos_y_go = pos_y(kin_go_completed_trials_idx);

vel_x_go = vel_x(kin_go_completed_trials_idx);
vel_y_go = vel_y(kin_go_completed_trials_idx);

acc_x_go = acc_x(kin_go_completed_trials_idx);
acc_y_go = acc_y(kin_go_completed_trials_idx);


% position at REWARD OR FAIL
pos_x_comp = pos_x(kin_end_completed_trials_idx);
pos_y_comp = pos_y(kin_end_completed_trials_idx);

vel_x_comp = vel_x(kin_end_completed_trials_idx);
vel_y_comp = vel_y(kin_end_completed_trials_idx);

acc_x_comp = acc_x(kin_end_completed_trials_idx);
acc_y_comp = acc_y(kin_end_completed_trials_idx);


MAXSAMPLES = 5000+timebuffer*2*1000;


ts_kin   =NaN*ones(length(kin_go_completed_trials_idx),MAXSAMPLES);
pos_kin_x=NaN*ones(length(kin_go_completed_trials_idx),MAXSAMPLES);
pos_kin_y=NaN*ones(length(kin_go_completed_trials_idx),MAXSAMPLES);
vel_kin_x=NaN*ones(length(kin_go_completed_trials_idx),MAXSAMPLES);
vel_kin_y=NaN*ones(length(kin_go_completed_trials_idx),MAXSAMPLES);
speed_kin=NaN*ones(length(kin_go_completed_trials_idx),MAXSAMPLES);
acc_kin_x=NaN*ones(length(kin_go_completed_trials_idx),MAXSAMPLES);
acc_kin_y=NaN*ones(length(kin_go_completed_trials_idx),MAXSAMPLES);

% pull out kinectories
for ri=1:length(kin_end_completed_trials_idx)
    tlength=kin_endbuffer_completed_trials_idx(ri)-kin_outerbuffer_completed_trials_idx(ri)+1;
    if(tlength<=MAXSAMPLES)
        ts_kin(ri,1:tlength)    = kin_ts(kin_outerbuffer_completed_trials_idx(ri):kin_endbuffer_completed_trials_idx(ri));
        pos_kin_x(ri,1:tlength) = pos_x(kin_outerbuffer_completed_trials_idx(ri):kin_endbuffer_completed_trials_idx(ri));
        pos_kin_y(ri,1:tlength) = pos_y(kin_outerbuffer_completed_trials_idx(ri):kin_endbuffer_completed_trials_idx(ri));
        vel_kin_x(ri,1:tlength) = vel_x(kin_outerbuffer_completed_trials_idx(ri):kin_endbuffer_completed_trials_idx(ri));
        vel_kin_y(ri,1:tlength) = vel_y(kin_outerbuffer_completed_trials_idx(ri):kin_endbuffer_completed_trials_idx(ri));
        acc_kin_x(ri,1:tlength) = acc_x(kin_outerbuffer_completed_trials_idx(ri):kin_endbuffer_completed_trials_idx(ri));
        acc_kin_y(ri,1:tlength) = acc_y(kin_outerbuffer_completed_trials_idx(ri):kin_endbuffer_completed_trials_idx(ri));
    end
    clear tlength;
end

speed_kin = sqrt(vel_kin_x.^2+vel_kin_y.^2);

for ri=1:length(kin_end_completed_trials_idx)
    tlength=kin_endbuffer_completed_trials_idx(ri)-kin_outerbuffer_completed_trials_idx(ri)+1;
    
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


kin.meta.fileName = filename;
kin.meta.monkeyName = monkeyName;
kin.meta.brainArea = brainArea;
kin.meta.dateStamp = dateStamp;
kin.meta.taskCode = taskCode;
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

kin.center_ts       = center_ts_completed_trials';
kin.outer_ts        = outer_ts_completed_trials';
kin.go_ts           = go_ts_completed_trials';
kin.cloud_on_ts     = ts_cloud';
kin.endpoint_ts     = end_ts_completed_trials;
kin.endcode_by_trial= end_codes_completed_trials;
kin.visualShift     = shifts_completed_trials;
kin.cloudVar  = feedback_var_completed_trials;
kin.endbuffer = timebuffer;


% numMoves = size(kin.ts,1);
% for mi=1:numMoves
%     prange = [1:find(isnan(kin.pos_x(mi,:))==1,1,'first')];
%     [pks2, locs2] = findpeaks(-kin.speed(mi,prange),'MINPEAKHEIGHT',-15);
%     minl = locs2(find(kin.pos_y(mi,locs2)>=kin.cloudPosition,1,'first'));
%     minsp = -pks2(find(kin.pos_y(mi,locs2)>=kin.cloudPosition,1,'first'));
%     if isempty(minl)
%         minloc_idx(mi) =NaN;
%         minloc_pos_x(mi) =NaN;
%         minloc_pos_y(mi) =NaN;
%         minspeed(mi)=NaN;
%     else
%         minloc_idx(mi) = minl;
%         minloc_plus_idx(mi)=minl+TSH;
%         minloc_pos_x(mi) = kin.pos_x(mi,   minloc_idx(mi));
%         minloc_pos_y(mi) =kin.pos_y(mi,   minloc_idx(mi));
%         minspeed(mi)=minsp;
%     end
% end
% 
% kin.pos_x_minspeed = minloc_pos_x';
% kin.pos_y_minspeed = minloc_pos_y';
% kin.idx_minspeed = minloc_idx';

return;
