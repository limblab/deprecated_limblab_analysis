% This file will compare how individual cells are classified across days to
% compare behavior under different experimental conditions

clear;
clc;

rootDir = 'C:\Users\Matt Perich\Desktop\lab\data\';
saveData = true;
rewriteFiles = true;

monkey = 'Mihili';

dataSummary;

switch monkey
    case 'MrT'
        dateInds = 1:12;
        dataDir = 'Z:\MrT_9I4\Matt';
        doFiles = mrt_data(dateInds,:);
    case 'Chewie'
        dateInds = 1:20;
        dataDir = 'Z:\Chewie_8I2\Matt';
        doFiles = chewie_data(dateInds,:);
    case 'Mihili'
        dateInds = 1:15;
        dataDir = 'Z:\Mihili_12A3\Matt';
        doFiles = mihili_data(dateInds,:);
    otherwise
        error('Monkey not recognized');
end

baseDir = fullfile(rootDir,monkey);

paramFiles = cell(1,size(doFiles,1));
for i = 1:size(doFiles,1)
    paramFiles{i} = fullfile(rootDir,monkey,doFiles{i,2},[doFiles{i,2} '_experiment_parameters.dat']);
end

% now do the tracking
if ~exist(fullfile(baseDir,'multiday_tracking.mat'),'file') || rewriteFiles
    tracking = trackNeuronsAcrossDays(paramFiles,baseDir,{'wf','isi'},saveData);
    save(fullfile(baseDir,'multiday_tracking.mat'));
else
    load(fullfile(baseDir,'multiday_tracking.mat'))
end
