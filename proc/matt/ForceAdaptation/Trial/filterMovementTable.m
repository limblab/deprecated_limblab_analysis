function mt = filterMovementTable(data,mt)
% filter movements out of one of my movement tables based on:
%   1) reaction time
%   2) time to target
%   3) amount of adaptation (not quite implemented... currently just
%   filters some percentage of adaptation and washout files)
%
%   The values to use are specified in the analysis_parameters file

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load all of the parameters
paramFile = fullfile(data.meta.out_directory, [data.meta.recording_date '_analysis_parameters.dat']);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
params = parseExpParams(paramFile);
excludeFraction = str2double(params.exclude_fraction{1});
minReactionTime = str2double(params.min_reaction_time{1});
maxReactionTime = str2double(params.max_reaction_time{1});
minTimeToTarget = str2double(params.min_time_to_target{1});
maxTimeToTarget = str2double(params.max_time_to_target{1});
clear params;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

reactionTime = mt(:,4) - mt(:,3);
timeToTarget = mt(:,end) - mt(:,4);

mt = mt(reactionTime >= minReactionTime & reactionTime <= maxReactionTime & timeToTarget >= minTimeToTarget & timeToTarget <= maxTimeToTarget,:);

% for adaptation, exclude first set of trials
if excludeFraction > 0 && (strcmp(data.meta.epoch,'AD') || strcmp(data.meta.epoch,'WO'));
    % remove the first however many trials
    mt = mt(floor(excludeFraction*size(mt,1)):end,:);
end