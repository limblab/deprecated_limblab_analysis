function params = DCO_plot_behavior(data_struct,params)
DCO = data_struct.DCO;
bdf = data_struct.bdf;

%% Hand position
params.fig_handles(end+1) = figure;
hold on
plot(DCO.pos_mov_x(:,1)',...
    DCO.pos_mov_y(:,2)','.r')
plot(DCO.pos_mov_x(:,:)',...
    DCO.pos_mov_y(:,:)','-k')

xlabel('X position (cm)')
ylabel('Y position (cm)')
title('Handle position')
set(params.fig_handles(end),'Name','Handle position')
axis equal

%% End of trial force
params.fig_handles(end+1) = figure;
hold on
for iTrial = 1:length(DCO.reward_trials)
    plot(DCO.trial_table(DCO.reward_trials(iTrial),DCO.table_columns.target_force),...
        sqrt(mean(bdf.force(DCO.ot_last_hold_idx(iTrial):DCO.end_idx(iTrial),2))^2+...
        mean(bdf.force(DCO.ot_last_hold_idx(iTrial):DCO.end_idx(iTrial),3))^2),'.r')
end
plot(DCO.target_forces,DCO.target_forces*(1+DCO.target_force_range),'-b')
plot(DCO.target_forces,DCO.target_forces*(1-DCO.target_force_range),'-b')    

xlabel('Target force (N)')
ylabel('Actual force (N)')
title('Handle force')
set(params.fig_handles(end),'Name','Handle force')
axis equal