% PROCESSFFDATA  Script to run analysis on a day of data
%   - make an experiment parameters file before running
%   - will copy over analysis parameters file from paramFileDir if
%       rewriteFiles is true.
close all;
clear;
clc;


useUnsorted = false;

% exclude these analysis steps
%   Note: I recommend if you change analysis parameters relevant to one of
%   these you re-run them so that the parameter file in the folder is up to
%   date with the actual data
rewriteFiles        = 1;

doDataStruct        = 0;
doAdaptationMetrics = 1;
trackNeurons        = 0;
doTuning            = 1;
doClassification    = 1;
doPlotting          = 1;
doReport            = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Specify these things %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
goodDates = {'2013-09-24'};

paramFileDir = 'Z:\MrT_9I4\Matt';
paramSetName = '';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for iDate = 1:length(goodDates)
    useDate = goodDates{iDate};
    disp(['Processing data for ' useDate '...']);
    
    % Process a day's experimental data
    expParamFile = ['Z:\MrT_9I4\Matt\ProcessedData\' useDate '\' useDate '_experiment_parameters.dat'];
    
    % get parameters
    params = parseExpParams(expParamFile);
    baseDir = params.out_dir{1};
    useDate = params.date{1};
    clear params;
    
    dataPath = fullfile(baseDir,useDate);
    
    % where the experiment parameters are
    expParamFile = fullfile(dataPath,[useDate '_experiment_parameters.dat']);
    
    % if not specified above, load what is in default location
    if ~exist('paramSetName','var') || isempty(paramSetName)
        % now we want to get the name of the current parameter set
        paramFile = fullfile(paramFileDir,'ff_analysis_parameters.dat');
        params = parseExpParams(paramFile);
        paramSetName = params.parameter_set_name{1};
        clear params;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    
    paramSetDir = fullfile(dataPath,paramSetName);
    if ~exist(paramSetDir,'dir')
        mkdir(paramSetDir);
    end
    
    % path to the analysis parameters. If not found, will copy the general one
    %   assumes the general one is in the paramFileDir
    analysisParamFile = fullfile(paramSetDir,[useDate '_analysis_parameters.dat']);
    if ~exist(analysisParamFile,'file') || rewriteFiles
        copyfile(fullfile(paramFileDir,'ff_analysis_parameters.dat'),analysisParamFile,'f');
    end
    plottingParamFile = fullfile(dataPath,[useDate '_plotting_parameters.dat']);
    if ~exist(plottingParamFile,'file') || rewriteFiles
        copyfile(fullfile(paramFileDir,'ff_plotting_parameters.dat'),plottingParamFile,'f');
    end
    
    
    if doDataStruct
        disp('');
        disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
        disp('%%% Making Data Struct %%%')
        disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
        % make my data file (will convert things to BDF if necessary
        [~,useUnsorted] = makeDataStruct(expParamFile);
    end
    
    if doAdaptationMetrics
        disp('');
        disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
        disp('%%% Adaptation Metrics %%%')
        disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
        % calculate some behavioral metrics over files
        [~] = getAdaptationMetrics(expParamFile, paramSetName);
    end
    
    if ~useUnsorted
        if trackNeurons
            disp('');
            disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
            disp('%%%  Tracking Neurons  %%%')
            disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
            % do empirical test to track neurons across epochs
            [~] = trackNeuronsAcrossEpochs(expParamFile);
        end
        
        if doTuning
            disp('');
            disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
            disp('%%%  Fit Tuning Curves %%%')
            disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
            % calculate tuning curves
            [~] = fitTuningCurves(expParamFile, paramSetName);
        end
        
        if doClassification
            disp('');
            disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
            disp('%%% Classifying Cells  %%%')
            disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
            % Look for memory cells
            [~] = findMemoryCells(expParamFile, paramSetName);
        end
        
    end
    
    if doPlotting
        disp('');
        disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
        disp('%%% Saving Data Plots  %%%')
        disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
        % make my plots
        [~] = makeFFPlots(expParamFile,paramSetName,useUnsorted);
    end
    
    if doReport
        disp('');
        disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
        disp('%%% Generating Report  %%%')
        disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
        % make an HTML document detailing it all
        [~] = makeSummaryReport(expParamFile, paramSetName, useUnsorted);
    end
    
    clc;
end
disp('');
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('%%%  ALL DONE!  YAY!   %%%')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
