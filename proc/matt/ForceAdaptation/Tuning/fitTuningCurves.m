function tuning = fitTuningCurves(expParamFile)
% wrapper function that takes in data struct and calls subfunctions
% tuneType: (string) what kind of tuning to do (can be cell to do multiple)
%   'pre': use the time period immediately after target presentation
%   'initial': use the time period starting from movement onset
%   'peak': use time period centered around movement peak
%   'final': use time period ending when trial ends
%   'full': entire movement from target presentation to completion
%   'file': use the whole file (***ONLY WORKS FOR GLM***)
%
% compType: what computational method to use for PDs
%   'glm': use a GLM
%   'regression': use regression of cosines
%   'vectorsum': use vector sum
%
%   The time window size is specified in the parameters file.

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
paramFile = fullfile(dataPath, [ useDate '_analysis_parameters.dat']);
params = parseExpParams(paramFile);
tuningPeriods = params.tuning_periods;
tuningMethods = params.tuning_methods;
clear params;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

doPlots = false;

%%


for iEpoch = 1:length(epochs)
    saveFile = fullfile(dataPath,[taskType '_' adaptType '_' epochs{iEpoch} '_' useDate '.mat']);
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
                        tuning.(useArray).(tuningMethods{iMethod}).(tuningPeriods{iTune}) = fitTuningCurves_GLM(data,tuningPeriods{iTune},useArray,doPlots);
                        
                    case 'nonparametric'
                        % NOT: for now, must do regression (or vectorsum) first
                        if ~strcmpi(tuningPeriods{iTune},'file')
                            tuning.(useArray).(tuningMethods{iMethod}).(tuningPeriods{iTune}) = nonparametricTuning(data,tuningPeriods{iTune},useArray,doPlots);
                        else
                            disp('WARNING: cannot use whole file for this tuning method, so skipping this tuning period input');
                        end
                        
                    otherwise % do regression of cosine model for period specified in tuneType
                        if ~strcmpi(tuningPeriods{iTune},'file')
                            tuning.(useArray).(tuningMethods{iMethod}).(tuningPeriods{iTune}) = fitTuningCurves_Reg(data,tuningPeriods{iTune},tuningMethods{iMethod},useArray,doPlots);
                        else
                            disp('WARNING: cannot use whole file for this tuning method, so skipping this tuning period input');
                        end
                        
                end
            end
        end
    end
    
    tuning.meta = data.meta;
    % save the new file with tuning info
    save(saveFile,'data','tuning');
    
end