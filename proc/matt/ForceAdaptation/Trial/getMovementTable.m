function [mt,targcent] = getMovementTable(tt,task)
% [ target angle, on_time, go cue, move_time, peak_time, end_time, ]

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
        mt = -1*ones(size(tt,1),6);
        targcent = -1*ones(size(tt,1),2);
        for iTrial = 1:size(tt,1)
            mt(iTrial,:) = [tt(iTrial,3),...
                tt(iTrial,8),...
                tt(iTrial,9),...
                tt(iTrial,10),...
                tt(iTrial,11),...
                tt(iTrial,13)];
            
            % x and y centers
            x = tt(iTrial,6)-tt(iTrial,4);
            y = tt(iTrial,5)-tt(iTrial,7);
            targcent(iTrial,1) = tt(iTrial,4)+abs(x)/2;
            targcent(iTrial,2) = tt(iTrial,7)+abs(y)/2;
        end
        
    case 'RT'
        %    1: Start time
        %    [2->1+(5*num_tgts)]: [go cue, onset, peak, x_center, y_center] for each target
        %    (1+5*num_tgts)+1   : Trial End time
        %    (1+5*num_tgts)+2   : Trial result    -- R, A, F, I or N (N coresponds to no-result)
        
        numTargets = (size(tt,2) - 3)/5; % subtract one because I skip the first
        numMoves = numTargets - 1;
        
        mt = -1*ones(numMoves*size(tt,2),6);
        targcent = -1*ones(numMoves*size(tt,2),2);
        
        for iTrial = 1:size(tt,1)
            % we don't count movement to first target... think of it as
            % center target in center out paradigm
            for iTarg = 2:numTargets
                % use the x/y centers of this and iTrial+1 to find target angle
                xc = tt(iTrial, 2+5*(iTarg-2)+3 );
                yc = tt(iTrial, 2+5*(iTarg-2)+4 );
                
                xc2 = tt(iTrial, 2+5*(iTarg-1)+3 );
                yc2 = tt(iTrial, 2+5*(iTarg-1)+4 );
                
                dx = xc2-xc;
                dy = yc2-yc;
                
                % find the angle
                moveAngle = atan2(dy,dx);
                
                % for rt task, find vector from position at movement onset
                % to target and make that target angle
                %                 t_start = tt(iTrial, 3+5*(iTarg-1));
                %
                %                 pos_end = [tt(iTrial, 5+5*(iTarg-1)), tt(iTrial, 6+5*(iTarg-1))];
                %                 pos_start = pos(find(t <= t_start,1,'last'),:);
                %                 try
                %                     moveAngle = atan2(pos_end(2)-pos_start(2),pos_end(1)-pos_start(1));
                %                 catch
                %                     moveAngle = NaN;
                %                 end
                
                
                %                 t_end = tt(iTrial,2+5*(iTarg-1)+5);
                %                 posInds = find(t > t_start & t < t_end);
                %                 usePos = pos(t > t_start & t < t_end,:);
                %
                %                 close all;
                %                 figure;
                %                 hold all;
                %                 rectangle('Position',[xc-1, yc-1, 2, 2],'FaceColor','r');
                %                 rectangle('Position',[xc2-1, yc2-1, 2, 2],'FaceColor','r');
                %                 plot(xc,yc,'kd','LineWidth',2);
                %                 plot(usePos(:,1),usePos(:,2),'b','LineWidth',2);
                %                 plot(pos_start(1),pos_start(2),'bd');
                %
                %                 axis('square')
                
                
                % add angle, on time, move time, peak time, then make end time the on time of the next target
                %   Note for RT go cue is assumed to be same as on time
                mt(numMoves*(iTrial-1) + iTarg-1,:) = [moveAngle, ...                 %angle
                    tt(iTrial,2+5*(iTarg-1)), ...  %on time
                    tt(iTrial, 2+5*(iTarg-1):2+5*(iTarg-1)+2), ... % go cue, move time, peak time
                    tt(iTrial,2+5*(iTarg-1)+5)]; % trial end time
                
                targcent(numMoves*(iTrial-1) + iTarg-1,1) = xc2;
                targcent(numMoves*(iTrial-1) + iTarg-1,2) = yc2;
            end
        end
        
        % remove any bad trials. NaNs sometimes pop up here if there is no
        % peak or onset identified
        targcent(any(isnan(mt),2),:) = [];
        mt(any(isnan(mt),2),:) = [];
        
    otherwise
        error('task not recognized. only knows CO or RT');
end


