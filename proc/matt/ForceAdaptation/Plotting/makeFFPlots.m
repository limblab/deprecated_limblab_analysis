function plotted = makeFFPlots(expParamFile)
% NOTE: hard-coded for PMd right now

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
plotted.doCurvature = str2double(params.do_curvature{1});
plotted.doWF = str2double(params.do_waveform{1});
plotted.doISI = str2double(params.do_isi{1});
plotted.doMovementTuning = str2double(params.do_movement_tuning{1});
plotted.doEpochTuningComparison = str2double(params.do_epoch_tuning_comparison{1});
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
load(blFile);
bl = data;
blt = tuning;
load(adFile);
ad = data;
adt = tuning;
load(woFile);
wo = data;
wot = tuning;
clear data;

% make force plots for AD
if plotted.doForce
    disp('Creating force plots...')
    makeForcePlots(ad,figPath,forceThresh);
    close all;
end

if plotted.doBehavior
    disp('Creating behavior plots...')
    makeBehaviorPlots(bl,figPath);
    close all;
    makeBehaviorPlots(ad,figPath);
    close all;
    makeBehaviorPlots(wo,figPath);
    close all;
end

if plotted.doCurvature
    disp('Creating curvature plots...')
    makeCurvaturePlots(bl,figPath);
    close all;
    makeCurvaturePlots(ad,figPath);
    close all;
    makeCurvaturePlots(wo,figPath);
    close all;
end

if plotted.doWF
    disp('Creating waveform plots...')
    makeWaveformPlots(bl,figPath);
    close all;
    makeWaveformPlots(ad,figPath);
    close all;
    makeWaveformPlots(wo,figPath);
    close all;
end

if plotted.doISI
    disp('Creating ISI plots...')
    makeISIPlots(bl,figPath);
    close all;
    makeISIPlots(ad,figPath);
    close all;
    makeISIPlots(wo,figPath);
    close all;
end

if plotted.doMovementTuning
    disp('Creating movement tuning plots...')
    makeMovementTuningPlots(bl,blt,figPath);
    close all;
    makeMovementTuningPlots(ad,adt,figPath);
    close all;
    makeMovementTuningPlots(wo,wot,figPath);
    close all;
end

if plotted.doEpochTuningComparison
    disp('Creating tuning comparison plots...')
    plotEpochTuningComparison(blt,adt,wot,figPath);
    close all;
end
