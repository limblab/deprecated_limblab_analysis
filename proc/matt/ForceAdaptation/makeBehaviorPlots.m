function makeBehaviorPlots(data,saveFilePath)

% make plots to show:
%       reaction time histogram
%       histogram of target directions
%       histogram of time to target
%
%       plots over course of files, all files condensed into one
%           time to target
%           reward rate?

% Load some parameters
paramFile = fullfile(data.meta.out_directory, [data.meta.recording_date '_analysis_parameters.dat']);
params = parseExpParams(paramFile);
fontSize = str2double(params.font_size{1});
numBins = str2double(params.num_hist_bins{1});
clear params;

task = data.meta.task;
epoch = data.meta.epoch;

mt = data.movements.movement_table;
mt = filterMovementTable(data,mt);

% reaction time: diff between target on and movement onset
reactionTime = mt(:,3) - mt(:,2);
targetDirection = mt(:,1);
timeToTarget = mt(:,end) - mt(:,2);
% timeToPeak = mt(:,4)-mt(:,2);

fh = figure;

set(0, 'CurrentFigure', fh);
clf reset;
hist(reactionTime.*1000,numBins);
xlabel('Reaction Time (ms)','FontSize',fontSize);
axis('tight');

if ~isempty(saveFilePath)
    fn = fullfile(saveFilePath,[epoch '_hist_reaction_time.png']);
    saveas(fh,fn,'png');
else
    pause;
end


set(0, 'CurrentFigure', fh);
clf reset;
hist(targetDirection.*180/pi,numBins);
xlabel('Target Directions (deg)','FontSize',fontSize);
axis('tight');

if ~isempty(saveFilePath)
    fn = fullfile(saveFilePath,[epoch '_hist_target_direction.png']);
    saveas(fh,fn,'png');
else
    pause;
end

set(0, 'CurrentFigure', fh);
clf reset;
hist(timeToTarget.*1000,numBins);
xlabel('Time To Target (ms)','FontSize',fontSize);
axis('tight');

if ~isempty(saveFilePath)
    fn = fullfile(saveFilePath,[epoch '_hist_time_to_target.png']);
    saveas(fh,fn,'png');
else
    pause;
end


