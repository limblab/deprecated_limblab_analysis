% Build trial_table
% trial_table = 
%[ cursor_on_ct start end result bump_direction bump_magnitude stim_id Xstart Ystart Xend Yend; ... ] for each trial
% trial type = 1 (bump), 2 (stim)

function [trial_table , table_columns] = BC_trial_table(filename)
load(filename)
databurst_version = bdf.databursts{1,2}(2);
start_trial_code = hex2dec('1A');
end_code = hex2dec('20');
reward_code = hex2dec('20');
abort_code = hex2dec('21');
fail_code = hex2dec('22');
incomplete_code = hex2dec('23');
bump_code = hex2dec('50');
stim_code = hex2dec('60');
ct_on_code = hex2dec('30');

table_columns.cursor_on_ct = 1;
table_columns.start = 2;
table_columns.bump_time = 3;
table_columns.end = 4;
table_columns.result = 5;
table_columns.bump_direction = 6;
table_columns.bump_magnitude = 7;
table_columns.stim_id = 8;
table_columns.Xstart = 9;
table_columns.Ystart = 10;
table_columns.Xend = 11;
table_columns.Yend = 12;
table_columns.training = 13;
table_columns.num_outer_targets = 14;
table_columns.bump_and_stim = 15;

bdf.words = bdf.words(find(bdf.words(:,1)>bdf.databursts{1} & bitand(bdf.words(:,2),hex2dec('f0'))==hex2dec('10'),1,'first'):...
    find(bitand(bdf.words(:,2),hex2dec('f0'))==hex2dec('20'),1,'last'),:);

bdf.words = bdf.words(find([diff(bdf.words(:,2))~=0;1]),:);

trial_starts = bdf.words(bdf.words(:,2)==start_trial_code,:);
ct_on = bdf.words(bdf.words(:,2)==ct_on_code,:);

