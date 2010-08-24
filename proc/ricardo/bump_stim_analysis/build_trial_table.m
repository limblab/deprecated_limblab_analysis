% Build trial_table
% trial_table = [ start end direction result trial_type bump_magnitude stim_id; ... ]

function trial_table = build_trial_table(filename)

load(filename)
forward_start_trial_code = hex2dec('14');
reverse_start_trial_code = hex2dec('15');
reward_code = hex2dec('20');
abort_code = hex2dec('21');
fail_code = hex2dec('22');
bump_code = hex2dec('50');
stim_code = hex2dec('60');
forward_trial_starts = bdf.words(bdf.words(:,2) == forward_start_trial_code, 1);
reverse_trial_starts = bdf.words(bdf.words(:,2) == reverse_start_trial_code, 1);

bdf.words = bdf.words(find(bitand(bdf.words(:,2),hex2dec('f0'))==hex2dec('10'),1):...
    find(bitand(bdf.words(:,2),hex2dec('f0'))==hex2dec('20'),1,'last'),:);

trial_starts = bdf.words(bitand(bdf.words(:,2),hex2dec('f0'))==hex2dec('10'),1);
 
trial_ends = bdf.words(bitand(bdf.words(:,2), hex2dec('f0')) == hex2dec('20'), :);
trial_table = zeros(length(trial_starts),12); % will hold the 
%[ start end direction result trial_type bump_magnitude stim_id Xstart Ystart Xend Yend direction_index; ... ] for each trial
% trial type = 0 (control), 1 (bump), 2 (stim)
for i=1:length(trial_starts)
    start_time = trial_starts(i);
    trial_type = 0;
    bump_or_stim = bdf.words(min(find(bdf.words(:,1)==start_time,1)+4,length(bdf.words)),2);
    bump_trial = bitand(bump_or_stim,hex2dec('F0'))==bump_code;
    if bump_trial
        bump_mag = bitand(bump_or_stim,hex2dec('07'));
        bump_mag = (-2*(bitand(bump_or_stim,hex2dec('08'))>0)+1)*bump_mag;
        trial_type = 1;
    else
        bump_mag = 0;
    end
    stim_trial = bitand(bump_or_stim,hex2dec('F0'))==stim_code;
    if stim_trial
        stim_id =  bitand(bump_or_stim,hex2dec('07'));
        trial_type = 2;
    else
        stim_id = -1;
    end        
    end_idx = find(trial_ends(:,1) > start_time, 1, 'first');
    direction = bdf.words(find(bdf.words(:,1)==start_time,1),2) == forward_start_trial_code;
    trial_table(i,:) = [start_time trial_ends(end_idx,1) direction trial_ends(end_idx,2) trial_type bump_mag stim_id 0 0 0 0 0];
end

% dump the ones that were aborted
trial_table = trial_table(trial_table(:,4) == hex2dec('20')|trial_table(:,4) == hex2dec('22'), : );

% replace the trial start time with the go cue start time and add databurst
% info
go_times = bdf.words(bdf.words(:,2) == hex2dec('31'), 1);
databurst_times = cell2mat(bdf.databursts(:,1));
for i = 1:size(trial_table,1)
    trial_table(i,1) = go_times(find(go_times < trial_table(i,2),1,'last'));
    temp_databurst = cell2mat(bdf.databursts(find(databurst_times<trial_table(i,2),1,'last'),2));
    trial_table(i,8:11) = bytes2float(temp_databurst(end-15:end))';
end

trial_table = trial_table(abs(trial_table(:,8))<20,:);

start_pos = abs(trial_table(1,8));
trial_table(1,12) = 1;
direction_index = 1;
for iTrial = 2:length(trial_table)
    if abs(abs(trial_table(iTrial,8))-start_pos)>1e-3
        direction_index = direction_index+1;
        start_pos = abs(trial_table(iTrial,8));
    end
    trial_table(iTrial,12) = direction_index;
end
        