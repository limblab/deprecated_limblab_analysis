function tt = getCOTrialTable(bdf)
% GETCOTRIALTABLE returns a table containing the key timestamps for
% all of the successful trials in a center out file. This code is meant to
% be a generally useful function with some key information that can then be
% copied and modified to suit individual analysis needs.
%
% Each row of the table coresponds to a single trial.  Columns are as
% follows:
%    1: Start time
%    2: Target 'on' time
%    3: Go cue
%    4: Movement start time based on velocity threshold
%    5: Trial End time
%    6-9: Target location -- ULx ULy LRx LRy

words = bdf.words;

result_codes = 'RAFI------------';

word_start = hex2dec('11');
start_words = words(words(:,2) == word_start, 1);
if isempty(start_words)
    word_start = hex2dec('1B'); %visual search
    start_words = words(words(:,2) == word_start, 1);
end
num_trials = length(start_words);

word_ot_on = hex2dec('40');
ot_on_words = words( bitand(hex2dec('f0'),words(:,2)) == word_ot_on, 1);
ot_on_codes = words( bitand(hex2dec('f0'),words(:,2)) == word_ot_on, 2);

word_go = hex2dec('31');
go_cues = words(words(:,2) == word_go, 1);

word_end = hex2dec('20');
end_words = words( bitand(hex2dec('f0'),words(:,2)) == word_end, 1);
end_codes = words( bitand(hex2dec('f0'),words(:,2)) == word_end, 2);

tt = zeros(num_trials-1, 9) - 1;

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
    dbtimes = vertcat(bdf.databursts{:,1});
    dbidx = find(dbtimes > start_time, 1, 'first');
    burst_size = bdf.databursts{1,2}(1);
    target = bdf.databursts{dbidx,2}(burst_size-15:end);
    target = bytes2float(target, 'little')';
    
    % Go cue
    go_cue_idx = find(go_cues > start_time & go_cues < stop_time, 1, 'first');
    if isempty(go_cue_idx)
        go_cue = -1;
    else
        go_cue = go_cues(go_cue_idx);
    end
    
    % Find movement onset
    if trial_result == double('R')
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
                mvt_start = NaN;
            end
            mvt_peak = find(peaks & t(2:end) > mvt_start & d(2:end) > 1, 1, 'first');
            thresh = d(mvt_peak)/2;                             % Threshold is half max of acceleration peak
            on_idx = find(d<thresh & t<t(mvt_peak),1,'last');
            onset = t(on_idx); % Movement onset is last threshold crossing before peak
        catch
            onset = NaN;
        end
    else
        onset = NaN;
    end
    
    % Build table
    if ot_dir ~= -1 % ignore trials that don't make it to target presentation
        tt(trial,:) = [...
            start_time, ... % Trial start
            ot_time, ...    % Timestamp of OT On event
            go_cue, ...     % Timestamp of Go Cue
            onset, ...      % Detected movement onset
            stop_time, ...  % End of trial
            target];        % location of target
    end
end

% Remove trials that have no go cue?
remInds = tt(:,4) == -1;
tt(remInds,:) = [];
remInds = isnan(tt(:,5));
tt(remInds,:) = [];


