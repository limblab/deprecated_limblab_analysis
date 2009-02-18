% load multiple files

chan = 9;
cell = 1;

filename = '../../../data_cache/Arthur_S1_006-1of10.mat';
load(filename);

% get unit index
ul = unit_list(bdf);
cell_idx = find(ul(:,1) == chan & ul(:,2) == cell);

% spikes = [];
% words = [];
% 
% disp('Loading files');
% for i=1:10
%     filename = sprintf('../../../data_cache/Arthur_S1_006-%dof10.mat', i);
%     disp(filename);
%     load(filename);
%     spikes = [spikes; bdf.units(cell_idx).ts];
%     words = [words; bdf.words];
%     clear bdf filename;
% end

%%% Passive
figure;
bump_word_base = hex2dec('50');
all_bumps = words(words(:,2) >= (bump_word_base) & words(:,2) <= (bump_word_base+5), 1)';
all_bump_codes = words(words(:,2) >= (bump_word_base) & words(:,2) <= (bump_word_base+5), 2)';

word_start = hex2dec('11');
start_words = words(words(:,2) == word_start, 1);

word_go = hex2dec('31');
go_words = words(words(:,2) == word_go, 1);

center_hold_bumps = [];
for i = 2:length(all_bumps);
    bump_time = all_bumps(i);
    trial_start = start_words(find(start_words < bump_time, 1, 'last'));
    if sum(go_words > trial_start & go_words < bump_time) == 0
        center_hold_bumps = [center_hold_bumps; bump_time all_bump_codes(i)];
    end
end

% generate plot
pasive_tuning = zeros(1,3);
for dir = 0:5
    bump = center_hold_bumps(center_hold_bumps(:,2) == (bump_word_base+dir), 1);
    H = subplot(2,3,dir+1);
    [table, all] = raster(spikes, bump, -.5, 1.5, H);
    axis([-.5, 1.5, 0, 10]);
    pasive_tuning(dir+1) = sum(all > 0 & all < .1)/length(bump);
end

%%% Active
word_reward = hex2dec('');

%%% Polar plot
pasive_tuning = [pasive_tuning pasive_tuning(1)] ./ .1;
theta = 0:pi/3:2*pi;

figure;
polar(theta, pasive_tuning);


