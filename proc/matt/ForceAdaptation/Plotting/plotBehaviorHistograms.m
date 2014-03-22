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

plotColors = {'b','r','g'};
nBins = 20; %hard code for now
doNorm = true; % normalize?
numTargs = 8; % hard code for now

if ~iscell(adaptation)
    adaptation = {adaptation};
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%
% Load some of the analysis parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
paramFile = fullfile(adaptation{1}.meta.out_directory, [adaptation{1}.meta.recording_date '_analysis_parameters.dat']);
params = parseExpParams(paramFile);
fontSize = str2double(params.font_size{1});
% nBins = str2double(params.num_hist_bins{1});
clear params;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fh = figure;

%% plot histogram of reaction time
set(0, 'CurrentFigure', fh);
clf reset;
hold all;
for iFile = 1:length(adaptation)
    [N,X] = hist(adaptation{iFile}.reaction_time.*1000,nBins);
    if doNorm
        N = N./max(N);
    end
    plot(X,N,[plotColors{iFile} '-'],'LineWidth',3);
end
xlabel('Reaction Time (ms)','FontSize',fontSize);
axis('tight');
V = axis;
axis([V(1) V(2) 0 V(4)]);

if ~isempty(saveFilePath)
    fn = fullfile(saveFilePath,'behavior_reaction_time.png');
    saveas(fh,fn,'png');
else
    pause;
end

%% plot histogram of time to target
set(0, 'CurrentFigure', fh);
clf reset;
hold all;
for iFile = 1:length(adaptation)
    [N,X] = hist(adaptation{iFile}.time_to_target.*1000,nBins);
    if doNorm
        N = N./max(N);
    end
    plot(X,N,[plotColors{iFile} '-'],'LineWidth',3);
end
xlabel('Time To Target (ms)','FontSize',fontSize);
axis('tight');
V = axis;
axis([V(1) V(2) 0 V(4)]);

if ~isempty(saveFilePath)
    fn = fullfile(saveFilePath,'behavior_time_to_target.png');
    saveas(fh,fn,'png');
else
    pause;
end


%% plot histogram of target directions

set(0, 'CurrentFigure', fh);
clf reset;
hold all;
for iFile = 1:length(adaptation)
    [N,X] = hist(adaptation{iFile}.movement_table(:,1).*180/pi,numTargs);
    if doNorm
        N = N./max(N);
    end
    plot(X,N,[plotColors{iFile} '-'],'LineWidth',3);
end
xlabel('Target Directions (deg)','FontSize',fontSize);
axis('tight');
V = axis;
axis([V(1) V(2) 0 V(4)]);

if ~isempty(saveFilePath)
    fn = fullfile(saveFilePath,'behavior_target_direction.png');
    saveas(fh,fn,'png');
else
    pause;
end


%% plot histogram of time between onset and peak
set(0, 'CurrentFigure', fh);
clf reset;
hold all;
for iFile = 1:length(adaptation)
    [N,X] = hist(adaptation{iFile}.move_to_peak.*1000,nBins);
    if doNorm
        N = N./max(N);
    end
    plot(X,N,[plotColors{iFile} '-'],'LineWidth',3);
end
xlabel('Reaction Time (ms)','FontSize',fontSize);
axis('tight');
V = axis;
axis([V(1) V(2) 0 V(4)]);

if ~isempty(saveFilePath)
    fn = fullfile(saveFilePath,'behavior_move_to_peak.png');
    saveas(fh,fn,'png');
else
    pause;
end

%% plot histogram of time between presentation and peak
set(0, 'CurrentFigure', fh);
clf reset;
hold all;
for iFile = 1:length(adaptation)
    [N,X] = hist(adaptation{iFile}.targ_to_peak.*1000,nBins);
    if doNorm
        N = N./max(N);
    end
    plot(X,N,[plotColors{iFile} '-'],'LineWidth',3);
end
xlabel('Reaction Time (ms)','FontSize',fontSize);
axis('tight');
V = axis;
axis([V(1) V(2) 0 V(4)]);

if ~isempty(saveFilePath)
    fn = fullfile(saveFilePath,'behavior_targ_to_peak.png');
    saveas(fh,fn,'png');
else
    pause;
end


