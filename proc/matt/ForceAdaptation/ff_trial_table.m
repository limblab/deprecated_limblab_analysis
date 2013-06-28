function tt = ff_trial_table(bdf, targ_angs, move_time)
% FF_TRIAL_TABLE - returns a table containing the key timestamps for all of
%                  the successful center-out trials in BDF
%
% Each row of the table coresponds to a single trial.  Columns are as
% follows:
%    1: Start time
%    2: Target                  -- -1 for none
%    3: OT on time
%    4: Go cue
%    5: Movement start time
%    6: Peak speed time
%    7: End of movement window (for pd purposes)
%    8: Trial End time
%    9: Angle of target
%   10: Angle of movement
%
%  ASSUMES A 0.5 SECOND HOLD TIME WHEN REQUIRED

% $Id: co_trial_table.m 334 2011-01-12 04:18:39Z chris $

binMoveDir = true;

if nargin < 3
    % Total time to consider when computing window for movement direction
    move_time = 0.6; %seconds
    if nargin < 2
        % Angles of targets
        targ_angs = [0, pi/4, pi/2, 3*pi/4, pi, -3*pi/4, -pi/2, -pi/4];
    end
end

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
            peak = t(mvt_peak);
            
            px = smooth(bdf.pos(sidx,2),1000);
            py = smooth(bdf.pos(sidx,3),1000);
            
            % it appears as though the pos +/- is opposite of what I expect
            px = -px;
            py = -py;
            
            if move_time > 0
                % use initial movement period
                off_idx = find(t < onset+move_time,1,'last');
            elseif move_time < 0
                % use final movement period
                on_idx = find(t < stop_time-0.5+move_time,1,'last');
                off_idx = find(t < stop_time-0.5,1,'last');
            elseif move_time == 0
                % Use peak velocity period
                on_idx = find(t < peak-0.25,1,'last');
                off_idx = find(t < peak+0.25,1,'last');
            end
            
            offset = t(off_idx);
            p_start = [px(on_idx), py(on_idx)];
            p_end = [px(off_idx), py(off_idx)];
            
            move_angle = atan2(p_end(2)-p_start(2), p_end(1)-p_start(1));
            
            if binMoveDir
                % Bin the movement direction into 45 degree bins
                angSize = pi/4;
                move_angle = round(move_angle./angSize).*angSize;
            end
            
%             figure;
%             plot(px(on_idx:off_idx),py(on_idx:off_idx));
%             hold all;
%             plot([0 cos(move_angle)],[0 sin(move_angle)],'r');
%             plot([0 cos(targ_angs(ot_dir+1))],[0 sin(targ_angs(ot_dir+1))],'b');
%             pause;
%             close all;
        catch
            onset = NaN;
            peak = NaN;
            move_angle = NaN;
        end
    else
        onset = NaN;
        peak = NaN;
        move_angle = NaN;
    end
    
    % Build table
    if ot_dir ~= -1 % ignore trials that don't make it to target presentation
        tt(trial,:) = [...
            start_time, ... % Trial start
            ot_dir, ...     % Outer target direction (-1 for none)
            ot_time, ...    % Timestamp of OT On event
            go_cue, ...     % Timestamp of Go Cue
            onset, ...      % Detected movement onset
            peak, ...       % Time of peak movement speed
            offset, ...     % Time when movement window ends (for pd purposes)
            stop_time, ...  % End of trial
            targ_angs(ot_dir+1), ... % Angle to target
            move_angle];    % Angle of movement
    end
end

% Remove trials that have no go cue?
remInds = tt(:,4) == -1;
tt(remInds,:) = [];
remInds = isnan(tt(:,5));
tt(remInds,:) = [];


