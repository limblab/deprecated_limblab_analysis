function plotTrajProgression(seq,groups)
% seq: output of GPFA code
% groups: cell array with indices for each group to plot
%   mxn, where m is number of groups and n is number of conditions.
%
% first group will be gray, second group will rainbow forward, third will rainbow backward, fourth forward etc, etc

numConds = size(groups,2);

numColors = 2;

figure;
a = zeros(1,numConds);
subplot1(2,ceil(numConds/2),'Gap',[0 0]);

for i = 1:numConds
    a(i) = subplot1(i);
    hold on;
    diff_conds = groups(:,i);
    
    plot3D_addon(seq(groups{1,i}), 'xorth', 0.7*[1,1,1], 'dimsToPlot', 1:3,'nPlotMax',10000);
    
    for j = 2:length(diff_conds)
        
        % build color vector for this condition
        trajs = groups{j,i};
        % cols2plot = jet(length(trajs));
        cols2plot = jet(numColors);
        
        for k = 1:length(trajs)            
            plot3D_addon(seq(trajs(k)), 'xorth', cols2plot(ceil(numColors*k/length(trajs)),:),...
                'dimsToPlot', 1:3,'nPlotMax',10000);
        end
    end
    set(a(i),'XLim',[0,4],'YLim',[-2,2],'ZLim',[-2,2]);
end

Link = linkprop(a,{'CameraUpVector', 'CameraPosition', 'CameraTarget'});
setappdata(gcf, 'StoreTheLink', Link);