function plotted = makeFFPlots(expParamFile,useUnsorted)
% MAKEFFPLOTS  Wrapper function to save a lot of plots for adaptation analysis
%
%   This code will make a variety of plots from processed data.
%
% INPUTS:
%   expParamFile: (string) path to file containing experimental parameters
%   useUnsorted: (bool) will skip various plots if file is not sorted
%
% OUTPUTS:
%   plotted: (struct) list of booleans showing which plots were just made
%
% NOTES:
%   -This function requires several bits of pre-processing
%       1) Create a data struct from the Cerebus files (makeDataStruct)
%       2) Create adaptation metrics struct (getAdaptationMetrics)
%       3) Fit tuning for neurons (fitTuningCurves)
%   - This function will automatically write the images to a file, too
%   - See "experimental_parameters_doc.m" for documentation on expParamFile
%   - Analysis parameters file must exist (see "analysis_parameters_doc.m")

sigMethod = 'regression';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load some of the experimental parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
params = parseExpParams(expParamFile);
baseDir = params.out_dir{1};
useDate = params.date{1};
taskType = params.task{1};
adaptType = params.adaptation_type{1};
clear params;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dataPath = fullfile(baseDir,useDate);
figPath = fullfile(baseDir,useDate,'figs');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load some of the analysis parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
paramFile = fullfile(dataPath, [ useDate '_analysis_parameters.dat']);
params = parseExpParams(paramFile);
forceThresh = str2double(params.vel_thresh{1});
plotted.doForce = str2double(params.do_force{1});
plotted.doBehavior = str2double(params.do_behavior{1});
plotted.doWF = str2double(params.do_waveform{1});
plotted.doISI = str2double(params.do_isi{1});
plotted.doMovementTuning = str2double(params.do_movement_tuning{1});
plotted.doEpochTuningComparison = str2double(params.do_epoch_tuning_comparison{1});
plotted.doCOTrajectories = str2double(params.do_co_trajectories{1});
plotted.doPDChange = str2double(params.do_pd_change{1});
clear params;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% need a place to save them thar figures
if ~exist(figPath,'dir')
    mkdir(figPath);
end

blFile = fullfile(dataPath,[taskType '_' adaptType '_BL_' useDate '.mat']);
adFile = fullfile(dataPath,[taskType '_' adaptType '_AD_' useDate '.mat']);
woFile = fullfile(dataPath,[taskType '_' adaptType '_WO_' useDate '.mat']);

% load data
disp('Loading data files for plotting...')

if ~useUnsorted
    tuneFile = fullfile(dataPath,[taskType '_' adaptType '_tuning_' useDate '.mat']);
    load(tuneFile);
    blt = tuning.BL;
    adt = tuning.AD;
    wot = tuning.WO;
    clear tuning;
end

load(blFile);
bl = data;
load(adFile);
ad = data;
load(woFile);
wo = data;
clear data;

% make force plots for AD
if plotted.doForce && strcmpi(adaptType,'FF')
    disp('Creating force plots...')
    makeForcePlots(ad,figPath,forceThresh);
    close all;
end

if plotted.doWF && ~useUnsorted
    disp('Creating waveform plots...')
    makeWaveformPlots(bl,figPath);
    close all;
    makeWaveformPlots(ad,figPath);
    close all;
    makeWaveformPlots(wo,figPath);
    close all;
end

if plotted.doISI && ~useUnsorted
    disp('Creating ISI plots...')
    makeISIPlots(bl,figPath);
    close all;
    makeISIPlots(ad,figPath);
    close all;
    makeISIPlots(wo,figPath);
    close all;
end

if plotted.doMovementTuning && ~useUnsorted
    disp('Creating movement tuning plots...')
    makeMovementTuningPlots(bl,blt,figPath);
    close all;
    makeMovementTuningPlots(ad,adt,figPath);
    close all;
    makeMovementTuningPlots(wo,wot,figPath);
    close all;
end

if plotted.doEpochTuningComparison && ~useUnsorted
    disp('Creating tuning comparison plots...')
    plotEpochTuningComparison(blt,adt,wot,figPath);
    close all;
end

if plotted.doBehavior
    % THIS IS A HACK FOR NOW
    %   Eventually I need to resolve how to set axes to be the same
    % but for now, do it for curvature and find them brute force
    disp('Creating adaptation/behavior plots...')
    load(fullfile(dataPath,[taskType '_' adaptType '_adaptation_' useDate '.mat']));
    curvLims = [min(structfun(@(x) min(x.curvature_max(:,1)),adaptation)), max(structfun(@(x) max(x.curvature_max(:,1)),adaptation))];
    makeBehaviorPlots(adaptation.BL,figPath,curvLims);
    close all;
    makeBehaviorPlots(adaptation.AD,figPath,curvLims);
    close all;
    makeBehaviorPlots(adaptation.WO,figPath,curvLims);
    close all;
end

if plotted.doCOTrajectories && strcmpi(taskType,'CO')
    disp('Creating center-out trajectory plots...');
    % plot first and last movements to each target in adaptation period
    plotCOTrajectoriesStartEnd(bl, figPath);
    close all;
    plotCOTrajectoriesStartEnd(ad, figPath);
    close all;
    plotCOTrajectoriesStartEnd(wo, figPath);
    close all;
    
    % plot comparison of mean trajectories
    plotCOMeanTrajectories(bl,figPath);
    close all;
    plotCOMeanTrajectories(ad,figPath);
    close all;
    plotCOMeanTrajectories(wo,figPath);
    close all;
    
end

if plotted.doCOTrajectories && strcmpi(taskType,'CRC')
    disp('Creating center-out trajectory plots...');
    % plot first and last movements to each target in adaptation period
    plotCOTrajectoriesStartEnd(bl, figPath);
    close all;
    plotCOTrajectoriesStartEnd(wo, figPath);
    close all;
end

if plotted.doPDChange && ~useUnsorted
    load(fullfile(dataPath,[taskType '_' adaptType '_classes_' useDate '.mat']));
    load(fullfile(dataPath,[taskType '_' adaptType '_tracking_' useDate '.mat']));
    plotPDChanges(blt,adt,wot,classes,tracking,sigMethod,figPath);
    close all;
end
