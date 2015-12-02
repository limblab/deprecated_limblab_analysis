function trials=get_trials(words)
    %trials=get_trials(words)
    %words is a table, where the first column is labeled 'ts' and has
    %timestamps, and the second column is labeled 'word' and contains the
    %actual words.
    %makes a simple table with trial data that is common to any task. 
    %output is a dataset with the following columns:
    %trial_number   -allows later subtables to maintain trial order
    %start_time     -start of trial
    %go_time        -Time of first go cue, ignores multiple cues as you'd
    %                   get in RW
    %end_time       -end of trial
    %trial_result   -Numeric code: 0=Reward,1=Abort,2=Fail,3=Incomplete
    %
    %if there is a trial start word and no end word before the next trial
    %start, that trial start will be ignored. Also ignores the first 1s of
    %data to avoid problems associated with the missing 1s of kinematic
    %data

    word_start = hex2dec('10');
    
    start_time =  words.ts( bitand(hex2dec('f0'),words.word) == word_start &  words.ts>1.000);
    num_trials = length(start_time);

    word_go = hex2dec('30');
    go_cues =  words.ts(bitand(hex2dec('f0'), words.word) == word_go);

    word_end = hex2dec('20');
    end_time =  words.ts( bitand(hex2dec('f0'), words.word) == word_end);
    end_codes =  words.word( bitand(hex2dec('f0'), words.word) == word_end);
    
    %preallocate with -1
    stop_time=-1*ones(size(start_time));
    trial_result=stop_time;
    go_time=stop_time;
    
    for ind = 1:num_trials-1
        % Find the end of the trial
        if ind==num_trials
            trial_end_idx = find(end_time > start_time(ind), 1, 'first');
        else
            next_trial_start = start_time(ind+1);
            trial_end_idx = find(end_time > start_time(ind) & end_time < next_trial_start, 1, 'first');
        end
        if isempty(trial_end_idx)
            stop_time(ind) = -1;
            trial_result(ind) = -1;
        else
            stop_time(ind) = end_time(trial_end_idx);
            trial_result(ind) = mod(end_codes(trial_end_idx),32); %0 is reward, 1 is abort, 2 is fail, and 3 is incomplete (incomplete should never happen)
        end
        % Find any go cues 
        if ~isempty(trial_end_idx)
            go_idx=find(go_cues>start_time(ind) & go_cues<stop_time(ind),1);
            go_time(ind)=go_cues(go_idx);
        end
        
    end
    mask=trial_result~=-1;
    trials=table([1:sum(mask)]',start_time(mask),go_time(mask),stop_time(mask),trial_result(mask),'VariableNames',{'trial_number','start_time','go_time','end_time','trial_result'});
    
end