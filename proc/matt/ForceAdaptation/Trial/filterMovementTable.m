function [mt,centers] = filterMovementTable(data,paramSetName,excludeTrials,useBlock)
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
minTimeToPeak = str2double(params.min_time_to_peak{1});
maxTimeToPeak = str2double(params.max_time_to_peak{1});
clear params;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% don't count the hold time in the time to target
holdTime = data.params.hold_time;
mt = data.movement_table;
centers = data.movement_centers;

if minReactionTime ~= -1 && maxReactionTime ~= -1
    reactionTime = mt(:,4) - mt(:,3);
    idx = reactionTime >= minReactionTime & reactionTime <= maxReactionTime;
    
    mt = mt(idx,:);
    centers = centers(idx,:);
end

if minTimeToTarget ~= -1 && maxTimeToTarget ~= -1
    timeToTarget = ( mt(:,6) - mt(:,4) ) - holdTime;
    idx = timeToTarget >= minTimeToTarget & timeToTarget <= maxTimeToTarget;
    
    mt = mt(idx,:);
    centers = centers(idx,:);
end

if minTimeToPeak ~= -1 && maxTimeToPeak ~= -1
    timeToPeak = mt(:,5) - mt(:,4);
    idx = timeToPeak >= minTimeToPeak & timeToPeak <= maxTimeToPeak;
    
    mt = mt(idx,:);
    centers = centers(idx,:);
end

% for adaptation, exclude some trials
if excludeTrials && ~isempty(ADexcludeFraction) && strcmp(data.meta.epoch,'AD')
    if useBlock ~= -1 % then pick the correct indices
        ADexcludeFraction = ADexcludeFraction(useBlock:useBlock+1);
    end
    
    if length(ADexcludeFraction) == 1
        if ADexcludeFraction > 1 %it's a number of trials, not a fraction
            % use the first however many trials
            ADexcludeFraction = min([ADexcludeFraction,size(mt,1)]);
            
            mt = mt(1:ADexcludeFraction,:);
            centers = centers(1:ADexcludeFraction,:);
        else
            % remove the first fraction of trials trials
            mt = mt(floor(ADexcludeFraction*size(mt,1)):end,:);
            centers = centers(floor(ADexcludeFraction*size(mt,1)):end,:);
        end
    else
        if any(ADexcludeFraction > 1)
            % then trial number must be specified
            ADexcludeFraction(2) = min([ADexcludeFraction(2),size(mt,1)]);
            mt = mt(ADexcludeFraction(1):ADexcludeFraction(2),:);
            centers = centers(ADexcludeFraction(1):ADexcludeFraction(2),:);
        else
            start = floor(ADexcludeFraction(1)*size(mt,1));
            if start <= 0
                start = 1;
            end
            mt = mt(start:floor(ADexcludeFraction(2)*size(mt,1)),:);
            centers = centers(start:floor(ADexcludeFraction(2)*size(mt,1)),:);
        end
    end
    
end

% Do the same for washout
if excludeTrials && (length(WOexcludeFraction) > 0) && strcmp(data.meta.epoch,'WO')
    if useBlock ~= -1 % then pick the correct indices
        WOexcludeFraction = WOexcludeFraction(useBlock:useBlock+1);
    end
    
    if length(WOexcludeFraction) == 1
        if WOexcludeFraction > 1 %it's a number of trials, not a fraction
            % use the first however many trials
            WOexcludeFraction = min([WOexcludeFraction,size(mt,1)]);
            mt = mt(1:WOexcludeFraction,:);
            centers = centers(1:WOexcludeFraction,:);
        else
            % remove the first fraction of trials trials
            mt = mt(floor(WOexcludeFraction*size(mt,1)):end,:);
            centers = centers(floor(WOexcludeFraction*size(mt,1)):end,:);
        end
    else
        if any(WOexcludeFraction > 1)
            % then trial number must be specified
            WOexcludeFraction(2) = min([WOexcludeFraction(2),size(mt,1)]);
            mt = mt(WOexcludeFraction(1):WOexcludeFraction(2),:);
            centers = centers(WOexcludeFraction(1):WOexcludeFraction(2),:);
        else
            start = floor(WOexcludeFraction(1)*size(mt,1));
            if start <= 0
                start = 1;
            end
            mt = mt(start:floor(WOexcludeFraction(2)*size(mt,1)),:);
            centers = centers(start:floor(WOexcludeFraction(2)*size(mt,1)),:);
        end
    end
end