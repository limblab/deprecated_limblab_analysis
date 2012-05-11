function tt = bc_trial_table(bdf)
% BC_TRIAL_TABLE - returns a table containing the key timestamps for all of
%                  the 2 bump choice trials in BDF
%
% Each row of the table coresponds to a single trial.  Columns are as
% follows:
%    1: Start time
%    2: Staircase used
%    3: Bump direction
%    4: Bump time
%    5: Time of go queue
%    6: End trial time
%    7: Trial result            -- R, F, or A
%    8: Direction moved         -- 1 for primary, 2 for secondary

words = bdf.words;
db_times = cell2mat( bdf.databursts(:,1) );

result_codes = 'RAFI------------';

bump_word_base = hex2dec('50');
all_bumps = words(words(:,2) >= (bump_word_base) & words(:,2) <= (bump_word_base+5), 1)';

word_start = hex2dec('1F');
start_words = words(words(:,2) == word_start, 1);

num_trials = length(start_words);

word_go = hex2dec('31');
go_cues = words(words(:,2) == word_go, 1);

word_end = hex2dec('20');
end_words = words( bitand(hex2dec('f0'),words(:,2)) == word_end, 1);
end_codes = words( bitand(hex2dec('f0'),words(:,2)) == word_end, 2);

tt = zeros(num_trials-1, 8);

for trial = 1:num_trials-1
    try
        start_time = start_words(trial);
        next_trial_start = start_words(trial+1);
        trial_end_idx = find(end_words > start_time & end_words < next_trial_start, 1, 'first');
        if isempty(trial_end_idx)
            end_time = next_trial_start - .001;
            trial_result = -1;
        else
            end_time = end_words(trial_end_idx);
            trial_result = double(result_codes(bitand(hex2dec('0f'),end_codes(trial_end_idx)) + 1));
        end

        idx = find(all_bumps > start_time & all_bumps < end_time, 1);
        if ~isempty(idx)
            bump_time = all_bumps(idx);
        else
            bump_time = 0;
        end

        idx = find(go_cues > start_time & go_cues < end_time, 1);
        if ~isempty(idx)
            go_cue = go_cues(idx);
        else
            go_cue = 0;
        end

        db = bdf.databursts{trial,2};
        %sc_id = db(8);
        %bump_dir = bytes2float(db(13:16));
        sc_id = db(10);
        bump_dir = bytes2float(db(15:18));
        tt(trial,:) = [start_time sc_id bump_dir bump_time go_cue end_time trial_result 0];
    catch
        tt(trial,:) = [NaN NaN NaN NaN NaN NaN NaN NaN];
    end
end

tt = tt(~isnan(tt(:,1)),:);

lr = (tt(:,7)==double('R') & tt(:,2)==1) | (tt(:,2)==0 & tt(:,7)==double('F'));
lr = lr | ((tt(:,7)==double('R') & tt(:,2)==3) | (tt(:,2)==2 & tt(:,7)==double('F')));
tt(:,8) = lr;
