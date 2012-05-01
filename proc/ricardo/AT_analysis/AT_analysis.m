% load file
curr_dir = pwd;
cd('..\..\..\')
load_paths;
cd(curr_dir)

filename = 'Bump_test_003';
fileExt = '.nev';
filepath = 'Z:\TestData\Bump magnitudes\';

temp = dir([filepath filename '_bdf.mat']);
if isempty(temp)
    bdf = get_cerebus_data([filepath filename fileExt],3);
    save([filepath filename '_bdf'],'bdf');
else
    load([filepath filename '_bdf.mat'])
end

[trial_table tc] = AT_trial_table([filepath filename '_bdf']);

% Displacement as a function of bump direction

