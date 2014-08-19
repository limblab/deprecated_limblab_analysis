% Dos cell modulate at all?
% f-test for directional tuning?
%

% PROCESSFFDATA  Script to run analysis on a day of data
%   - make an experiment parameters file before running
%   - will copy over analysis parameters file from paramFileDir if
%       rewriteFiles is true.
close all;
clear;
clc;

% would be great to have proper database
%   - could load monkey info
dataRoot = 'C:\Users\Matt Perich\Desktop\lab\data\';

useUnsorted = false;
sigCompMethod = 'diff';
sigMethod = 'regression';

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
% tuning options
doTuning            = 1;
doClassification    = 1;
doReport            = 0;
% plotting options
doPlotting          = 0; % 1 for all, 2 for only general, 3 for only tuning

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Specify these things %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% paramSetNames = {'movement','target','move_time','targ_time','movement_fine','target_fine'};
paramSetNames = {'speed_slow','speed_fast'};
classifierBlocks = [1 2 3];

monkeys = {'Chewie','Mihili'};
dataSummary;

for iMonkey = 1:length(monkeys)
    monkey = monkeys{iMonkey};
    
    paramFileDir = fullfile(dataRoot,monkey);
    dataFileDir = fullfile(dataRoot,monkey);
    outDir = fullfile(dataRoot,monkey);
    
    switch monkey
        case 'MrT'
            arrays = {'PMd'};
            
            dateInds = strcmpi(mrt_data(:,4),'CO') | strcmpi(mrt_data(:,4),'RT');
            
            dataDir = 'Z:\MrT_9I4\Matt';
            goodDates = mrt_data(dateInds,2);
        case 'Chewie'
            arrays = {'M1'};
            
            dateInds = strcmpi(chewie_data(:,3),'FF');
            
            dataDir = 'Z:\Chewie_8I2\Matt';
            goodDates = chewie_data(dateInds,2);
        case 'Mihili'
            arrays = {'M1'};
            
            dateInds = strcmpi(mihili_data(:,3),'FF');
            
            dataDir = 'Z:\Mihili_12A3\Matt';
            goodDates = mihili_data(dateInds,2);
        otherwise
            error('Monkey not recognized');
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    for iDate = 1:length(goodDates)
        useDate = goodDates{iDate};
        disp(['Processing data for ' useDate '...']);
        
        dataPath = fullfile(outDir,useDate);
        
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
        end
        
        if doDataStruct
            disp('');
            disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
            disp('%%% Making Data Struct %%%')
            disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
            % make my data file (will convert things to BDF if necessary
            try
                [~,useUnsorted] = makeDataStruct(expParamFile,dataDir,outDir,'nevnsx', false, useUnsorted);
            catch
                [~,useUnsorted] = makeDataStruct(expParamFile,dataDir,outDir,'nev', false, useUnsorted);
            end
        end
        
        if doAdaptation
            disp('');
            disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
            disp('%%% Adaptation Metrics %%%')
            disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
            % calculate some behavioral metrics over files
            [~] = getAdaptationMetrics(expParamFile,outDir,'movement');
        end
        
        if doTracking && ~useUnsorted
            disp('');
            disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
            disp('%%%  Tracking Neurons  %%%')
            disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
            % do empirical test to track neurons across epochs
            [~] = trackNeuronsAcrossEpochs(expParamFile,outDir,{'wf','isi'});
        end
        
        % Now loop along the tuning parameter sets
        for iParam = 1:length(paramSetNames)
            paramSetName = paramSetNames{iParam};
            
            disp(['Using the "' paramSetName '" set of tuning parameters...']);
            
            if ~useUnsorted
                if doTuning
                    disp('');
                    disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
                    disp('%%%  Fit Tuning Curves %%%')
                    disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
                    % calculate tuning curves
                    [~] = fitTuningCurves(expParamFile, outDir, paramSetName,arrays);
                end
                
                if doClassification
                    disp('');
                    disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
                    disp('%%% Classifying Cells  %%%')
                    disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
                    % Look for memory cells
                    [~] = findMemoryCells(expParamFile, outDir, paramSetName,sigCompMethod,classifierBlocks);
                end
            end
            
            if doReport
                disp('');
                disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
                disp('%%% Generating Report  %%%')
                disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
                % make an HTML document detailing it all
                [~] = makeSummaryReport(expParamFile, outDir, paramSetName, useUnsorted,sigMethod);
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
                makeGeneralPlots(expParamFile,outDir,useUnsorted);
            end
            
            if doPlotting == 1 || doPlotting == 3
                makeTuningPlots(expParamFile,outDir,paramSetNames,sigMethod)
            end
        end
    end
    
end
disp('');
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('%%%  ALL DONE!  YAY!   %%%')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
