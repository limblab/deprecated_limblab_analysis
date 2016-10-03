data_path = ['/Users/mariajantz/Documents/Work/data/kinematics/processed/']; 
filename = 'collate_stats.mat'; 

load([data_path filename]); 

%% Summarize a given variable for diff trials
trials = {'160902_10', '160902_07','160902_09'};
idx = []; 
for i=1:length(trials)
    idx = [idx find(ismember(trialname, trials(i)))]; 
end

means = []; 
stds = []; 
for i=1:length(trials)
    means = [means mean(endpoint_xval_stepranges{idx(i)})]; 
    stds = [stds std(endpoint_xval_stepranges{idx(i)})]; 
end

figure; hold on;
set(gca, 'TickDir', 'out'); 
set(gca, 'XTick', []); 
set(gca, 'fontsize', 24); 
ylabel('Step Length (mm)');
set(gca, 'XTick', 1:3, 'XTickLabel', {'100%', '120%', '200%'});
xlabel('Increase factor IP/ST');
bar(means, 'FaceColor', [.5 .5 .5]); 
errorbar(1:length(means), means, stds, '.', 'color','k', 'linewidth', 4); 


%% Summarize height and length
%define trials to use to accumulate a certain statistic
trials = {'160617_09', '160617_10'}; 
%get correct indices for these trials
idx = []; 
for i=1:length(trials)
    idx = [idx find(ismember(trialname, trials(i)))]; 
end

%calculate the average height and length of this set of trials
heightranges = []; 
lengthranges = [];
for i=1:length(idx)
    heightranges = [heightranges endpoint_xval_stepranges{idx(i)}]; 
    lengthranges = [lengthranges endpoint_yval_stepranges{idx(i)}]; 
end

mean_h1 = mean(heightranges); 
std_h1 = std(heightranges); 
mean_l1 = mean(lengthranges);
std_l1 = std(lengthranges);

%do same calculation process for recent values
%define trials to use to accumulate a certain statistic
trials = {'160902_04', '160902_06', '160908_01'}; 
%get correct indices for these trials
idx = []; 
for i=1:length(trials)
    idx = [idx find(ismember(trialname, trials(i)))]; 
end

%calculate the average height and length of this set of trials
heightranges = []; 
lengthranges = [];
for i=1:length(idx)
    heightranges = [heightranges endpoint_xval_stepranges{idx(i)}]; 
    lengthranges = [lengthranges endpoint_yval_stepranges{idx(i)}]; 
end
%drop end values when I had dropped markers
heightranges(find(heightranges<30)) = []; 
lengthranges(find(lengthranges<20)) = []; 

mean_h2 = mean(heightranges); 
std_h2 = std(heightranges); 
mean_l2 = mean(lengthranges);
std_l2 = std(lengthranges);

%TODO: do this for treadmill as well (note caveat of ground reaction)
mean_tdm_h = mean(endpoint_xval_stepranges{12}); 
std_tdm_h = std(endpoint_xval_stepranges{12}); 
mean_tdm_l = mean(endpoint_yval_stepranges{12}); 
std_tdm_l = std(endpoint_yval_stepranges{12}); 

figure; hold on;
set(gca, 'TickDir', 'out'); 
set(gca, 'XTick', []); 
set(gca, 'fontsize', 24); 
ylabel('Step Height (mm)'); 
set(gca, 'XTick', 1:3, 'XTickLabel', {'June', 'Sept', 'Tdm'});
means_h = [mean_h1, mean_h2, mean_tdm_h];
bar(means_h, 'FaceColor', [.5 .5 .5]); 
errorbar(1:3, means_h, [std_h1, std_h2, std_tdm_h], '.', 'color','k', 'linewidth', 4); 

figure; hold on;
set(gca, 'TickDir', 'out'); 
set(gca, 'XTick', []); 
set(gca, 'fontsize', 24); 
ylabel('Step Length (mm)')
set(gca, 'XTick', 1:3, 'XTickLabel', {'June', 'Sept', 'Tdm'});
means_l = [mean_l1, mean_l2, mean_tdm_l]; 
bar(means_l, 'FaceColor', [.5 .5 .5]); 
errorbar(1:3, means_l, [std_l1, std_l2, std_tdm_l], '.', 'color','k', 'linewidth', 4); 



%% Look at early to end trials (fatigue issues)
trials = {'160902_04','160902_06', '160902_07','160902_09', '160902_10',...
    '160908_01', '160908_02', '160908_03'};
idx = []; 
for i=1:length(trials)
    idx = [idx find(ismember(trialname, trials(i)))]; 
end

colors = {[255 22 22], [255 149 0], [103 206 0], [39 124 26], ...
    [63 155 175], [0 80 155], [113 84 153], [175 0 129]}; 

figure(1); hold on;
set(gca, 'fontsize', 24); 
set(gca, 'TickDir', 'out'); 
xlabel('Trial'); 
ylabel('Step Length (mm)'); 
xlim([1 8]); 

figure(2); hold on;
set(gca, 'fontsize', 24); 
set(gca, 'TickDir', 'out'); 
xlabel('Trial'); 
ylabel('Step Height (mm)'); 
xlim([1 8]); 

%get trend
xmat = [];
ymat = []; 
for i=1:length(trials)
    xmat = [xmat; endpoint_xval_stepranges{idx(i)}]; 
    ymat = [ymat; endpoint_yval_stepranges{idx(i)}]; 
end
x=1:8; 
figure(1); 
patch([x fliplr(x)], [mean(xmat)+std(xmat) fliplr(mean(xmat)-std(xmat))], [.9 .9 .9], 'EdgeColor', 'none'); 
figure(2); 
patch([x fliplr(x)], [mean(ymat)+std(ymat) fliplr(mean(ymat)-std(ymat))], [.9 .9 .9], 'EdgeColor', 'none'); 


for i=1:length(trials)
    figure(1);
    plot(endpoint_xval_stepranges{idx(i)}, 'o--', 'linewidth', 4, ...
        'color', colors{i}/255); 
    
    figure(2);
    plot(endpoint_yval_stepranges{idx(i)}, 'o--', 'linewidth', 4, ...
        'color', colors{i}/255)
end

%legend(trials)

