function [ts] = Get_Center_Go_EOT_ts(out_struct)
    % reads a bdf file and returns a list of CT_On, Go_Cue and EndOfTrial ts
    % argin-
    % out_struct: bdf file to be read
    %
    % argout-
    % ts : 3 x numtrials array of corresponding CT_On, Go_cue and EndOfTrial ts
    %      i.e. [CT_On  go_cue_ts  EOT_ts]
    %

    w=WF_Words;

    %% --------------%
    % get target list
    % ---------------%
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

    %% -----------------------------%
    % get reward and target ts pairs
    % ------------------------------%
    words_and_Tgts=sortrows([out_struct.words;Tgts_ts]);
  
    numRewards = numel(out_struct.words(out_struct.words(:,2)==w.Reward,1));
    Reward_ts = zeros(numRewards,2);
    
    index=1;
    for i=1:numTgts
        ts_pairs = Get_Words_ts_pairs(w.Start, Tgts(i,1), w.Reward, words_and_Tgts);
        tmpNum_ts = size(ts_pairs,1);
        if tmpNum_ts
            Reward_ts(index:index+tmpNum_ts-1,1) = ts_pairs(:,2);
            Reward_ts(index:index+tmpNum_ts-1,2) = i;
            index = index+tmpNum_ts;
        end
    end
    
    ts = sortrows([Center_ts; Reward_ts]);

%%%%% Temp: to use for data with tgt offset by 1 trial
%     tmp=sortrows(Reward_ts);
%     tmp = [tmp(1:end-1,1) tmp(2:end,2)];
%     
%     ts = sortrows([Center_ts; tmp]);
% %%%%% End of Temp        

    
end


