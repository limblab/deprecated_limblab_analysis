function S = ave_sigs_tgt_gdt(Sigs, GR_ts, aveTime)
    % first column of Sigs (e.g. EMGs) is time, others are signals per se (e.g. activity from individual muscles)
    % GR_ts = Get_GR_ts_MG() =  NxM array, N=2xNumReward, M=3 ([ts tgt gdt])
    %   tgt, gdt = 0 if ts corresponds to touchPad hold
    %   tgt = [1-15] and gdt = [1-4] if ts corresponds to Reward time
    % aveTime is the time over which to calculate the mean of the signals (in seconds)
    % S is a numGadget+1 x numSigs array, in which
    %   row 1 is the "rest pattern" (all signals = 0)
    %   rows 2 to last represent the ave contraction pattern for each
    %   combination of gadget and target

    numTgts = max(GR_ts(:,2));
    numGdts = max(GR_ts(:,3));
    numSigs = size(Sigs,2)-1;

    S = zeros(numTgts*numGdts+1, numSigs);

    numRewards   = size(GR_ts,1);
    binsize = Sigs(2,1) - Sigs(1,1);
    numBins = int8(aveTime/binsize);
    tmp_ave_sigs = zeros(numRewards,numSigs,numTgts*numGdts);
    
    %gdt_tgt_counter counts each apparition of each combination of tgt,gdt
    % its elements are organized as gadget-target [ gdt1tgt1, gdt1tgt2, gdt1tgtM, gdt2tgt1, ..., gdtNtgtM]
    gdt_tgt_counter = zeros(numTgts*numGdgts,1);
    
    
    for i=1:numRewards
        tgt_id = GR_ts(i,2);
        gdt_id = GR_ts(i,3);
        
        if gdt_id %skip gdt id 0, which corresponds to S0
            timeWindow = find(Sigs(:,1)<=GR_ts(i,1),numBins,'last');
            if ~isempty(timeWindow)
                gdt_tgt_index = (gdt_id-1)*numTgts + tgt_id;
                
                gdt_tgt_counter(gdt_tgt_index) = gdt_tgt_counter(gdt_tgt_index)+1;
                tmp_ave_sigs(gdt_tgt_counter(gdt_tgt_index),:,gdt_tgt_index) = mean(Sigs(timeWindow,2:end),1);
            end
        end
    end
    
    for i=1:numTgts*numGdts
        S(i+1,:)=mean(tmp_ave_sigs(1:gdt_tgt_counter(i),:,i));
    end

end

