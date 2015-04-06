function [varargout] = wf_trial_table_hdr(bdf)
% WF_TRIAL_TABLE - returns a table containing the key timestamps for all of
%                  the wrist-flexion trials in BDF
%
% Each row of the table coresponds to a single trial.  Columns are as
% follows:
%    1: Start time
%  2-5: Target              -- ULx ULy LRx LRy
%    6: Outer target (OT) 'on' time
%    7: Go cue
%    8: Trial End time
%    9: Trial result        -- R, A, I, or F 
%   10: Target ID           -- Target ID (based on location)
%   11: Catch               -- 0 or 1, regular or catch trial
%   12: Adapt               -- 0 or 1, regular or adapt trial (as of 2013-10-18, adapt only during catch)

% $Id: wf_trial_table.m 1677 2015-03-03 20:00:37Z chris $

words = bdf.words;

result_codes = 'RAFI------------';

% Isolate the individual word timestamps
word_start = hex2dec('17');
start_words = words(words(:,2) == word_start, 1);
num_trials = length(start_words);

word_ot_on = hex2dec('40'); 
ot_on_words = words( bitand(hex2dec('f0'),words(:,2)) == word_ot_on, 1);
ot_on_codes = words( bitand(hex2dec('f0'),words(:,2)) == word_ot_on, 2);

word_go = hex2dec('31');
go_cues = words(words(:,2) == word_go, 1);

word_catch = hex2dec('32');
catch_words= words(words(:,2)==word_catch,1);

word_adapt = hex2dec('B0');
adapt_words= words(words(:,2)==word_adapt,1);


word_end = hex2dec('20');
end_words = words( bitand(hex2dec('f0'),words(:,2)) == word_end, 1);
end_codes = words( bitand(hex2dec('f0'),words(:,2)) == word_end, 2);

dbtimes = vertcat(bdf.databursts{:,1});

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
       
    % Outer target
    ot_idx = find(ot_on_words > start_time & ot_on_words < stop_time, 1, 'first');
    if isempty(ot_idx)
        ot_time = -1;
        ot_dir = -1;
    else
        ot_time = ot_on_words(ot_idx);
        ot_dir = bitand(hex2dec('0f'), ot_on_codes(ot_idx));
    end
    
    % Target location
    dbidx = find(dbtimes > start_time, 1, 'first');
    burst_size = bdf.databursts{1,2}(1);
    target = bdf.databursts{dbidx,2}(burst_size-15:end);
    target = bytes2float(target, 'little')';
    
    % Target ID
    if isempty(target)
        warning('databurst(%d) is corrupted, no target info',dbidx);
        target = [-1 -1 -1 -1];
        target_id = -1;
    else
        target_id = get_tgt_id(target);
    end
    
    % Go cue ts
    go_cue_idx = find(go_cues > start_time & go_cues < stop_time, 1, 'first');
    if isempty(go_cue_idx)
        catch_word_idx = find(catch_words > start_time & catch_words < stop_time, 1, 'first');
        if isempty(catch_word_idx)
            go_cue = -1;
        else
            go_cue = catch_words(catch_word_idx);
        end
    else
        go_cue = go_cues(go_cue_idx);
    end
    
    % catch
    catch_word_idx = find(catch_words > start_time & catch_words < stop_time, 1, 'first');
    if isempty(catch_word_idx)
        catch_word = 0;
    else
        catch_word = 1;
    end   

   % Adapt
    adapt_word_idx = find(adapt_words > start_time & adapt_words < stop_time, 1, 'first');
    if isempty(adapt_word_idx)
        adapt_word = 0;
    else
        adapt_word = 1;
    end       
            
    % Build table
    tt(trial,:) = [...
        start_time, ... % Trial start
        target, ...     % Outer target coordinates
        ot_time, ...    % Timestamp of OT On event
        go_cue, ...     % Timestamp of Go Cue
        stop_time, ...  % End of trial
        trial_result,...% Result of trial ('R', 'A', 'I', or 'N')
        target_id,...   % Target ID based on location
        catch_word,...  % whether or not trial is a catch trial
        adapt_word];    % whether or not trial is an adaptation trial
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%build hdr object with associated column numbers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tt_hdr.start_time               = 1;
tt_hdr.ot_time                  = 6;
tt_hdr.go_cue                  = 7;
tt_hdr.end_time                 = 8;
tt_hdr.trial_result             = 9;




varargout = {tt,tt_hdr};