while length(trial_starts)<length(ct_on)
    temp = diff([trial_starts(:,1) ct_on(1:length(trial_starts),1)]')';
    temp = find(temp<0,1,'first');
%     temp = temp-1;
    words_idx_remove = [find(bdf.words(:,1)==ct_on(temp)):find(bdf.words(:,1)==trial_starts(temp))-1];
    words_idx = 1:length(bdf.words);
    bdf.words = bdf.words(setdiff(words_idx,words_idx_remove),:);
    trial_starts = bdf.words(bdf.words(:,2)==start_trial_code,:);
    ct_on = bdf.words(bdf.words(:,2)==ct_on_code,:);
end

% trial_starts = bdf.words(bdf.words(:,2) == start_trial_code, 1);
% trial_starts = [trial_starts repmat(start_trial_code,length(trial_starts),1)];

trial_starts = bdf.words(find(bdf.words(:,2)==ct_on_code)+1,:);
trial_ends = bdf.words(bdf.words(:,2)>=reward_code &...
    bdf.words(:,2)<=incomplete_code,:);

trial_table = zeros(length(trial_starts),length(fieldnames(table_columns)));

trial_table(:,table_columns.start) = trial_starts(:,1);
trial_table(:,table_columns.end) = trial_ends(:,1);
trial_table(:,table_columns.result) = trial_ends(:,2);

trial_table = trial_table(trial_table(:,table_columns.end)<bdf.pos(end,1),:);

databurst_times = cell2mat(bdf.databursts(:,1));

for i = 1:size(trial_table,1)
    trial_table(i,[table_columns.Xstart table_columns.Ystart]) =...
        bdf.pos(find(bdf.pos(:,1)>trial_table(i,table_columns.start),1),2:3);        % x and y start
    temp_databurst = cell2mat(bdf.databursts(find(databurst_times<trial_table(i,table_columns.start),1,'last'),2));     
    trial_table(i,table_columns.bump_direction) = bytes2float(temp_databurst(16:19))';     % bump direction 
    trial_table(i,table_columns.bump_magnitude) = 2*bytes2float(temp_databurst(20:23))';   % bump magnitude
    trial_table(i,table_columns.training) = temp_databurst(7);
    trial_table(i,table_columns.num_outer_targets) = temp_databurst(25);
    trial_table(i,table_columns.bump_and_stim) = temp_databurst(24);
    end_pos = bdf.pos(find(bdf.pos(:,1)<=trial_table(i,table_columns.end),1,'last'),2:3);
    trial_table(i,[table_columns.Xend table_columns.Yend]) = end_pos;
end

for i = 2:length(bdf.words)
    if bdf.words(i-1,2)==ct_on_code
        table_idx = find(trial_table(:,table_columns.start)== bdf.words(i,1));
        if bdf.words(i,2)==abort_code
            trial_table(table_idx,table_columns.bump_time) = 0;
            trial_table(table_idx,table_columns.stim_id) = -1;
        elseif (bdf.words(i,2)>=bump_code && bdf.words(i,2)<stim_code)
            trial_table(table_idx,table_columns.start) = bdf.words(i,1);
            trial_table(table_idx,table_columns.bump_time) = bdf.words(i,1);
        elseif (bdf.words(i,2)>=stim_code && bdf.words(i,2)<=stim_code+16)
            trial_table(table_idx,table_columns.start) = bdf.words(i,1);
            trial_table(table_idx,table_columns.stim_id) = bdf.words(i,2)-stim_code;
            if (bdf.words(i+1,2)>=bump_code && bdf.words(i+1,2)<stim_code)
                trial_table(table_idx,table_columns.bump_time) = bdf.words(i+1,1);
            end
        end
    end
end
        
% remove x and y offsets
trial_table(:,[table_columns.Xstart table_columns.Xend]) = trial_table(:,[table_columns.Xstart table_columns.Xend])+repmat(bytes2float(bdf.databursts{1,2}(8:11)),size(trial_table,1),2);
trial_table(:,[table_columns.Ystart table_columns.Yend]) = trial_table(:,[table_columns.Ystart table_columns.Yend])+repmat(bytes2float(bdf.databursts{1,2}(12:15)),size(trial_table,1),2);

trial_table(:,table_columns.bump_direction) = round(10000*mod(trial_table(:,table_columns.bump_direction),2*pi))/10000;

%get target size in a very smart way
target_size = bytes2float(bdf.databursts{1,2}(26:29));

ct_on = bdf.words(bdf.words(:,2)==26,1);

%time at which monkey moves into center target
cursor_on_ct = zeros(size(trial_table,1),1);
x_offset = bytes2float(bdf.databursts{1,2}(8:11));
y_offset = bytes2float(bdf.databursts{1,2}(12:15));
for i=1:size(trial_table,1)
    ct_on_idx = find(bdf.pos(:,1)>=ct_on(i),1,'first');
    go_cue_idx = find(bdf.pos(:,1)<=trial_table(i,table_columns.start),1,'last');
    pos_temp = bdf.pos(ct_on_idx:min(length(bdf.pos),go_cue_idx+200),:);
    pos_temp(:,2) = pos_temp(:,2)+x_offset;
    pos_temp(:,3) = pos_temp(:,3)+y_offset;
    cursor_on_ct_idx = find(abs(pos_temp(:,2))<=target_size/2 &...
        abs(pos_temp(:,3))<=target_size/2,1,'first');
    if isempty(cursor_on_ct_idx)
        [temp cursor_on_ct_idx] = min(max(pos_temp(:,2),pos_temp(:,3)));
    end
%     if ~isempty(cursor_on_ct_idx)
        cursor_on_ct(i) = pos_temp(cursor_on_ct_idx,1);
%     else
%         cursor_on_ct(i) = trial_table(i,table_columns.start)-.01;
%     end
    if cursor_on_ct(i) > trial_table(i,table_columns.start)
        cursor_on_ct(i) = trial_table(i,table_columns.start)-.01;
    end
end

trial_table(:,table_columns.cursor_on_ct) = cursor_on_ct;
% trial_table = trial_table(trial_table(:,table_columns.bump_magnitude)>=0,:);
save(filename,'trial_table','table_columns','-append')