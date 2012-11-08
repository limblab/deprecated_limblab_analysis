function length_T = get_length_path_WF(binnedData,varigin)

% Get the length of the path for all succesful trials per target for the WF task
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
length_T = zeros(100,length(tgts));

for i=1:length(tgts)
    a2t = tt(:,10)==i & (tt(:,9)=='R') & tt(:,7)>=0;
    go_t = round(tt(a2t,7)/binsize) - lag/2;
    rew_t = round(tt(a2t,8)/binsize) - lag/2;
    for j=1:length(go_t)
        path_x = x_pos(go_t(j):rew_t(j));
        path_y = y_pos(go_t(j):rew_t(j));
        A = [path_x,path_y];
        l_p = (A(2:end,:) - A(1:end-1,:)).^2; % difference between points
        l_p = sum(sqrt(sum(l_p,2))); % sqrt and sum all distances
        length_T(j,i) = l_p;         
    end
end






