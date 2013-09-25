function makeBehaviorPlots(adaptation,saveFilePath,curvLims)
% MAKEBEHAVIORPLOTS  Generate and save plots for adaptation and behavior metrics
%
%   This function takes in Matt's proprietary 'adaptation' struct and makes
% plots to show the characteristics and time course of various adaptation
% and behavior metrics.
%
%   Does the following plots:
%       histograms of reaction time, time to target, target directions
%       time course of reaction time, curvature, time to target
%
% INPUTS:
%   adaptation: (struct) output from getAdaptationMetrics
%   saveFilePath: (string) directory where figures will be saved
%       if empty, no figures are saved
%
% OUTPUTS:
%       none.
%
% NOTES:
%

if nargin < 3
    curvLims = [];
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%
% Load some of the analysis parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
paramFile = fullfile(adaptation.meta.out_directory, [adaptation.meta.recording_date '_plotting_parameters.dat']);
params = parseExpParams(paramFile);
fontSize = str2double(params.font_size{1});
numBins = str2double(params.num_hist_bins{1});
clear params;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Plot histograms of some metrics
epoch = adaptation.meta.epoch;

fh = figure;

% plot histogram of reaction time
set(0, 'CurrentFigure', fh);
clf reset;
hist(adaptation.reaction_time.*1000,numBins);
xlabel('Reaction Time (ms)','FontSize',fontSize);
axis('tight');

if ~isempty(saveFilePath)
    fn = fullfile(saveFilePath,[epoch '_behavior_reaction_time.png']);
    saveas(fh,fn,'png');
else
    pause;
end

% plot histogram of time to target
set(0, 'CurrentFigure', fh);
clf reset;
hist(adaptation.time_to_target.*1000,numBins);
xlabel('Time To Target (ms)','FontSize',fontSize);
axis('tight');

if ~isempty(saveFilePath)
    fn = fullfile(saveFilePath,[epoch '_behavior_time_to_target.png']);
    saveas(fh,fn,'png');
else
    pause;
end


% plot histogram of target directions
numTargs = length(unique(adaptation.movement_table(:,1)));
% if we only have 8 targets don't need a ton of bins
if numTargs < numBins
    numBins = numTargs;
end

set(0, 'CurrentFigure', fh);
clf reset;
hist(adaptation.movement_table(:,1).*180/pi,numBins);
xlabel('Target Directions (deg)','FontSize',fontSize);
axis('tight');

if ~isempty(saveFilePath)
    fn = fullfile(saveFilePath,[epoch '_behavior_target_direction.png']);
    saveas(fh,fn,'png');
else
    pause;
end

%% Now want to make some plots showing metrics over time
moveCounts = adaptation.movement_counts;

%% plot curvature over time
mC = adaptation.sliding_curvature_mean(:,1);
sC = adaptation.sliding_curvature_mean(:,2);

set(0, 'CurrentFigure', fh);
clf reset;

% if multiple points occur at same movement count, take average
repeats = moveCounts(diff(moveCounts) == 0);
uRepeats = unique(repeats);
for i = 1:length(uRepeats)
    useInds = moveCounts==uRepeats(i);
    mC(useInds) = mean(mC(useInds));
    sC(useInds) = mean(sC(useInds));
end

nans = find(isnan(mC));
for i = 1:length(nans)
    % find value of last non-nan
    ind = find(~isnan(mC(1:nans(i))),1,'last');
    if isempty(ind)
        mval = 0;
        sval = 0;
    else
        mval = mC(ind);
        sval = sC(ind);
    end
    mC(nans(i)) = mval;
    sC(nans(i)) = sval;
end

% do additional filtering
doFiltering = false;
if doFiltering
    filtWidth = 2;
    f = ones(1, filtWidth)/filtWidth; % w is filter width in samples
    mC = filter(f, 1, mC);
end


hold all;
% h = area(adaptation.movement_counts,[mC-sC 2*sC]);
% set(h(1),'FaceColor',[1 1 1]);
% set(h(2),'FaceColor',[0.8 0.9 1],'EdgeColor',[1 1 1]);
plot(moveCounts,mC','b','LineWidth',2);

xlabel('Movements','FontSize',fontSize);
ylabel('Curvature','FontSize',fontSize);
axis('tight');

if ~isempty(curvLims)
    set(gca,'Ylim',curvLims);
end

if ~isempty(saveFilePath)
    fn = fullfile(saveFilePath, [adaptation.meta.epoch '_adaptation_curvature.png']);
    saveas(fh,fn,'png');
else
    pause;
end

%% plot reaction time over time
mC = adaptation.reaction_time_mean(:,1).*1000;
sC = adaptation.reaction_time_mean(:,2).*1000;

% if multiple points occur at same movement count, take average
repeats = moveCounts(diff(moveCounts) == 0);
uRepeats = unique(repeats);
for i = 1:length(uRepeats)
    useInds = moveCounts==uRepeats(i);
    mC(useInds) = mean(mC(useInds));
    sC(useInds) = mean(sC(useInds));
end

nans = find(isnan(mC));
for i = 1:length(nans)
    % find value of last non-nan
    ind = find(~isnan(mC(1:nans(i))),1,'last');
    if isempty(ind)
        mval = 0;
        sval = 0;
    else
        mval = mC(ind);
        sval = sC(ind);
    end
    mC(nans(i)) = mval;
    sC(nans(i)) = sval;
end


set(0, 'CurrentFigure', fh);
clf reset;

hold all;
h = area(adaptation.movement_counts,[mC-sC 2*sC]);
set(h(1),'FaceColor',[1 1 1]);
set(h(2),'FaceColor',[0.8 0.9 1],'EdgeColor',[1 1 1]);
plot(adaptation.movement_counts,mC,'b','LineWidth',2);

xlabel('Movements','FontSize',fontSize);
ylabel('Reaction Time (msec)','FontSize',fontSize);
axis('tight');

if ~isempty(saveFilePath)
    fn = fullfile(saveFilePath, [adaptation.meta.epoch '_adaptation_reactiontime.png']);
    saveas(fh,fn,'png');
else
    pause;
end

%% plot reaction time over time

mC = adaptation.time_to_target_mean(:,1).*1000;
sC = adaptation.time_to_target_mean(:,2).*1000;

% if multiple points occur at same movement count, take average
repeats = moveCounts(diff(moveCounts) == 0);
uRepeats = unique(repeats);
for i = 1:length(uRepeats)
    useInds = moveCounts==uRepeats(i);
    mC(useInds) = mean(mC(useInds));
    sC(useInds) = mean(sC(useInds));
end


nans = find(isnan(mC));
for i = 1:length(nans)
    % find value of last non-nan
    ind = find(~isnan(mC(1:nans(i))),1,'last');
    if isempty(ind)
        mval = 0;
        sval = 0;
    else
        mval = mC(ind);
        sval = sC(ind);
    end
    mC(nans(i)) = mval;
    sC(nans(i)) = sval;
end


set(0, 'CurrentFigure', fh);
clf reset;

hold all;
h = area(adaptation.movement_counts,[mC-sC 2*sC]);
set(h(1),'FaceColor',[1 1 1]);
set(h(2),'FaceColor',[0.8 0.9 1],'EdgeColor',[1 1 1]);
plot(adaptation.movement_counts,mC,'b','LineWidth',2);

xlabel('Movements','FontSize',fontSize);
ylabel('Time to Target (msec)','FontSize',fontSize);
axis('tight');

if ~isempty(saveFilePath)
    fn = fullfile(saveFilePath, [adaptation.meta.epoch '_adaptation_timetotarget.png']);
    saveas(fh,fn,'png');
else
    pause;
end
