function plot_heat_map(act,zerod_ep)
%% plot heat map of neurons in cartesian space
    
    % scale this activity to between 0 and 1
%     stdev_act = std(act);
%     mean_act = mean(act);
%     min_act = mean_act-2*stdev_act;
%     max_act = mean_act+2*stdev_act;
    min_act = min(act);
    max_act = max(act);
    
    act_scaled = (act-min_act)/(max_act-min_act);
    
%     red_vec = max(0,min(1,act_scaled));
%     blue_vec = max(0,min(1,-act_scaled));
    
    map = colormap;
    colorvec = interp1(linspace(0,1,length(map))',map,act_scaled(:));
    
    scatter(zerod_ep(:,1),zerod_ep(:,2),100,colorvec,'filled')
    title('Heat Map')
    xlabel('x')
    ylabel('y')
    colorbar('YTick',[0 1],'YTickLabel',{'Low activity','High Activity'})
    
    axis off
    axis equal
end