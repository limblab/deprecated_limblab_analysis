function tt = vs_trial_table(bdf)
% CO_TRIAL_TABLE - returns a table containing the key timestamps for all of
%                  the center-out trials in BDF
%
% Each row of the table coresponds to a single trial.  Columns are as
% follows:
%    1: Start time
%    2: Target id                -- -1 for none (e.g., a neutral bump)
%    3: CT_ON
%    4: CT_Hold
%    5: OT_ON
%    6: Reach
%    7: OT_Hold
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
if isempty(start_words)
    word_start = hex2dec('1B'); %visual search
    start_words = words(words(:,2) == word_start, 1);    
end
num_trials = length(start_words);

word_ct_on = hex2dec('30');
ct_on_words= words( words(:,2) == word_ct_on, 1);

word_ct_hold = hex2dec('A0');
ct_hold_words= words( words(:,2) == word_ct_hold, 1);

word_ot_on = hex2dec('40');
ot_on_words = words( bitand(hex2dec('f0'),words(:,2)) == word_ot_on, 1);
ot_on_codes = words( bitand(hex2dec('f0'),words(:,2)) == word_ot_on, 2);

word_reach = hex2dec('80');
reach_words= words( words(:,2) == word_reach, 1);

word_ot_hold = hex2dec('A1');
ot_hold_words= words( words(:,2) == word_ot_hold, 1);

word_end = hex2dec('20');
end_words = words( bitand(hex2dec('f0'),words(:,2)) == word_end, 1);
end_codes = words( bitand(hex2dec('f0'),words(:,2)) == word_end, 2);

tt = zeros(num_trials-1, 10) - 1;

for trial = 1:num_trials-1
    % Start_time
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
    
    % Center target ON
    idx=[];
    idx = find(ct_on_words > start_time & ct_on_words < stop_time, 1, 'first');
    if isempty(idx)
        ct_on_time = -1;
    else
        ct_on_time = ct_on_words(idx);
    end
    
    % Center target Hold
    idx=[];
    idx = find(ct_hold_words > start_time & ct_hold_words < stop_time, 1, 'first');
    if isempty(idx)
        ct_hold_time = -1;
    else
        ct_hold_time = ct_hold_words(idx);
    end
    
    % Outer target On
    idx=[];
    idx = find(ot_on_words > start_time & ot_on_words < stop_time, 1, 'first');
    if isempty(idx)
        ot_on_time = -1;
        ot_dir = -1;
    else
        ot_on_time = ot_on_words(idx);
        ot_dir = bitand(hex2dec('0f'), ot_on_codes(idx));
    end

    % Reach (cursor out of center target)
    idx=[];
    idx = find(reach_words > start_time & reach_words < stop_time, 1, 'first');
    if isempty(idx)
        reach_time = -1;
    else
        reach_time = reach_words(idx);
    end
    
    % Outer target Hold
    idx=[];
    idx = find(ot_hold_words > start_time & ot_hold_words < stop_time, 1, 'first');
    if isempty(idx)
        ot_hold_time = -1;
    else
        ot_hold_time = ot_hold_words(idx);
    end
    
    % Find movement onset
    if trial_result == double('R') || trial_result == double('I')
        try
            sidx = find(bdf.vel(:,1) > start_time,1,'first'):find(bdf.vel(:,1) > stop_time+1,1,'first');

            t = bdf.vel(sidx,1);                                % Set up time index vector
            s = sqrt(bdf.vel(sidx,2).^2 + bdf.vel(sidx,3).^2);  % Calculate speeds

            d = [0; diff(smooth(s,100))*25];                    % Absolute acceleration (dSpeed/dt)
            dd = [diff(smooth(d,100)); 0];                      % d^2 Speed / dt^2
            peaks = dd(1:end-1)>0 & dd(2:end)<0;                % zero crossings are abs. acc. peaks
            mvt_start = ot_on_time;
            
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
        ot_dir, ...     % Outer target direction (id) (-1 for none)
        ct_on_time,...  % Timestamp of CT On event
        ct_hold_time,...% Cursor in center target
        ot_on_time,...  % Timestamp of OT On event
        reach_time,...  % Cursor out of center target
        ot_hold_time,...% Cursor in outer target
        onset, ...      % Detected movement onset
        stop_time, ...  % End of trial
        trial_result];  % Result of trial ('R', 'A', 'I', or 'N')
end



