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
paramFile = fullfile(data.meta.out_directory, paramSetName, [data.meta.recording_date '_' paramSetName '_tuning_parameters.dat']);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
params = parseExpParams(paramFile);
ADexcludeFraction = str2double(params.ad_exclude_fraction);
WOexcludeFraction = str2double(params.wo_exclude_fraction);
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

if minReactionTime ~= -1 && maxReactionTime ~= -1
    mt = mt(reactionTime >= minReactionTime & reactionTime <= maxReactionTime & timeToTarget >= minTimeToTarget & timeToTarget <= maxTimeToTarget,:);
end

% for adaptation, exclude some trials
if excludeTrials && (length(ADexcludeFraction) > 0) && strcmp(data.meta.epoch,'AD')
    if length(ADexcludeFraction) == 1
        % remove the first however many trials
        mt = mt(floor(ADexcludeFraction*size(mt,1)):end,:);
    else
        start = floor(ADexcludeFraction(1)*size(mt,1));
        if start <= 0
            start = 1;
        end
        mt = mt(start:floor(ADexcludeFraction(2)*size(mt,1)),:);
    end
end

if excludeTrials && (length(WOexcludeFraction) > 0) && strcmp(data.meta.epoch,'WO')
    if length(WOexcludeFraction) == 1
        % remove the first however many trials
        mt = mt(floor(WOexcludeFraction*size(mt,1)):end,:);
    else
        start = floor(WOexcludeFraction(1)*size(mt,1));
        if start <= 0
            start = 1;
        end
        mt = mt(start:floor(WOexcludeFraction(2)*size(mt,1)),:);
    end
end