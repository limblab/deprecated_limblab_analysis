function S = ave_sigs_BD(Sigs, GR_ts, aveTime)
    % first column of Sigs (e.g. EMGs) is time, others are signals per se (e.g. activity from individual muscles)
    % GR_ts = Get_GR_ts_MG() =  Nx2 array, N=2xNumReward ([ts reward])
    %   reward = 0 if ts corresponds to touchPad hold
    %   reward = 1 if ts corresponds to Reward time
    % aveTime is the time over which to calculate the mean of the signals (in seconds)
    % S is a 2 x numSigs array, in which
    %   row 1 is the "rest pattern" (all signals = 0)
    %   rows 2 to represent the ave contraction pattern before reward time

    numSigs = size(Sigs,2)-1;

    S = zeros( 2, numSigs);

    numRewards   = size(GR_ts,1);
    binsize = Sigs(2,1) - Sigs(1,1);
    numBins = int8(aveTime/binsize);
    tmp_ave_sigs = zeros(numRewards,numSigs);
    
    for i=1:numRewards
        
        if GR_ts(i,2) %skip reward=0, which corresponds to S0
            timeWindow = find(Sigs(:,1)<=GR_ts(i,1),numBins,'last');
            if ~isempty(timeWindow)
                tmp_ave_sigs(i,:) = mean(Sigs(timeWindow,2:end),1);
            end
        end
    end
    
    S(2,:)=mean(tmp_ave_sigs(:,:));

end

