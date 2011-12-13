function [Go_Rew_ts_w_EMGs] = get_expected_EMGs_WF(tt, EMGpatterns)

% This function returns a matrix of [ts emg1 emg2 ... emgn]
% datastruct can be either a BDF or a binnedData structure
%
% ts is the time at which a 'Go_Cue' or a 'Reward' word was issue
% emg1, emg2, ..., emgn consist of the expected EMG amplitude in each
% of the muscles for the respectvie ts.
%
% Go_Rew_ts_w_EMGs is an array that provides the information as to what EMG
% value is to be expected at a particular time stamp
% It is a two dimensional array of size numTargets x numEMG.
%  Note: numTarget has to be 8, so that Go_Rew_ts_w_EMGs has 9 rows.
%        targets are identified using their position (see get_tgt_id.m)
%        row 1 has expected EMG values for Center hold,
%        row 2 for tgt 1, row 3 for tgt 3 and so on
%
% Note: At "Go_Cue", the expected EMG values are assumed to be 0
%
% Note 2: the arrangement of the WF trial table is as follow:
%    1: Start time
%  2-5: Target              -- ULx ULy LRx LRy
%    6: OT on time
%    7: Go cue
%    8: Trial End time
%    9: Trial result        -- R, A, I, or F 
%   10: Target ID           -- Target ID (based on location)

    targets = unique(tt(tt(:,10)>=0,10)); %skip if tgt = -1, something was wrong
    
    % Find Go and Reward rows in tt :
    Go = find(tt(:,7) >= 0); %sometimes Go ts may be = -1 in tt if something was wrong
    Rewards = find( tt(:,9)==double('R') );

    numRew = length(Rewards);
    numEMGs = size(EMGpatterns,2);
    numGo = length(Go);
    Rew_ts_w_EMGs = zeros(numRew,numEMGs+1);

    % Assign expected EMGs for Go
    % first row of EMGpatterns.
    Go_ts_w_EMGs = [tt(Go,7) repmat(EMGpatterns(1,:),numGo,1)];

    for i = 1:numRew
        %Assign expected EMGs for each Reward Trial:
        tgtIdx = find(targets==tt(Rewards(i),10))+1; %first line if for Go, so +1 for 2-indexed tgtIdx
        Rew_ts_w_EMGs(i,:) = [tt(Rewards(i),8) EMGpatterns(tgtIdx,:)];
    end

    Go_Rew_ts_w_EMGs = sortrows([Go_ts_w_EMGs; Rew_ts_w_EMGs],1);

