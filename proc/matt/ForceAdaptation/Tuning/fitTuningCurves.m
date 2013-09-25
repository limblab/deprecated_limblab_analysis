function tuning = fitTuningCurves(expParamFile, paramSetName)
% FITTUNINGCURVES  Wrapper function to calculate tuning curves
%
%   This function will calculate tuning using a variety of methods for
% different periods of the movements.
%
% INPUTS:
%   expParamFile: (string) path to file containing experimental parameters
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
baseDir = params.out_dir{1};
useDate = params.date{1};
taskType = params.task{1};
adaptType = params.adaptation_type{1};
epochs = params.epochs;
clear params
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dataPath = fullfile(baseDir,useDate);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load some of the parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
paramFile = fullfile(dataPath, paramSetName, [ useDate '_analysis_parameters.dat']);
params = parseExpParams(paramFile);
tuningPeriods = params.tuning_periods;
tuningMethods = params.tuning_methods;
clear params;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

doPlots = false;

%%

saveFile = fullfile(dataPath,paramSetName,[taskType '_' adaptType '_tuning_' useDate '.mat']);

for iEpoch = 1:length(epochs)
    getFile = fullfile(dataPath,[taskType '_' adaptType '_' epochs{iEpoch} '_' useDate '.mat']);
    load(getFile);
    
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
                
                switch lower(tuningMethods{iMethod})
                    case 'glm' % fit a GLM model
                        % NOT IMPLEMENTED
                        tuning.(epochs{iEpoch}).(useArray).(tuningMethods{iMethod}).(tuningPeriods{iTune}) = fitTuningCurves_GLM(data,tuningPeriods{iTune},useArray,paramSetName);
                        
                    case 'nonparametric'
                        % NOT: for now, must do regression (or vectorsum) first
                        if ~strcmpi(tuningPeriods{iTune},'file')
                            tuning.(epochs{iEpoch}).(useArray).(tuningMethods{iMethod}).(tuningPeriods{iTune}) = nonparametricTuning(data,tuningPeriods{iTune},useArray,paramSetName,doPlots);
                        else
                            disp('WARNING: cannot use whole file for this tuning method, so skipping this tuning period input');
                        end
                        
                    otherwise % do regression of cosine model for period specified in tuneType
                        if ~strcmpi(tuningPeriods{iTune},'file')
                            tuning.(epochs{iEpoch}).(useArray).(tuningMethods{iMethod}).(tuningPeriods{iTune}) = fitTuningCurves_Reg(data,tuningPeriods{iTune},tuningMethods{iMethod},useArray,paramSetName,doPlots);
                        else
                            disp('WARNING: cannot use whole file for this tuning method, so skipping this tuning period input');
                        end
                        
                end
            end
        end
    end
    tuning.(epochs{iEpoch}).meta = data.meta;
end

% save the new file with tuning info
save(saveFile,'tuning');
