function tt = ff_trial_table_rt(bdf)
% FF_TRIAL_TABLE_RT - returns a table containing the key timestamps for all of
%                  the random walk trials in BDF
%
% Each row of the table coresponds to a single trial.  Columns are as
% follows:
%    1: Start time
%    [2->1+(3*num_tgts)]: [go cue, onset, peak] for each target
%    (1+3*num_tgts)+1   : Trial End time
%    (1+3*num_tgts)+2   : Trial result    -- R, A, F, I or N (N coresponds to no-result)


words = bdf.words;

result_codes = 'RAFI------------';

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
tt = [(zeros(num_trials-1,1)-1)  NaN(num_trials-1,5*num_targets)  (zeros(num_trials-1,2)-1) ];

for trial = 1:num_trials-1
    start_time = start_words(trial);
    if (bdf.databursts{trial,2}(1)-18)/8 ~= num_targets
        warning('rw_trial_table: Inconsistent number of targets @ t = %.3f, operation interrupted',start_time);
%         tt = tt(1:trial-1,:);
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
    
    cues = [these_go_cues stop_time];
    
    cue_array = [];
    for iCue = 1:length(cues)-1
        if trial_result == double('R') && num_targets_attempted == num_targets
            sidx = find(bdf.vel(:,1) > cues(iCue),1,'first'):find(bdf.vel(:,1) > cues(iCue+1),1,'first');
            
            t = bdf.vel(sidx,1);                                % Set up time index vector
            s = sqrt(bdf.vel(sidx,2).^2 + bdf.vel(sidx,3).^2);  % Calculate speeds
            
            d = [0; diff(smooth(s,100))*25];                    % Absolute acceleration (dSpeed/dt)
            dd = [diff(smooth(d,100)); 0];                      % d^2 Speed / dt^2
            peaks = dd(1:end-1)>0 & dd(2:end)<0;                % zero crossings are abs. acc. peaks
            
            try
            mvt_peak = find(peaks & t(2:end) > cues(iCue) & d(2:end) > 1, 1, 'first');
            catch
                keyboard
            end
            % if it's empty it usually means the monkey never really
            % accelerated to the target... for instance, he was
            % mid-movement and it appeared in front of him
            if ~isempty(mvt_peak)
                thresh = d(mvt_peak)/2;                             % Threshold is half max of acceleration peak
                on_idx = find(d<thresh & t<t(mvt_peak),1,'last');
                t_onset = t(on_idx);
                if isempty(t_onset)
                    % in RT, don't have to come to complete stop so use 1
                    t_onset = t(1);
                end
                % Movement onset is last threshold crossing before peak
                
                % find movement peak as maximum velocity
                [~, i_peak] = max(s);
                t_peak = t(i_peak);
                
                % find movement end time as when velocity goes below thresh?
                %                 off_idx = find(d>thresh & t>t(mvt_peak),1,'last');
                %                 t_offset = t(off_idx);
                %                 if isempty(t_offset)
                %                     t_offset = cues(iCue+1);
                %                 end
            else
                t_onset = NaN;
                t_peak = NaN;
                %                 t_offset = NaN;
            end
            
            try
                tgt_center_x = bytes2float(bdf.databursts{trial,2}(19+8*(iCue-1):19+8*(iCue-1)+3));
                tgt_center_y = bytes2float(bdf.databursts{trial,2}(19+8*(iCue-1)+4:19+8*(iCue-1)+7));
            catch
                keyboard
            end
            
            cue_array = [cue_array, these_go_cues(iCue), t_onset, t_peak, tgt_center_x, tgt_center_y];
        end
    end
    
    % Offsets, target size
    %     x_offset = bytes2float(bdf.databursts{trial,2}(7:10));
    %     y_offset = bytes2float(bdf.databursts{trial,2}(11:14));
    %     tgt_size = bytes2float(bdf.databursts{trial,2}(15:18));
    
    % Build table
    % throws a bug sometimes, gotta figure it out, but for now just ditch
    % trials that have too many go codes
    
    if trial_result == double('R') && num_targets_attempted == num_targets
        try
            tt(trial,:) = [...
                start_time, ...             % Trial start
                cue_array,... % for each target, [go onset peak offset xcenter ycenter]
                stop_time, ...  % End of trial
                trial_result];  % Result of trial ('R', 'A', 'I', or 'N')
        catch
            keyboard
        end
    end
end

badTrials = tt(:,end) == -1;
tt(badTrials,:) = [];

% these_go_codes,...          % 0:center_tgt_on 1:go_cue 2:catch_trial

