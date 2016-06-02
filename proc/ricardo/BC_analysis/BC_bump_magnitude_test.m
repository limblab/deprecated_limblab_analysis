
% BC_011 -> MG2 = 1.4?
% BC_012 -> MG2 = 1.45, L1 = 25, L2 = 23.5
% BC_013 -> MG2 = 1.5, L1 = 25, L2 = 23.5
% BC_014 -> MG2 = 1.5, L1 = 24.8, L2 = 23.8
% BC_015 -> MG2 = 1.5, L1 = 24.8, L2 = 24
% BC_016 -> MG2 = 1.5, L1 = 25, L2 = 24
% BC_017 -> MG2 = 1.4, L1 = 24.7, L2 = 24.1
% BC_018 -> MG2 = 1.4, L1 = 24.8, L2 = 24
% BC_019 -> MG2 = 1.45, L1 = 24.8, L2 = 24
% BC_020 -> MG2 = 1.45, L1 = 24.8, L2 = 24 (different arm configuration: x=-26, y=8)

BC_batch;
load('D:\Data\TestData\Processed\BumpMagnitudesTest_BC_020','bdf','trial_table','table_columns')
trial_table = trial_table(1:end-1,:);

% figure; 
% plot(bdf.force(:,2),bdf.force(:,3))

bump_magnitudes_command = trial_table(:,table_columns.bump_magnitude);
bump_directions = trial_table(:,table_columns.bump_direction);

mag_selection = bump_magnitudes_command>0 & bump_magnitudes_command<0.3;

% figure; 
% plot(cos(bump_directions).*bump_magnitudes_command,...
%     sin(bump_directions).*bump_magnitudes_command,'.');

bump_table_x = zeros(size(trial_table,1),0.2*2000);
bump_table_y = zeros(size(trial_table,1),0.2*2000);
for iTrial = 1:size(trial_table,1)
    bump_start = trial_table(iTrial,table_columns.bump_time);
    bump_start_idx = find(bdf.force(:,1)>bump_start,1,'first');
    bump_start_idx = bump_start_idx - 100;
    bump_table_x(iTrial,:) = bdf.force(bump_start_idx:bump_start_idx+size(bump_table_x,2)-1,2)';
    bump_table_y(iTrial,:) = bdf.force(bump_start_idx:bump_start_idx+size(bump_table_y,2)-1,3)';
end

bump_time_axis = ([1:size(bump_table_x,2)]-100)./2000;
bump_magnitudes_table = sqrt(bump_table_x.^2+bump_table_y.^2);
max_bump_magnitudes = max(bump_magnitudes_table,[],2);
mean_bump_magnitudes = mean(bump_magnitudes_table(:,150:end),2);

force_magnitude = sqrt(bdf.force(:,2).^2+bdf.force(:,3).^2);

% figure;
% plot(bump_table_x',bump_table_y')
% 
% figure;
% plot(bump_time_axis,bump_magnitudes_table(mag_selection,:)')
% 
% figure; 
% plot(bump_magnitudes_command,max_bump_magnitudes,'.')
% hold on
% plot(bump_magnitudes_command,mean_bump_magnitudes,'.r')
% 
% figure; 
% plot(bump_directions,max_bump_magnitudes,'.')


% figure; 
% plot(bump_table_x(mag_selection,:)',bump_table_y(mag_selection,:)','Color',[0.7 0.7 1])
% hold on
% % plot(cos(bump_directions(mag_selection)).*max_bump_magnitudes(mag_selection),...
% %     sin(bump_directions(mag_selection)).*max_bump_magnitudes(mag_selection),'.b')
% plot(mean(bump_table_x(mag_selection,find(bump_time_axis>0.05):end),2),...
%     mean(bump_table_y(mag_selection,find(bump_time_axis>0.05):end),2),'r.')
% plot(0,0,'.k')
% xlim([-35 35])
% ylim([-35 35])
% axis square

figure;
plot(mean(bump_table_x(mag_selection,find(bump_time_axis>0.05):end),2),...
    mean(bump_table_y(mag_selection,find(bump_time_axis>0.05):end),2),'r.')
hold on
% plot(0,0,'.k')
xlim([-35 35])
ylim([-35 35])
axis square

x = mean(bump_table_x(mag_selection,find(bump_time_axis>0.05):end),2);
y = mean(bump_table_y(mag_selection,find(bump_time_axis>0.05):end),2);

ellipse = fit_ellipse(x,y,gca);
text(-30,-30,[{['Axes ratio: ' num2str(ellipse.long_axis/ellipse.short_axis)]};
    {['Angle: ' num2str(180*ellipse.phi/pi)]}])

% figure; 
% plot(bdf.force(:,1),force_magnitude)
