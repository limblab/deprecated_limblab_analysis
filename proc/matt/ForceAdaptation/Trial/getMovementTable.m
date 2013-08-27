function mt = getMovementTable(tt,task)

% [ angle, on_time, move_time, peak_time, end_time ]

switch task
    case 'CO'
        %    1: Start time
        %    2: Target ID                 -- -1 for none
        %`   3: Target angle (rad)
        %    4-7: Target location (ULx ULy LRx LRy)
        %    8: OT on time
        %    9: Go cue
        %    10: Movement start time
        %    11: Peak speed time
        %    12: Movement end time
        %    13: Trial End time
        mt = zeros(size(tt,1),5);
        for iTrial = 1:size(tt,1)
            mt(iTrial,:) = [tt(iTrial,3),...
                tt(iTrial,8),...
                tt(iTrial,10),...
                tt(iTrial,11),...
                tt(iTrial,13)];
        end
        
    case 'RT'
        %    1: Start time
        %    [2->1+(3*num_tgts)]: [go cue, onset, peak] for each target
        %    (1+3*num_tgts)+1   : Trial End time
        %    (1+3*num_tgts)+2   : Trial result    -- R, A, F, I or N (N coresponds to no-result)
        
        numTargets = (size(tt,2) - 3)/3;
        
        mt = zeros(numTargets*size(tt,2),5);
        for iTrial = 1:size(tt,1)
            for iTarg = 1:numTargets
                mt(numTargets*(iTrial-1) + iTarg,:) = [NaN, tt(iTrial, 2+3*(iTarg-1):2+3*iTarg )];
            end
        end
        
        % remove any bad trials. NaNs usually pop up here if there is no
        % peak or onset identified
        mt(isnan(mt(:,3)),:) = [];
        
    otherwise
        error('task not recognized. only knows CO or RT');
end


