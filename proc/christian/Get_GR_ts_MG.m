function [ts] = Get_GR_ts_MG(out_struct)
    % [ts] is a NxM array, N=2xNumReward, M=3 ([ts tgt gdt])
    % tgt = 0 if ts corresponds to touchPad hold
    % tgt = [1-15] and gdt = [1-4] if ts corresponds to Reward time

    w=MG_Words;
    
    first_start = find(out_struct.words(:,2)==w.Start,1);
    first_start_ts = out_struct.words(first_start,1);

    %%---------------------------------%
    % get matching Go_cue and Reward ts
    %%---------------------------------%
    
    GR_pairs = Get_Words_ts_pairs(w.Start, w.Go_Cue, w.Reward, out_struct.words);
    
    numRewards = size(GR_pairs,1);
    
    Go_ts = [GR_pairs(:,1) zeros(numRewards,2)];
    Reward_ts = [GR_pairs(:,2) zeros(numRewards,2)];
    
    %%-----------------------%
    % get targets and gadgets
    %%-----------------------%
    
    Tgts_ts = out_struct.words(out_struct.words(:,2) >= w.Reach ...
                      & out_struct.words(:,2) <= w.Reach + 15,:);
                  
    Tgts_ts(:,2) = Tgts_ts(:,2) - w.Reach + 1;
    
    num_tgts = length(unique(Tgts_ts(:,2)));
                  
    Gdts_ts = out_struct.words(out_struct.words(:,2) >= w.Gadget_On ...
                      & out_struct.words(:,2) <= w.Gadget_On + 3,:);

    Gdts_ts(:,2) = Gdts_ts(:,2) - w.Gadget_On + 1;
                  
    num_gdts = length(unique(Gdts_ts(:,2)));

    
        
    %%----------------------------------------------%
    % Match Reward ts with corresponding tgt and gdt
    %%----------------------------------------------%
    
    for i = 1:numRewards
        tgt = Tgts_ts( sum(Tgts_ts(:,1)<Reward_ts(i,1)),2) ;
        gdt = Gdts_ts( sum(Gdts_ts(:,1)<Reward_ts(i,1)),2) ;
        Reward_ts(i,2:3) = [tgt gdt];
    end
    
    ts = sortrows([Go_ts; Reward_ts]);
    
end
