close all;
clear;
clc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Specify these things %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
useDate = '2013-08-13';
rewriteFiles = true;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Process a day's experimental data
paramFileDir = 'Z:\MrT_9I4\Matt';
expParamFile = ['Z:\MrT_9I4\Matt\' useDate '_experiment_parameters.dat'];

% get parameters
params = parseExpParams(expParamFile);
baseDir = params.out_dir{1};
useDate = params.date{1};
clear params;

dataPath = fullfile(baseDir,useDate);

% copy the parameter files
fn = fullfile(dataPath,[useDate '_experiment_parameters.dat']);
if ~exist(fn,'file') || rewriteFiles
    copyfile(expParamFile,fn,'f');
end
expParamFile = fn;

analysisParamFile = fullfile(dataPath,[useDate '_analysis_parameters.dat']);
if ~exist(analysisParamFile,'file') || rewriteFiles
    copyfile(fullfile(paramFileDir,'ff_analysis_parameters.dat'),analysisParamFile,'f');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load some of the parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
params = parseExpParams(analysisParamFile);
tuningPeriods = params.tuning_periods;
tuningMethods = params.tuning_methods;
clear params;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% make my data file (will convert things to BDF if necessary
[~] = makeDataStruct(expParamFile);

% Look at each cell in each file and determine if it is the same unit
%   use Brian's code....

% calculate tuning curves
[~] = fitTuningCurves(expParamFile);

% Look for memory cells
[~] = findMemoryCells(expParamFile);

% make my plots
[~] = makeFFPlots(expParamFile);

% make an HTML document detailing it all
[~] = neuronReports(expParamFile);




