function [S, S_TVP] = TVP_tgt_gdt(EMGs, Reward_ts, time_before, time_after)
    %first column of EMGs is ts, others signals from individual muscles
    %Reward_ts = Get_Center_and_Reward_ts() = 2x(NumReward+NumTrials) array of
    %[ts tgt_id], where tgt_id = 0 (center), 1 (tgt 1), 2 (tgt 2), ...
    % or [ts tgt_id gdt_id] if data from multigadget
    %center_ts is a numTrials x 1 vector of go_cue ts
    %S = numtimebins x numEMGs x numtargets matrice of average EMG patterns
    %      between time_before and time_after around reward ts for each
    %      target

    numTgts = max(Reward_ts(:,2));
    numEMGs = size(EMGs,2)-1;
    if size(Reward_ts,2)>2
        numGdts = max(Reward_ts(:,3));
    else
        numGdts = 1;
    end
    
    numRewards   = size(Reward_ts,1);
    binsize = EMGs(2,1) - EMGs(1,1);
    numBins = int32((time_after+time_before)/binsize);
    tmp_emg_resp = zeros(numBins, numEMGs, numTgts, numGdts, numRewards);
    tgt_gdt_counter = zeros(numTgts,numGdts);
    windowTimeFrame = -time_before:binsize:time_after-binsize;

    S_TVP =zeros(numBins, numEMGs+1, numTgts, numGdts);
    S =zeros(numBins, numEMGs+1, numTgts, numGdts);
    
    for i = 1:numTgts
        for j = 1:numGdts
            S_TVP(:,1,i,j)=windowTimeFrame';
            S(:,1,i,j)=windowTimeFrame';
        end
    end
        
    for i=1:numRewards
        tgt_id = Reward_ts(i,2);
        gdt_id = Reward_ts(i,3);
        
        timeWindow = find(EMGs(:,1)>=Reward_ts(i,1)-time_before & ...
                          EMGs(:,1)<=Reward_ts(i,1)+time_after);
                      
        if length(timeWindow)<numBins % part of timeWindow falls outside data?
            continue;
        end
        
        if ~isempty(timeWindow)
            tgt_gdt_counter(tgt_id,gdt_id) = tgt_gdt_counter(tgt_id,gdt_id)+1;
            tmp_emg_resp(:,:,tgt_id,gdt_id,tgt_gdt_counter(tgt_id,gdt_id)) = EMGs(timeWindow,2:end);
        end
    end
    
    for i=1:numTgts
        for j=1:numGdts
            S_TVP(:,2:end,i,j) = mean(tmp_emg_resp(:,:,i,j,1:tgt_gdt_counter(i,j)),5);
            S(:,2:end,i,j) = repmat(mean(S_TVP(:,2:end,i,j)),numBins,1);
        end
    end
end

