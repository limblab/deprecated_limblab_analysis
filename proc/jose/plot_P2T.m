function plot_P2T(binnedData,varigin)

if nargin >= 2
    tgts = varigin(2);
else
    tgts = 1:8
end

tt = binnedData.trialtable;
binsize = binnedData.timeframe(2)-binnedData.timeframe(1);
lag = 10; % 10*0.05 = 0.5 seg
x_pos = binnedData.cursorposbin(:,1);
y_pos = binnedData.cursorposbin(:,2);

pos2T_wf = zeros(length(tgts),size(binnedData.cursorposbin,2))
colors = ['r' 'm' 'b' 'c' 'm' 'r' 'b' 'm'];
i=2
for i=1:length(tgts)
    a2t = tt(:,10)==i;
    go_t = round(tt(a2t,7)/binsize) - lag/2;
    rew_t = round(tt(a2t,8)/binsize) - lag/2;
    time2T =tt(a2t,8)-tt(a2t,7);
    figure(i);plot(1:length(go_t),time2T,'*'); ylim([0 5]);
    title(sprintf('Time to reach the target %i',i));
    xlabel('Time (sec)'); 
    ylabel('trials'); 
    for j=1:length(go_t)
        hold on
        figure(9)
        plot(x_pos(go_t(j):rew_t(j)),y_pos(go_t(j):rew_t(j)),colors(i));
        axis([-12 12 -12 12])
        title(sprintf('Paths from go cue to targets'));
        xlabel('X position');
        ylabel('Y position'); 
        axis equal
    end
end

axis([-10 10 -10 10])
rectangle('Position',[-2,-2,4,4])
rectangle('Position',[5,-2,4,4])
rectangle('Position',[2.95,2.95,4,4])
rectangle('Position',[-2,5,4,4])
rectangle('Position',[-6.95,2.95,4,4])
rectangle('Position',[-9,-2,4,4])
rectangle('Position',[-6.95,-6.95,4,4])
rectangle('Position',[-2,-9,4,4])
rectangle('Position',[2.95,-6.95,4,4])
