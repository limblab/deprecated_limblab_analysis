function [Center_ts, Reward_ts] = get_tgt_id(out_struct)

    w=WF_Words;

    %% -------------%
    % get targets id
    % --------------%
    numTrials = size(out_struct.targets.corners,1);
    Tgts = zeros(16,5); % [ Tgt_Id   tgt_y   tgt_h   tgt_x   tgt_w   ];
    Tgts_ts = zeros(numTrials,2);
    numTgts = 0;

    for i=1:numTrials
        current_target= out_struct.targets.corners(i,:);
        existing_target = find( Tgts(:,2)==current_target(2) & Tgts(:,3)==current_target(3) & ...
                                Tgts(:,4)==current_target(4) & Tgts(:,5)==current_target(5) );
        if ~isempty(existing_target)
            Tgts_ts(i,:)=[current_target(1) existing_target];
        else
            numTgts = numTgts+1;
            Tgts(numTgts,:)=[numTgts current_target(2:5)];
            Tgts_ts(i,:)=[current_target(1) numTgts];
        end
    end

    Tgts = Tgts(1:numTgts,:);

    %% ------------%
    % get center ts
    % -------------%
    Center_ts = out_struct.words(out_struct.words(:,2)==w.Go_Cue,1);
    Center_ts(:,2)=0;
    numCenters = size(Center_ts,1);

    %% -----------------------------%
    % get reward and target ts pairs
    % ------------------------------%
    words_and_Tgts=sortrows([out_struct.words;Tgts_ts]);

%     Center_and_Tgts_ts = zeros(size(Center_ts,numTgts);
    numRewards = numel(out_struct.words(out_struct.words(:,2)==w.Reward,1));
    
    Reward_ts = zeros(numRewards,2);
    index=1;
    for i=1:numTgts
        ts_pairs = Get_Words_ts_pairs(w.Start, Tgts(i,1), w.Reward, words_and_Tgts);
        tmpNum_ts = size(ts_pairs,1);
        Reward_ts(index:tmpNum_ts-1,1) = ts_pairs(:,2);
        Reward_ts(index:tmpNum_ts-1,2) = i;
        index = index+tmpNum_ts;
    end

end


