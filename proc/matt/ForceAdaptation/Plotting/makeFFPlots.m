function plotted = makeFFPlots(expParamFile,paramSetNames,useUnsorted, tuningFlag)
% MAKEFFPLOTS  Wrapper function to save a lot of plots for adaptation analysis
%
%   This code will make a variety of plots from processed data.
%
% INPUTS:
%   expParamFile: (string) path to file containing experimental parameters
%   paramSetName: (string) name of tuning parameter set to plot from
%       NOTE: if empty, will only make generally applicable figures
%   useUnsorted: (bool) will skip various plots if file is not sorted
%   tuningFlag: (bool) will only do tuning-related plots if true
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

if nargin < 4
    tuningFlag = false;
end

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
genFigPath = fullfile(baseDir,useDate,'general_figs');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load some of the analysis parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
paramFile = fullfile(dataPath, [ useDate '_plotting_parameters.dat']);
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
plotted.doMDComparison = str2double(params.do_md_comparison{1});
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

if plotted.doForce || plotted.doCOTrajectories || plotted.doWF || plotted.doISI || plotted.doMovementTuning
    bl = load(blFile);
    ad = load(adFile);
    wo = load(woFile);
end

%% These plots are general and not analysis parameter specific
if ~tuningFlag
    % make force plots for AD
    if plotted.doForce && ( strcmpi(adaptType,'FF') || strcmpi(adaptType,'VRFF') )
        disp('Creating force plots...')
        makeForcePlots(ad,genFigPath,forceThresh);
        close all;
    end
    
    if plotted.doCOTrajectories && strcmpi(taskType,'CO')
        disp('Creating center-out trajectory plots...');
        % plot first and last movements to each target in adaptation period
        plotCOTrajectoriesStartEnd(bl, genFigPath);
        close all;
        plotCOTrajectoriesStartEnd(ad, genFigPath);
        close all;
        plotCOTrajectoriesStartEnd(wo, genFigPath);
        close all;
    end
    
    if plotted.doCOTrajectories && strcmpi(taskType,'CRC')
        disp('Creating center-out trajectory plots...');
        % plot first and last movements to each target in adaptation period
        plotCOTrajectoriesStartEnd(bl, genFigPath);
        close all;
        plotCOTrajectoriesStartEnd(wo, genFigPath);
        close all;
    end
    
    if plotted.doWF && ~useUnsorted
        disp('Creating waveform plots...')
        makeWaveformPlots(bl,genFigPath);
        close all;
        makeWaveformPlots(ad,genFigPath);
        close all;
        makeWaveformPlots(wo,genFigPath);
        close all;
    end
    
    if plotted.doISI && ~useUnsorted
        disp('Creating ISI plots...')
        makeISIPlots(bl,genFigPath);
        close all;
        makeISIPlots(ad,genFigPath);
        close all;
        makeISIPlots(wo,genFigPath);
        close all;
    end
    
    if plotted.doBehavior
        % THIS IS A HACK FOR NOW
        %   Eventually I need to resolve how to set axes to be the same
        % but for now, do it for curvature and find them brute force
        disp('Creating adaptation/behavior plots...')
        adaptation = load(fullfile(dataPath,[taskType '_' adaptType '_adaptation_' useDate '.mat']));
        plotBehaviorHistograms(adaptation.BL,genFigPath);
        close all;
        plotBehaviorHistograms(adaptation.AD,genFigPath);
        close all;
        plotBehaviorHistograms(adaptation.WO,genFigPath);
        close all;
        
        % plot adaptation over time
        % cell array to pass into function.... {date, task, perturbation, plot label}
        dateInfo = {useDate, taskType, adaptType, ''};
        plotAdaptationOverTime('dir',baseDir,'dates',dateInfo,'metric','angle_error','savepath',genFigPath);
    end
    
end

%% These plots will change with parameters and thus go in subfolders
% these figures are only applicable to tuning, so if no tuning parameter
% name is specified these are skipped
if ~isempty(paramSetNames) && ~useUnsorted
    if ~iscell(paramSetNames)
        paramSetNames = {paramSetNames};
    end
    
    % now loop along all of the parameter types
    for iParam = 1:length(paramSetNames)
        paramSetName = paramSetNames{iParam};
        
        figPath = fullfile(baseDir,useDate,paramSetName,'figs');
        if ~exist(figPath,'dir')
            mkdir(figPath);
        end
        
        disp('Loading tuning data...')
        tuneFile = fullfile(dataPath,paramSetName,[taskType '_' adaptType '_tuning_' useDate '.mat']);
        tuning = load(tuneFile);
        blt = tuning.BL;
        adt = tuning.AD;
        wot = tuning.WO;
        clear tuning;
        
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
        
        if plotted.doPDChange && ~useUnsorted
            classes = load(fullfile(dataPath,paramSetName,[taskType '_' adaptType '_classes_' useDate '.mat']));
            tracking = load(fullfile(dataPath,[taskType '_' adaptType '_tracking_' useDate '.mat']));
            
            plotPDChanges(blt,adt,wot,classes,tracking,sigMethod,figPath);
            close all;
        end
        
        if plotted.doMDComparison && ~useUnsorted
            classes = load(fullfile(dataPath,paramSetName,[taskType '_' adaptType '_classes_' useDate '.mat']));
            tracking = load(fullfile(dataPath,[taskType '_' adaptType '_tracking_' useDate '.mat']));
            
            plotPDvsMD(blt,adt,wot,classes,tracking,sigMethod,figPath);
            plotMDvsOS(blt,adt,wot,classes,tracking,sigMethod,figPath);
        end
    end
end
