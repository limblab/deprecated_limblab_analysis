% TO IMPLEMENT:
%   - f-test for directional tuning?
%
% TO FIX:
%   - Fix classification for time results
%   - Fix analysis scripts to use params struct
%   - Fix all filterMovementTable calls
%   - Clean up classification? Not sure if possible.
%   - make classification less bootstrapping dependent?

% PROCESSFFDATA  Script to run analysis on a day of data
%   - make an experiment parameters file before running
close all;
clear;
clc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Specify these things %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% would be great to have proper database
%   - could load monkey info
dataRoot = 'F:\';
monkeys = {'Mihili'};
paramSetNames = {'planning'}; %,'target','speedSlow','speedFast','moveTime','moveFine','targFine'};

% exclude these analysis steps
%    Note: I recommend if you change analysis parameters relevant to one of
%    these you re-run them so that the parameter file in the folder is up to
%    date with the actual data
% processing options
doDataStruct        = 0;
doAdaptation        = 0;
doTracking          = 0;
% tuning options
doTuning            = 1;
doClassification    = 1;
doReport            = 0;
% plotting options
doPlotting          = 0; % 1 for all, 2 for only general, 3 for only tuning
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~iscell(paramSetNames)
    paramSetNames = {paramSetNames};
end

% load defaults and start setting values for analysis
params = getParamDefaults;
params = setParamValues(params,'dataRoot',dataRoot);

dataSummary;

for iMonkey = 1:length(monkeys)
    monkey = monkeys{iMonkey};
    params = setParamValues(params,'outDir',fullfile(dataRoot,monkey));
    
    switch monkey
        case 'MrT'
            arrays = {'PMd'};            
            params = setParamValues(params,'MonkeyID',1,'dataDir','Z:\MrT_9I4\Matt');
            goodDates = mrt_data(:,2);
        case 'Chewie'
            arrays = {'M1'};            
            params = setParamValues(params,'MonkeyID',2,'dataDir','Z:\Chewie_8I2\Matt');
            goodDates = chewie_data(:,2);
            
            %goodDates = {'2015-03-09';'2015-03-11';'2015-03-12';'2015-03-13';'2015-03-16';'2015-03-17';'2015-03-18';'2015-03-19';'2015-03-20'};
                
        case 'Mihili'
            arrays = {'M1','PMd'};            
            params = setParamValues(params,'MonkeyID',3,'dataDir','Z:\Mihili_12A3\Matt');
            goodDates = mihili_data(:,2);
        otherwise
            error('Monkey not recognized');
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    for iDate = 1:length(goodDates)
        useDate = goodDates{iDate};
        disp(['Processing data for ' useDate '...']);
        
        % where the data and experiment parameters are
        dataPath = fullfile(params.outDir,useDate);
        expParamFile = fullfile(dataPath,[useDate '_experiment_parameters.dat']);
        
        % if doesn't exist, make folder for tuning results
        for iArray = 1:length(arrays)
            if ~exist(fullfile(dataPath,[arrays{iArray} '_tuning']),'dir') && (doTuning || doClassification)
                mkdir(fullfile(dataPath,[arrays{iArray} '_tuning']));
            end
        end
        
        % load experiment parameters from text file
        params.exp = parseExpParams(expParamFile);
        
        if doDataStruct
            disp('');
            disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
            disp('%%% Making Data Struct %%%')
            disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
            % make my data file (will convert things to BDF if necessary
            load_success = makeDataStruct(params, 'nevnsx', false);
            if ~load_success
                disp('No NEVNSX found... trying NEV...')
                load_success = makeDataStruct(params, 'nev', false);
                if ~load_success
                    error('Could not find specified file!');
                end
            end
        end
        
        if doAdaptation
            disp('');
            disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
            disp('%%% Adaptation Metrics %%%')
            disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
            % calculate some behavioral metrics over files
            [~] = getAdaptationMetrics(params);
        end
        
        if doTracking && ~params.useUnsorted
            disp('');
            disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
            disp('%%%  Tracking Neurons  %%%')
            disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
            % do empirical test to track neurons across epochs
            [~] = trackNeuronsAcrossEpochs(params);
        end
        
        % Now loop along the tuning parameter sets
        for iParam = 1:length(paramSetNames)
            paramSetName = paramSetNames{iParam};
            disp(['Using the "' paramSetName '" set of tuning parameters...']);
            
            params = setParamValues(params,'paramSetName',paramSetName);
            
            % load the parameter values for the parameter names
            params = parameterSets(params,paramSetName);
            
            % some analyses I won't want to do on every type of task
            if ismember(params.exp.task,params.useTasks) && ismember(params.exp.adaptation_type,params.useTasks)
                if ~params.useUnsorted
                    if doTuning
                        disp('');
                        disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
                        disp('%%%  Fit Tuning Curves %%%')
                        disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
                        % calculate tuning curves
                        fitTuningCurves(params,arrays);
                    end
                    
                    if doClassification
                        disp('');
                        disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
                        disp('%%% Classifying Cells  %%%')
                        disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
                        % Look for memory cells
                        findMemoryCells(params,arrays);
                    end
                end
                
                if doReport
                    disp('');
                    disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
                    disp('%%% Generating Report  %%%')
                    disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
                    % make an HTML document detailing it all
                    [~] = makeSummaryReport(params);
                end
            end
        end
        
        % do the plotting outside of that loop so that we don't have to
        % continually reload any data
        if doPlotting
            disp('');
            disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
            disp('%%% Saving Data Plots  %%%')
            disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
            % make my plots
            if doPlotting == 1 || doPlotting == 2
                makeGeneralPlots(params);
            end
            
            if doPlotting == 1 || doPlotting == 3
                makeTuningPlots(params)
            end
        end
    end
    
end
disp('');
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('%%%  ALL DONE!  YAY!   %%%')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
