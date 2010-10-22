function tt = co_trial_table(bdf)
% CO_TRIAL_TABLE - returns a table containing the key timestamps for all of
%                  the center-out trials in BDF
%
% Each row of the table coresponds to a single trial.  Columns are as
% follows:
%    1: Start time
%    2: Bump direction          -- -1 for none
%    3: Bump phase              -- H (hold), D (delay), or M (movement)
%    4: Bump time
%    5: Target                  -- -1 for none (e.g., a neutral bump)
%    6: OT on time
%    7: Go cue
%    8: Movement start time
%    9: Trial End time
%   10: Trial result            -- R, A, I, or N (N coresponds to no-result)

% $Id$

words = bdf.words;

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
    if bump_time == -1
        bump_phase = -1;
    elseif ot_time == -1
        bump_phase = double('H');
    elseif bump_time > go_cue + .002
        bump_phase = double('M');
    else
        bump_phase = double('D');
    end
     
    % Find movement onset
    if trial_result == double('R') || bump_phase == double('H')
        try
            sidx = find(bdf.vel(:,1) > start_time,1,'first'):find(bdf.vel(:,1) > stop_time+1,1,'first');

            t = bdf.vel(sidx,1);                                % Set up time index vector
            s = sqrt(bdf.vel(sidx,2).^2 + bdf.vel(sidx,3).^2);  % Calculate speeds

            d = [0; diff(smooth(s,100))*25];                    % Absolute acceleration (dSpeed/dt)
            dd = [diff(smooth(d,100)); 0];                      % d^2 Speed / dt^2
            peaks = dd(1:end-1)>0 & dd(2:end)<0;                % zero crossings are abs. acc. peaks
            if go_cue > 0
                mvt_start = go_cue;
            else
                mvt_start = bump_time;
            end
            mvt_peak = find(peaks & t(2:end) > mvt_start & d(2:end) > 1, 1, 'first'); 
            thresh = d(mvt_peak)/2;                             % Threshold is half max of acceleration peak
            onset = t(find(d<thresh & t<t(mvt_peak),1,'last')); % Movement onset is last threshold crossing before peak
        catch
            onset = NaN;
        end
    else
        onset = NaN;
    end
    
    % Build table
    tt(trial,:) = [...
        start_time, ... % Trial start
        bump_dir, ...   % Bump Direction (-1 for none)
        bump_phase, ... % Bump Timing (-1 for none, 'H' for center hold, 'M' for movement, 'D' for go-cue
        bump_time, ...  % Timestamp of bump event
        ot_dir, ...     % Outer target direction (-1 for none)
        ot_time, ...    % Timestamp of OT On event
        go_cue, ...     % Timestamp of Go Cue
        onset, ...      % Detected movement onset
        stop_time, ...  % End of trial
        trial_result];  % Result of trial ('R', 'A', 'I', or 'N')
end



