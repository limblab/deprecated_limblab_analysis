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
    %  Note: numTarget has to be 8, so that Go_Rew_ts_w_EMGs has 8 rows.
    %        targets are identified using their position (see get_tgt_id.m)
    %        row 1 has expected EMG values for tgt 1 and so on
    %
    % Note: At "Go_Cue", the expected EMG values are assumed to be 0

    
    % Find Go and Reward rows in tt :
    Go    = find(tt(:,7) > 0); %sometimes Go ts = -1 in tt if something was wrong
    numGo = length(Go);
    
    Rewards = find( tt(:,9)==double('R') );
    numRew = length(Rewards);
    
    % Assign expected EMGs for Go -> all zeros
    numEMGs = size(EMGpatterns,2);
    Go_ts_w_EMGs = [tt(Go,7) zeros(numGo,numEMGs)];

    %Assign expected EMGs for each Reward Trial:
    Rew_ts_w_EMGs = zeros(numRew,numEMGs+1);
    for i = 1:numRew
        tgtIdx = tt(Rewards(i),10);
        Rew_ts_w_EMGs(i,:) = [tt(Rewards(i),8) EMGpatterns(tgtIdx,:)];
    end
    
    Go_Rew_ts_w_EMGs = sortrows([Go_ts_w_EMGs;Rew_ts_w_EMGs],1);
    

