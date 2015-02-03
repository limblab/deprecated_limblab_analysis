function fitTuningCurves(params,arrays)
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

doPlots = false;

if nargin < 3
    arrays = [];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load some of the experimental parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
root_dir = params.outDir;
paramSetName = params.paramSetName;

useDate = params.exp.date;
taskType = params.exp.task;
adaptType = params.exp.adaptation_type;
epochs = params.exp.epochs;
monkey = params.exp.monkey;

tuningPeriods = params.tuning.tuningPeriods;
tuningMethods = params.tuning.tuningMethods;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dataPath = fullfile(root_dir,useDate);

%%
% load all of the data into memory
disp('%% Loading data...');
epochData = cell(1,length(epochs));
for iEpoch = 1:length(epochs)
    epochData{iEpoch} = loadResults(params.dataRoot,{monkey, useDate, adaptType, taskType},'data',[],epochs{iEpoch});
end
disp('%% Done.');

if isempty(arrays)
    % if not specified, assume first data has correct array list
    arrays = epochData{1}.meta.arrays;
end

for iArray = 1:length(arrays)
    useArray = arrays{iArray};
    for iMethod = 1:length(tuningMethods)
        for iTune = 1:length(tuningPeriods)
            disp(['%% Running on ' useArray ' data... (' num2str(iArray) ' of ' num2str(length(arrays)) ')']);
            disp(['%% Running for ' tuningMethods{iMethod} ' method... (' num2str(iMethod) ' of ' num2str(length(tuningMethods)) ')']);
            disp(['%% Running for ' tuningPeriods{iTune} ' period... (' num2str(iTune) ' of ' num2str(length(tuningPeriods)) ')']);
            
            % define the filename to save these results
            saveFile = fullfile(dataPath,[arrays{iArray} '_tuning'],[taskType '_' adaptType '_' paramSetName '_' tuningMethods{iMethod} '_' tuningPeriods{iTune} '_' useDate '.mat']);
            
            % here is where I start combining epochs
            tuning = [];
            for iEpoch = 1:length(epochs)
                disp(['%% Running on ' epochs{iEpoch} ' file... (' num2str(iEpoch) ' of ' num2str(length(epochs)) ')']);
                
                % 'file' method only works with GLM
                if ~strcmpi(tuningPeriods{iTune},'file')
                    switch lower(tuningMethods{iMethod})
                        case {'regression','reg'} % do regression of cosine model for period specified in tuneType
                            t_out = fitTuningCurves_Reg(epochData{iEpoch},params,tuningPeriods{iTune},useArray,doPlots);
                        case 'glm' % fit a GLM model
                            t_out = fitTuningCurves_GLM(epochData{iEpoch},params,tuningPeriods{iTune},useArray);
                        case {'nonparametric','nonp'}
                            t_out = nonparametricTuning(epochData{iEpoch},params,tuningPeriods{iTune},useArray,doPlots);
                        case {'vectorsum','vecs'}
                            error('Vector sum method not implemented currently.');
                        otherwise
                            error('Tuning method not recognized.');
                    end
                elseif strcmpi(tuningMethods{iMethod},'glm')
                    t_out = fitTuningCurves_GLM(epochData{iEpoch},params,tuningPeriods{iTune},useArray);
                else
                    disp('WARNING: cannot use whole file for this method, so skipping');
                end
                
                % assign results for saving... here we want to concatenate all of the epochs together
                tuning = [tuning, t_out];
            end
            t.tuning = tuning;
            % save the new file with tuning info
            save(saveFile,'-struct','t');
        end
    end
end


