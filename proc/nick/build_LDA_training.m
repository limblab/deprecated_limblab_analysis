function [training_set, groups] = build_LDA_training(bdf_file)

% This function accepts a bdf file and generates a training set and
% grouping set that can be used to classify hold and movement periods based
% on linear discriminant analysis (LDA).

% For classification:
% 0 = hold
% 1 = movement

% This is built to work with VISUAL SEARCH files only.

% Define bin length and averaging window length (in seconds).

bin = 0.01;
window = 0.2;
samps = floor(window/bin);

% Bin data starting at 1 second to eliminate missing initial position
% data from plexon.

% binnedData_file = convertBDF2binned(bdf_file, bin, 1, 0);
binnedData_file = convertBDF2binned('/Users/nsachs/Documents/MATLAB/Keedoo_Spike_12142010001-01.mat', bin, 1, 0);

% Calculate overall speed from x and y velocities

% old version:
% column 1 is time, column 2 is speed
% speed(:,1) = bdf_file.vel(:,1);
% speed(:,2) = sqrt((bdf_file.vel(:,2)).^2 + (bdf_file.vel(:,3)).^2);

% speed = sqrt((binnedData_file.cursorvelbin(:,1)).^2 + (binnedData_file.cursorvelbin(:,2)).^2);

speed = binnedData_file.velocbin(:,3);

% Filter speed with 4th order butterworth LPF.
% Use filtfilt to prevent lag.
% Max speed values will be used as timepoints from which to collect neural
% data for movement training sets.
% Min speed values will be used as timepoints from which to collect neural
% data for hold training sets.

% old version:
% [B,A] = butter(4,2/max(bdf_file.speed(:,1)),'low');
% speed_filt(:,1) = speed(:,1);
% speed_filt(:,2) = filtfilt(B,A,speed(:,2));

cutoff = 1; % in Hz

[B,A] = butter(4,cutoff*bin/2,'low');
speed_filt = filtfilt(B,A,speed);

% Calculate number of targets.

max_target = 0;

for x = 1:length(bdf_file.words)
    if bdf_file.words(x,2) < 80 % maximum 16 targets
        max_target = max([max_target bdf_file.words(x,2)]);
    end
end
number_targets = max_target - 63;

% Initialize training set.
%
% Each column of training set includes average firing rates for a single
% neuron for (approximately) the window period preceding the point of
% movement used for classification.
%
% Each row of training set includes average firing rates for a single type
% of movement.
%
% Structure of training set:
% row 1 = center hold
% row 2 = target 1 hold
% |
% row (2 + no.targets) = movement from center to target 1
% |
% row (2 + 2*no.targets) = movement from target 1 to center

training_set = zeros(3*number_targets+1,length(binnedData_file.spikeguide));

% Initialize groups (classifications for rows in training_set).
%
% 0 = hold
% 1 = movement

groups = zeros(3*number_targets+1,1);
for x = number_targets+2:length(groups)
    groups(x) = 1;
end

% Sort through words and look for successful trials (start_trial followed
% by reward and successful start to following trial).
% Successful trials get divided into center hold, outward movement, outer
% hold, and inward movement periods.
% The appropriate number of bins preceding the first minimum during hold 
% periods and first maximum during movement periods are added to the spike
% data for the correct row of taining_set (depending on target).

trials = zeros(number_targets,1); % initialize vector of number of trials to each target

for x = 1:length(bdf_file.words)-9
    if bdf_file.words(x,2) == 27 % start_trial
        if (bdf_file.words(x+6,2) == 32) && (bdf_file.words(x+9,2) == 160) % reward and back to center
            target = bdf_file.words(x+3,2) - 63; % determine target (between 1 and number_targets)
            complete = zeros(4,1);
            for y = samps:length(binnedData_file.timeframe)-1
                if (binnedData_file.timeframe(y) > bdf_file.words(x+2,1)) && (speed_filt(y) < speed_filt(y+1)) && (complete(1) == 0) % first min after center_hold
                    training_set(1,:) = training_set(1,:) + sum(binnedData_file.spikeratedata(y+1-samps:y,:),1); % sum previous 20 spike rates
                    complete(1) = 1;
                elseif (binnedData_file.timeframe(y) > bdf_file.words(x+4,1)) && (speed_filt(y) > speed_filt(y+1)) && (complete(2) == 0) % first max after after movement_onset
                    training_set(1+number_targets+target,:) = training_set(1+number_targets+target,:) + sum(binnedData_file.spikeratedata(y+1-samps:y,:),1); % sum previous 20 spike rates
                    trials(target) = trials(target) + 1; % increment trial count for correcct target
                    complete(2) = 1;
                elseif (binnedData_file.timeframe(y) > bdf_file.words(x+5,1)) && (speed_filt(y) < speed_filt(y+1)) && (complete(3) == 0) % first min after after outer_hold
                    training_set(1+target,:) = training_set(1+target,:) + sum(binnedData_file.spikeratedata(y+1-samps:y,:),1); % sum previous 20 spike rates
                    complete(3) = 1;
                elseif (binnedData_file.timeframe(y) > bdf_file.words(x+6,1)) && (speed_filt(y) > speed_filt(y+1)) && (complete(4) == 0) % first max after reward
                    training_set(1+2*number_targets+target,:) = training_set(1+2*number_targets+target,:) + sum(binnedData_file.spikeratedata(y+1-samps:y,:),1); % sum previous 20 spike rates
                    complete(4) = 1;
                end                    
            end
        end
    end
end

training_set = training_set./samps;

% Divide rows of training_set by number of trials included in each to get
% average values.

training_set(1,:) = training_set(1,:)./sum(trials);
for x = 1:number_targets
    training_set(1+x,:) = training_set(1+x,:)./trials(x);
    training_set(1+number_targets+x,:) = training_set(1+number_targets+x,:)./trials(x);
    training_set(1+2*+number_targets+x,:) = training_set(1+2*number_targets+x,:)./trials(x);
end