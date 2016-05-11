%% Figure 4 (used unit number 11, corresponding to i=5 here)
% (use unit number 43, corresponding to i=19 here, for more representative)
best_act_ind = VAF_cart_unc>0.4;
best_act = activity_unc(best_act_ind,:);
best_PD = yupd(best_act_ind);
best_PD_con = ycpd(best_act_ind);
best_nonlog_ind = find(best_act_ind);
for i = 19
    figure(1234)
    clf
    plot_heat_map(base_leg,best_act(i,:),endpoint_positions',best_PD(i))
    title(['Polar R2: ' num2str(VAF_unc(best_nonlog_ind(i))) ', Cart R2: ' num2str(VAF_cart_unc(best_nonlog_ind(i)))])
    disp(['Unit number: ' num2str(best_nonlog_ind(i)) ', Elastic PD: ' num2str(best_PD(i)*180/pi) ', Knee-fixed PD: ' num2str(best_PD_con(i)*180/pi) ', PD diff: ' num2str((best_PD_con(i)-best_PD(i))*180/pi)])
    
    waitforbuttonpress
end

%% Figure 5 Plane regression figures (Cartesian)
x_list = zerod_ep(:,1);
y_list = zerod_ep(:,2);
x_corners = [min(x_list) min(x_list) max(x_list) max(x_list)]';
y_corners = [min(y_list) max(y_list) max(y_list) min(y_list)]';

% elastic
figure(1)
clf
for i = [11]
    plane_list = predict(cart_fit_unc{i},[x_list y_list]);
    plane_corners = predict(cart_fit_unc{i},[x_corners y_corners]);
    figure(1)
    plot3([x_corners(1) x_corners(2)],[y_corners(1) y_corners(2)],[plane_corners(1) plane_corners(2)],'k-','linewidth',2)
    hold on
    plot3([x_corners(2) x_corners(3)],[y_corners(2) y_corners(3)],[plane_corners(2) plane_corners(3)],'k-','linewidth',2)
    plot3([x_corners(3) x_corners(4)],[y_corners(3) y_corners(4)],[plane_corners(3) plane_corners(4)],'k-','linewidth',2)
    plot3([x_corners(4) x_corners(1)],[y_corners(4) y_corners(1)],[plane_corners(4) plane_corners(1)],'k-','linewidth',2)
    plot3(x_list,y_list,plane_list,'k.')
    plot3(x_list,y_list,activity_unc(i,:)','bo','linewidth',2)
    for j = 1:100
        plot3([x_list(j) x_list(j)],[y_list(j) y_list(j)],[plane_list(j) activity_unc(i,j)],'k-','linewidth',2)
    end
    
    xlabel('X Position (cm)')
    ylabel('Y Position (cm)')
    zlabel('Activity (Hz)')
end

% knee-fixed
% figure(2)
% clf
% for i = [11]
%     plane_list = predict(pol_fit_con{i},[rsg_list asg_list]);
%     plane_corners = predict(pol_fit_con{i},[rsg_corners asg_corners]);
%     figure(2)
%     plot3([rsg_corners(1) rsg_corners(2)],180/pi*[asg_corners(1) asg_corners(2)],[plane_corners(1) plane_corners(2)],'k-')
%     hold on
%     plot3([rsg_corners(2) rsg_corners(3)],180/pi*[asg_corners(2) asg_corners(3)],[plane_corners(2) plane_corners(3)],'k-')
%     plot3([rsg_corners(3) rsg_corners(4)],180/pi*[asg_corners(3) asg_corners(4)],[plane_corners(3) plane_corners(4)],'k-')
%     plot3([rsg_corners(4) rsg_corners(1)],180/pi*[asg_corners(4) asg_corners(1)],[plane_corners(4) plane_corners(1)],'k-')
%     plot3(rsg_list,180/pi*asg_list,plane_list,'k.')
%     plot3(rsg_list,180/pi*asg_list,activity_con(i,:)','bo')
%     for j = 1:100
%         plot3([rsg_list(j) rsg_list(j)],180/pi*[asg_list(j) asg_list(j)],[plane_list(j) activity_con(i,j)],'k-')
%     end
% end