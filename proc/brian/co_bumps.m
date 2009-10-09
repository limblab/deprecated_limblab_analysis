function [base, passive, active, delay_bump_mean, delay_bump_var, anova] = co_bumps(bdf, chan, unit)
% co_bumps.m

ul = unit_list(bdf);
cell_idx = find(ul(:,1) == chan & ul(:,2) == unit);

spikes = bdf.units(cell_idx).ts;
words = bdf.words;

speed = sqrt(bdf.vel(:,2).^2 + bdf.vel(:,3).^2);

%%% Passive
bump_word_base = hex2dec('50');
all_bumps = words(words(:,2) >= (bump_word_base) & words(:,2) <= (bump_word_base+5), 1)';
all_bump_codes = words(words(:,2) >= (bump_word_base) & words(:,2) <= (bump_word_base+5), 2)';

word_start = hex2dec('11');
start_words = words(words(:,2) == word_start, 1);

word_ot_on = hex2dec('40');
ot_on_words = words( bitand(hex2dec('f0'),words(:,2)) == word_ot_on, 1);
ot_on_codes = words( bitand(hex2dec('f0'),words(:,2)) == word_ot_on, 2);

center_hold_bumps = [];
delay_bumps = cell(1,4);
for i = 2:length(all_bumps);
    bump_time = all_bumps(i);
    trial_start = start_words(find(start_words < bump_time, 1, 'last'));
    if sum(ot_on_words > trial_start & ot_on_words < bump_time) == 0
        % Center Hold bump
        %%% HACK!!!
        if isempty(center_hold_bumps) || center_hold_bumps(end,1) < bump_time-.002
            center_hold_bumps = [center_hold_bumps; bump_time all_bump_codes(i)];
        end
    else
        % Delay bump
        ot_word = ot_on_codes(find(ot_on_words > trial_start, 1, 'first'));
        target = 1 + bitand(ot_word, hex2dec('0f'));
        delay_bumps{target} = [delay_bumps{target}; bump_time bitand(all_bump_codes(i),hex2dec('0f'))];
    end
end


%%% Active 
ot_on_words = words( bitand(hex2dec('f0'),words(:,2)) == word_ot_on, :);
word_go = hex2dec('31');
go_cues = words(words(:,2) == word_go, 1);

word_reward = hex2dec('20');
rewards = words(words(:,2) == word_reward, 1);

movement_starts = cell(1,4);
for i = 1:length(ot_on_words)
    ot_time = ot_on_words(i,1);
    ot_id = ot_on_words(i,2);
    reach_dir = bitand(ot_id, hex2dec('0f'));
    
    % check that the trial was completed
    reward = rewards(find(rewards>ot_time, 1, 'first'));
    if isempty(reward) || sum(start_words > ot_time & start_words < reward) ~= 0
        continue;
    end
    
    % check that there was no bump in the movement
    if sum(all_bumps > ot_time & all_bumps < reward) ~= 0
        continue;
    end
           
    % save the timestamp of the go cue
    go_cue = go_cues(find(go_cues<reward,1,'last'));
    movement_starts{reach_dir+1} = [movement_starts{reach_dir+1} go_cue];
    
end

% generate plots
passive_tuning = zeros(2,4);
active_tuning = zeros(2,4);
baseline = zeros(1,4);
for dir = 0:3
    % active
    mvts = movement_starts{dir+1};
    [table, all] = raster(spikes, mvts, 0.000, 0.500, -1);
    active_tuning(1,dir+1) = length(all) / length(table) / .50;
    tmp = zeros(1,length(table));
    for i = 1:length(table)
        tmp(i) = length(table{i});
    end
    active_tuning(2,dir+1) = var(tmp);
    
    % passive
    bump = center_hold_bumps(center_hold_bumps(:,2) == (bump_word_base+dir), 1);
    [table, all] = raster(spikes, bump, 0.000, 0.150, -1);
    passive_tuning(1,dir+1) = length(all) / length(table) / .15;    
    tmp = zeros(1,length(table));
    for i = 1:length(table)
        tmp(i) = length(table{i});
    end
    passive_tuning(2,dir+1) = var(tmp);
    
    % baseline
    [table, all] = raster(spikes, bump, -0.5, 0, -1);
    baseline(1,dir+1) = length(all) / length(table) / .5;
end

base = [chan, unit, mean(baseline)];
passive = passive_tuning;
active = active_tuning;

delay_bump_mean = zeros(4);
delay_bump_var = zeros(4);
all_trials = cell(4,4);
for tgt_dir = 0:3
    bumps = delay_bumps{tgt_dir+1};
    for bump_dir = 0:3
        bump = bumps(bumps(:,2) == bump_dir, 1);
        [table, all] = raster(spikes, bump, 0.000, 0.150, -1);
        delay_bump_mean(tgt_dir+1,bump_dir+1) = length(all) / length(table) / .15;    
        tmp = zeros(1,length(table));
        for i = 1:length(table)
            tmp(i) = length(table{i});
        end
        delay_bump_var(tgt_dir+1,bump_dir+1) = var(tmp);
        all_trials{tgt_dir+1,bump_dir+1} = tmp;
    end
end

anova = g_anova2(all_trials);
