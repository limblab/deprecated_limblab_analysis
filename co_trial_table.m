function tt = co_trial_table(bdf)
% CO_TRIAL_TABLE - returns a table containing the key timestamps for all of
%                  the center-out trials in BDF
%
% Each row of the table coresponds to a single trial.  Columns are as
% follows:
%   Start time
%   Bump direction          -- -1 for none
%   Bump phase              -- H (hold), D (delay), or M (movement)
%   Bump time
%   Target                  -- -1 for none (e.g., a neutral bump)
%   OT on time
%   Go cue
%   Movement start time     -- Not implemented yet
%   Trial End time
%   Trial result            -- R, A, I, or N (N coresponds to no-result)

% $Id$

words = bdf.words;
speed = [bdf.vel(:,1), sqrt(bdf.vel(:,2).^2 + bdf.vel(:,3).^2)];

result_codes = 'RAFI------------';

% Isolate the individual word timestamps
bump_word_base = hex2dec('50');
all_bumps = words(words(:,2) >= (bump_word_base) & words(:,2) <= (bump_word_base+5), 1)';
all_bump_codes = words(words(:,2) >= (bump_word_base) & words(:,2) <= (bump_word_base+5), 2)';

word_start = hex2dec('11');
start_words = words(words(:,2) == word_start, 1);
num_trials = length(start_words);

word_ot_on = hex2dec('40');
ot_on_words = words( bitand(hex2dec('f0'),words(:,2)) == word_ot_on, 1);
ot_on_codes = words( bitand(hex2dec('f0'),words(:,2)) == word_ot_on, 2);

word_go = hex2dec('31');
go_cues = words(words(:,2) == word_go, 1);

word_end = hex2dec('20');
end_words = words( bitand(hex2dec('f0'),words(:,2)) == word_end, 1);
end_codes = words( bitand(hex2dec('f0'),words(:,2)) == word_end, 2);

tt = zeros(num_trials-1, 10) - 1;

for trial = 1:num_trials-1
    start_time = start_words(trial);
    
    % Find the end of the trial
    next_trial_start = start_words(trial+1);
    trial_end_idx = find(end_words > start_time & end_words < next_trial_start, 1, 'first');
    if isempty(trial_end_idx)
        stop_time = next_trial_start - .001;
        trial_result = -1;
    else
        stop_time = end_words(trial_end_idx);
        trial_result = double(result_codes(bitand(hex2dec('0f'),end_codes(trial_end_idx)) + 1));
    end
       
    % Bump direction and time
    bump_word_idx = find(all_bumps > start_time & all_bumps < stop_time, 1, 'first');
    if isempty(bump_word_idx)
        bump_time = -1;
        bump_dir = -1;
    else
        bump_time = all_bumps(bump_word_idx);
        bump_dir = bitand(hex2dec('0f'),all_bump_codes(bump_word_idx));
    end
    
    % Outer target
    ot_idx = find(ot_on_words > start_time & ot_on_words < stop_time, 1, 'first');
    if isempty(ot_idx)
        ot_time = -1;
        ot_dir = -1;
    else
        ot_time = ot_on_words(ot_idx);
        ot_dir = bitand(hex2dec('0f'), ot_on_codes(ot_idx));
    end
    
    % Go cue
    go_cue_idx = find(go_cues > start_time & go_cues < stop_time, 1, 'first');
    if isempty(go_cue_idx)
        go_cue = -1;
    else
        go_cue = go_cues(go_cue_idx);
    end
    
    % Classify bump phasing
    if ot_time == -1
        bump_phase = double('H');
    elseif bump_time > go_cue + .002
        bump_phase = double('M');
    elseif bump_time ~= -1
        bump_phase = double('D');
    end
     
    % Find movement onset
    %spd_start_idx = find(speed(:,1) > start_time, 1, 'first');
    %spd_stop_idx = find(speed(:,1) < stop_time, 1, 'last');
    %trial_speed = speed(spd_start_idx:spd_stop_idx,:);
    
    tt(trial,:) = [start_time bump_dir bump_phase bump_time ot_dir ot_time go_cue -1 stop_time trial_result];
end




