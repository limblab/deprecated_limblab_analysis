function S = updateStaircase(S,plotStair)

% function S = staircaseOneUpOneDown(S,plotStair)
%
%   updates stimulus value based on subject response and a one-up, one-down
%   adaptive staircase method
%
% S is a staircase structure containing the following fields
%   .trial_num:      current trial number (used for indexing other fields)
%   .value:         current value of the staircase ...      (1xtrialNum)
%   .resp:          current response of subject; 1 -> comp bigger, -1 ->
%                        comp smaller ...                   (1xtrialNum)
%                   (THIS VARIABLE MUST BE SET OUTSIDE OF THIS FUNCTION!)
%   .max_reservals:  max number of reversals (for staircase termination)
%   .num_reversals:  current number of reversals ...         (1xtrialNum)
%   .reversalPoint: 1 -> marks reversal point, 0 -> not ... (1xtrialNum)
%   .init_stepsize:  duh
%   .min_stepsize:   double duh
%   .stepSize:      current step size ...                   (1xtrialNum)
%   .terminated:    0 -> staircase active, 1 -> staircase terminated
%
% plotStair:        1 -> plots staircase data, 0 -> not so much


% HANDLE INPUT
if (nargin < 2) plotStair = 0; end

if (S.terminated)
    warning('staircase_oneup_onedown_fov: attempt to update terminated staircase');
    return;
end

% update trial number
S.trial_num = S.trial_num + 1;

if (S.trial_num > 1) % if not the 1st trial
    % IF A REVERSAL
    if (length(S.resp) ~= S.trial_num)
        killer = 1;
    end
    if (S.resp(S.trial_num) ~= S.resp(S.trial_num-1))
        S.num_reversals(S.trial_num) = S.num_reversals(S.trial_num-1) + 1;
        S.reversal_point(S.trial_num) = 1;
        if (S.stepsize(S.trial_num-1) > S.min_stepsize)
            S.stepsize(S.trial_num) = S.stepsize(S.trial_num-1)/2;
        end
        % clamp stepsize to min_stepsize
        if (S.stepsize(S.trial_num-1) <= S.min_stepsize)
            S.stepsize(S.trial_num) = S.min_stepsize;            %original linear stepsize:
        end
    % IF NOT A REVERSAL    
    else 
        S.num_reversals(S.trial_num) = S.num_reversals(S.trial_num-1);
        S.reversal_point(S.trial_num) = 0;
        S.stepsize(S.trial_num) = S.stepsize(S.trial_num-1);

        % clamp stepsize to min_stepsize
        if (S.stepsize(S.trial_num) <= S.min_stepsize)        
            S.stepsize(S.trial_num) = S.min_stepsize;
        end        
    end
else
    S.stepsize = S.init_stepsize; % staircase setup
    S.num_reversals = 0;
    S.reversal_point = 0;
    S.terminated = 0;
end


% UPDATE STIMULUS VALUE
S.value(S.trial_num+1) = S.value(S.trial_num);
if length(S.resp)>=max(S.updown)
    if (sum(S.resp(S.trial_num-S.updown(1)+1:end)) == -S.updown(1))
        S.value(S.trial_num+1) = S.value(S.trial_num) + S.stepsize(S.trial_num);
    elseif (sum(S.resp(S.trial_num-S.updown(2)+1:end)) == S.updown(2))
        S.value(S.trial_num+1) = S.value(S.trial_num) - S.stepsize(S.trial_num);
    end
end

% is the staircase terminated?
if (S.num_reversals(S.trial_num) >= S.max_reversals)
    S.value(end) = [];
    S.terminated = 1;
end

% plot staircase data if desired
if (plotStair)
    figure(10);
    cla;
    plot(S.value,'bo-'); hold on
    plot(find(S.reversal_point),S.value(find(S.reversal_point)),'rs','linewidth',3)
    pause(.2);
end