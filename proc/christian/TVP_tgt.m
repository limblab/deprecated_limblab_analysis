function [S, S_TVP] = TVP_tgt(EMGs, Reward_ts, time_before, time_after)
    %first column of EMGs is ts, others signals from individual muscles
    %Reward_ts = Get_Center_and_Reward_ts() = 2x(NumReward+NumTrials) array of
    %[ts tgt_id], where tgt_id = 0 (center), 1 (tgt 1), 2 (tgt 2), ...
    %center_ts is a numTrials x 1 vector of go_cue ts
    %S = numtimebins x numEMGs x numtargets matrice of average EMG patterns
    %      between time_before and time_after around reward ts for each
    %      target

    numTgts = max(Reward_ts(:,2));
    numEMGs = size(EMGs,2)-1;
    
    numRewards   = size(Reward_ts,1);
    binsize = EMGs(2,1) - EMGs(1,1);
    numBins = int32((time_after+time_before)/binsize);
    tmp_emg_resp = zeros(numBins, numEMGs, numTgts, numRewards);
    tgt_i_counter = zeros(numTgts,1);
    windowTimeFrame = -time_before:binsize:time_after-binsize;

    S_TVP =zeros(numBins, numEMGs+1, numTgts);
    S =zeros(numBins, numEMGs+1, numTgts);
    
    for i = 1:numTgts
        S_TVP(:,1,i)=windowTimeFrame';
        S(:,1,i)=windowTimeFrame';
    end
        
    for i=1:numRewards
        tgt_id = Reward_ts(i,2);

        timeWindow = find(EMGs(:,1)>=Reward_ts(i,1)-time_before & ...
                          EMGs(:,1)<=Reward_ts(i,1)+time_after);
                      
        if length(timeWindow)<numBins % part of timeWindow falls outside data?
            continue;
        end
        
        if ~isempty(timeWindow)
            tgt_i_counter(tgt_id) = tgt_i_counter(tgt_id)+1;
            tmp_emg_resp(:,:,tgt_id,tgt_i_counter(tgt_id)) = EMGs(timeWindow,2:end);
        end
    end
    
    for i=1:numTgts
        S_TVP(:,2:end,i) = mean(tmp_emg_resp(:,:,i,1:tgt_i_counter(i)),4);
        S(:,2:end,i) = ones(numBins,1)*mean(S_TVP(:,2:end,i));
    end
end

