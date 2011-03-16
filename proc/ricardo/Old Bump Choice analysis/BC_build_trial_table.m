% Build trial_table
% trial_table = 
%[ start end result trial_type training bump_direction bump_magnitude stim_id Xstart Ystart Xend Yend; ... ] for each trial
% trial type = 1 (bump), 2 (stim)

function trial_table = BC_build_trial_table(filename)
load(filename)
databurst_version = bdf.databursts{1,2}(2);
start_trial_code = hex2dec('1A');
reward_code = hex2dec('20');
abort_code = hex2dec('21');
fail_code = hex2dec('22');
bump_code = hex2dec('50');
stim_code = hex2dec('60');
trial_starts = bdf.words(bdf.words(:,2) == start_trial_code, 1);

bdf.words = bdf.words(find(bitand(bdf.words(:,2),hex2dec('f0'))==hex2dec('10'),1):...
    find(bitand(bdf.words(:,2),hex2dec('f0'))==hex2dec('20'),1,'last'),:);

trial_starts = bdf.words(bitand(bdf.words(:,2),hex2dec('f0'))==hex2dec('10'),1);
 
trial_ends = bdf.words(bitand(bdf.words(:,2), hex2dec('f0')) == hex2dec('20'), :);

flag = 1;
while flag == 1 
    for i = 1:length(trial_starts)-1
        flag = 0;
        if trial_starts(i+1) < trial_ends(i,1)
            trial_starts(i:end-1) = trial_starts(i+1:end);
            trial_starts = trial_starts(1:end-1);
            flag = 1;
            break
        end
    end
end
        
trial_table = zeros(length(trial_starts),12);

for i=1:length(trial_starts)
    start_time = trial_starts(i);
    trial_type = 0;
    bump_or_stim = bdf.words(min(find(bdf.words(:,1)==start_time,1)+2,length(bdf.words)),2);
    bump_trial = bitand(bump_or_stim,hex2dec('F0'))==bump_code;
    if bump_trial
        bump_mag = bitand(bump_or_stim,hex2dec('07'));
%         bump_mag = (-2*(bitand(bump_or_stim,hex2dec('08'))>0)+1)*bump_mag;
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
    end_pos = bdf.pos(find(bdf.pos(:,1)<=trial_ends(i),1,'last'),2:3);
    trial_table(i,:) = [start_time trial_ends(end_idx,1) trial_ends(end_idx,2) trial_type 0 0 bump_mag stim_id 0 0 end_pos];
end

% dump the ones that were aborted
trial_table = trial_table(trial_table(:,3) == hex2dec('20')|trial_table(:,3) == hex2dec('22'), : );

 
% replace the trial start time with the go cue start time and add databurst
% info
% go_times = bdf.words(bdf.words(:,2) == hex2dec('31'), 1);
% go_times = bdf.words(bdf.words(:,2) == hex2dec('31'), 1);
% go_times = trial_table(:,1);  %%% FIX!!!
go_times = bdf.words(bitand(bdf.words(:,2),hex2dec('60'))==hex2dec('60') |...
    bitand(bdf.words(:,2),hex2dec('50'))==hex2dec('50'),1);
go_times = go_times(1:length(trial_table));
databurst_times = cell2mat(bdf.databursts(:,1));

if (databurst_version == 0)
    for i = 1:size(trial_table,1)
        trial_table(i,1) = go_times(find(go_times < trial_table(i,2),1,'last'));    % start time
        trial_table(i,9:10) = bdf.pos(find(bdf.pos(:,1)>go_times(i),1),2:3);        % x and y start
        temp_databurst = cell2mat(bdf.databursts(find(databurst_times<trial_table(i,2),1,'last'),2));  
        trial_table(i,5) = temp_databurst(3);                                       % training trial?
        trial_table(i,6:7) = bytes2float(temp_databurst(4:11))';                    % bump direction and magnitude
    end
    % remove x and y offsets
    trial_table(:,[end-3 end-1]) = trial_table(:,[end-3 end-1])-repmat(mean(trial_table(:,end-3)),length(trial_table),2);
    trial_table(:,[end-2 end]) = trial_table(:,[end-2 end])-repmat(mean(trial_table(:,end-2)),length(trial_table),2);
elseif (databurst_version == 1)
    for i = 1:size(trial_table,1)
        trial_table(i,1) = go_times(find(go_times < trial_table(i,2),1,'last'));    % start time
        trial_table(i,9:10) = bdf.pos(find(bdf.pos(:,1)>go_times(i),1),2:3);        % x and y start
        temp_databurst = cell2mat(bdf.databursts(find(databurst_times<trial_table(i,2),1,'last'),2));  
        trial_table(i,5) = temp_databurst(7);                                       % training trial?
        trial_table(i,6:7) = bytes2float(temp_databurst(16:23))';                   % bump direction and magnitude
    end
    % remove x and y offsets
    trial_table(:,[end-3 end-1]) = trial_table(:,[end-3 end-1])+repmat(bytes2float(bdf.databursts{1,2}(8:11)),length(trial_table),2);
    trial_table(:,[end-2 end]) = trial_table(:,[end-2 end])+repmat(bytes2float(bdf.databursts{1,2}(12:15)),length(trial_table),2);
end

trial_table(:,6) = round(10000*mod(trial_table(:,6),2*pi))/10000;
trial_table = trial_table(abs(trial_table(:,7))<10,:);
trial_table(:,7) = round(10000*trial_table(:,7))/10000;

save(filename,'trial_table','-append')