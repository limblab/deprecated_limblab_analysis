function [outMT,outCenters] = filterMovementTable(data,params,blockTrials,verbose)
% filter movements out of one of my movement tables based on:
%   1) reaction time
%   2) time to target
%   3) amount of adaptation (not quite implemented... currently just
%   filters some percentage of adaptation and washout files)
%
%   If useBlock is true, will pass out a cell array corresponding to trials
%   for each of the blocks specified in the params.tuning.blocks value, for
%   whatever the current epoch data came from
%
% Note: for now, I require that blockTrials be true if I'm going to do the
% random trial subset resampling thing or the speed separation thing

if nargin < 4
    verbose = true;
    if nargin < 3
        blockTrials = true;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load all of the parameters
MonkeyID = params.MonkeyID;
epochs = params.exp.epochs;
paramSetName = params.paramSetName;
blocks = params.tuning.blocks;
minReactionTime = params.trials.min_reactionTime(MonkeyID);
maxReactionTime = params.trials.max_reactionTime(MonkeyID);
minTimeToTarget = params.trials.min_time2target(MonkeyID);
maxTimeToTarget = params.trials.max_time2target(MonkeyID);
minTimeToPeak = params.trials.min_time2peak(MonkeyID);
maxTimeToPeak = params.trials.max_time2peak(MonkeyID);
doRandSubset = params.tuning.doRandSubset;
numSamples = params.tuning.numSamples;
numResamples = params.tuning.numSamples;

% don't count the hold time in the time to target
holdTime = params.exp.target_hold_high;
if iscell(holdTime)
    holdTime = str2num(holdTime{1});
end

mt = data.movement_table;
centers = data.movement_centers;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

% used for breaking data into blocks of trials
if blockTrials
    fullMT = mt;
    fullCenters = centers;
    % get index of current data epoch
    idx = find(strcmpi(epochs,data.meta.epoch));
    b = blocks{idx};
    
    if doRandSubset
        numBlocks = numResamples;
    else
        numBlocks = length(b)-1;
    end
    
    outMT = cell(1,numBlocks);
    outCenters = cell(1,numBlocks);
    
    % break up trials for each block
    for iBlock = 1:numBlocks
        if doRandSubset % the first two points specify which trials
            excludeFraction = b(1:2);
        else % change based on each block
            excludeFraction = b(iBlock:iBlock+1);
        end
        
        if any(excludeFraction > 1) % not a proportion, so trial number must be specified
            excludeFraction(2) = min([excludeFraction(2),size(fullMT,1)]);
            mt = fullMT(excludeFraction(1):excludeFraction(2),:);
            centers = fullCenters(excludeFraction(1):excludeFraction(2),:);
        else
            start = floor(excludeFraction(1)*size(fullMT,1));
            if start <= 0,
                start = 1;
            end
            theend = ceil(excludeFraction(2)*size(fullMT,1));
            if theend > size(fullMT,1)
                theend = size(fullMT,1);
            end
            mt = fullMT(start:theend,:);
            centers = fullCenters(start:theend,:);
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
        if strcmpi(paramSetName,'speedSlow') || strcmpi(paramSetName,'speedFast')           
            meanVels = zeros(size(mt,1),1);
            for iMove = 1:size(mt,1)
                % get time indices for this movement
                idx = data.cont.t > mt(iMove,4) & data.cont.t < (mt(iMove,5));
                v = sqrt(data.cont.vel(idx,1).^2 + data.cont.vel(idx,2).^2);
                meanVels(iMove) = rms(v);
            end
            
            % find the mean time
            m = mean(meanVels);
            switch lower(paramSetName)
                case 'speedslow'
                    idx = meanVels < m;
                case 'speedfast'
                    idx = meanVels > m;
            end
            mt = mt(idx,:);
            centers = centers(idx,:);
        end
        
        % assign outputs now
        outMT{iBlock} = mt;
        outCenters{iBlock} = centers;
    end
else
    outMT = {mt};
    outCenters = {centers};
end
