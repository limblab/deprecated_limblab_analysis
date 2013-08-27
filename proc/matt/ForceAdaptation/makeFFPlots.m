function makeFFPlots(expParamFile,forceThresh,doForce,doCurvature,doWF,doISI,doMovementTuning)
% NOTE: hard-coded for PMd right now

doCOTraces = true;

% get parameters from file
params = parseExpParams(expParamFile);
baseDir = params.outDir{1};
useDate = params.useDate{1};
taskType = params.taskType{1};
adaptType = params.adaptType{1};
clear params;

dataPath = fullfile(baseDir,useDate);
figPath = fullfile(baseDir,useDate,'figs');
% need a place to save them thar figures
if ~exist(figPath,'dir')
    mkdir(figPath);
end

blFile = fullfile(dataPath,[taskType '_' adaptType '_BL_' useDate '.mat']);
adFile = fullfile(dataPath,[taskType '_' adaptType '_AD_' useDate '.mat']);
woFile = fullfile(dataPath,[taskType '_' adaptType '_WO_' useDate '.mat']);

% load data
load(blFile);
bl = data;
load(adFile);
ad = data;
load(woFile);
wo = data;
clear data;

% make force plots for AD
if doForce
    makeForcePlots(ad,figPath,forceThresh);
    close all;
end

if doCurvature
    makeCurvaturePlots(bl,figPath);
    close all;
    makeCurvaturePlots(ad,figPath);
    close all;
    makeCurvaturePlots(wo,figPath);
    close all;
end

if doWF
    makeWaveformPlots(bl,figPath);
    close all;
    makeWaveformPlots(ad,figPath);
    close all;
    makeWaveformPlots(wo,figPath);
    close all;
end

if doISI
    makeISIPlots(bl,figPath);
    close all;
    makeISIPlots(ad,figPath);
    close all;
    makeISIPlots(wo,figPath);
    close all;
end

if doMovementTuning
    makeMovementTuningPlots(bl,figPath);
    close all;
    makeMovementTuningPlots(ad,figPath);
    close all;
    makeMovementTuningPlots(wo,figPath);
    close all;
end

if doCOTraces
    if strcmp(taskType,'CO')
        
    end
end