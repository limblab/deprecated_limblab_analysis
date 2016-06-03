function plot_P2T_4(binnedData,varigin)

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

colors = ['r';'k';'b';'c';'m';'r';'b';'m'];
color_l = ['-ro';'-ko';'-bo';'-co';'-mo';'-ro';'-bo';'-mo'];
color_s_e = ['r*';'k*';'b*';'c*';'m*';'r*';'b*';'m*'];
rgb_c = [  1    0.9   0.9;
          0.9   0.9   0.9;
          0.9   0.9    1 ;
          0.85   1     1 ;
           1    0.85    1;
           1    0.9   0.9;
          0.9   0.9    1 ;      
           1    0.85   1 ];

m_paths_x = zeros(length(tgts),101);
m_paths_y = zeros(length(tgts),101);
       
if (tt(:,7)>=0)
    for i=1:length(tgts)
        a2t = tt(:,10)==i & (tt(:,9)=='R');
        go_t = round(tt(a2t,7)/binsize) - lag/2;
        rew_t = round(tt(a2t,8)/binsize) - lag/2;
%         time2T =tt(a2t,8)-tt(a2t,7);
%         figure(i);plot(1:length(go_t),time2T,'*'); ylim([0 5]);
%         title(sprintf('Time to reach the target %i',i));
%         xlabel('Time (sec)'); 
%         ylabel('trials'); 
        paths_x = zeros(length(go_t),101);
        paths_y = zeros(length(go_t),101);
        for j=1:length(go_t)
            time_path = (go_t(j):rew_t(j)) - go_t(j);
            time_path = (time_path/max(time_path))*100.0;        
            path_x = x_pos(go_t(j):rew_t(j));
            path_xr = interp1(time_path,path_x,0:100);
            path_y = y_pos(go_t(j):rew_t(j));
            path_yr = interp1(time_path,path_y,0:100);      
            paths_x(j,:) = path_xr;
            paths_y(j,:) = path_yr;
        end
        m_paths_x(i,:) = mean(paths_x,1);
        m_paths_y(i,:) = mean(paths_y,1);        
        std_path = [std(paths_x,1,1);std(paths_y,1,1)];
        figure(9)   
        for k=1:101
            plot_ellipse(std_path(1,k),std_path(2,k),m_paths_x(i,k),m_paths_y(i,k),0,rgb_c(i,:)); 
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
            hold on;
        end
    end
    for i=1:length(tgts)
        figure(9)
        plot(m_paths_x(i,:),m_paths_y(i,:),color_l(i,:),'LineWidth',2,'MarkerEdgeColor',...
        colors(i),'MarkerFaceColor',colors(i),'MarkerSize',1);hold on
        plot(m_paths_x(i,1),m_paths_y(i,1),color_s_e(i,:),'LineWidth',2,'MarkerSize',7)
        plot(m_paths_x(i,end),m_paths_y(i,end),color_s_e(i,:),'LineWidth',2,'MarkerSize',7)        
        axis equal;
        title(sprintf('Paths from go cue to targets'));
        xlabel('X position');
        ylabel('Y position');
    end
end






