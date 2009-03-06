% $Id$

% Plots average trajectories on bump-stim task

clear
load '../../../data_cache/Tiki Bumps003'

%
% build trial table
%%%%%%%%%%%%%%%%%%%%%
forward_start_trial_code = hex2dec('15');
reverse_start_trial_code = hex2dec('15');

forward_trial_starts = bdf.words(bdf.words(:,2) == forward_start_trial_code, 1);
%reverse_trial_starts = bdf.words(bdf.words(:,2) == reverse_start_trial_code, 2);

trial_ends = bdf.words(bitand(bdf.words(:,2), hex2dec('f0')) == hex2dec('20'), :);
trial_table = zeros(length(forward_trial_starts)-1,3); % will hold the [ start end result; ... ] for each trial
for i=1:length(forward_trial_starts)-1
    start_time = forward_trial_starts(i);
    end_idx = find(trial_ends(:,1) > start_time, 1, 'first');
    trial_table(i,:) = [start_time trial_ends(end_idx,:)];
end

% dump the ones that were not successes
trial_table = trial_table( trial_table(:,3) == hex2dec('20'), : );

% replace the trial start time with the go cue start time
go_times = bdf.words(bdf.words(:,2) == hex2dec('31'), 1);
for i = 1:size(trial_table,1)
    trial_table(i,1) = go_times(find(go_times < trial_table(i,2),1,'last'));
end

% generate the bump and control trial tables
bump_trials = [];
control_trials = [];
bump_times = bdf.words(bdf.words(:,2) == hex2dec('51') , 1);
non_bump_times = bdf.words(bdf.words(:,2) == hex2dec('50') , 1);
for i = 1:size(trial_table,1)
    if ~isempty( find(bump_times >= trial_table(i,1) & bump_times <= trial_table(i,2), 1) )
        bump_trials = [bump_trials; trial_table(i,1:2)]; %#ok<AGROW>
    end
    
    if ~isempty( find(non_bump_times >= trial_table(i,1) & non_bump_times <= trial_table(i,2), 1) )
        control_trials = [control_trials; trial_table(i,1:2)]; %#ok<AGROW>
    end
end

% Plot the raw trials and generate reach tables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
control_reaches = cell(size(control_trials,1), 1);
bump_reaches = cell(size(bump_trials,1), 1);

figure; hold on;
for i = 1:size(control_trials,1)
    start_idx = find(bdf.pos(:,1) >= control_trials(i,1), 1, 'first');
    stop_idx  = find(bdf.pos(:,1) >= control_trials(i,2), 1, 'first');
    x = bdf.pos(start_idx:stop_idx, 2);
    y = bdf.pos(start_idx:stop_idx, 3);
    plot(x,y,'b-');
    control_reaches{i} = [x y];
end

for i = 1:size(bump_trials,1)
    start_idx = find(bdf.pos(:,1) >= bump_trials(i,1), 1, 'first');
    stop_idx  = find(bdf.pos(:,1) >= bump_trials(i,2), 1, 'first');
    x = bdf.pos(start_idx:stop_idx, 2);
    y = bdf.pos(start_idx:stop_idx, 3);
    plot(x,y,'r-');
    bump_reaches{i} = [x y];
end

title('raw plot')

% Rotate and scale reaches
%%%%%%%%%%%%%%%%%%%%%%%%%%

total_length = 0; % used for scale at the end
for i = 1:length(control_reaches)
    offset = control_reaches{i}(1,:);
    displacement = control_reaches{i}(end,:) - offset;
    tmp_length = norm(displacement);
    angle = atan2(displacement(2), displacement(1));
    
    r = [cos(-angle) sin(-angle); -sin(-angle) cos(-angle)];
    control_reaches{i} = (control_reaches{i} - repmat(offset,length(control_reaches{i}),1))*r;
    
    total_length = total_length + tmp_length;
end

for i = 1:length(bump_reaches)
    offset = bump_reaches{i}(1,:);
    displacement = bump_reaches{i}(end,:) - offset;
    tmp_length = norm(displacement);
    angle = atan2(displacement(2), displacement(1));
    
    r = [cos(-angle) sin(-angle); -sin(-angle) cos(-angle)];
    bump_reaches{i} = (bump_reaches{i} - repmat(offset,length(bump_reaches{i}),1))*r;
    
    total_length = total_length + tmp_length;
end

% get interpolateed values
avg_length = total_length / (length(control_reaches)+length(bump_reaches));
x_ticks = 0:floor(avg_length);

control_interp = zeros(length(control_reaches), length(x_ticks));
for i = 1:length(control_reaches)
    control_interp(i,:) = interp1(control_reaches{i}(:,1), control_reaches{i}(:,2),x_ticks);
end

bump_interp = zeros(length(bump_reaches), length(x_ticks));
for i = 1:length(bump_reaches)
    bump_interp(i,:) = interp1(bump_reaches{i}(:,1), bump_reaches{i}(:,2),x_ticks);
end

% Plot adjusted trajectories
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure; hold on;
for i = 1:size(control_trials,1)
    plot(x_ticks, control_interp(i,:), 'b-');
end

for i = 1:size(bump_trials,1)
    plot(x_ticks, bump_interp(i,:), 'r-');
end

axis equal;


figure; hold on;
errorbar(x_ticks, mean(control_interp), var(control_interp), 'bo-');
errorbar(x_ticks, mean(bump_interp), var(bump_interp), 'ro-');
axis equal;

figure;
plot(x_ticks, mean(bump_interp) - mean(control_interp), 'ko-')
