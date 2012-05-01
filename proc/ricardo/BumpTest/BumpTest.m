% load file
curr_dir = pwd;
cd('..\..\..\')
load_paths;
cd(curr_dir)

filename = 'Bump_test_007';
fileExt = '.nev';
filepath = 'Z:\TestData\Bump magnitudes\';

temp = dir([filepath filename '_bdf.mat']);
if isempty(temp)
    bdf = get_cerebus_data([filepath filename fileExt],3);
    save([filepath filename '_bdf'],'bdf');
else
    load([filepath filename '_bdf.mat'])
end

cd('C:\Users\system administrator\Desktop\s1_analysis\proc\ricardo\AT_analysis');
[trial_table tc] = AT_trial_table([filepath filename '_bdf']);
cd(pwd)
trial_table = trial_table(5:end-5,:);

bump_duration = trial_table(1,tc.bump_duration);
bump_forces_x = zeros(size(trial_table,1),200);
bump_forces_y = zeros(size(trial_table,1),200);
force_offset_x = mean(bdf.force(2:500,2));
force_offset_y = mean(bdf.force(2:500,3));
for iBump = 1:size(trial_table,1)
    indices = 299+find(bdf.force(:,1) >= trial_table(iBump,tc.t_bump_1_onset),200,'first');
    bump_forces_x(iBump,:) = bdf.force(indices,2)-force_offset_x;
    bump_forces_y(iBump,:) = bdf.force(indices,3)-force_offset_y;
end
measured_forces_x = mean(bump_forces_x,2);
measured_forces_y = mean(bump_forces_y,2);
commanded_forces_x = trial_table(:,tc.bump_1_magnitude).*cos(trial_table(:,tc.bump_direction));
commanded_forces_y = trial_table(:,tc.bump_1_magnitude).*sin(trial_table(:,tc.bump_direction));

figure;
plot(commanded_forces_x,measured_forces_x,'r.');
hold on
plot(commanded_forces_y,measured_forces_y,'b.');

figure;
plot(commanded_forces_x,commanded_forces_y,'r.');
hold on
plot(measured_forces_x,measured_forces_y,'b.');