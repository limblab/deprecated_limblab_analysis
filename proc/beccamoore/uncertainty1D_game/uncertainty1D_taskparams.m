%untarget_taskparams

DEBUGMODE=1;























%%
%
%e
%  Parameter File
%
%

%% Global parameters
current_subject_ID = 'test';
% Data Source
useMouse = true; % true -> use Mouse; false -> use Optotrak

% Gamemode constants (used for task state loop)
gamemode.PRETRIAL     = 100;
gamemode.CENTER_DRAW  = 200;
gamemode.CENTER_HOLD  = 300;
gamemode.CENTER_DELAY = 400;
gamemode.MOVEMENT     = 500;
gamemode.TARGET_HOLD  = 600;
gamemode.REWARD       = 700;
gamemode.FAIL         = 701;
gamemode.ABORT        = 702;
gamemode.INCOMPLETE   = 703;

%% Calibration parameters

% Mouse Calibration Parameters
cal.cal_size     = 0.005; % size of calibration targets (in m)
cal.caltest_time = 1; % time to test calibration in seconds

% The marker to metric conversion
% This needs to be measured manually
% On the optotrak screen: marker size 10 has diameter of 0.01
cal.marker2m = 0.01/10;
cal.m2marker = 1/cal.marker2m;

%% Task Parameters

% Graphics parameters
params.bg_color            = [0.2 0.2 0.2];
params.targetbar_color     = [0.4 0.4 0.4];
params.targetbar_onoff     = false;

params.axis_x = 1.25;
params.axis_y = 1.25;

%% Target slice Parameters

params.slice_color         = 'c';
params.slice_num           = 7;            % number of target slices
params.slice_size          = 1/params.slice_num; % width of slice as percentage of true target size
params.slice_std           = [0.01 0.03]; % standard deviation of slice locations in m
params.slice_std_baseline  = geomean(params.slice_std);
params.slice_ratio         = [1 1];       % ratio of each target condition
params.slice_num_types     = length(params.slice_std);

params.slice_trigger_location = 0.04;
params.slice_duration = 0.400;

%% Timed Cursor cloud Parameters

params.cloud_color         = 'y';
params.cloud_num           = 7;            % number of dots in cloud
params.cloud_size          = 0.0025; % width of dot as percentage of true cursor size
params.cloud_std           = [0.01 0.03]; % standard deviation of dot locations in m
params.cloud_std_baseline  = geomean(params.cloud_std);
params.cloud_ratio         = [1 1];       % ratio of each cloud condition
params.cloud_num_types     = length(params.cloud_std);

params.cloud_trigger_location = 0.04;
params.cloud_duration = 0.400;

%% Other Parameters

% Outer Target
params.target_location     = pi/2; % only use 0, pi/2, pi, 3*pi/2 for now....
params.target_radius       = 0.10; % in m
params.target_size         = 0.015; % in m
params.target_color_reward = 'g';
params.target_color_fail   = 'r';
params.target_color = 'r';

% Center Target
params.center_size      = 0.015; % in m
params.center_color     = 'r';

% Cursor
params.cursor_size      = 0.005;  % in m
params.cursor_color     = 'y';

% These two parameters determine where the true cursor is hidden
params.block_window_start       = 0.00;
params.block_window_end         = params.target_radius*2;

% These two parameters determine where the true cursor is hidden pretrial
params.pretrial_block_window_start       = params.target_radius/3;
params.pretrial_block_window_end         = params.target_radius*2;


%% Timer parameters (in seconds)

% time bounds to hold cursor on center before target shown
params.center_hold_timeout_low    = 0.40;  
params.center_hold_timeout_high   = 0.60;

% time bounds to wait before moving with target displayed
params.center_delay_timeout_low   = 0.4;
params.center_delay_timeout_high  = 0.6;

% time bounds to hold on target for success
params.target_hold_timeout_low    = 0.0;
params.target_hold_timeout_high   = 0.0;

params.movement_timeout           = 2;   % maximum trial time
params.intertrial_interval        = 1; % time end position is shown
                                         % time before center is shown after success
params.failure_penalty            = 0.0; % extra timeout for failed trials
params.warning_time               = 0.5; % extra timeout for text warnings

%% Block Parameters

% Blocks Types
% Main game code implements different conditions for each block type
% UncertaintyTargets
%
%  0 baseline reach task
%  1 target timed task
%  2 cursor timed task
%  3 cursor continuous task
%
blocks{1}.type = 3;
blocks{2}.type = 3;
blocks{3}.type = 2;
blocks{4}.type = 1;
blocks{5}.type = 2;
blocks{6}.type = 1;

% Visibility of target, excl. feedback, in the block
%  0 -> target always off
%  1 -> target always on
blocks{1}.target_vis = 0;
blocks{2}.target_vis = 0;
blocks{3}.target_vis = 0;
blocks{4}.target_vis = 0;
blocks{5}.target_vis = 0;
blocks{6}.target_vis = 0;

% Visibility of cursor, excl. feedback, in the block
%  0 -> cursor always off
%  1 -> cursor always on
blocks{1}.cursor_vis=1;
blocks{2}.cursor_vis=0;
blocks{3}.cursor_vis=0;
blocks{4}.cursor_vis=0;
blocks{5}.cursor_vis=0;
blocks{6}.cursor_vis=0;

% Blocks: target shift mean (in m)
blocks{1}.pert_mean = 0;
blocks{2}.pert_mean = 0.025;
blocks{3}.pert_mean = 0.025;
blocks{4}.pert_mean = -0.025;
blocks{5}.pert_mean = 0.025;
blocks{6}.pert_mean = -0.025;

% Blocks: std of perturbation (in m)
blocks{1}.pert_std  = 0;
blocks{2}.pert_std  = 0.01;
blocks{3}.pert_std  = 0.01;
blocks{4}.pert_std  = 0.01;
blocks{5}.pert_std  = 0.01;
blocks{6}.pert_std  = 0.01;

% Blocks: number of trials
blocks{1}.num_trials =100;
blocks{2}.num_trials =5;
blocks{3}.num_trials =5;
blocks{4}.num_trials =5;
blocks{5}.num_trials =5;
blocks{6}.num_trials =5;