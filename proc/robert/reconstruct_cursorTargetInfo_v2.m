function [hitRate,hitTimes,hitRate2,hitTimes2,F]=reconstruct_cursorTargetInfo_v2(out_struct,targWidth,showPlot,encodeMovie)

% syntax [hitRate,hitTimes,hitRate2,hitTimes2]=reconstruct_cursorTargetInfo_v2(out_struct,targWidth,showPlot,encodeMovie);
%
% this function replaces (combines) both brainControlMovie.m and hitRateEmpirical.m

todayDateStr=regexp(out_struct.meta.filename,'[0-9]{8}(?=[0-9]{3})','match','once');
if ~isempty(todayDateStr)
    todayDateStr=[todayDateStr(1:2),'/',todayDateStr(3:4),'/',todayDateStr(5:end)];
end

targInd=1; hitRate=0; hitTimes=[];
hitRate2=0; hitTimes2=[];
out_struct.targets.centers(out_struct.targets.centers(:,1)<1,:)=[];
% hitThat=zeros(size(out_struct.targets.centers,1),1);
face=[]; target=[];
if showPlot
    fig=figure; set(fig,'Color',[0 0 0])
    set(gca,'Ylim',[min(out_struct.pos(:,3)) max(out_struct.pos(:,3))], ...
        'Xlim',[min(out_struct.pos(:,2)) max(out_struct.pos(:,2))], ...
        'XTick',[],'YTick',[],'Color',[0 0 0])
    hold on
    tic
end

% for the circle data, a default oscillator
t = 0 : .1 : 2*pi; r=0.5;
for n=1:length(t)
    circ_x = r * cos(t);
    circ_y = r * sin(t);
end, clear t

cursorInTarget=[0 0 0];
targetSelfDestruct=0;

for n=1:size(out_struct.pos,1)
    % out_struct.targets.centers(:,1) actually aligns with the word that
    % indicates the start of the trial (in RW, 18).  It SHOULD align
    % instead with the word that indicates target presentation (in RW,
    % that's 49).
    if n==targetSelfDestruct
        delete(target)
        target=[];
    end
    nextTargetActual=find(out_struct.words(:,2)==49 & ...
        out_struct.words(:,1)>=out_struct.targets.centers(targInd,1),1,'first');
    if out_struct.pos(n,1) >= out_struct.words(nextTargetActual,1)
%     if  out_struct.pos(n,1) >= out_struct.targets.centers(targInd,1)
        if showPlot
            % if for some crazy reason the old target hasn't gotten
            % extinguished by the time the new one is ready to get thrown up
            % there, then as a safety valve get rid of it.
            delete(target)
            target=fill(out_struct.targets.centers(targInd,3)+targWidth/2*[-1 -1 1 1], ...
                out_struct.targets.centers(targInd,4)+targWidth/2*[-1 1 1 -1],'r', ...
                'EdgeColor','none');
        end
        targInd=targInd+1;
%         failTargetCutoff=n+190;  % makes for a cutoff time of 9.5s for safety margin
    end
    
    % to take into account circumstances where the new target shows up 
    % on top of the current cursor position, do decision logic before
    % updating cursor position.
    if targInd > 1                  % out_struct.pos(n,2),out_struct.pos(n,3)
        [inpoly,onpoly]=inpolygon(cx,cy, ...
            out_struct.targets.centers(targInd-1,3)+targWidth/2*[-1 -1 1 1], ...
            out_struct.targets.centers(targInd-1,4)+targWidth/2*[-1 1 1 -1]);
        cursorInTarget(1:2)=cursorInTarget(2:3);
        cursorInTarget(3)=any(inpoly); % | onpoly
    end
    
    if isequal(cursorInTarget,[0 1 1])
        hitRate=hitRate+1;
        hitTimes=[hitTimes; out_struct.pos(n,1)];
        hitRate2=hitRate2+1;
        hitTimes2=[hitTimes2; out_struct.pos(n,1)];
        out_struct.targets.centers(targInd-1,3:4)=nan(1,2);
        cursorInTarget=[0 0 0];
        targetSelfDestruct=n+2;
    end
    if isequal(cursorInTarget,[0 1 0])
        hitRate2=hitRate2+1;
        hitTimes2=[hitTimes2; out_struct.pos(n,1)];
        out_struct.targets.centers(targInd-1,3:4)=nan(1,2);
        cursorInTarget=[0 0 0];
        targetSelfDestruct=n+1;
    end
    % update cursor position.  this is for the actual math
    cx=circ_x+out_struct.pos(n,2);
    cy=circ_y+out_struct.pos(n,3);
    
    if showPlot % this is for the movie
        delete(face)
        face=plot(out_struct.pos(n,2),out_struct.pos(n,3),'o', ...
            'MarkerEdgeColor','y','MarkerFaceColor','y','MarkerSize',12);
        figure(fig), drawnow
        % F(n)=getframe;
        % add something for aborts?
        title(sprintf('%s time= %.2f, %03d hits',todayDateStr,out_struct.pos(n,1),hitRate), ...
            'Color','w','HorizontalAlignment','left')
    end
    if targInd > size(out_struct.targets.centers,1)
        break
    end
end

if showPlot
    toc
    figure(fig), close
end

if nargout < 5
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



