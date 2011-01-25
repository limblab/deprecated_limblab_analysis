function PDMatrix = VS_PD(datafile,delay,window_length)

% VS_PD loads a Visual Search DATAFILE in BDF format and returns a matrix
% of preferred directions for all active neurons based on neural firing
% during the window of time beginning DELAY seconds before movement onset,
% and lasting for WINDOW_LENGTH seconds, assuming movement in the direction
% of the goal target.
%
% Default values for window parameters are:
%
%   DELAY = 100ms;
%   WINDOW_LENGTH = 200ms;
%
% PDMatrix is in the form of a matrix [a, b] where each represents the
% following:
% 
%   a - unit number
%   b - data
%       1 - preferred direction (angle in radians)
%       2 - 95% confidence interval (in radians)
%
% 'datafile' should be the BDF file of interest.  This version uses the
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
% NOTE: target_number will begin with 0 in the 12 o'clock position, while
% target_position will begin with 1 in the 12 o'clock position.  This is to
% fit with the dual convention used in the Visual Search behavior code as
% well as to simplify calculations.

VS_BDF = load(datafile); % load BDF struct

if (nargin == 1)
    delay = 0.1;
    window_length = 0.2;
end

total_units = 0;
for unit_check = 1:length(VS_BDF.bdf.units); % calculate number of units
    if size(VS_BDF.bdf.units(1,unit_check).id) ~= 0 % check for empty struct value
        total_units = total_units + 1;
    end
end

% calculate number of targets
target_words = VS_BDF.bdf.words(:,2) >= 64 & VS_BDF.bdf.words(:,2) <= 79;

total_targets = max(VS_BDF.bdf.words(target_words,2)) - 63;

spike_counts = cell(total_units, total_targets); % create a cell array to track the number of spikes for each reach in each direction

trial_count = zeros(1,total_targets); % create a matrix to track the number of trials that are in the direction of each target

% create logical arrays for words
reward_words = VS_BDF.bdf.words(:,2) == 32;

successful_move_words = VS_BDF.bdf.words(:,2) == 128 & [0; target_words(1:end-1)] & [reward_words(3:end); 0; 0];

successful_target_words = logical([successful_move_words(2:end); 0]);

targets = VS_BDF.bdf.words(successful_target_words,2);

target_positions = targets - 63;

move_times = VS_BDF.bdf.words(successful_move_words,1);

for direction = 1:total_targets
    trial_count(direction) = sum(target_positions == direction);
    direction_times = move_times(target_positions == direction);
    for unit = 1:total_units
        for trial = 1:trial_count(direction)
            spike_counts{unit}{direction}(trial) = sum((VS_BDF.bdf.units(1,unit).ts >= direction_times(trial) - delay) & (VS_BDF.bdf.units(1,unit).ts <= direction_times(trial) - delay + window_length));
        end
    end
end

% Temporarily, PDMatrix will be output in the form of a cell array, where
% each cell represents a neural unit and the matrix within each cell is Nx2
% where N is the number or function calls in bootstrapping and the columns
% represent preferred direction and vector magnitude calculations.

addpath('../../lib/bootstrapping');

PDMatrix = cell(1, total_units);

for x = 1:total_units
    PDMatrix{x} = bootstrap(@vector_sum_pd, spike_counts{x}, 'all', 1000);
    % PDMatrix = bootstrap(@PD_angle_calc, spike_rates, 'all', 1000);
end
