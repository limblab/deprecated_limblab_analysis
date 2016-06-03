function [Go_Rew_ts_w_tgt_centers] = get_tgt_center(tt)

% This function returns a matrix of [ts tgt_x tgt_y]
% tt is the trial table from wf task
%
% ts is the time at which a 'Go_Cue' or a 'Reward' word was issued
% tgt_x and tgt_y are the coordinates of the center of the target
% corresponding to this trial, in "cursor position" coordinate system.
%
% Note: for "Go_Cue" trials, the target is automatically defined as being at
% (0,0), so it could be wrong in case the user sets a different center
% target.
%
% Note 2: the arrangement of the WF trial table is as follow:
%    1: Start time
%  2-5: Target              -- ULx ULy LRx LRy
%    6: OT on time
%    7: Go cue
%    8: Trial End time
%    9: Trial result        -- R, A, I, or F 
%   10: Target ID           -- Target ID (based on location)


    % Find Go and Reward rows in tt :
    Go = find(tt(:,7) >= 0); %sometimes Go ts may be = -1 in tt if something was wrong
    Rewards = find( tt(:,9)==double('R') );

    numRew = length(Rewards);
    numGo = length(Go);
    Rew_ts_w_tgt = zeros(numRew,3);

    % Assign expected cursor position for Go ([ts 0 0])
    Go_ts_w_tgt = [tt(Go,7) zeros(numGo,2)];

    for i = 1:numRew
        %Assign expected cursor position for each Reward Trial ([ts tgtx tgty]):
        corners = tt(Rewards(i),2:5);
        tgtx = mean(corners([1 3]));
        tgty = mean(corners([2 4]));
        Rew_ts_w_tgt(i,:) = [tt(Rewards(i),8) tgtx tgty];
    end

    Go_Rew_ts_w_tgt_centers = sortrows([Go_ts_w_tgt; Rew_ts_w_tgt],1);

