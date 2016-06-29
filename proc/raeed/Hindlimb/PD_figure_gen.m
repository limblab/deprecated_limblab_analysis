%%
best_act_ind = VAF_cart_unc>0.4;
best_act = activity_unc(best_act_ind,:);
best_PD = yupd(best_act_ind);
best_PD_con = ycpd(best_act_ind);
best_nonlog_ind = find(best_act_ind);
for i = 1:100
    figure(1234)
    clf
    plot_heat_map(base_leg,best_act(i,:),endpoint_positions',best_PD(i))
    title(['Polar R2: ' num2str(VAF_unc(best_nonlog_ind(i))) ', Cart R2: ' num2str(VAF_cart_unc(best_nonlog_ind(i)))])
    disp(['Elastic PD: ' num2str(best_PD(i)*180/pi) ', Knee-fixed PD: ' num2str(best_PD_con(i)*180/pi) ', PD diff: ' num2str((best_PD_con(i)-best_PD(i))*180/pi)])
    
%     figure(1235)
%     clf
%     subplot(211)
%     plot_real_v_predicted(best_act(i,:),cart_fit_unc{best_nonlog_ind(i)},zerod_ep)
%     title(['Polar R2: ' num2str(VAF_unc(best_nonlog_ind(i))) ', Cart R2: ' num2str(VAF_cart_unc(best_nonlog_ind(i)))])
%     subplot(212)
%     plot_real_v_predicted(best_act(i,:),pol_fit_unc{best_nonlog_ind(i)},[x1' x2'])
%     disp(neurons(best_nonlog_ind(i),:)/norm(neurons(best_nonlog_ind(i),:)))
    waitforbuttonpress
end

%%
plot_PD_distr(randsample(best_PD,800,true),36)
hold on

center_ep = mean(endpoint_positions(:,[45 46 55 56]),2);
[~,~,~,segment_angles_unc] = find_kinematics(base_leg,center_ep, 0);
legpts = get_legpts(base_leg,segment_angles_unc);
ep = legpts(:,base_leg.segment_idx(end,end));
hip_rot = legpts(:,base_leg.segment_idx(1,1));
% angle = 

for i = 1:3
    s=base_leg.segment_idx(i,:);
    plot((legpts(1,s)-ep(1))/20, (legpts(2,s)-ep(2))/20, 'k-','LineWidth',2)
    plot((legpts(1,s)-ep(1))/20, (legpts(2,s)-ep(2))/20, 'bo', 'MarkerSize',10, 'LineWidth',2)
end

hold off
%%
rose(best_PD)