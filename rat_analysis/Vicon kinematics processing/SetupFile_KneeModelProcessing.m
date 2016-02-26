%% define constants for the analysis

% define the order of the markers in the CSV file - there are two patterns
%       depending on how they are labelled in VICON
% %PATTERN 1 - leg markers first
% OPTS.NMARKERS = 6;
% OPTS.HIP = 1;
% OPTS.PELVIS_TIP = 2;
% OPTS.PELVIS_END = 3;
% OPTS.KNEE = 4;
% OPTS.ANKLE = 5;
% OPTS.TOE = 6;
% OPTS.FRAME_OFFSET = 7;
% OPTS.FRAME_BACK = 8;
% OPTS.FRAME_FRONT = 9;
% OPTS.FRAME_MIDDLE = 10;

%PATTERN 2 - frame markers first
OPTS.NMARKERS = 5;
OPTS.FRAME_OFFSET = 1;
OPTS.FRAME_BACK = 2;
OPTS.FRAME_FRONT = 3;
OPTS.FRAME_MIDDLE = 4;
OPTS.HIP = 5;
OPTS.PELVIS_TIP = 6;
OPTS.PELVIS_END = 7;
OPTS.KNEE = 8;
OPTS.ANKLE = 9;
OPTS.TOE = 10;

% collect all the markers for each together
OPTS.ALL_FRAME = [OPTS.FRAME_OFFSET OPTS.FRAME_BACK OPTS.FRAME_FRONT OPTS.FRAME_MIDDLE];
OPTS.ALL_LEG = [ OPTS.PELVIS_TIP OPTS.PELVIS_END OPTS.HIP OPTS.KNEE OPTS.ANKLE OPTS.TOE];
OPTS.ALL_FRAME = [OPTS.FRAME_OFFSET OPTS.FRAME_BACK OPTS.FRAME_FRONT OPTS.FRAME_MIDDLE];
OPTS.ALL_LEG = [1:5];
OPTS.LABELS = {'Pelvis Tip', 'Pelvis Base', 'Hip', 'Knee', 'Ankle', 'Toe'};

% parameters for preprocessing
OPTS.MAX_NFRAMES_2_DROP = 1;  % how many frames can be dropped yet still allow it to be 'continuous'
OPTS.MIN_NFRAMES_PER_BLOCK = 50;  % how many frames in a row have to be marked for it to be considered a block

% parameters for identifying steps
OPTS.MIN_STEP_DUR = 25;  % mininum duration for an acceptable step
OPTS.MAX_STEP_DUR = 100;  % maximum duration for an acceptable step
