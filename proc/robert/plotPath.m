function plotPath(out_struct,timeRange)

% find the place in the position vector that meets the timeRange criteria

% trials=find(out_struct.pos(:,1)>=min(timeRange) & out_struct.pos(:,1)<=max(timeRange));
trials=find(out_struct.kin.trialTS>=min(timeRange) & out_struct.kin.trialTS<=max(timeRange));
% trials=[trials(1)-1; trials];
figure, set(gcf,'Color',[1 1 1])
% posInd=find(out_struct.pos(:,1) >= out_struct.kin.trialTS(trials(1)-1) & ...
%     out_struct.pos(:,1) <= out_struct.kin.trialTS(trials(1)));
% plot(out_struct.pos(posInd,2),out_struct.pos(posInd,3),'LineWidth',6)
% hold on

for n=2:length(trials)
    posInd=find(out_struct.pos(:,1) >= out_struct.kin.trialTS(trials(n-1)) & ...
        out_struct.pos(:,1) <= out_struct.kin.trialTS(trials(n)));
    plot(out_struct.pos(posInd,2),out_struct.pos(posInd,3),'LineWidth',6)
    set(gca,'Xlim',[-15 15],'Ylim',[-15 15],'TickLength',[0 0],'XTick',[],'YTick',[])
    hold on
%     plot(out_struct.pos(posInd(1),2),out_struct.pos(posInd(1),3),'o')
%     plot(out_struct.pos(posInd(end),2),out_struct.pos(posInd(end),3),'*')

    [~,thisTarg]=min(abs(out_struct.targets.centers(:,1)-out_struct.kin.trialTS(trials(n-1))));
    fill(out_struct.targets.centers(thisTarg,3)+[-2 -2 2 2], ...
        out_struct.targets.centers(thisTarg,4)+[-2 2 2 -2],'b')
    axis square
end

assignin('base','PLselect',out_struct.kin.path_length(trials))


