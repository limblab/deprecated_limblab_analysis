%% Figure 4 (used unit number 11, corresponding to i=5 here)
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
    disp(['Unit number: ' num2str(best_nonlog_ind(i)) ', Elastic PD: ' num2str(best_PD(i)*180/pi) ', Knee-fixed PD: ' num2str(best_PD_con(i)*180/pi) ', PD diff: ' num2str((best_PD_con(i)-best_PD(i))*180/pi)])
    
    waitforbuttonpress
end

%% Figure 5
