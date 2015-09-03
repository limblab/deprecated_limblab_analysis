function plot_heat_map(base_leg,act,zerod_ep,PD)
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
    
    map = colormap(jet);
    colorvec = interp1(linspace(0,1,length(map))',map,act_scaled(:));
    
    scatter(zerod_ep(:,1),zerod_ep(:,2),100,colorvec,'filled')
    hold on
    center_ep = mean(zerod_ep([45 46 55 56],:))';
    [~,~,~,segment_angles_unc] = find_kinematics(base_leg,center_ep, 0);
    draw_bones(base_leg,segment_angles_unc,false,2)
    PD_end = 7*[cos(PD);sin(PD)]+center_ep;
    plot([center_ep(1) PD_end(1)],[center_ep(2) PD_end(2)],'-k','linewidth',3)
    title('Heat Map')
    xlabel('x')
    ylabel('y')
    colorbar('YTick',[0 1],'YTickLabel',{[num2str(min_act) ' Hz'], [num2str(max_act) ' Hz']})
    
    axis off
    axis equal
end