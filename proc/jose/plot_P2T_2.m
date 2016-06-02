function plot_P2T_2(binnedData,varigin)

if nargin >= 2
    tgts = varigin(2);
else
    tgts = 1:8;
end

tt = binnedData.trialtable;
binsize = binnedData.timeframe(2)-binnedData.timeframe(1);
lag = 10; % 10*0.05 = 0.5 seg
x_pos = binnedData.cursorposbin(:,1);
y_pos = binnedData.cursorposbin(:,2);

colors = ['r' 'k' 'b' 'c' 'm' 'r' 'b' 'm'];

if (tt(:,7)>=0)
    for i=1:length(tgts)
        a2t = tt(:,10)==i & (tt(:,9)=='R');
        go_t = round(tt(a2t,7)/binsize) - lag/2;
        rew_t = round(tt(a2t,8)/binsize) - lag/2;
        time2T =tt(a2t,8)-tt(a2t,7);
        figure(i);plot(1:length(go_t),time2T,'*'); ylim([0 5]);
        title(sprintf('Time to reach the target %i',i));
        xlabel('Time (sec)'); 
        ylabel('trials'); 
        sum = zeros(2,101);
        for j=1:length(go_t)
            time_path = (go_t(j):rew_t(j)) - go_t(j);
            time_path = (time_path/max(time_path))*100.0;        
            path_x = x_pos(go_t(j):rew_t(j));
            path_xr = interp1(time_path,path_x,0:100);
            path_y = y_pos(go_t(j):rew_t(j));
            path_yr = interp1(time_path,path_y,0:100);
            sum = sum + [path_xr;path_yr];        
        end
        path_c2t = sum/length(go_t);
        figure(9)   
        hold on
        plot(path_c2t(1,:),path_c2t(2,:),colors(i));
        axis([-12 12 -12 12])
        title(sprintf('Paths from go cue to targets'));
        xlabel('X position');
        ylabel('Y position');
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




