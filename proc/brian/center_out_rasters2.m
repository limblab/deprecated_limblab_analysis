% load multiple files and draw center out perturbation rasters

%load '../../../data_cache/Arthur_S1_006-1of10.mat';
%units = unit_list(bdf);
%clear bdf;

%for cell_idx = 1:length(units);
%    chan = units(cell_idx,1);
%    cell = units(cell_idx,2);

    chan = 81;
    unit = 2;

    % get unit index
    ul = unit_list(bdf);
    cell_idx = find(ul(:,1) == chan & ul(:,2) == unit);

    spikes = bdf.units(cell_idx).ts;
    words = bdf.words;
    
    %%% Passive
    bump_word_base = hex2dec('50');
    all_bumps = words(words(:,2) >= (bump_word_base) & words(:,2) <= (bump_word_base+5), 1)';
    all_bump_codes = words(words(:,2) >= (bump_word_base) & words(:,2) <= (bump_word_base+5), 2)';

    word_start = hex2dec('11');
    start_words = words(words(:,2) == word_start, 1);

    word_ot_on = hex2dec('40');
    ot_on_words = words( bitand(hex2dec('f0'),words(:,2)) == word_ot_on, 1);

    center_hold_bumps = [];
    for i = 2:length(all_bumps);
        bump_time = all_bumps(i);
        trial_start = start_words(find(start_words < bump_time, 1, 'last'));
        if sum(ot_on_words > trial_start & ot_on_words < bump_time) == 0
            %%% HACK!!!
            if isempty(center_hold_bumps) || center_hold_bumps(end,1) < bump_time-.002
                center_hold_bumps = [center_hold_bumps; bump_time all_bump_codes(i)];
            end
        end
    end

    % generate plots
    figure;
    pasive_tuning = zeros(1,4);
    pt_var = zeros(1,4);
    for dir = 0:3
        bump = center_hold_bumps(center_hold_bumps(:,2) == (bump_word_base+dir), 1);
        H = subplot(2,2,dir+1);
        [table, all] = raster(spikes, bump, -.1, .3, H);
        axis([-.1, .3, 0, 20]);
        pasive_tuning(dir+1) = sum(all);
        
        tblsize = zeros(1,length(table));
        for i = 1:length(table)
            tblsize(i) = size(table{i},1);
        end
        pt_var(dir+1) = var(tblsize);
    end
    suptitle(sprintf('Passive %d-%d', chan, unit));

    pt_var = sqrt(pt_var);

    figure;
    %hold on;
    polar(0:pi/2:2*pi, [pasive_tuning(end),pasive_tuning]/.4,'k-');
    %polar(0:pi/2:2*pi, ([pasive_tuning(end),pasive_tuning] + [pt_var(end),pt_var])/.4,'r-');
    %polar(0:pi/2:2*pi, ([pasive_tuning(end),pasive_tuning] - [pt_var(end),pt_var])/.4,'r-');

    %     %%% Active
%     word_reward = hex2dec('20');
%     reward_words = words(words(:,2) == word_reward, 1);
% 
%     % get unperturbed reach times
%     reaches = [];
%     for i = 2:length(reward_words)
%         reward = reward_words(i);
%         go = go_words(find(go_words < reward, 1, 'last'));
%         if sum(all_bumps > go & all_bumps < reward) == 0
%             reaches = [reaches; go];
%         end
%     end
% 
%     % get reach directions
%     word_ot_base = hex2dec('40');
%     ot_word_times = words(words(:,2) >= word_ot_base & words(:,2) <= word_ot_base+5, 1);
%     ot_word_words = words(words(:,2) >= word_ot_base & words(:,2) <= word_ot_base+5, 2);
%     reaches = [reaches zeros(length(reaches), 1)];
%     for i = 2:length(reaches)
%         last_ot_idx = find(ot_word_times < reaches(i), 1, 'last');
%         reaches(i,2) = ot_word_words(last_ot_idx);
%     end
% 
%     % generate plots
%     figure;
%     active_tuning = zeros(1,6);
%     active_fr = zeros(21,6);
%     t = -.5:.1:1.5;
%     for dir = 0:5
%         go = reaches(reaches(:,2) == word_ot_base+dir, 1);
%         H = subplot(2,3,dir+1);
%         [table, all] = raster(spikes, go, -.5, 1.5, H);
%         axis([-.5, 1.5, 0, 10]);
%         active_tuning(dir+1) = sum(all > .1 & all < .4)/length(go);
%         active_fr(:, dir+1) = histc(all, t);
%     end
%     suptitle(sprintf('Active %d-%d', chan, unit));
% 
%     %%% Polar plot
%     pasive_tuning = [pasive_tuning pasive_tuning(1)] ./ .1;
%     active_tuning = [active_tuning active_tuning(1)] ./ .3;
%     theta = 0:pi/3:2*pi;
% 
%     figure;
%     polar(theta, pasive_tuning, 'b-');
%     title(sprintf('Passive %d-%d', chan, unit));
% 
%     figure;
%     polar(theta, active_tuning, 'r-');
%     title(sprintf('Active %d-%d', chan, unit));
% 
%     % Final analysis
% 
%     x = active_tuning(1:6).*cos(theta(1:6));
%     y = active_tuning(1:6).*sin(theta(1:6));
% 
%     pd_active = atan2(sum(x), sum(y))
%     
%     x = pasive_tuning(1:6).*cos(theta(1:6));
%     y = pasive_tuning(1:6).*sin(theta(1:6));
% 
%     pd_passive = atan2(sum(x), sum(y))
%     
%end


