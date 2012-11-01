function [t2T path2T_x path2T_y] = get_path_WF(binnedData,varigin)

% Get the average path across trials for each target for the WF task
% binnedData: Data binned at 50 ms, WF task
% tgts: vector containing the targets you want to analize
% t2T: average time (across trials) to go from the center to each target
%      t2T = ['target x', time to reach 'target x']
%      size(t2T) = [number of targets, 2]
% path2T_x : average position x from the center to each target
%            number of rows = number of targets
%            path2T_x = ['target x', vector_x ]
%            vector_x: vector contains position x from center to 'target x'
% path2T_y : correspondent average position y from the center to each target
% path has been resampled to 100 to make all paths standard
% Update at 11-01/12 ... By Jose

if nargin >= 2
    tgts = varigin(2);
else
    tgts = 1:8; % take all 8 targets by default
end

tt = binnedData.trialtable;
binsize = binnedData.timeframe(2)-binnedData.timeframe(1);
lag = 10; % 10*0.05 = 0.5 seg
x_pos = binnedData.cursorposbin(:,1);
y_pos = binnedData.cursorposbin(:,2);
t2T = zeros(length(tgts),2);
path2T_x = zeros(length(tgts),102); 
path2T_y = zeros(length(tgts),102);
if (tt(:,7)>=0)
    for i=1:length(tgts)
        a2t = tt(:,10)==i & (tt(:,9)=='R');
        go_t = round(tt(a2t,7)/binsize) - lag/2;
        rew_t = round(tt(a2t,8)/binsize) - lag/2;
        time2T =tt(a2t,8)-tt(a2t,7);
        t2T(i,:) = [tgts(i), mean(time2T)];
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
        path_c2t = [mean(paths_x,1);mean(paths_y,1)];
        path2T_x(i,:) = [tgts(i),path_c2t(1,:)];
        path2T_y(i,:) = [tgts(i),path_c2t(2,:)];
    end
end





