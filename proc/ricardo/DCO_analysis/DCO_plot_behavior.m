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
if numel(DCO.target_forces)==numel(DCO.target_force_range)
    plot(DCO.target_forces,DCO.target_forces*(1+DCO.target_force_range),'-b')
    plot(DCO.target_forces,DCO.target_forces*(1-DCO.target_force_range),'-b')
end

xlabel('Target force (N)')
ylabel('Actual force (N)')
title('Handle force')
set(params.fig_handles(end),'Name','Handle force')
axis equal

%% End of trial force
params.fig_handles(end+1) = figure;
hold on
for iTrial = 1:length(DCO.reward_trials)
    plot3(DCO.trial_table(DCO.reward_trials(iTrial),DCO.table_columns.target_force),...
        DCO.trial_table(DCO.reward_trials(iTrial),DCO.table_columns.outer_target_stiffness),...
        sqrt(mean(bdf.force(DCO.ot_last_hold_idx(iTrial):DCO.end_idx(iTrial),2))^2+...
        mean(bdf.force(DCO.ot_last_hold_idx(iTrial):DCO.end_idx(iTrial),3))^2),'.r')
end

if numel(DCO.target_forces)==numel(DCO.target_force_range)
    plot3(DCO.target_forces,repmat(DCO.target_stiffnesses(1),length(DCO.target_forces),1),DCO.target_forces*(1+DCO.target_force_range),'-b')
    plot3(DCO.target_forces,repmat(DCO.target_stiffnesses(end),length(DCO.target_forces),1),DCO.target_forces*(1+DCO.target_force_range),'-b')
    plot3(DCO.target_forces,repmat(DCO.target_stiffnesses(1),length(DCO.target_forces),1),DCO.target_forces*(1-DCO.target_force_range),'-b')
    plot3(DCO.target_forces,repmat(DCO.target_stiffnesses(end),length(DCO.target_forces),1),DCO.target_forces*(1-DCO.target_force_range),'-b')
end

xlabel('Target force (N)')
ylabel('Target stiffness (N/cm)')
zlabel('Actual force (N)')
title('Handle force')
set(params.fig_handles(end),'Name','Handle force(F,K)')
% axis equal