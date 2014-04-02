function tuning = fitTuningCurves(expParamFile, outDir, paramSetName)
% FITTUNINGCURVES  Wrapper function to calculate tuning curves
%
%   This function will calculate tuning using a variety of methods for
% different periods of the movements.
%
% INPUTS:
%   expParamFile: (string) path to file containing experimental parameters
%   outDir: (string) directory for output
%   paramSetName: (string) Name of the parameter file
%
% OUTPUTS:
%   tuning: (struct) has field for each array, each method, each period
%       Supported methods:
%           'glm': use a GLM
%           'regression': use regression of cosines
%           'vectorsum': use vector sum
%       Supported periods:
%           'pre': use the time period immediately after target presentation
%           'initial': use the time period starting from movement onset
%           'peak': use time period centered around movement peak
%           'final': use time period ending when trial ends
%           'full': entire movement from target presentation to completion
%           'onpeak': starting at onset ending at peak
%           'befpeak': window ending at peak
%           'file': use the whole file (***ONLY WORKS FOR GLM***)
%
% NOTES:
%   - non-'file' tuning requires a window to look in, specified by analysis
%         parameters file
%   - This function requires several bits of pre-processing
%       1) Create a data struct from the Cerebus files (makeDataStruct)
%       2) Create adaptation metrics struct (getAdaptationMetrics)
%       3) Run empirical KS test to track stability of neurons (trackNeurons)
%       4) Fit tuning for neurons, regression and nonparametric recommended (fitTuningCurves)
%       5) Classify cells based on adaptation behavior (findMemoryCells)
%       6) Generate a variety of plots (makeFFPlots)
%   - This function will automatically write the struct to a file, too
%   - See "experimental_parameters_doc.m" for documentation on expParamFile
%   - Analysis parameters file must exist (see "analysis_parameters_doc.m")

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load some of the experimental parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
params = parseExpParams(expParamFile);
useDate = params.date{1};
taskType = params.task{1};
adaptType = params.adaptation_type{1};
epochs = params.epochs;
clear params
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dataPath = fullfile(outDir,useDate);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load some of the parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
paramFile = fullfile(dataPath, paramSetName, [ useDate '_' paramSetName '_tuning_parameters.dat']);
params = parseExpParams(paramFile);
tuningPeriods = params.tuning_periods;
tuningMethods = params.tuning_methods;
adBlocks = params.ad_exclude_fraction;
woBlocks = params.wo_exclude_fraction;
clear params;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

doPlots = false;

%%

saveFile = fullfile(dataPath,paramSetName,[taskType '_' adaptType '_tuning_' useDate '.mat']);

blockLabels = [];

for iEpoch = 1:length(epochs)
    getFile = fullfile(dataPath,[taskType '_' adaptType '_' epochs{iEpoch} '_' useDate '.mat']);
    data = load(getFile);
    
    if ~exist('data','var')
        error('Data struct not found.');
    end
    
    if ~exist('tuning','var')
        tuning = struct();
    end
    
    arrays = data.meta.arrays;
    
    for iArray = 1:length(arrays)
        useArray = arrays{iArray};
        for iMethod = 1:length(tuningMethods)
            for iTune = 1:length(tuningPeriods)
                
                switch lower(epochs{iEpoch})
                    case 'bl'
                        numBlocks = 1;
                        idx = 0;
                    case 'ad'
                        numBlocks = length(adBlocks)-1;
                        idx = 1;
                    case 'wo'
                        numBlocks = length(woBlocks)-1;
                        idx = 1+length(adBlocks)-1;
                end
                
                if numBlocks < 1
                    numBlocks = 1;
                end
                
                for iBlock = 1:numBlocks
                    disp(['%% Running on ' epochs{iEpoch} ' file... (' num2str(iEpoch) ' of ' num2str(length(epochs)) ')']);
                    disp(['%% Running on ' useArray ' data... (' num2str(iArray) ' of ' num2str(length(arrays)) ')']);
                    disp(['%% Running for ' tuningMethods{iMethod} ' method... (' num2str(iMethod) ' of ' num2str(length(tuningMethods)) ')']);
                    disp(['%% Running for ' tuningPeriods{iTune} ' period... (' num2str(iTune) ' of ' num2str(length(tuningPeriods)) ')']);
                    disp(['%% Block ' num2str(iBlock) ' of ' num2str(numBlocks) '...']);
                    
                    switch lower(tuningMethods{iMethod})
                        case 'glm' % fit a GLM model
                            t = fitTuningCurves_GLM(data,tuningPeriods{iTune},useArray,paramSetName,iBlock);
                        case 'nonparametric'
                            % NOT: for now, must do regression (or vectorsum) first
                            if ~strcmpi(tuningPeriods{iTune},'file')
                                t = nonparametricTuning(data,tuningPeriods{iTune},useArray,paramSetName,iBlock,doPlots);
                            else
                                disp('WARNING: cannot use whole file for nonparametric tuning method, so skipping this tuning period input');
                            end
                            
                        case 'vectorsum'
                            if ~strcmpi(tuningPeriods{iTune},'file')
                                t = fitTuningCurves_VS(data,tuningPeriods{iTune},useArray,paramSetName,iBlock,doPlots);
                            else
                                disp('WARNING: cannot use whole file for vectorsum tuning method, so skipping this tuning period input');
                            end
                            
                        otherwise % do regression of cosine model for period specified in tuneType
                            if ~strcmpi(tuningPeriods{iTune},'file')
                                t = fitTuningCurves_Reg(data,tuningPeriods{iTune},useArray,paramSetName,iBlock,doPlots);
                                
                            else
                                disp('WARNING: cannot use whole file for regression/vectorsum tuning method, so skipping this tuning period input');
                            end
                            
                    end
                    t.meta = data.meta;
                    tuning.(tuningMethods{iMethod}).(tuningPeriods{iTune}).(useArray).tuning(idx+iBlock) = t;
                    
                end
                clear t;
            end
        end
    end
    
end

% save the new file with tuning info
save(saveFile,'-struct','tuning');
