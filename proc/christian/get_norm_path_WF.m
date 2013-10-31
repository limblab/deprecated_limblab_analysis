function [norm_paths time2tgt] = get_path_WF(binnedData)

% Get the normalized cursor path between go_cue and reward
% for each successful trial and each target

%        path_x = {, vector_x ]
%        vector_x: vector contains position x from center to 'target x'

binsize = binnedData.timeframe(2)-binnedData.timeframe(1);
num_trials = size(binnedData.trialtable,1);
num_targets = max(unique(binneData.trialtable(:,10)));
norm_paths = cell(1,num_targets);

for i = 1:num_trials
    
    if binnedData.trialtable(:,9)~='R'
        continue;
    end
    
    tgt = binnedData.trialtable(:,10);
    go_t = round(binnedData.trialtable(:,7)/binsize);
    rew_t = round(binnedData.trialtable(a2t,8)/binsize);% - lag/2;
    binned_path = 
    
x_pos = binnedData.cursorposbin(:,1);
y_pos = binnedData.cursorposbin(:,2);
path2T_x = zeros(length(tgts),102); 
path2T_y = zeros(length(tgts),102);
t2T = zeros(100,length(tgts));

final_time = size(binnedData.timeframe,1)*0.05; % final reward sometimes exceeds total data time

for i=1:length(tgts)
    a2t = tt(:,10)==i & (tt(:,9)=='R') & tt(:,7)>=0 & tt(:,8)<=final_time;
    go_t = round(tt(a2t,7)/binsize); %- lag/2;
    rew_t = round(tt(a2t,8)/binsize);% - lag/2;
    time2T =tt(a2t,8)-tt(a2t,7);
    t2T(1:length(go_t),i) = time2T;
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






