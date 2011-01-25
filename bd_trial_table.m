function tt = bd_trial_table(bdf)
% BD_TRIAL_TABLE - returns a table containing the key timestamps for all of
%                  the ball device trials in BDF
%
% Each row of the table coresponds to a single trial.  Columns are as
% follows:
%    1: Start time
%    2: Hand on Touch Pad
%    3: Go cue (word = Go | Catch)
%    4: Trial Type (0:Go, 1:Catch)
%    5: Pick up 
%    6: Trial End time
%    7: Trial result        -- R, A, F, or I

% $Id: $

words = bdf.words;
w = BD_Words();

result_codes = 'RAFI------------';

% Isolate the individual word timestamps
start_words = words(words(:,2) == w.Start, 1);
num_trials = length(start_words);

TP_times = words( words(:,2) == w.Touch_Pad, 1);

PU_times = words( words(:,2) == w.Pickup, 1);

go_cues = words( bitand(hex2dec('f3'),words(:,2)) == w.Go_Cue | ...
                 bitand(hex2dec('f3'),words(:,2)) == w.Catch, 1);
go_codes = words( bitand(hex2dec('f3'),words(:,2)) == w.Go_Cue | ...
                 bitand(hex2dec('f3'),words(:,2)) == w.Catch, 2) -w.Go_Cue;             

end_words = words( bitand(hex2dec('f0'),words(:,2)) == w.End_Code, 1);
end_codes = words( bitand(hex2dec('f0'),words(:,2)) == w.End_Code, 2);

tt = zeros(num_trials-1, 7) - 1;

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
    
    % Touch Pad
    TP_idx = find(TP_times > start_time & TP_times < stop_time, 1, 'first');
    if isempty(TP_idx)
        TP_time = -1;
    else
        TP_time = TP_times(TP_idx);
    end
        
    % Go cue & Trial Type
    go_cue_idx = find(go_cues > start_time & go_cues < stop_time, 1, 'first');
    if isempty(go_cue_idx)
        go_cue = -1;
        trial_type = -1;
    else
        go_cue = go_cues(go_cue_idx);
        trial_type = go_codes(go_cue_idx);
    end
    
    % Pick up
    PU_idx = find(PU_times > start_time & PU_times < stop_time, 1, 'first');
    if isempty(PU_idx)
        PU_time = -1;
    else
        PU_time = PU_times(PU_idx);
    end
            
    % Build table
    tt(trial,:) = [...
        start_time, ... % Trial start
        TP_time, ...    % Hand on Touch Pad
        go_cue, ...     % Timestamp of Go Cue
        trial_type, ... % Trial type (0=Go, 1=Catch)
        PU_time, ...    % Timestamp of ball pick up sensor
        stop_time, ...  % End of trial (timestamp of ball drop sensor or timeout)
        trial_result];  % Result of trial ('R', 'A', 'I', or 'N')
end
%    1: Start time
%    2: Hand on Touch Pad
%    3: Go cue (word = Go | Catch)
%    4: Trial Type (0:Go, 1:Catch)
%    5: Pick up 
%    6: Trial End time
%    7: Trial result        -- R, A, F, or I


