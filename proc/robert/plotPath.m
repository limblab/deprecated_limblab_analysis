function plotPath(out_struct,timeRange)

[PL,~,~,~,speedProfile,~,trialTS,~]=kinematicsHandControl(out_struct,struct('version',2));


% also make plots of the speedProfiles for each trial?
% smooth for plot?





% find the place in the position vector that meets the timeRange criteria
trials=find(trialTS(:,1)>=min(timeRange) & trialTS(:,1)<=max(timeRange));
figure
clf
set(gcf,'Color',[1 1 1],'Position',[50 70 700 700])
% posInd=find(out_struct.pos(:,1) >= out_struct.kin.trialTS(trials(1)-1) & ...
%     out_struct.pos(:,1) <= out_struct.kin.trialTS(trials(1)));
% plot(out_struct.pos(posInd,2),out_struct.pos(posInd,3),'LineWidth',6)
% hold on

numPlots=ceil(sqrt(numel(trials)))^2;

for n=2:length(trials)
    subplot(sqrt(numPlots),sqrt(numPlots),n)
    posInd=find(out_struct.pos(:,1) >= trialTS(trials(n-1),1) & ...
        out_struct.pos(:,1) <= trialTS(trials(n-1),3));
    % add a buffer at the end, to let the cursor get in the target a little
    % bit
    posInd=[posInd; posInd(end)+(1:3)'];
    % plot3(out_struct.pos(posInd,2),out_struct.pos(posInd,3),out_struct.pos(posInd,1),'LineWidth',6)
%     plot(out_struct.pos(posInd(1),2),out_struct.pos(posInd(1),3),'o')
%     plot(out_struct.pos(posInd(end),2),out_struct.pos(posInd(end),3),'*')

    [~,thisTarg]=min(abs(out_struct.targets.centers(:,1)-trialTS(trials(n-1))));
    fill(out_struct.targets.centers(thisTarg,3)+[-2 -2 2 2], ...
        out_struct.targets.centers(thisTarg,4)+[-2 2 2 -2],'r','EdgeColor','none')    
    set(gca,'Xlim',[-15 15],'Ylim',[-15 15],'TickLength',[0 0],'XTick',[],'YTick',[])
    hold on
    % add a straight line in grey
%     plot(out_struct.pos(posInd([1 end]),2),out_struct.pos(posInd([1 end]),3),'LineWidth',1.5, ...
%         'Color',[0.5 0.5 0.5])
    % the actual path
    plot(out_struct.pos(posInd,2),out_struct.pos(posInd,3),'LineWidth',3,'Color','k');
    % add the cursor
    t = (0:1/100:1)'*2*pi;
    x=sin(t); y=cos(t);
    fill(x+out_struct.pos(posInd(end),2),y+out_struct.pos(posInd(end),3),'y')
    axis square
    
%     plot(out_struct.pos(posInd(end),2),out_struct.pos(posInd(end),3),'o', ...
%         'MarkerSize',12,'MarkerFaceColor','y','MarkerEdgeColor','k')
end

assignin('base','PLselect',PL(trials))


