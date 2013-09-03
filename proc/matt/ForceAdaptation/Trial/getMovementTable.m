function mt = getMovementTable(tt,task)

% [ target angle, on_time, go cue, move_time, peak_time, end_time ]

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
        mt = zeros(size(tt,1),6);
        for iTrial = 1:size(tt,1)
            mt(iTrial,:) = [tt(iTrial,3),...
                tt(iTrial,8),...
                tt(iTrial,9),...
                tt(iTrial,10),...
                tt(iTrial,11),...
                tt(iTrial,13)];
        end
        
    case 'RT'
        %    1: Start time
        %    [2->1+(5*num_tgts)]: [go cue, onset, peak, x_center, y_center] for each target
        %    (1+5*num_tgts)+1   : Trial End time
        %    (1+5*num_tgts)+2   : Trial result    -- R, A, F, I or N (N coresponds to no-result)
        
        numTargets = (size(tt,2) - 3)/5;
        
        mt = zeros(numTargets*size(tt,2),6);
        for iTrial = 1:size(tt,1)
            % we don't count movement to first target... think of it as
            % center target in center out paradigm
            for iTarg = 2:numTargets
                % use the x/y centers of this and iTrial+1 to find movement angle
                xc = tt(iTrial, 2+5*(iTarg-2)+3 );
                yc = tt(iTrial, 2+5*(iTarg-2)+4 );
                
                xc2 = tt(iTrial, 2+5*(iTarg-1)+3 );
                yc2 = tt(iTrial, 2+5*(iTarg-1)+4 );
                
                % find the angle
                moveAngle = atan2(yc2-yc,xc2-xc);

                % add angle, on time, move time, peak time, then make end time the on time of the next target
                %   Note for RT go cue is assumed to be same as on time
                mt(numTargets*(iTrial-1) + iTarg-1,:) = [moveAngle, ...                 %angle
                                                         tt(iTrial,2+5*(iTarg-1)), ...  %on time
                                                         tt(iTrial, 2+5*(iTarg-1):2+5*(iTarg-1)+2), ... % go cue, move time, peak time
                                                         tt(iTrial,2+5*(iTarg-1)+5)]; % trial end time
            end
        end
        
        % remove any bad trials. NaNs usually pop up here if there is no
        % peak or onset identified
        mt(isnan(mt(:,3)),:) = [];
        
    otherwise
        error('task not recognized. only knows CO or RT');
end


