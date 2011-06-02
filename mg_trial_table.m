function tt = mg_trial_table(bdf)
% BD_TRIAL_TABLE - returns a table containing the key timestamps for all of
%                  the ball device trials in BDF
%
% Each row of the table coresponds to a single trial.  Columns are as
% follows:
%    1: Start time
%    2: Hand on Touch Pad
%    3: Go cue (word = Go | Catch)
%    4: Trial Type (0:Go, 1:Catch)
%    5: Gadget ID (0:3)
%    6: Target ID (0:15)
%    12: Target UL X
%    8: Target UL Y
%    9: Target LR X
%    10:Target LR Y
%    11:Trial End time
%    12:Trial result        -- R, A, F, or I

% $Id: bd_trial_table.m 381 2011-02-15 15:08:01Z brian $

words = bdf.words;
w = MG_Words();

result_codes = 'RAFI------------';

% Isolate the individual word timestamps
start_words = words(words(:,2) == w.Start, 1);
num_trials = length(start_words);

TP_times = words( words(:,2) == w.Touch_Pad, 1);

gadget_words = words(bitand(hex2dec('f0'),words(:,2)) == w.Gadget_On,1);
gadget_codes = w.GetGdt(words(bitand(hex2dec('f0'),words(:,2)) == w.Gadget_On,2));

target_words = words(bitand(hex2dec('f0'),words(:,2)) == w.Reach,1);
target_codes = w.GetTgt(words(bitand(hex2dec('f0'),words(:,2)) == w.Reach,2));

go_cues = words( bitand(hex2dec('f3'),words(:,2)) == w.Go_Cue | ...
                 bitand(hex2dec('f3'),words(:,2)) == w.Catch, 1);
go_codes = words( bitand(hex2dec('f3'),words(:,2)) == w.Go_Cue | ...
                 bitand(hex2dec('f3'),words(:,2)) == w.Catch, 2) -w.Go_Cue;             

end_words = words( bitand(hex2dec('f0'),words(:,2)) == w.End_Code, 1);
end_codes = words( bitand(hex2dec('f0'),words(:,2)) == w.End_Code, 2);

tt = zeros(num_trials-1, 12) - 1;

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
    
    % Gadget ID
    gadget_idx = find(gadget_words > start_time & gadget_words < stop_time, 1, 'first');
    if isempty(gadget_idx)
        gadget = -1;
    else
        gadget = gadget_codes(gadget_idx);
    end
    
    % Target ID
    target_idx = find(target_words > start_time & target_words < stop_time, 1, 'first');
    if isempty(target_idx)
        target = -1;
    else
        target = target_codes(target_idx);
    end
    
    % Target UL and LR Corners
    if isfield(bdf,'targets')
        target_idx = find(bdf.targets.corners(:,1) > start_time & bdf.targets.corners(:,1) < stop_time, 1, 'first');
        if isempty(target_idx)
            tgt_corners = [-1 -1 -1 -1];
        else
            tgt_corners = bdf.targets.corners(target_idx,2:5);
        end
    else
        tgt_corners = [-1 -1 -1 -1];
    end
            
    % Build table
    tt(trial,:) = [...
        start_time, ... % Trial start
        TP_time, ...    % Hand on Touch Pad
        go_cue, ...     % Timestamp of Go Cue
        trial_type, ... % Trial type (0=Go, 1=Catch)
        gadget, ...     % Gadget ID (0 to 3)
        target, ...     % Target ID (0 to 15)
        tgt_corners,... % Target corners [ULx, ULy, LRx, LRy]
        stop_time, ...  % End of trial (timestamp of ball drop sensor or timeout)
        trial_result];  % Result of trial ('R', 'A', 'I', or 'N')
end
%    1: Start time
%    2: Hand on Touch Pad
%    3: Go cue (word = Go | Catch)
%    4: Trial Type (0:Go, 1:Catch)
%    5: Gadget ID (0:3)
%    6: Target ID (0:15)
%    7: Target UL X
%    8: Target UL Y
%    9: Target LR X
%    10:Target LR Y
%    11:Tgt Hold time
%    12:Trial End time
%    13:Trial result        -- R, A, F, or I


