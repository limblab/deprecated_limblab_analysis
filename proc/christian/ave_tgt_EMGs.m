function S = ave_tgt_EMGs(EMGs,CR_ts, timeWindow)
    %first column of EMGs is ts, others signals from individual muscles
    %CR_ts = Get_Center_and_Reward_ts() = 2x(NumReward+NumTrials) array of
    %[ts tgt_id], where tgt_id = 0 (center), 1 (tgt 1), 2 (tgt 2), ...
    %center_ts is a numTrials x 1 vector of go_cue ts
    %num_bins is the number of bins over which to calculate the mean signals

    numTgts = max(CR_ts(:,2));
    numEMGs = size(EMGs,2)-1;

    S = zeros(numTgts+1, numEMGs);

    numRewards   = size(CR_ts,1);
    binsize = EMGs(2,1) - EMGs(1,1);
    numBins = int32(timeWindow/binsize);
    tmp_ave_emgs = zeros(numRewards,numEMGs,numTgts);
    tgt_i_counter = zeros(numTgts,1);
    
    
    for i=1:numRewards
        tgt_id = CR_ts(i,2);
        
        if tgt_id %skip tgt id 0, which corresponds to S0
             timeWindow = find(EMGs(:,1)<=CR_ts(i,1),numBins,'last');
%            timeWindow = find(EMGs(:,1)>=CR_ts(i,1)-time_before & ...
%                               EMGs(:,1)<=CR_ts(i,1)+time_after);
            if ~isempty(timeWindow)
                tgt_i_counter(tgt_id) = tgt_i_counter(tgt_id)+1;
                tmp_ave_emgs(tgt_i_counter(tgt_id),:,tgt_id) = mean(EMGs(timeWindow,2:end),1);
            end
        end
    end
    
    for i=1:numTgts
        
        S(i+1,:)=mean(tmp_ave_emgs(1:tgt_i_counter(i),:,i));
    end
       
    
%         tmp_ave_emgs = zeros(length(Tgts_ts{1,i}), numEMGs);
%     
%     
%     for i=1:numTgts
%         tmp_ave_emgs = zeros(length(Tgts_ts{1,i}),numEMGs);
%         for j=length(Tgts_ts{1,i}):-1:1
%             timewindow = find(EMGs(:,1)<=Tgts_ts{1,i}(j,1),num_bins,'last');
%             if ~isempty(timewindow)
%                 tmp_ave_emgs(j,:) = mean( EMGs(timewindow,2:end),1 );
%             end
%         end
%         S(i+1,:)=mean(tmp_ave_emgs);
%     end
% 
%     EMGmax = max(S,[],1);
%     
%     for i=1:numTgts
%         S(i+1,:) = S(i+1,:)./EMGmax;
%     end

end

