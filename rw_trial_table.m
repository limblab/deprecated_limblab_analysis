function varargout = rw_trial_table(bdf)
    % CO_TRIAL_TABLE - returns a table containing the key timestamps for all of
    %                  the random walk trials in BDF
    %
    % Each row of the table coresponds to a single trial.  Columns are as
    % follows:
    %    1: Start time
    %    2: max number of targets
    %    3: number of targets attempted
    %    4: x offset
    %    5: y offset
    %    6: target size - tolerance
    %    [7->6+(2*num_tgts)]: [Go_types, Go_times] (Go_types: 0=Center_target_on, 1=Go_cue, 2=Catch_trial)
    %    (6+2*num_tgts)+1   : Trial End time
    %    (6+2*num_tgts)+2   : Trial result    -- R, A, F, I or N (N coresponds to no-result)

    words = bdf.words;

    result_codes = 'RAFI------------';

    % Isolate the individual word timestamps
    % bump_word_base = hex2dec('50');
    % all_bumps = words(words(:,2) >= (bump_word_base) & words(:,2) <= (bump_word_base+5), 1)';
    % all_bump_codes = words(words(:,2) >= (bump_word_base) & words(:,2) <= (bump_word_base+5), 2)';

    word_start = hex2dec('12');
    start_words = words(words(:,2) == word_start & words(:,1)>1.000, 1);
    num_trials = length(start_words);

    word_go = hex2dec('30');
    go_cues = words(bitand(hex2dec('f0'),words(:,2)) == word_go, 1);
    go_codes= words(bitand(hex2dec('f0'),words(:,2)) == word_go, 2)-word_go;

    word_end = hex2dec('20');
    end_words = words( bitand(hex2dec('f0'),words(:,2)) == word_end, 1);
    end_codes = words( bitand(hex2dec('f0'),words(:,2)) == word_end, 2);

    num_targets = (bdf.databursts{1,2}(1)-18)/8;

    %tt= [-1 -1 -1 -1 -1 -1 NaN ... NaN -1 -1]
    tt = [(zeros(num_trials-1,6)-1)  NaN(num_trials-1,2*num_targets)  (zeros(num_trials-1,2)-1) ];

    for trial = 1:num_trials-1
        start_time = start_words(trial);
        if (bdf.databursts{trial,2}(1)-18)/8 ~= num_targets
            warning('rw_trial_table: Inconsistent number of targets @ t = %.3f, operation interrupted',start_time);
            tt = tt(1:trial-1,:);
            continue;
        end

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

        % Go cues
        go_cue_idx = find(go_cues > start_time & go_cues < stop_time);
        these_go_cues = -1*ones(1,num_targets);
        these_go_codes= -1*ones(1,num_targets);
        if isempty(go_cue_idx)
            num_targets_attempted = 0;
        else
            num_targets_attempted = length(go_cue_idx);
            these_go_cues(1:num_targets_attempted) = go_cues(go_cue_idx);
            these_go_codes(1:num_targets_attempted)= go_codes(go_cue_idx);
        end

        % Offsets, target size
        x_offset = bytes2float(bdf.databursts{trial,2}(7:10));
        y_offset = bytes2float(bdf.databursts{trial,2}(11:14));
        tgt_size = bytes2float(bdf.databursts{trial,2}(15:18));

        % Build table
        TT(trial,:) = [...
            start_time, ...             % Trial start
            num_targets, ...            % max number of targets
            num_targets_attempted, ...  % Bump Timing (-1 for none, 'H' for center hold, 'M' for movement, 'D' for go-cue
            x_offset,...                % x offset
            y_offset,...                % y offset
            tgt_size,...                % target size - tolerance
            these_go_codes,...          % 0:center_tgt_on 1:go_cue 2:catch_trial
            these_go_cues,...           % time stamps of go_cue(s)
            stop_time, ...  % End of trial
            trial_result];  % Result of trial ('R', 'A', 'I', or 'N')
    end
    TT_hdr.start_time=1;
    TT_hdr.number_targets=2;
    TT_hdr.number_targets_attempted=3;
    TT_hdr.x_offset=4;
    TT_hdr.y_offset=5;
    TT_hdr.target_size=6;
    TT_hdr.go_codes=bdf.TT(:,7:7+num_targets-1);   
    TT_hdr.go_cues=bdf.TT(:,7+num_targets:7+2*num_targets-1);
    TT_hdr.end_time=9;
    TT_hdr.result=10;
    
    varargout{1}=TT;
    if nargout>1
        varargout{2}=TT_hdr;
    end
end
%    1: Start time
%    2: max number of targets
%    3: number of targets attempted
%    4: x offset
%    5: y offset
%    6: target size - tolerance
%    [7->6+(2*num_tgts)]: [logical(is_Catch), Tgt_Go/Catch time]
%    (6+2*num_tgts)+1   : Trial End time
%    (6+2*num_tgts)+2   : Trial result    -- R, A, F, I or N (N coresponds to no-result)    
    
% ------------------------------------------------------------- %    
           
%     % Outer target
%     ot_idx = find(ot_on_words > start_time & ot_on_words < stop_time, 1, 'first');
%     if isempty(ot_idx)
%         ot_time = -1;
%         ot_dir = -1;
%     else
%         ot_time = ot_on_words(ot_idx);
%         ot_dir = bitand(hex2dec('0f'), ot_on_codes(ot_idx));
%     end
%     
% 
%     
%     % Classify bump phasing
%     if bump_time == -1
%         bump_phase = -1;
%     elseif ot_time == -1
%         bump_phase = double('H');
%     elseif bump_time > go_cue + .002
%         bump_phase = double('M');
%     else
%         bump_phase = double('D');
%     end
%      
%     % Find movement onset
%     if trial_result == double('R') || bump_phase == double('H')
%         try
%             sidx = find(bdf.vel(:,1) > start_time,1,'first'):find(bdf.vel(:,1) > stop_time+1,1,'first');
% 
%             t = bdf.vel(sidx,1);                                % Set up time index vector
%             s = sqrt(bdf.vel(sidx,2).^2 + bdf.vel(sidx,3).^2);  % Calculate speeds
% 
%             d = [0; diff(smooth(s,100))*25];                    % Absolute acceleration (dSpeed/dt)
%             dd = [diff(smooth(d,100)); 0];                      % d^2 Speed / dt^2
%             peaks = dd(1:end-1)>0 & dd(2:end)<0;                % zero crossings are abs. acc. peaks
%             if go_cue > 0
%                 mvt_start = go_cue;
%             else
%                 mvt_start = bump_time;
%             end
%             mvt_peak = find(peaks & t(2:end) > mvt_start & d(2:end) > 1, 1, 'first'); 
%             thresh = d(mvt_peak)/2;                             % Threshold is half max of acceleration peak
%             onset = t(find(d<thresh & t<t(mvt_peak),1,'last')); % Movement onset is last threshold crossing before peak
%         catch
%             onset = NaN;
%         end
%     else
%         onset = NaN;
%     end
    