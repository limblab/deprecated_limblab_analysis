function F=brainControlMovie(out_struct,encodeFlag)

todayDateStr=regexp(out_struct.meta.filename,'[0-9]{8}(?=[0-9]{3})','match','once');
if ~isempty(todayDateStr)
    todayDateStr=[todayDateStr(1:2),'/',todayDateStr(3:4),'/',todayDateStr(5:end)];
end

targInd=1;
intarget=0; intargetCutoff=0; failTargetCutoff=0;
face=[]; target=[];
out_struct.targets.centers(out_struct.targets.centers(:,1)<1,:)=[];
figure, set(gcf,'Color',[0 0 0])
set(gca,'Ylim',[min(out_struct.pos(:,3)) max(out_struct.pos(:,3))], ...
    'Xlim',[min(out_struct.pos(:,2)) max(out_struct.pos(:,2))], ...
    'XTick',[],'YTick',[],'Color',[0 0 0])
hold on
tic
for n=1:size(out_struct.pos,1)
    if out_struct.pos(n,1) >= out_struct.targets.centers(targInd,1)
        % if for some crazy reason the old target hasn't gotten
        % extinguished by the time the new one is ready to get thrown up
        % there, then as a safety valve get rid of it.
        delete(target)
        target=fill(out_struct.targets.centers(targInd,3)+[-2 -2 2 2], ...
            out_struct.targets.centers(targInd,4)+[-2 2 2 -2],'r', ...
            'EdgeColor','none');
        targInd=targInd+1;
        failTargetCutoff=n+190;  % makes for a cutoff time of 9.5s for safety margin
    end
    delete(face)
    face=plot(out_struct.pos(n,2),out_struct.pos(n,3),'o', ...
        'MarkerEdgeColor','y','MarkerFaceColor','y','MarkerSize',12);
    if targInd>1 && inpolygon(out_struct.pos(n,2),out_struct.pos(n,3), ...
            out_struct.targets.centers(targInd-1,3)+[-2 -2 2 2], ...
            out_struct.targets.centers(targInd-1,4)+[-2 2 2 -2])
        intarget=intarget+1;
        intargetCutoff=n+2;
    end
    drawnow
    F(n)=getframe;
    if intarget>=2 || intargetCutoff==n ||n>=failTargetCutoff
        intarget=0;
        intargetCutoff=0;
        delete(target)
        target=[];
    end
    title([todayDateStr,' time= ',num2str(out_struct.pos(n,1))],'Color','w','HorizontalAlignment','left')
%     pause(0.05)
    if targInd > size(out_struct.targets.centers,1)
        break
    end
end
toc
close

if nargin==1 || encodeFlag==0
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