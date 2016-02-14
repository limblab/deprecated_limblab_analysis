% TO IMPLEMENT:
%   - f-test for directional tuning?

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
procDirName = 'Processed';
monkeys = {'Jaco'};
paramSetNames = {'movement'};

% exclude these analysis steps
% processing options
doDataStruct        = 0;
doAdaptation        = 0;
doTracking          = 0;
% tuning options
doTuning            = 1;
doClassification    = 0;
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
            
            mrt_data = sessionList(strcmpi(sessionList(:,1),'MrT'),:);
            params = setParamValues(params,'MonkeyID',1,'dataDir','F:\MrT');
            goodDates = mrt_data(:,2);
        case 'Chewie'
            arrays = {'M1'};
            
            chewie_data = sessionList(strcmpi(sessionList(:,1),'Chewie'),:);
            params = setParamValues(params,'MonkeyID',2,'dataDir','F:\Chewie');
            goodDates = chewie_data(:,2);

        case 'Mihili'
            arrays = {'M1','PMd'};
            
            mihili_data = sessionList(strcmpi(sessionList(:,1),'Mihili'),:);
            params = setParamValues(params,'MonkeyID',3,'dataDir','F:\Mihili');
            goodDates = mihili_data(:,2);
            
            case 'Jaco'
            arrays = {'M1'};
            
            jaco_data = sessionList(strcmpi(sessionList(:,1),'Jaco'),:);
            params = setParamValues(params,'MonkeyID',2,'dataDir','F:\Jaco');
            goodDates = jaco_data(:,2);
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
        dataPath = fullfile(params.outDir,procDirName,useDate);
        expParamFile = fullfile(dataPath,[useDate '_experiment_parameters.dat']);
        
        % if doesn't exist, make folder for tuning results
        for iArray = 1:length(arrays)
            if ~exist(fullfile(dataPath,[arrays{iArray} '_tuning']),'dir') && (doTuning || doClassification)
                mkdir(fullfile(dataPath,[arrays{iArray} '_tuning']));
            end
        end
        
        % load experiment parameters from text file
        params.exp = parseExpParams(expParamFile);

        params.useUnsorted = true;
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
