function [tt,tt_hdr] = rw_trial_table_hdr(bdf)
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

    j=0;

    %check DB version number and run appropriate parsing code. DB version 0
    %only has 2 words before target positions, while version 1 has 18.
    db_version=bdf.databursts{1,2}(2);
    if db_version==0
            %check whether we can trust the databurst target information and
            %then either estimate the number of targets from the databurst, or
            %from the go cues:
            if datenum(bdf.meta.datetime) < datenum('3/9/2009') 
                num_targets = (bdf.databursts{1,2}(1)-18)/8;
            else
                warning('rw_trial_table_hdr:MalformedDatabursts',...
                    ['Databursts from data files collected around when this '...
                    'one was can have malformed databursts. instead of using'...
                    'the databurst to find the number of targets, rw_trial_table_hdr '...
                    'will use the median number of go cues seen between trial '...
                    'start and trial end.'])
                tgts_attempted=-1*ones(num_trials,1);
                for trial=1:num_trials-1;
                    start_time = start_words(trial);
                    % Find the end of the trial
                    [stop_time,~]=get_end();
                    % Go cues
                    tgts_attempted(trial) = numel(find(go_cues > start_time & go_cues < stop_time));
                end
                num_targets=median(tgts_attempted);
            end
            %tt= [-1 -1 -1 -1 -1 -1 NaN ... NaN -1 -1]
            tt = [(zeros(num_trials-1,3)-1)  NaN(num_trials-1,2*num_targets)  (zeros(num_trials-1,2)-1) ];

            for trial = 1:num_trials-1
                start_time = start_words(trial);
                % Find the end of the trial
                [stop_time,trial_result]=get_end();

                % Go cues
                [go_cue_idx,these_go_cues,these_go_codes]=get_go();

                %catch trials with corrupt end codes that might end up with extra
                %targets
                if length(go_cue_idx) > num_targets
                    warning('rw_trial_table: Inconsistent number of targets @ t = %.3f, skipping trial:%d',start_time,trial);
                    tt = tt(1:end-1,:);
                    j=j+1;
                    continue;
                end
                
                % Build table
                tt(trial-j,:) = [...
                    start_time, ...             % Trial start
                    num_targets, ...            % max number of targets
                    num_targets_attempted, ...  % Bump Timing (-1 for none, 'H' for center hold, 'M' for movement, 'D' for go-cue
                    these_go_codes,...          % 0:center_tgt_on 1:go_cue 2:catch_trial
                    these_go_cues,...           % time stamps of go_cue(s)
                    stop_time, ...  % End of trial
                    trial_result];  % Result of trial ('R', 'A', 'I', or 'N')

            end
            tt_hdr.start_time               = 1;
            tt_hdr.num_targets              = 2;
            tt_hdr.num_targets_attempted    = 3;
            tt_hdr.go_codes                 =[ 4:4+max(tt(:,2))-1];
            tt_hdr.go_cues                  =[ 4+max(tt(:,2)): 4+2*max(tt(:,2))-1];
            tt_hdr.end_time                 = 4+2*max(tt(:,2));
            tt_hdr.trial_result             = 4+2*max(tt(:,2))+1;
    elseif db_version==1 || db_version==2 %HACK: DON'T KNOW WHAT'S DIFFERENT BETWEEN v1 AND v2
            num_targets = (bdf.databursts{1,2}(1)-18)/8;
            %tt= [-1 -1 -1 -1 -1 -1 NaN ... NaN -1 -1]
            tt = [(zeros(num_trials-1,6)-1)  NaN(num_trials-1,2*num_targets)  (zeros(num_trials-1,2)-1) ];

            for trial = 1:num_trials-1
                start_time = start_words(trial);
                if (bdf.databursts{trial,2}(1)-18)/8 ~= num_targets
                    %catch weird/corrupt databursts with different numbers of targets
                    warning('rw_trial_table: Inconsistent number of targets @ t = %.3f, operation interrupted',start_time);
                    tt = tt(1:end-1,:);
                    j=j+1;
                    continue;
                end
                % Find the end of the trial
                [stop_time,trial_result]=get_end();

                % Go cues
                [go_cue_idx,these_go_cues,these_go_codes]=get_go();

                %catch trials with corrupt end codes that might end up with extra
                %targets
                if length(go_cue_idx) > num_targets
                    warning('rw_trial_table: Inconsistent number of targets @ t = %.3f, skipping trial:%d',start_time,trial);
                    tt = tt(1:end-1,:);
                    j=j+1;
                    continue;
                end

                % Offsets, target size
                x_offset = bytes2float(bdf.databursts{trial,2}(7:10));
                y_offset = bytes2float(bdf.databursts{trial,2}(11:14));
                tgt_size = bytes2float(bdf.databursts{trial,2}(15:18));

                % Build table

                tt(trial-j,:) = [...
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
            tt_hdr.start_time               = 1;
            tt_hdr.num_targets              = 2;
            tt_hdr.num_targets_attempted    = 3;
            tt_hdr.x_offset                 = 4;
            tt_hdr.y_offset                 = 5;
            tt_hdr.tgt_size                 = 6;
            tt_hdr.go_codes                 =[ 7:7+max(tt(:,2))-1];
            tt_hdr.go_cues                  =[ 7+max(tt(:,2)): 7+2*max(tt(:,2))-1];
            tt_hdr.end_time                 = 7+2*max(tt(:,2));
            tt_hdr.trial_result             = 7+2*max(tt(:,2))+1;
    else
            error('rw_trial_table_hdr:BadDataburstVersion',['Trial table parsing not implemented for databursts with version: ', num2str(db_version)])
    end

    
    function [go_cue_idx,these_go_cues,these_go_codes]=get_go()
        go_cue_idx = find(go_cues > start_time & go_cues < stop_time);

        %get the codes and times for the go cues
        these_go_cues = -1*ones(1,num_targets);
        these_go_codes= -1*ones(1,num_targets);
        if isempty(go_cue_idx)
            num_targets_attempted = 0;
        else
            num_targets_attempted = length(go_cue_idx);
            these_go_cues(1:num_targets_attempted) = go_cues(go_cue_idx);
            these_go_codes(1:num_targets_attempted)= go_codes(go_cue_idx);
        end
    end
    function [stop_time,trial_result]=get_end()
        next_trial_start = start_words(trial+1);
        trial_end_idx = find(end_words > start_time & end_words < next_trial_start, 1, 'first');
        if isempty(trial_end_idx)
            stop_time = next_trial_start - .001;
            trial_result = -1;
        else
            stop_time = end_words(trial_end_idx);
            %the following line converts the lab standard word-codes into
            %ascii numeric codes for 'R','A','F','I', and is dcommented out
            %in favor of numeric codes 0=reward,1=abort,2=fail,3=incomplete
%             trial_result = double(result_codes(bitand(hex2dec('0f'),end_codes(trial_end_idx)) + 1));
            trial_result = mod(end_codes(trial_end_idx),32); %0 is reward, 1 is abort, 2 is fail, and 3 is incomplete (incomplete should never happen)
        end
        
    end
end