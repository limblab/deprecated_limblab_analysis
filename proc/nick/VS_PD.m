function PDMatrix = VS_PD(datafile,delay,window_length)

% VS_PD loads a Visual Search DATAFILE in BDF format and returns a matrix
% of preferred directions for all active neurons based on neural firing
% during the window of time beginning DELAY seconds before movement onset,
% and lasting for WINDOW_LENGTH seconds, assuming movement in the direction
% of the goal target.
%
% Default values for window parameters are:
%
%   DELAY = 100ms
%   WINDOW_LENGTH = 200ms
%
% PDMatrix is in the form of a matrix [a, b] where each represents the
% following:
% 
%   a - unit number
%   b - data
%       1 - 5th percentile of preferred direction (in radians)
%       2 - mean preferred direction (in radians)
%       3 - 95th percentile of preferred direction (in radians)
%
% DATAFILE should be the BDF file of interest.  This version uses the
% following words to determine timing of events and target positions:
%
%    32 = reward
%    64 = target 0 (top-most target)
%    65-79 = targets 1-15 (progressing clockwise)
%            NOTE: 16 is the maximum possible number of total targets, but
%            most files will include fewer.  In all cases targets are
%            evenly distributed around a circle, giving an inter-target
%            separation angle of 2*pi/total_targets.  (Future versions,
%            starting with databurst version 1, can use actual target
%            positions from the databurst to simplify angle calcualtions
%            and make the code more flexible).
%   128 = movement onset
%
% NOTE: TARGET_POSITIONS begins with 1 in the 12 o'clock position and is
% incremented clockwise.  This is to fit with the Visual Search behavior
% code.  DIRECTIONS begins with 12 o'clock and is incremented counter-
% clockwise.  Preferred directions are calcuated using DIRECTIONS and then
% rotated by 90 degrees to make zero coincident with the x axis.  Hence PDs
% are referenced to the x axis and increase in a counter-clockwise fashion.

VS_BDF = load(datafile); % load BDF struct

cd('../..'); % change directory to s1_analysis
load_paths % load paths to include subdirectories with BOOTSTRAP and CPRCTILE functions

if (nargin == 1)
    delay = 0.1; % set default delay
    window_length = 0.2; % set default window length
end

total_units = 0;
for unit_check = 1:length(VS_BDF.bdf.units); % calculate number of units
    if size(VS_BDF.bdf.units(1,unit_check).id) ~= 0 % check for empty struct value
        total_units = total_units + 1; % increment number of units if struct is not empty
    end
end

target_words = VS_BDF.bdf.words(:,2) >= 64 & VS_BDF.bdf.words(:,2) <= 79; % create logical array with indices of all words that represent outer target appearance

total_targets = max(VS_BDF.bdf.words(target_words,2)) - 63; % find maximum value for target words and use this to define total number of targets used

spike_counts = cell(total_units, total_targets); % create a cell array to track the number of spikes for each reach in each direction

trial_count = zeros(1,total_targets); % create a matrix to track the number of trials that are in the direction of each target

reward_words = VS_BDF.bdf.words(:,2) == 32; % create a logical array with indices of all words that represent rewards (successful trials)

successful_move_words = VS_BDF.bdf.words(:,2) == 128 & [0; target_words(1:end-1)] & [reward_words(3:end); 0; 0]; % compare logical arrays for targets and rewards to create logical array with indices of successful movement onsets

successful_target_words = logical([successful_move_words(2:end); 0]); % create logical array with indices of targets that were reached successfully

targets = VS_BDF.bdf.words(successful_target_words,2); % create array of all targets that were successfully reached

target_positions = targets - 63; % convert successful target words to positions (1 = 12 o'clock, increasing clockwise)

move_times = VS_BDF.bdf.words(successful_move_words,1); % create array off all successful movement onset times (this couples with previous array for successful target positions)

for direction = 1:total_targets
    if direction == 1
        position = direction;
    else
        position = total_targets + 2 - direction; % find directions from positions (1 = 12 o'clock, increasing counter-clockwise)
    end
    trial_count(direction) = sum(target_positions == position); % count number of successful trials for direction of interest
    direction_times = move_times(target_positions == position); % find movement onset times for direction of interest
    for unit = 1:total_units
        for trial = 1:trial_count(direction)
            spike_counts{unit}{direction}(trial) = sum((VS_BDF.bdf.units(1,unit).ts >= direction_times(trial) - delay) & (VS_BDF.bdf.units(1,unit).ts <= direction_times(trial) - delay + window_length)); % sum spikes for each unit in window of interest for movement trials in direction of interest
        end
    end
end

bootstrapPDs = cell(1, total_units); % create a cell array to store the bootstrapped PDs for each unit 
PDMatrix = zeros(total_units,3); % create a matrix to save the mean PD and error bounds for each unit

for x = 1:total_units
    bootstrapPDs{x} = bootstrap(@vector_sum_pd, spike_counts{x}, 'all', 1000); % perform 1000 bootstrapped PD calculations for each unit (returns [PD magnitude] for each sample set)
    bootstrapPDs{x}(:,1) = bootstrapPDs{x}(:,1) + pi/2; % rotate all bootstrapped PD calculations by 90 degrees (VECTOR_SUM_PD assumes 0 degrees is in direction of first target, we need to realign with x axis)
    PDMatrix(x,:) = cprctile(bootstrapPDs{x}(:,1),[5 50 95]); % calculate 5th percentile, mean, and 95th percetile of PD for each unit based on bootstrapping results
end

% PDMatrix = PDMatrix * 180 / pi; % convert PDs to degrees