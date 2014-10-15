function [mt,centers] = filterMovementTable(data,paramSetName,excludeTrials,useBlock,verbose)
% filter movements out of one of my movement tables based on:
%   1) reaction time
%   2) time to target
%   3) amount of adaptation (not quite implemented... currently just
%   filters some percentage of adaptation and washout files)
%
%   The values to use are specified in the analysis_parameters file

% Stuff to do a random subset
% currently hardcoded. Change this eventually

% I pass in -1 if I'm doing the random subset thing

doRandSubset = false;

if nargin < 5
    verbose = true;
    if nargin < 4
        useBlock = [];
        if nargin < 3
            excludeTrials = true;
        end
    end
end

if useBlock < 0
    doRandSubset = true;
    numSamples = -useBlock;
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

t = data.cont.t;
vel = data.cont.vel;

total_trials = length(centers);
num_removed = 0;

if minReactionTime ~= -1 && maxReactionTime ~= -1
    reactionTime = mt(:,4) - mt(:,3);
    idx = reactionTime >= minReactionTime & reactionTime <= maxReactionTime;
    
    % keep track of how many are removed
    nr = length(centers)-sum(idx);
    
    mt = mt(idx,:);
    centers = centers(idx,:);
    
    num_removed = num_removed + nr;
end

if minTimeToTarget ~= -1 && maxTimeToTarget ~= -1
    timeToTarget = ( mt(:,6) - mt(:,4) ) - holdTime;
    idx = timeToTarget >= minTimeToTarget & timeToTarget <= maxTimeToTarget;
    
    nr = length(centers)-sum(idx);
    
    mt = mt(idx,:);
    centers = centers(idx,:);
    
    num_removed = num_removed + nr;
end

if minTimeToPeak ~= -1 && maxTimeToPeak ~= -1
    timeToPeak = mt(:,5) - mt(:,4);
    idx = timeToPeak >= minTimeToPeak & timeToPeak <= maxTimeToPeak;
    
    nr = length(centers)-sum(idx);
    
    mt = mt(idx,:);
    centers = centers(idx,:);
    
    num_removed = num_removed + nr;
end

if verbose
    disp(['Removed ' num2str(num_removed) ' trials (' num2str(100*num_removed/total_trials) '%)...']);
end

% for adaptation, exclude some trials
if excludeTrials && ~isempty(ADexcludeFraction) && strcmp(data.meta.epoch,'AD')
    if useBlock > 0 % then pick the correct indices
        ADexcludeFraction = ADexcludeFraction(useBlock:useBlock+1);
    elseif useBlock < 0
        ADexcludeFraction = ADexcludeFraction(1:2);
    end
    
    if length(ADexcludeFraction) == 1
        if ADexcludeFraction > 1 %it's a number of trials, not a fraction
            % use the first however many trials
            ADexcludeFraction = min([ADexcludeFraction,size(mt,1)]);
            
            mt = mt(1:ADexcludeFraction,:);
            centers = centers(1:ADexcludeFraction,:);
        else
            % remove the first fraction of trials trials
            centers = centers(floor(ADexcludeFraction*size(mt,1)):end,:);
            mt = mt(floor(ADexcludeFraction*size(mt,1)):end,:);
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
            centers = centers(start:floor(ADexcludeFraction(2)*size(mt,1)),:);
            mt = mt(start:floor(ADexcludeFraction(2)*size(mt,1)),:);
        end
    end
    
end

% Do the same for washout
if excludeTrials && (length(WOexcludeFraction) > 0) && strcmp(data.meta.epoch,'WO')
    if useBlock > 0 % then pick the correct indices
        WOexcludeFraction = WOexcludeFraction(useBlock:useBlock+1);
    elseif useBlock < 0
        WOexcludeFraction = WOexcludeFraction(1:2);
    end
    
    if length(WOexcludeFraction) == 1
        if WOexcludeFraction > 1 %it's a number of trials, not a fraction
            % use the first however many trials
            WOexcludeFraction = min([WOexcludeFraction,size(mt,1)]);
            mt = mt(1:WOexcludeFraction,:);
            centers = centers(1:WOexcludeFraction,:);
        else
            % remove the first fraction of trials trials
            centers = centers(floor(WOexcludeFraction*size(mt,1)):end,:);
            mt = mt(floor(WOexcludeFraction*size(mt,1)):end,:);
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
            centers = centers(start:floor(WOexcludeFraction(2)*size(mt,1)),:);
            mt = mt(start:floor(WOexcludeFraction(2)*size(mt,1)),:);
        end
    end
end

% Now, select random subset of trials if it's that protocol
if doRandSubset
    disp('DOING THE RANDOM SUBSET THING! WATCH OUT!');
    idx = randi(size(mt,1),1,numSamples);
    idx = sort(idx);
    mt = mt(idx,:);
    centers = centers(idx,:);
end

% Now, filter based on speed (slow or fast?) if needed
% [ target angle, on_time, go cue, move_time, peak_time, end_time, ]
if strcmpi(paramSetName,'speed_slow') || strcmpi(paramSetName,'speed_fast')
    meanVels = zeros(size(mt,1),1);
    for iMove = 1:size(mt,1)
        % get time indices for this movement
        idx = t > mt(iMove,4) & t < (mt(iMove,5));
        v = sqrt(vel(idx,1).^2 + vel(idx,2).^2);
        meanVels(iMove) = mean(v);
    end
    
    % find the mean time
    m = mean(meanVels);
    
    switch lower(paramSetName)
        case 'speed_slow'
            idx = meanVels < m;
        case 'speed_fast'
            idx = meanVels > m;
    end
    
    mt = mt(idx,:);
    centers = centers(idx,:);

end
