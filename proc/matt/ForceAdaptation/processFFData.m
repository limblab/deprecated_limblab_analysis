% PROCESSFFDATA  Script to run analysis on a day of data
%   - make an experiment parameters file before running
%   - will copy over analysis parameters file from paramFileDir if
%       rewriteFiles is true.
close all;
clear;
clc;
useUnsorted = false;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Specify these things %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
goodDates = {'2013-09-04'};
rewriteFiles = false;
paramFileDir = 'Z:\MrT_9I4\Matt';
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
    
    % path to the analysis parameters. If not found, will copy the general one
    %   assumes the general one is in the paramFileDir
    analysisParamFile = fullfile(dataPath,[useDate '_analysis_parameters.dat']);
    if ~exist(analysisParamFile,'file') || rewriteFiles
        copyfile(fullfile(paramFileDir,'ff_analysis_parameters.dat'),analysisParamFile,'f');
    end
    
    disp('');
    disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
    disp('%%% Making Data Struct %%%')
    disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
    % make my data file (will convert things to BDF if necessary
    [~,useUnsorted] = makeDataStruct(expParamFile);
    
    disp('');
    disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
    disp('%%% Adaptation Metrics %%%')
    disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
    % calculate some behavioral metrics over files
    [~] = getAdaptationMetrics(expParamFile);
    
    if ~useUnsorted
        disp('');
        disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
        disp('%%%  Tracking Neurons  %%%')
        disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
        % do empirical test to track neurons across epochs
        [~] = trackNeurons(expParamFile);
        
        disp('');
        disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
        disp('%%%  Fit Tuning Curves %%%')
        disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
        % calculate tuning curves
        [~] = fitTuningCurves(expParamFile);
        
        disp('');
        disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
        disp('%%% Classifying Cells  %%%')
        disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
        % Look for memory cells
        [~] = findMemoryCells(expParamFile);
        
    end
    
    disp('');
    disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
    disp('%%% Saving Data Plots  %%%')
    disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
    % make my plots
    [~] = makeFFPlots(expParamFile,useUnsorted);
    
    disp('');
    disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
    disp('%%% Generating Report  %%%')
    disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
    % make an HTML document detailing it all
    [~] = makeSummaryReport(expParamFile,useUnsorted);
    
    clc;
end
disp('');
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('%%%  ALL DONE!  YAY!   %%%')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
