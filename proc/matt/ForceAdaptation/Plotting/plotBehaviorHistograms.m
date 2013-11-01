function plotBehaviorHistograms(adaptation,saveFilePath)
% PLOTBEHAVIORHISTOGRAMS  Generate and save plots for adaptation and behavior metrics
%
%   This function takes in Matt's proprietary 'adaptation' struct and makes
% plots to show the characteristics and time course of various adaptation
% and behavior metrics.
%
%   Does the following plots:
%       histograms of reaction time, time to target, target directions
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

%% plot histogram of reaction time
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

%% plot histogram of time to target
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


%% plot histogram of target directions
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


%% plot histogram of time between onset and peak
set(0, 'CurrentFigure', fh);
clf reset;
hist(adaptation.move_to_peak.*1000,numBins);
xlabel('Reaction Time (ms)','FontSize',fontSize);
axis('tight');

if ~isempty(saveFilePath)
    fn = fullfile(saveFilePath,[epoch '_behavior_move_to_peak.png']);
    saveas(fh,fn,'png');
else
    pause;
end

%% plot histogram of time between presentation and peak
set(0, 'CurrentFigure', fh);
clf reset;
hist(adaptation.targ_to_peak.*1000,numBins);
xlabel('Reaction Time (ms)','FontSize',fontSize);
axis('tight');

if ~isempty(saveFilePath)
    fn = fullfile(saveFilePath,[epoch '_behavior_targ_to_peak.png']);
    saveas(fh,fn,'png');
else
    pause;
end


