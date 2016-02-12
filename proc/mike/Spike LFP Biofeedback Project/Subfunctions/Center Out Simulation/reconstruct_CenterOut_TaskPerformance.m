function [Task,F]=reconstruct_CenterOut_TaskPerformance(out_struct,showPlot,encodeMovie)

% syntax [hitRate,hitTimes,hitRate2,Abort]=reconstruct_cursorTargetInfo_v2(out_struct,targWidth,showPlot,encodeMovie);
%
% this function replaces (combines) both brainControlMovie.m and hitRateEmpirical.m
%% To Do
% x- Change words to reflect center out
% x- Add second target check from center to outer target
% x- Add Fails and Incompletes (currently only success and aborts)
% x- Change target drawing variables (CO uses target corners instead of
% target centers
% - Simulate center out!

%% Initialize variables
% These are the screen limits for BC in Lab 2 
xlimits = [14.38 -14.38];
ylimits = [11.5 -11.5];
% Initialize cursor position to zero
cx = 0;
cy = 0;

cursorstate = 0;
centerOn = 0;
targetOn = 0;
targInd = 1;
numTargs = size(out_struct.targets.corners,1);
randTarg = randi(numTargs,numTargs,1);
out_struct.targets.corners = sortrows([out_struct.targets.corners randTarg],6);
errorInd = 1;
face=[];
target=[];
% Inner target hold index
Holdi = 1;
% Outer target hold index
Holdo = 1;
CursorTrial = [];
PL = 0;

Task.TrialStarts = 0;
Task.Success = 0;
Task.SuccessTimes = [];
Task.Fail = 0;
Task.FailTimes = [];
Task.Abort = 0;
Task.AbortTimes = [];
Task.Incomplete = 0;
Task.IncompleteTimes = [];
Task.Error = 0;
Task.ErrorTimes = [];
Task.ErrorTarget= [];
Task.ErrorTargetActual= zeros(length(find(out_struct.words(:,2)==17)),4);
out_struct.targets.corners(out_struct.targets.corners(:,1)<1,:)=[];

targetSelfDestruct = 0;
TrialTime = 0;

todayDateStr=regexp(out_struct.meta.filename,'[0-9]{8}(?=[0-9]{3})','match','once');
if ~isempty(todayDateStr)
    todayDateStr=[todayDateStr(1:2),'/',todayDateStr(3:4),'/',todayDateStr(5:end)];
end

%% Determine what the center target width is

TC = unique(out_struct.targets.corners(:,2:5),'rows');
% Need this to remove junk targets that come in the
% Targets.Corners of the bdf
if sum(sum(abs(TC),2)) > 1000
    TC = TC(sum(abs(TC),2) < 100,:)
end

if sum(sum(abs(TC) < 0.01,2))
    TC = TC(sum(abs(TC) < 0.01,2) == 0,:)
end

if size(TC,1) >3  % if this is 4 target ONF control
    Center = abs((TC(1,1)-TC(1,3)))/2;
else % if this is anything else
    Center = round(min(min(abs(TC))));
end

%% Draw behavior plot

% In HC there is an offset between the robot hand coordinates and screen
% coordinates, this corrects for that
if round((out_struct.pos(2,1)-out_struct.pos(1,1))*1000) == 1
    % Need this to correct for the offset present in the pos field in bdf,
    % converts the pos from robot handle coordinates to screen coordinates
    out_struct.pos(:,2) = out_struct.pos(:,2) + bytes2float(sort(out_struct.databursts{1,2}(7:10)));
    out_struct.pos(:,3) = out_struct.pos(:,3) + bytes2float(sort(out_struct.databursts{1,2}(11:14)));
    % Target size?
    %     r = bytes2float(sort(out_struct.databursts{1,2}(15:18))); % Not
    %     sure if 15:18 is correct index for this calculation
    maxTrialTime = 2;
    cursorInCenterTarget = zeros(100,1);
    cursorInOuterTarget  = zeros(100,1);
else
    %% logic to determine max trial time depending on monkey      
    if regexp(out_struct.meta.filename,'Chewie')
        maxTrialTime = 15;
    else
        maxTrialTime = 25;
    end
    
    cursorInCenterTarget = zeros(1,3);
    cursorInOuterTarget  = zeros(1,3);
end



if showPlot
    fig=figure; set(fig,'Color',[0 0 0])
    set(gca,'Ylim',[ylimits(2)-2 ylimits(1)+2], ...
        'Xlim',[xlimits(2)-2 xlimits(1)+2], ...
        'XTick',[],'YTick',[],'Color',[0 0 0])
    hold on
    tic
end

%% To represent the cursor, create circle data, a default oscillator
% t = 0 : .1 : 2*pi; r=0.5;
% for n=1:length(t)
%     circ_x = r * cos(t);
%     circ_y = r * sin(t);
% end, clear t

for n=1:size(out_struct.pos,1)
    %% Start simulating cursor movement
    
    % out_struct.targets.centers(:,1) actually aligns with the word that
    % indicates the start of the trial (in RW, 18).  It SHOULD align
    % instead with the word that indicates target presentation (in RW,
    % that's 49).

    % update cursor position.  this is for the actual math
    t  = out_struct.pos(n,1);
    
%     if  round((out_struct.pos(2,1)-out_struct.pos(1,1))*1000) == 1
        % if HC
        cx = out_struct.pos(n,2);
        cy = out_struct.pos(n,3);
%     else
%         % if BC
%         cx = cx + out_struct.vel(n,2) * diff(out_struct.pos([1 2],1));
%         cy = cy + out_struct.vel(n,3) * diff(out_struct.pos([1 2],1));
%     end
%     
    if cx > xlimits(1)
        cx=xlimits(1);
    end
    if cx < xlimits(2)
        cx=xlimits(2);
    end
    if cy > ylimits(1)
        cy=ylimits(1);
    end
    if cy < ylimits(2)
        cy=ylimits(2);
    end

    if showPlot && mod(n,5) == 0% this is for the movie
        out_struct.pos(n,1)
        delete(face)
        if  round((out_struct.pos(2,1)-out_struct.pos(1,1))*1000) == 1
            face=plot(out_struct.pos(n,2),out_struct.pos(n,3),'o', ...
            'MarkerEdgeColor','y','MarkerFaceColor','y','MarkerSize',12);
        else 
            face=plot(cx,cy,'o', ...
            'MarkerEdgeColor','y','MarkerFaceColor','y','MarkerSize',12);
        end
        figure(fig), drawnow
        F(n)=getframe;
        % add something for aborts?
        title(sprintf('%s time= %.2f, %03d hits',todayDateStr,out_struct.pos(n,1),hitRate(out_struct)), ...
            'Color','w','HorizontalAlignment','left')
    end
    
    if targInd > size(out_struct.targets.corners,1)
        break
    end

    switch cursorstate
        % 0 - Cursor needs to move to center target
        % 1 - Cursor needs to move to outer target        
        case 0
            %% Logic for center target
            % Find when target should be displayed and display it
            if n==targetSelfDestruct
                delete(target)
                target=[];
            end                        
            
            centerTargetActual=find(out_struct.words(:,2)==48 & ...
                isnan(out_struct.words(:,1))== 0,1,'first');
            nextTrialStart = centerTargetActual -1 +...
                find(out_struct.words(centerTargetActual:end,2)==17,1,'first');
           
            % If the time goes past what the end of the trial (because of
            % some bug in the target coordinates stored in the bdf), skip
            % to the next trial check this one off as an error
%             if t > out_struct.words(nextTrialStart,1) - 1.5
%                 Task.Error = Task.Error +1;
%                 Task.ErrorTimes = [Task.ErrorTimes; out_struct.words(nextTrialStart,:)];
%                 out_struct.words(centerTargetActual,1) = nan;
%                 % if there was an error in the target location for this
%                 % file, make sure to invalidate the outer target go cue so
%                 % that the next go cue can be detected
%                 if exist('outerTargetActual','var')
%                     if out_struct.words(nextTrialStart-1,2) == 32 || 34 || 35
%                         out_struct.words(outerTargetActual,1) = nan;
%                     end
%                 end
%                 if round((out_struct.pos(2,1)-out_struct.pos(1,1))*1000) == 1
%                     cursorInCenterTarget = zeros(100,1);
%                 else
%                     cursorInCenterTarget = [0 0 0];
%                 end
%                 Holdi = 1;
%                 centerOn = 0;
%                 targetSelfDestruct = n+1;
%                 targInd=targInd+1;
%             end
            
            if out_struct.pos(n,1) >= out_struct.words(centerTargetActual,1)
                
                if showPlot
                    % if for some crazy reason the old target hasn't gotten
                    % extinguished by the time the new one is ready to get thrown up
                    % there, then as a safety valve get rid of it.
                    delete(target)

                    target = fill([Center*-1,Center*-1,Center,Center],...
                        [Center*-1,Center,Center,Center*-1],'r','EdgeColor','none');
                end
                centerOn = 1;
            end
            
            if centerOn == 1
                [inpoly,onpoly]=inpolygon(cx,cy, ...
                    [Center,Center,Center*-1,Center*-1],...
                    [Center,Center*-1,Center*-1,Center]);
                % If HC
                if  round((out_struct.pos(2,1)-out_struct.pos(1,1))*1000) == 1
                    if inpoly
                        cursorInCenterTarget(Holdi) = inpoly;
                        Holdi = Holdi + 1;
                    end
                    
                    if ~inpoly && sum(cursorInCenterTarget) > 0                        
                        Holdi = Holdi + 1;
                    end
                % If BC
                else
                    cursorInCenterTarget(1:2) = cursorInCenterTarget(2:3);
                    cursorInCenterTarget(3) = any(inpoly | onpoly); % | onpoly
                end
            end
            
            % Check if hold in center target long enough
            if  round((out_struct.pos(2,1)-out_struct.pos(1,1))*1000) == 1
                % If HC
                if isequal(cursorInCenterTarget,ones(100,1))
                    Task.TrialStarts = Task.TrialStarts + 1;
                    out_struct.words(centerTargetActual,1) = nan;
                    cursorInCenterTarget = zeros(100,1);
                    Holdi = 1;
                    targetSelfDestruct = n+1;
                    centerOn = 0;
                    cursorstate = 1;
                end
                
            else
                % If BC
                if isequal(cursorInCenterTarget,[0 1 1])
                    Task.TrialStarts = Task.TrialStarts + 1;
                    out_struct.words(centerTargetActual,1) = nan;
                    cursorInCenterTarget = [0 0 0];
                    targetSelfDestruct = n+1;
                    centerOn = 0;
                    cursorstate = 1;
                end
            end
            
            % Check if didn't hold in center target long enough
            if  round((out_struct.pos(2,1)-out_struct.pos(1,1))*1000) == 1
                if sum(cursorInCenterTarget) < Holdi - 1  
                    Task.Abort = Task.Abort +1;
                    Task.AbortTimes = [Task.AbortTimes; out_struct.pos(n,1)];
                    out_struct.words(centerTargetActual,1) = nan;
                    cursorInCenterTarget = zeros(100,1);
                    Holdi = 1;
                    centerOn = 0;
                    targetSelfDestruct = n+1;
                    targInd=targInd+1;
                end
            else
                if isequal(cursorInCenterTarget,[0 1 0])
                    Task.Abort = Task.Abort +1;
                    Task.AbortTimes = [Task.AbortTimes; out_struct.pos(n,1)];
                    out_struct.words(centerTargetActual,1) = nan;
                    cursorInCenterTarget = [0 0 0];
                    centerOn = 0;
                    targetSelfDestruct = n+1;
                    targInd=targInd+1;
                end
            end
            
            
        case 1
            %% Logic for outer target
            if n==targetSelfDestruct
                delete(target)
                target=[];
            end
            
            % Logic to determine if HC or BC
            if round((out_struct.pos(2,1)-out_struct.pos(1,1))*1000) == 1
                TrialTime = TrialTime + .001; % If HC
                CursorTrial(round(TrialTime/.001),:) = [cx, cy];
                % Calculate the path length at each time step to calculate
                % at the end
                if TrialTime/.001 > 1
                PLpoint=sqrt((CursorTrial(round(TrialTime/.001),1)- ...
                    CursorTrial((round(TrialTime/.001))-1,1))^2 + ...
                    (CursorTrial(round(TrialTime/.001),2)- ...
                    CursorTrial((round(TrialTime/.001))-1,2))^2);
                    PL = PL+PLpoint;   
                end
                                                             
            else
                TrialTime = TrialTime + .05; % If BC
                CursorTrial(round(TrialTime/.05),:) = [cx, cy];
                
                if TrialTime/.05 > 1
                PLpoint=sqrt((CursorTrial(round(TrialTime/.05),1)- ...
                    CursorTrial((round(TrialTime/.05))-1,1))^2 + ...
                    (CursorTrial(round(TrialTime/.05),2)- ...
                    CursorTrial((round(TrialTime/.05))-1,2))^2);
                    PL = PL+PLpoint;  
                end
                
            end
            
%             if t > out_struct.words(nextTrialStart,1) - 1.5
%                 Task.Error = Task.Error +1;
%                 Task.ErrorTimes = [Task.ErrorTimes; out_struct.words(nextTrialStart,:)];
%                 
%                 % Find where target should have been based on cursor
%                 % position at that word
%                 %                 if out_struct.words(nextTrialStart-1,1) == 32
%                 Task.ErrorTarget = [Task.ErrorTarget; out_struct.targets.corners(targInd,:)]
%                 trueind = find(out_struct.words(nextTrialStart-1,1)-0.1 < out_struct.pos(:,1),1,'first');
%                 
%                 % Reset path length
%                 PL = 0;
%                 % Reset Cursor Trajectory
%                 CursorTrial = [0 0];
%                 
%                 cx = out_struct.pos(trueind,2);
%                 cy = out_struct.pos(trueind,3);
%                 for w = 1:size(TC,1)
%                     ErrorTargID(w) =inpolygon(cx,cy, ...
%                         [TC(w,1),TC(w,1),TC(w,3),TC(w,3)],...
%                         [TC(w,2),TC(w,4),TC(w,4),TC(w,2)])
%                 end
%                 if TC(ErrorTargID,:)
%                     Task.ErrorTargetActual(size(Task.ErrorTarget,1),:) = TC(ErrorTargID,:)
%                 end
%                 %                 elseif out_struct.words(nextTrialStart-1,1) == 33
%                 
%                 if out_struct.pos(n,1) > out_struct.words(outerTargetActual,1)
%                     out_struct.words(outerTargetActual,1) = nan;
%                 end
%                 if round((out_struct.pos(2,1)-out_struct.pos(1,1))*1000) == 1
%                     cursorInOuterTarget = zeros(100,1);
%                 else
%                     cursorInOuterTarget = [0 0 0];
%                 end
%                 errorInd = errorInd + 1;
%                 Holdo = 1;
%                 targInd= find(out_struct.targets.corners(:,1)> out_struct.pos(n,1),1,'first');
%                 targetSelfDestruct = n+1;
%                 TrialTime = 0;
%                 targetOn = 0;
%                 cursorstate = 0;
%             end
            
            outerTargetActual=find(out_struct.words(:,2)==49 & ...
                isnan(out_struct.words(:,1))== 0,1,'first');
             
            if out_struct.pos(n,1) >= out_struct.words(outerTargetActual,1)
                
                % Set target to appropriate index
                Targ = out_struct.targets.corners(targInd,:);
                
                if showPlot
                    % if for some crazy reason the old target hasn't gotten
                    % extinguished by the time the new one is ready to get thrown up
                    % there, then as a safety valve get rid of it.
                    delete(target)
                    
                    % **************** Change to target corners *************************
                    target = fill([Targ(1,2),Targ(1,2),Targ(1,4),Targ(1,4)],...
                        [Targ(1,3),Targ(1,5),Targ(1,5),Targ(1,3)],'r','EdgeColor','none');
                end
                targetOn = 1;
            end
            
            if targetOn == 1                
                %% Check if cursor has now entered outer target
                [inpoly,onpoly]=inpolygon(cx,cy, ...
                    [Targ(1,2),Targ(1,2),Targ(1,4),Targ(1,4)],...
                    [Targ(1,3),Targ(1,5),Targ(1,5),Targ(1,3)]);
                if  round((out_struct.pos(2,1)-out_struct.pos(1,1))*1000) == 1
                    if inpoly
                        cursorInOuterTarget(Holdo) = inpoly;
                        Holdo = Holdo + 1;
                    end
                    
                    if ~inpoly && sum(cursorInOuterTarget) > 0                        
                        Holdo = Holdo + 1;
                    end
                % If BC
                else
                    cursorInOuterTarget(1:2) = cursorInOuterTarget(2:3);
                    cursorInOuterTarget(3) = any(inpoly | onpoly); % | onpoly
                end
            end
            
            
            % Check for success
            if  round((out_struct.pos(2,1)-out_struct.pos(1,1))*1000) == 1
                % If HC
                if isequal(cursorInOuterTarget,ones(100,1))
                    Task.Success = Task.Success + 1;
                    Task.SuccessTimes = [Task.SuccessTimes; out_struct.pos(n,1)];
                    Task.Success_TTT(Task.Success) = TrialTime;
                    interTargetDistance = sqrt(sum(diff(CursorTrial([1 end],1:2)).^2));
                    Task.Success_PL(Task.Success) = PL/interTargetDistance;
                    
                    % Reset path length
                    PL = 0; 
                    % Reset Cursor Trajectory
                    CursorTrial = [0 0];
                    % Set to nan so that next target will be selected using
                    % find command
                    out_struct.words(outerTargetActual,1) = nan;
                    % Reset cursor buffer
                    cursorInOuterTarget  = zeros(100,1);
                    Holdo = 1;
                    % Increment target index
                    targInd=targInd+1;
                    % Set var so that target will be deleted on next loop iter
                    targetSelfDestruct=n+1;
                    % Reset trial time
                    TrialTime = 0;
                    % Stop checking if cursor is in target
                    targetOn = 0;
                    % Change cursor state
                    cursorstate = 0;                    
                end                
            else
                % If BC
                if isequal(cursorInOuterTarget,[0 1 1])
                    Task.Success = Task.Success + 1;
                    Task.SuccessTimes = [Task.SuccessTimes; out_struct.pos(n,1)];
                    Task.Success_TTT(Task.Success) = TrialTime;                   
                    interTargetDistance = sqrt(sum(diff(CursorTrial([1 end],1:2)).^2));
                    Task.Success_PL(Task.Success) = PL/interTargetDistance;
                    
                    PL = 0; 
                    CursorTrial = [0 0];
                    out_struct.words(outerTargetActual,1) = nan;
                    cursorInOuterTarget  = [0 0 0];
                    targInd=targInd+1;
                    targetSelfDestruct=n+1;
                    TrialTime = 0;
                    targetOn = 0;
                    cursorstate = 0;
                    
                end
            end
            
            % Check for incomplete
            if  round((out_struct.pos(2,1)-out_struct.pos(1,1))*1000) == 1
                % If HC
                if sum(cursorInOuterTarget) < Holdi - 1  
                    Task.Incomplete = Task.Incomplete +1;
                    Task.IncompleteTimes = [Task.IncompleteTimes; out_struct.pos(n,1)];
                    Task.Incomplete_TTT(Task.Incomplete) = TrialTime;
                    interTargetDistance = sqrt(sum(diff(CursorTrial([1 end],1:2)).^2));
                    Task.Incomplete_PL(Task.Incomplete) = PL/interTargetDistance;
                    
                    PL = 0; 
                    CursorTrial = [0 0];
                    out_struct.words(outerTargetActual,1) = nan;
                    cursorInOuterTarget  = zeros(100,1);
                    Holdo = 1;
                    targInd = targInd+1;
                    targetSelfDestruct=n+1;
                    TrialTime = 0;
                    targetOn = 0;
                    cursorstate = 0;
                    
                end
            else
                if isequal(cursorInOuterTarget,[0 1 0])
                    Task.Incomplete = Task.Incomplete +1;
                    Task.IncompleteTimes = [Task.IncompleteTimes; out_struct.pos(n,1)];
                    Task.Incomplete_TTT(Task.Incomplete) = TrialTime;
                    interTargetDistance = sqrt(sum(diff(CursorTrial([1 end],1:2)).^2));
                    Task.Incomplete_PL(Task.Incomplete) = PL/interTargetDistance;

                    PL = 0; 
                    CursorTrial = [0 0];
                    out_struct.words(outerTargetActual,1) = nan;
                    cursorInOuterTarget  = [0 0 0];
                    targInd = targInd+1;
                    targetSelfDestruct=n+1;
                    TrialTime = 0;
                    targetOn = 0;
                    cursorstate = 0;
                end
            end
            
            % Check for failure
            if  round((out_struct.pos(2,1)-out_struct.pos(1,1))*1000) == 1
                if TrialTime >= maxTrialTime
                    Task.Fail = Task.Fail +1;
                    Task.FailTimes = [Task.FailTimes; out_struct.pos(n,1)];
                    Task.Fail_TTT(Task.Fail) = TrialTime;
                    interTargetDistance = sqrt(sum(diff(CursorTrial([1 end],1:2)).^2));
                    Task.Fail_PL(Task.Fail) = PL/interTargetDistance;
                    
                    PL = 0; 
                    CursorTrial = [0 0];
                    out_struct.words(outerTargetActual,1) = nan;
                    cursorInOuterTarget  = zeros(100,1);
                    Holdo = 1;
                    targInd = targInd+1;
                    targetSelfDestruct=n+1;
                    TrialTime = 0;
                    targetOn = 0;
                    cursorstate = 0;
                end
            else
                if TrialTime >= maxTrialTime
                    Task.Fail = Task.Fail +1;
                    Task.FailTimes = [Task.FailTimes; out_struct.pos(n,1)];
                    Task.Fail_TTT(Task.Fail) = TrialTime;
                    interTargetDistance = sqrt(sum(diff(CursorTrial([1 end],1:2)).^2));
                    Task.Fail_PL(Task.Fail) = PL/interTargetDistance;                    
                    
                    PL = 0; 
                    CursorTrial = [0 0];
                    out_struct.words(outerTargetActual,1) = nan;
                    cursorInOuterTarget  = [0 0 0];
                    targInd = targInd+1;
                    targetSelfDestruct=n+1;
                    TrialTime = 0;
                    targetOn = 0;
                    cursorstate = 0;
                end
            end                        
                       
    end    
    
end

if showPlot
    toc
    figure(fig), close
end

if nargout < 2
    F=[];
end

if nargin < 4 || encodeMovie==0
    return
end

%% to just encode the movie
disp('encoding movie...')
tic
avobj=VideoWriter(regexprep(out_struct.meta.filename,'\.plx','.avi'),'Motion JPEG AVI');
avobj.FrameRate=20;
open(avobj)
writeVideo(avobj,F)
close(avobj)
toc
disp('done')



