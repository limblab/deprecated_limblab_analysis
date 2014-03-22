function makeGeneralPlots(expParamFile,outDir,useUnsorted)
% MAKEFFPLOTS  Wrapper function to save a lot of plots for adaptation analysis
%
%   This code will make a variety of plots from processed data.
%
% INPUTS:
%   expParamFile: (string) path to file containing experimental parameters
%   outDir: (string) directory for output
%
% OUTPUTS:
%
% NOTES:
%   -This function requires several bits of pre-processing
%       1) Create a data struct from the Cerebus files (makeDataStruct)
%       2) Create adaptation metrics struct (getAdaptationMetrics)
%       3) Fit tuning for neurons (fitTuningCurves)
%   - This function will automatically write the images to a file, too
%   - See "experimental_parameters_doc.m" for documentation on expParamFile
%   - Analysis parameters file must exist (see "analysis_parameters_doc.m")

skipNeurons = true;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load some of the experimental parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
params = parseExpParams(expParamFile);
useDate = params.date{1};
taskType = params.task{1};
adaptType = params.adaptation_type{1};
clear params;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dataPath = fullfile(outDir,useDate);
genFigPath = fullfile(outDir,useDate,'general_figs');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load some of the analysis parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
paramFile = fullfile(dataPath, [ useDate '_analysis_parameters.dat']);
params = parseExpParams(paramFile);
forceThresh = str2double(params.vel_thresh{1});
adaptMetrics = params.adaptation_metrics;
clear params;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% need a place to save them thar figures
if ~exist(genFigPath,'dir')
    mkdir(genFigPath);
end

blFile = fullfile(dataPath,[taskType '_' adaptType '_BL_' useDate '.mat']);
adFile = fullfile(dataPath,[taskType '_' adaptType '_AD_' useDate '.mat']);
woFile = fullfile(dataPath,[taskType '_' adaptType '_WO_' useDate '.mat']);

% load data
disp('Loading data files for plotting...')
bl = load(blFile);
ad = load(adFile);
wo = load(woFile);

%%% make force plots for AD
if ( strcmpi(adaptType,'FF') || strcmpi(adaptType,'VRFF') )
    disp('Creating force plots...')
    makeForcePlots(ad,genFigPath,forceThresh);
    close all;
end

%%% Center out trajectories
if strcmpi(taskType,'CO')
    disp('Creating center-out trajectory plots...');
    % plot first and last movements to each target in adaptation period
    plotCOTrajectoriesStartEnd(bl, genFigPath);
    close all;
    plotCOTrajectoriesStartEnd(ad, genFigPath);
    close all;
    plotCOTrajectoriesStartEnd(wo, genFigPath);
    close all;
end

%%% Special case with CO/RT/CO (rare)
if strcmpi(taskType,'CRC')
    disp('Creating center-out trajectory plots...');
    % plot first and last movements to each target in adaptation period
    plotCOTrajectoriesStartEnd(bl, genFigPath);
    close all;
    plotCOTrajectoriesStartEnd(wo, genFigPath);
    close all;
end

if ~skipNeurons
    %%% Waveform plots
    if ~useUnsorted
        disp('Creating waveform plots...')
        makeWaveformPlots({bl,ad,wo},genFigPath);
        close all;
    end
    
    %%% ISI Plots
    if ~useUnsorted
        disp('Creating ISI plots...')
        makeISIPlots({bl,ad,wo},genFigPath);
        close all;
    end
end

%%% Behavior adaptation
% THIS IS A HACK FOR NOW
%   Eventually I need to resolve how to set axes to be the same
% but for now, do it for curvature and find them brute force
disp('Creating adaptation/behavior plots...')
adaptation = load(fullfile(dataPath,[taskType '_' adaptType '_adaptation_' useDate '.mat']));
plotBehaviorHistograms({adaptation.BL adaptation.AD adaptation.WO},genFigPath);
close all;

% plot adaptation over time
% cell array to pass into function.... {date, task, perturbation, plot label}
dateInfo = {useDate, taskType, adaptType, ''};
for iMetric = 1:length(adaptMetrics)
    plotAdaptationOverTime('dir',outDir,'dates',dateInfo,'metric',adaptMetrics{iMetric},'savepath',genFigPath);
end

