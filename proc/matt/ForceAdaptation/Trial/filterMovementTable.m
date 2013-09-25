function mt = filterMovementTable(data,paramSetName,excludeTrials)
% filter movements out of one of my movement tables based on:
%   1) reaction time
%   2) time to target
%   3) amount of adaptation (not quite implemented... currently just
%   filters some percentage of adaptation and washout files)
%
%   The values to use are specified in the analysis_parameters file

if nargin < 3
    excludeTrials = true;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load all of the parameters
paramFile = fullfile(data.meta.out_directory, paramSetName, [data.meta.recording_date '_analysis_parameters.dat']);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
params = parseExpParams(paramFile);
excludeFraction = str2double(params.exclude_fraction);
minReactionTime = str2double(params.min_reaction_time{1});
maxReactionTime = str2double(params.max_reaction_time{1});
minTimeToTarget = str2double(params.min_time_to_target{1});
maxTimeToTarget = str2double(params.max_time_to_target{1});
clear params;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% don't count the hold time in the time to target
holdTime = data.params.hold_time;
mt = data.movement_table;

reactionTime = mt(:,4) - mt(:,3);
timeToTarget = ( mt(:,end) - mt(:,4) ) - holdTime;

mt = mt(reactionTime >= minReactionTime & reactionTime <= maxReactionTime & timeToTarget >= minTimeToTarget & timeToTarget <= maxTimeToTarget,:);

% for adaptation, exclude first set of trials
if excludeTrials && (length(excludeFraction) > 0) && (strcmp(data.meta.epoch,'AD') || strcmp(data.meta.epoch,'WO'));
    if length(excludeFraction) == 1
        % remove the first however many trials
        mt = mt(floor(excludeFraction*size(mt,1)):end,:);
    else
        start = floor(excludeFraction(1)*size(mt,1));
        if start <= 0
            start = 1;
        end
        mt = mt(start:floor(excludeFraction(2)*size(mt,1)),:);
    end
end