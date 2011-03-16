% Build trial_table
% trial_table = 
%[ cursor_on_ct start end result bump_direction stim_id Xstart Ystart Xend Yend; ... ] for each trial
% trial type = 1 (bump), 2 (stim)

function trial_table = BC_detectionB_trial_table(filename)
load(filename)
databurst_version = bdf.databursts{1,2}(2);
start_trial_code = hex2dec('1A');
reward_code = hex2dec('20');
abort_code = hex2dec('21');
fail_code = hex2dec('22');
incomplete_code = hex2dec('23');
bump_code = hex2dec('50');
stim_code = hex2dec('60');
trial_starts = bdf.words(bdf.words(:,2) == start_trial_code, 1);

bdf.words = bdf.words(find(bdf.words(:,1)>bdf.databursts{1} & bitand(bdf.words(:,2),hex2dec('f0'))==hex2dec('10'),1,'first'):...
    find(bitand(bdf.words(:,2),hex2dec('f0'))==hex2dec('20'),1,'last'),:);

% trial_starts = bdf.words(bitand(bdf.words(:,2),hex2dec('f0'))==hex2dec('10'),1);

trial_starts = bdf.words(bitand(bdf.words(:,2),hex2dec('60'))==hex2dec('60') |...    
    bdf.words(:,2)==abort_code,1);
 
trial_ends = bdf.words(bitand(bdf.words(:,2), hex2dec('f0')) == hex2dec('20'), :);
        
trial_table = zeros(length(trial_starts),9);

for i=1:length(trial_starts)
    start_time = trial_starts(i);

    if trial_ends(i,2) ~= abort_code
        stim_id = bdf.words(bdf.words(:,1)==start_time,2);
        stim_id = stim_id-hex2dec('60');
    else
        stim_id = -1;
    end
%     stim_id =  bitand(bump_or_stim,hex2dec('07'));

      
    end_idx = find(trial_ends(:,1) >= start_time, 1, 'first');
    end_pos = bdf.pos(find(bdf.pos(:,1)<=trial_ends(i),1,'last'),2:3);
    %[ start end result bump_direction stim_id Xstart Ystart Xend Yend ]
    trial_table(i,:) = [start_time trial_ends(end_idx,:) 0 stim_id 0 0 end_pos];
end

databurst_times = cell2mat(bdf.databursts(:,1));

for i = 1:size(trial_table,1)  
    trial_table(i,6:7) = bdf.pos(find(bdf.pos(:,1)>trial_table(i,1),1),2:3);        % x and y start
    temp_databurst = cell2mat(bdf.databursts(find(databurst_times<trial_table(i,2),1,'last'),2));     
    trial_table(i,4) = bytes2float(temp_databurst(16:19))';                   % bump direction and magnitude
end
% remove x and y offsets
trial_table(:,[end-3 end-1]) = trial_table(:,[end-3 end-1])+repmat(bytes2float(bdf.databursts{1,2}(8:11)),length(trial_table),2);
trial_table(:,[end-2 end]) = trial_table(:,[end-2 end])+repmat(bytes2float(bdf.databursts{1,2}(12:15)),length(trial_table),2);

trial_table(:,4) = round(10000*mod(trial_table(:,4),2*pi))/10000;

%get target size in a very stupid way
[hist_bins,half_size] = hist(abs(trial_table(:,6)),0:.1:5);
[max_bin,max_ind] = max(hist_bins);
target_size = 2*half_size(max_ind);

ct_on = bdf.words(bdf.words(:,2)==26,1);

%time at which monkey moves into center target
cursor_on_ct = zeros(length(trial_table),1);
x_offset = bytes2float(bdf.databursts{1,2}(8:11));
y_offset = bytes2float(bdf.databursts{1,2}(12:15));
for i=1:length(trial_table)
    ct_on_idx = find(bdf.pos(:,1)>=ct_on(i),1,'first');
    go_cue_idx = find(bdf.pos(:,1)<=trial_table(i,1),1,'last');
    pos_temp = bdf.pos(ct_on_idx:go_cue_idx+200,:);
    pos_temp(:,2) = pos_temp(:,2)+x_offset;
    pos_temp(:,3) = pos_temp(:,3)+y_offset;
    cursor_on_ct_idx = find(abs(pos_temp(:,2))<=target_size/2 &...
        abs(pos_temp(:,3))<=target_size/2,1,'first');
    if isempty(cursor_on_ct_idx)
        [temp cursor_on_ct_idx] = min(max(pos_temp(:,2),pos_temp(:,3)));
    end
    cursor_on_ct(i) = pos_temp(cursor_on_ct_idx,1);
    if cursor_on_ct(i) > trial_table(i,1)
        cursor_on_ct(i) = trial_table(i,1)-.01;
    end
end

trial_table = [cursor_on_ct trial_table];

% save(filename,'trial_table','-append')