% Task metrics

% Created by SNN | 4/26/2012

%


% Recap of what is in each column of binnedData.trialtable
%    1: Start time
%    2-5: Target            -- ULx ULy LRx LRy
%    6: Outer target (OT) 'on' time
%    7: Go cue
%    8: Trial End time
%    9: Trial result        -- R, A, I, or F 
%   10: Target ID           -- Target ID based on location






% Calculate Time to Target (Time2Target)----------------------------------
% We want the timestamp for when the cursor got into the target
% This timestamp is RewardTimestamp - TargetHoldingPeriod
% Find only the successful trials (Reward)
% "Drive-by" target 

%binnedData.trialtable

% Time2Target