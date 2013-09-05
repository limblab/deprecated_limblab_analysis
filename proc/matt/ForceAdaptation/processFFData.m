% PROCESSFFDATA  Script to run analysis on a day of data
close all;
clear;
clc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Specify these things %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
goodDate = {'2013-08-19'};
rewriteFiles = true;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for iDate = 1:length(goodDate)
    useDate = goodDates{iDate};
    disp(['Processing data for ' useDate '...']);
    
    % Process a day's experimental data
    paramFileDir = 'Z:\MrT_9I4\Matt';
    % expParamFile = ['Z:\MrT_9I4\Matt\' useDate '_experiment_parameters.dat'];
    expParamFile = ['Z:\MrT_9I4\Matt\ProcessedData\' useDate '\' useDate '_experiment_parameters.dat'];
    
    % get parameters
    params = parseExpParams(expParamFile);
    baseDir = params.out_dir{1};
    useDate = params.date{1};
    clear params;
    
    dataPath = fullfile(baseDir,useDate);
    
    % where the experiment parameters are
    expParamFile = fullfile(dataPath,[useDate '_experiment_parameters.dat']);
    
    % path to the analysis parameters. If not found, will copy the general one
    %   assumes the general one is in the paramFileDir
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
    
    disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
    disp('%%% Making Data Struct %%%')
    disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
    % make my data file (will convert things to BDF if necessary
    [~] = makeDataStruct(expParamFile);
    
    disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
    disp('%%% Adaptation Metrics %%%')
    disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
    % calculate some behavioral metrics over files
    [~] = getAdaptationMetrics(expParamFile);
    
    disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
    disp('%%%  Tracking Neurons  %%%')
    disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
    % do empirical test to track neurons across epochs
    [~] = trackNeurons(expParamFile);
    
    disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
    disp('%%%  Fit Tuning Curves %%%')
    disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
    % calculate tuning curves
    [~] = fitTuningCurves(expParamFile);
    
    disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
    disp('%%% Classifying Cells  %%%')
    disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
    % Look for memory cells
    [~] = findMemoryCells(expParamFile);
    
    disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
    disp('%%% Saving Data Plots  %%%')
    disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
    % make my plots
    [~] = makeFFPlots(expParamFile);
    
    disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
    disp('%%% Generating Report  %%%')
    disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
    % make an HTML document detailing it all
    [~] = neuronReports(expParamFile);
    
    clc;
end

