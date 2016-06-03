function makeTuningPlots(expParamFile,outDir,paramSetNames,sigMethod)
% MAKEFFPLOTS  Wrapper function to save a lot of plots for adaptation analysis
%
%   This code will make a variety of plots from processed data.
%
% INPUTS:
%   expParamFile: (string) path to file containing experimental parameters
%   outDir: (string) directory for output
%   paramSetName: (string) name of tuning parameter set to plot from
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


if nargin < 4
    sigMethod = 'regression';
end

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

% These plots will change with parameters and thus go in subfolders
% these figures are only applicable to tuning, so if no tuning parameter
% name is specified these are skipped
if ~isempty(paramSetNames)
    if ~iscell(paramSetNames)
        paramSetNames = {paramSetNames};
    end
    
    % now loop along all of the parameter types
    for iParam = 1:length(paramSetNames)
        paramSetName = paramSetNames{iParam};
        
        figPath = fullfile(outDir,useDate,paramSetName,'figs');
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
        
%         %%% Movement Tuning
%         disp('Creating movement tuning plots...')
%         makeMovementTuningPlots(bl,blt,figPath);
%         close all;
%         makeMovementTuningPlots(ad,adt,figPath);
%         close all;
%         makeMovementTuningPlots(wo,wot,figPath);
%         close all;
        
        %%% Epoch uning comparison
%         disp('Creating tuning comparison plots...')
%         plotEpochTuningComparison(blt,adt,wot,figPath);
%         close all;
        
        
        disp('Creating tuning comparison plots...')
        plotPolarEpochPDComparison(blt,adt,wot,figPath);
        close all
        
        
        %%% Plot classes
        classes = load(fullfile(dataPath,paramSetName,[taskType '_' adaptType '_classes_' useDate '.mat']));
        tracking = load(fullfile(dataPath,[taskType '_' adaptType '_tracking_' useDate '.mat']));
        
        plotPDChanges(blt,adt,wot,classes,tracking,sigMethod,figPath);
        close all;
        
        %%% MD COmparison
        classes = load(fullfile(dataPath,paramSetName,[taskType '_' adaptType '_classes_' useDate '.mat']));
        tracking = load(fullfile(dataPath,[taskType '_' adaptType '_tracking_' useDate '.mat']));
        
%         plotPDvsMD(blt,adt,wot,classes,tracking,sigMethod,figPath);
%         plotMDvsOS(blt,adt,wot,classes,tracking,sigMethod,figPath);
    end
end
