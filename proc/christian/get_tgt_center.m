function [Go_EOT_ts_w_tgt_centers] = get_tgt_center(out_struct)

    % This function returns a matrix of [ts tgt_x tgt_y]
    % out_struct can be either a BDF or a binnedData structure (as of 4/12/10)
    %
    % ts is the time at which a 'Go_Cue' or a 'End of trial' word was issue
    % tgt_x and tgt_y are the coordinates of the center of the target
    % corresponding to this trial, in "cursor position" coordinate system.
    % Note: for "Go_Cue" trials, the target is automatically defined as being at
    % (0,0), so it could be wrong in case the user sets a different center
    % target.

    w=WF_Words;

    %% -------------%
    % get targets id
    % --------------%
    numTrials = size(out_struct.targets.corners,1);
    Tgts = zeros(16,5); % [ Tgt_Id   tgt_xul   tgt_yul   tgt_xlr   tgt_ylr   ];
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
    Center_ts(:,2:3)=0;
    numCenters = size(Center_ts,1);

    %% -----------------------------%
    % get EOT ts and target center pairs
    % ------------------------------%
    words_and_Tgts=sortrows([out_struct.words;Tgts_ts]);

%     Center_and_Tgts_ts = zeros(size(Center_ts,numTgts);

%     numEOT = numel(out_struct.words(isWord(out_struct.words,'endtrial'),1));
    
    
%     numRewards = numel(out_struct.words(out_struct.words(:,2)==w.Reward,1));
    
%     Reward_ts = zeros(numRewards,2);
%     EOT_ts = zeros(size(Tgts_ts,1),3);
    EOT_ts = [];

    for i=1:numTgts
        % find the EOT_ts corresponding to target i
        ts_pairs = Get_Words_ts_pairs(w.Start, Tgts(i,1), w.IsEndWord, words_and_Tgts);

        %time stamps for End Of Trials for target i in first column of EOT_ts
        %target i x and y center coord in 2nd and 3rd columns
        tgt_x = mean([Tgts(i,2) Tgts(i,4)]);
        tgt_y = mean([Tgts(i,3) Tgts(i,5)]);
        tgt_centers = ones(size(ts_pairs,1),1)*[tgt_x tgt_y];
        EOT_ts = [EOT_ts; [ts_pairs(:,2) tgt_centers]];

%         % find the EOT_ts corresponding to target i
%         ts_pairs = Get_Words_ts_pairs(w.Start, Tgts(i,1), w.IsEndWord, words_and_Tgts);
%         tmpNum_ts = size(ts_pairs,1);
%         range = index:index+tmpNum_ts-1;
%         %time stamps for End Of Trials for target i in first column of EOT_ts
%         EOT_ts(range,1) = ts_pairs(:,2);
%         %target i x and y center coord in 2nd and 3rd columns
%         tgt_x = mean([Tgts(i,2) Tgts(i,4)]);
%         tgt_y = mean([Tgts(i,3) Tgts(i,5)]);
%         EOT_ts(range,2:3) = ones(length(range),1)*[tgt_x tgt_y];
%         %update index for next target
%         index = index+tmpNum_ts;
    end
    
    
    %concat and sort Center and End of Trial ts, with corresponding target center
    Go_EOT_ts_w_tgt_centers = sortrows([Center_ts;EOT_ts],1);
    
end


