% figure
% 
% subplot(4,1,1)
% area(binnedData.timeframe, binnedData.states(:,1), 'FaceColor', [208 255 255]./255, 'LineStyle', 'none')
% hold on
% plot(binnedData.timeframe, binnedData.states(:,2), 'k', binnedData.timeframe, binnedData.velocbin(:,3)/max(binnedData.velocbin(:,3)), 'r')
% axis([285 305 -0.1 1.1])
% title(binnedData.statemethods(2,:));
% legend('movement classes', 'predicted classes', 'normalized velocity');
% hold off
% 
% subplot(4,1,2)
% area(binnedData.timeframe, binnedData.states(:,1), 'FaceColor', [208 255 255]./255, 'LineStyle', 'none')
% hold on
% plot(binnedData.timeframe, binnedData.states(:,3), 'k', binnedData.timeframe, binnedData.velocbin(:,3)/max(binnedData.velocbin(:,3)), 'r')
% axis([285 305 -0.1 1.1])
% title(binnedData.statemethods(3,:));
% hold off
% 
% subplot(4,1,3)
% area(binnedData.timeframe, binnedData.states(:,1), 'FaceColor', [208 255 255]./255, 'LineStyle', 'none')
% hold on
% plot(binnedData.timeframe, binnedData.states(:,4), 'k', binnedData.timeframe, binnedData.velocbin(:,3)/max(binnedData.velocbin(:,3)), 'r')
% axis([285 305 -0.1 1.1])
% title(binnedData.statemethods(4,:));
% hold off
% 
% subplot(4,1,4)
% area(binnedData.timeframe, binnedData.states(:,1), 'FaceColor', [208 255 255]./255, 'LineStyle', 'none')
% hold on
% plot(binnedData.timeframe, binnedData.states(:,5), 'k', binnedData.timeframe, binnedData.velocbin(:,3)/max(binnedData.velocbin(:,3)), 'r')
% axis([285 305 -0.1 1.1])
% title(binnedData.statemethods(5,:));
% xlabel('time (s)');
% ylabel('state 1 = movement, state 0 = hold');
% hold off
% 
% 
% start = find(binnedData.timeframe >= 285,1,'first');
% stop  = find(binnedData.timeframe >= 305,1,'first');
start = find(binnedData.timeframe >= 284,1,'first');
stop  = find(binnedData.timeframe >= 305,1,'first');
data = binnedData;
data.timeframe = binnedData.timeframe(start:stop);
data.states    = binnedData.states(start:stop,:);
data.velocbin = binnedData.velocbin(start:stop,:);
data.spikeratedata = binnedData.spikeratedata(start:stop,:);
data.cursorposbin  = binnedData.cursorposbin(start:stop,:);
data.cursorposbin  = binnedData.cursorposbin(start:stop,:);

figure
hold on;
numStates = size(data.states,2);
bottom = [-0.1 0.9 1.1 1.3 1.5];
top    = [ 1.6 1.0 1.2 1.4 1.6];
g0 = [200 200 200];
g1 = [120 120 120];
g2 = [90 90 90];
g3 = [60 60 60];
g4 = [30 30 30];
colors = {g0 g1 g2 g3 g4};
axis([285 305 -0.1 1.6]);

for state = 1:numStates
    endx = 0;
    while endx<length(data.timeframe)
        startx = endx + find(data.states(endx+1:end,state),1,'first');
        if isempty(startx)
            break;
        end
        endx   = startx + find(data.states(startx:end,state)==0,1,'first')-2;
        if isempty(endx)
            endx = length(data.timeframe);
        end
        x = [ data.timeframe(startx) data.timeframe(endx)];
        y = [ top(state) top(state)];
        area(x,y,bottom(state),'FaceColor',colors{state}/255,'LineStyle','none');
    end
end
plot(data.timeframe,0.7*data.velocbin/max(data.velocbin),'k');

% 
% figure
% area(binnedData.timeframe, binnedData.states(:,1).*200 - 100, -100, 'FaceColor', [200 200 200]./255, 'LineStyle', 'none')
% hold on
% plot(binnedData.timeframe, binnedData.velocbin(:,3)/max(binnedData.velocbin(:,3)), 'k')
% area(binnedData.timeframe, 1.4 + binnedData.states(:,2)./10, 1.4, 'FaceColor', [120 120 120]./255, 'LineStyle', 'none')
% area(binnedData.timeframe, 1.2 + binnedData.states(:,3)./10, 1.2, 'FaceColor', [90 90 90]./255, 'LineStyle', 'none')
% area(binnedData.timeframe, 1.0 + binnedData.states(:,4)./10, 1.0, 'FaceColor', [60 60 60]./255, 'LineStyle', 'none')
% area(binnedData.timeframe, 0.8 + binnedData.states(:,5)./10, 0.8, 'FaceColor', [30 30 30]./255, 'LineStyle', 'none')
% area(binnedData.timeframe, 1.5 - binnedData.states(:,2)./10, 1.5, 'FaceColor', [120 120 120]./255, 'LineStyle', 'none')
% area(binnedData.timeframe, 1.3 - binnedData.states(:,3)./10, 1.3, 'FaceColor', [90 90 90]./255, 'LineStyle', 'none')
% area(binnedData.timeframe, 1.1 - binnedData.states(:,4)./10, 1.1, 'FaceColor', [60 60 60]./255, 'LineStyle', 'none')
% area(binnedData.timeframe, 0.9 - binnedData.states(:,5)./10, 0.9, 'FaceColor', [30 30 30]./255, 'LineStyle', 'none')
% axis([285 305 -0.1 1.6])
% title('Movement Classification');
% xlabel('time (s)');
% legend('Movement State', 'Normalized Speed', 'GFR Threshold', 'Complete Bayesian', 'Peak Bayesian', 'Peak LDA');
% hold off
