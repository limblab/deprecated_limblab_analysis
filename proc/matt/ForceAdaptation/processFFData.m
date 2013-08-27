close all;
clear;
clc;

% Process a day's experimental data
paramFileDir = 'C:\Users\Matt Perich\Desktop\lab\code\s1_analysis\proc\matt';
expParamFile = 'Z:\MrT_9I4\Matt\2013-08-13_experiment_parameters.dat';

tuningPeriods = {'initial','peak','final','full'};
% tuneType: (string) what kind of tuning to do
%   'glm': use a glm for the whole file (NOT IMPLEMENTED YET!)
%   'pre': use the time period immediately after target presentation (not implemented for RT task)
%   'initial': use the time period starting from movement onset
%   'peak': use time period centered around movement peak
%   'final': use time period ending when trial ends
%   'full': use time from go cue to end of trial with target direction <- IMPLEMENT THIS

tuningMethod = {'regression','vectorsum'};

% copy parameter files
params = parseExpParams(expParamFile);
baseDir = params.outDir{1};
useDate = params.useDate{1};
clear params;

dataPath = fullfile(baseDir,useDate);

% copy the parameter files
copyfile(expParamFile,fullfile(dataPath,[useDate '_experiment_parameters.dat']),'f');
copyfile(fullfile(paramFileDir,'ff_analysis_parameters.dat'),fullfile(dataPath,[useDate '_analysis_parameters.dat']),'f');

% make my data file (will convert things to BDF if necessary
[~] = makeDataStruct(expParamFile);

% calculate tuning curves
[~] = calculateTuningCurves(expParamFile,tuningPeriods,tuningMethod);

% make my plots
doForce          = 0;
doCurvature      = 0;
doWF             = 0;
doISI            = 0;
doMovementTuning = 0;
makeFFPlots(expParamFile,30,doForce,doCurvature,doWF,doISI,doMovementTuning);

% make an HTML document detailing it all
neuronReports(expParamFile);




