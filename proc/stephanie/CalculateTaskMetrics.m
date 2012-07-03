% Task metrics (for WF task)

% Created by SNN | 4/26/2012

% Time to target
% Number of successful targets
% Path length
% Number of path reversals (probably won't include this)

% Recap of what is in each column of binnedData.trialtable
%    1: Start time
%    2-5: Target            -- ULx ULy LRx LRy
%    6: Outer target (OT) 'on' time
%    7: Go cue
%    8: Trial End time
%    9: Trial result        -- R, A, I, or F 
%   10: Target ID           -- Target ID based on location

trialtable = wf_trial_table(out_struct);


% Calculate Time to Target (Time2Target)----------------------------------
% We want the timestamp for when the cursor got into the target
% This timestamp is RewardTimestamp - TargetHoldingPeriod
% Find only the successful trials (Reward)
% "Drive-by" target




% Time2Target

%Get the cursor's position in the center target when the go cue sounds
% Get the go cue timestamp



        xCenter = (trialtable(a,4)-trialtable(a,2))/2;
        yCenter = (trialtable(a,5)-trialtable(a,3))/2;  


% Is the cursor in the target?
for c = 1:length(binnedData.trialtable)
    for d = 1:length(binnedData.timeframe)        
        
        %Get the cursor's position in the center target when the go cue sounds
        % Get the go cue timestamp
        goCue = binnedData.trialtable(c,7);

        % Get cursor position
        cursorXpos = binnedData.cursorposbin(c,1);
        cursorYpos = binnedData.cursorposbin(c,2);

        time = binnedData.timeframe(d);
        if time <= TrialStartTime && time <= TrialStopTime
            % Get the smallest x value for the target
            minTgtX = min(binnedData.trialtable(d,2), binnedData.trialtable(d,4));
            % Get the largest x value for the target
            maxTgtX = max(binnedData.trialtable(d,2), binnedData.trialtable(d,4));
            % Get the smallest y value for the target
            minTgtY = min(binnedData.trialtable(d,3), binnedData.trialtable(d,5));
            % Get the largest y value for the target
            maxTgtY = max(binnedData.trialtable(d,3), binnedData.trialtable(d,5));

            if (cursorXpos > minTgtX) && (cursorXpos < maxTgtX) && (cursorYpos > minTgtY) && (cursorYpos < maxTgtY)
                INtarget = true;
                %Calculate path length
            else
                INtarget = false;
            end


    else
        %update the trialtable row that you are looking at
        
    
        end
        
    end
    
end

% Trial start and stop times are in the trial table
d = 1;
TrialStartTime = binnedData.trialtable(d,1);
TrialStopTime = binnedData.trialtable(d,8);

% if time < endoftrialtime
i = 1; %just for now
minTgtX = min(binnedData.targets.corners(i,2), binnedData.targets.corners(i,4));
maxTgtX = max(binnedData.targets.corners(i,2), binnedData.targets.corners(i,4));
minTgtY = min(binnedData.targets.corners(i,3), binnedData.targets.corners(i,5));
maxTgtY = max(binnedData.targets.corners(i,3), binnedData.targets.corners(i,5));
if cursorXpos > minTgtX && cursorXpos < maxTgtX && cursorYpos > minTgtY && cursorYpos < maxTgtY
    INtarget = true;
else
    INtarget = false;
end


% Percentage of successful trials
NumSuccesses = 0;
NumTrials = length(trialtable);
for N = 1:NumTrials
    if trialtable(N, 9) == 82;
        NumSuccesses = NumSuccesses + 1;
    end
end
PerSuccessfulTrials = NumSuccesses/NumTrials;


    





