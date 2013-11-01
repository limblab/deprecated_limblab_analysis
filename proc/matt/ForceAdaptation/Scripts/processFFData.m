% PROCESSFFDATA  Script to run analysis on a day of data
%   - make an experiment parameters file before running
%   - will copy over analysis parameters file from paramFileDir if
%       rewriteFiles is true.
close all;
clear;
clc;

% would be great to have proper database
%   - could load monkey info

useUnsorted = false;
sigCompMethod = 'diff';

% if false, will not copy over new parameter files if they already exist
rewriteFiles  = 1;

% exclude these analysis steps
%    Note: I recommend if you change analysis parameters relevant to one of
%    these you re-run them so that the parameter file in the folder is up to
%    date with the actual data
% processing options
doDataStruct        = 0;
doAdaptation        = 0;
doTracking          = 0;
% tuning options1
doTuning            = 1;
doClassification    = 1;
doReport            = 0;
% plotting options
doPlotting          = 0; % 1 for all, 2 for only general, 3 for only tuning

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Specify these things %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
paramSetNames = {'middle1','middle2','end','targmiddle1','targmiddle2','targend'};

monkey = 'MrT';

switch monkey
    case 'MrT'
        paramFileDir = 'Z:\MrT_9I4\Matt\';
        goodDates = {'2013-09-10', ...
            '2013-09-06', ...
            '2013-09-04', ...
            '2013-08-20', ... % S RT
            '2013-08-22', ... % S RT
            '2013-08-30'};
        
        dataFileDir = 'Z:\MrT_9I4\Matt\ProcessedData\';
    case 'Chewie'
        paramFileDir = 'Z:\Chewie_8I2\Matt\';
        goodDates = {'2013-10-11','2013-10-09'};
        dataFileDir = 'Z:\Chewie_8I2\Matt\ProcessedData\';
    otherwise
        error('Monkey not recognized');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for iDate = 1:length(goodDates)
    useDate = goodDates{iDate};
    disp(['Processing data for ' useDate '...']);
    
    % Process a day's experimental data
    expParamFile = fullfile(dataFileDir, useDate,[useDate '_experiment_parameters.dat']);
    
    % get parameters
    params = parseExpParams(expParamFile);
    baseDir = params.out_dir{1};
    useDate = params.date{1};
    clear params;
    
    dataPath = fullfile(baseDir,useDate);
    
    % where the experiment parameters are
    expParamFile = fullfile(dataPath,[useDate '_experiment_parameters.dat']);
    
    % if not specified above, load what is in default location
    if ~exist('paramSetNames','var') || isempty(paramSetNames)
        % now we want to get the name of the current parameter set
        paramFile = fullfile(paramFileDir,[monkey '_tuning_parameters.dat']);
        params = parseExpParams(paramFile);
        paramSetNames = params.parameter_set_name{1};
        clear params;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    
    if ~iscell(paramSetNames)
        paramSetNames = {paramSetNames};
    end
    
    % path to the analysis parameters. If not found, will copy the general one
    %   assumes the general one is in the paramFileDir
    analysisParamFile = fullfile(dataPath,[useDate '_analysis_parameters.dat']);
    if ~exist(analysisParamFile,'file') || rewriteFiles
        copyfile(fullfile(paramFileDir,[monkey '_analysis_parameters.dat']),analysisParamFile,'f');
    end
    plottingParamFile = fullfile(dataPath,[useDate '_plotting_parameters.dat']);
    if ~exist(plottingParamFile,'file') || rewriteFiles
        copyfile(fullfile(paramFileDir,[monkey '_plotting_parameters.dat']),plottingParamFile,'f');
    end
    
    if doDataStruct
        disp('');
        disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
        disp('%%% Making Data Struct %%%')
        disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
        % make my data file (will convert things to BDF if necessary
        [~,useUnsorted] = makeDataStruct(expParamFile, 'nev', false, useUnsorted);
    end
    
    if doAdaptation
        disp('');
        disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
        disp('%%% Adaptation Metrics %%%')
        disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
        % calculate some behavioral metrics over files
        [~] = getAdaptationMetrics(expParamFile);
    end
    
    if doTracking && ~useUnsorted
        disp('');
        disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
        disp('%%%  Tracking Neurons  %%%')
        disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
        % do empirical test to track neurons across epochs
        [~] = trackNeuronsAcrossEpochs(expParamFile,{'wf'});
    end
    
    % Now loop along the tuning parameter sets
    for iParam = 1:length(paramSetNames)
        paramSetName = paramSetNames{iParam};
        
        disp(['Using the "' paramSetName '" set of tuning parameters...']);
        
        paramSetDir = fullfile(dataPath,paramSetName);
        if ~exist(paramSetDir,'dir')
            mkdir(paramSetDir);
        end
        
        tuningParamFile = fullfile(paramSetDir,[useDate '_' paramSetName '_tuning_parameters.dat']);
        if ~exist(tuningParamFile,'file') || rewriteFiles
            copyfile(fullfile(paramFileDir,[monkey '_' paramSetName '_tuning_parameters.dat']),tuningParamFile,'f');
        end
        
        if ~useUnsorted
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
                [~] = findMemoryCells(expParamFile, paramSetName,sigCompMethod);
            end
        end
        
        if doReport
            disp('');
            disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
            disp('%%% Generating Report  %%%')
            disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
            % make an HTML document detailing it all
            [~] = makeSummaryReport(expParamFile, paramSetName, useUnsorted);
        end
    end
    
    % do the plotting outside of that loop so that we don't have to
    % continually reload any data
    if doPlotting
        try
        disp('');
        disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
        disp('%%% Saving Data Plots  %%%')
        disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
        % make my plots
        if doPlotting == 1
            [~] = makeFFPlots(expParamFile,paramSetNames,useUnsorted);
        elseif doPlotting == 2
            [~] = makeFFPlots(expParamFile,'',useUnsorted);
        elseif doPlotting == 3
            [~] = makeFFPlots(expParamFile,paramSetNames,useUnsorted,true);
        else
            error('Not sure what to plot!');
        end
        catch
            disp('error in plotting')
        end
    end
end

disp('');
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('%%%  ALL DONE!  YAY!   %%%')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
