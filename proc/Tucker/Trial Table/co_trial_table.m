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


word_start = hex2dec('11');
start_words = words(words(:,2) == word_start, 1);

num_trials = length(start_words);
disp(strcat('Trials: ',num2str(num_trials)))


word_end = hex2dec('20');
end_words = words( bitand(hex2dec('f0'),words(:,2)) == word_end, 1);
end_codes = words( bitand(hex2dec('f0'),words(:,2)) == word_end, 2);

word_reward=word_end;
rewards=words(words(:,2)==word_reward,1);
disp(strcat('Rewards: ',num2str(length(rewards))))
word_abort=hex2dec('21');
aborts=words(words(:,2)==word_abort,1);
disp(strcat('Aborts: ',num2str(length(aborts))))
word_fail=hex2dec('22');
fails=words(words(:,2)==word_fail,1);
disp(strcat('Fails: ',num2str(length(fails))))
word_incomplete=hex2dec('23');
incomplete=words(words(:,2)==word_incomplete,1);
disp(strcat('Incompletes: ',num2str(length(incomplete))))
z=words(words(:,2)==0,1);
disp(strcat('Num zeros: ',num2str(length(z))))
word_go = hex2dec('31');
go_cues = words(words(:,2) == word_go, 1);
disp(strcat('Go cues: ',num2str(length(go_cues))))

bump_word_base = hex2dec('50');
all_bumps = words(words(:,2) >= (bump_word_base) & words(:,2) <= (bump_word_base+5), 1)';
disp(strcat('Bumps: ',num2str(length(all_bumps))))

disp('')
db=bdf.databursts{1,2};
disp(strcat('Num Bytes in DB: ',num2str(db(1))))
size(db)


tt = zeros(num_trials-1, 5);
disp(size(tt))

        start_time = start_words(1);
disp(size(start_time)  )      
        
        next_trial_start = start_words(1+1);
        trial_end_idx = find(end_words > start_time & end_words < next_trial_start, 1, 'first');
        if isempty(trial_end_idx)
            end_time = next_trial_start - .001;
            trial_result = -1;
        else
            end_time = end_words(trial_end_idx);
            trial_result = double( result_codes( end_codes(trial_end_idx)-word_end + 1 ) );
        end
disp(size(end_time))
disp(size(trial_result))
        idx = find(all_bumps > start_time & all_bumps < end_time, 1);
        if ~isempty(idx)
            bump_time = all_bumps(idx);
        else
            bump_time = 0;
        end
disp(size(bump_time))
        idx = find(go_cues > start_time & go_cues < end_time, 1);
        if ~isempty(idx)
            go_cue = go_cues(idx);
        else
            go_cue = 0;
        end
disp(size(go_cue))

% for trial = 1:num_trials-1
% %    try
%         start_time = start_words(trial);
%         next_trial_start = start_words(trial+1);
%         trial_end_idx = find(end_words > start_time & end_words < next_trial_start, 1, 'first');
%         if isempty(trial_end_idx)
%             end_time = next_trial_start - .001;
%             trial_result = -1;
%         else
%             end_time = end_words(trial_end_idx);
%             trial_result = double( result_codes( end_codes(trial_end_idx)-word_end + 1 ) );
%         end
% 
%         idx = find(all_bumps > start_time & all_bumps < end_time, 1);
%         if ~isempty(idx)
%             bump_time = all_bumps(idx);
%         else
%             bump_time = 0;
%         end
% 
%         idx = find(go_cues > start_time & go_cues < end_time, 1);
%         if ~isempty(idx)
%             go_cue = go_cues(idx);
%         else
%             go_cue = 0;
%         end
% 
%         tt(trial,:)=[start_time, bump_time, go_cue, end_time, trial_result];
% end
