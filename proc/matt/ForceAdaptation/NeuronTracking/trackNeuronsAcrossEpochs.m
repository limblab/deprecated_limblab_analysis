function tracking = trackNeuronsAcrossEpochs(expParamFile,criteria)
% TRACKNEURONS  Run empirical KS test to check for stability of neurons
%
%   This function will allow you to track cells across a session for the
% three epochs (baseline, adaptation, washout).
%
% INPUTS:
%   expParamFile: (string) path to file containing experimental parameters
%   criteria: (cell array of strings) for significance, 'isi' and/or 'wf'
%
% OUTPUTS:
%   tracking: (struct) results
%       Output may not be super intuitive to interpret so talk to Matt or
%         Brian for now until I can code up a description.
%
% NOTES:
%   -This function requires several bits of pre-processing
%       1) Create a data struct from the Cerebus files (makeDataStruct)
%   - This function will automatically write the struct to a file, too
%   - See "experimental_parameters_doc.m" for documentation on expParamFile
%   - Analysis parameters file must exist (see "analysis_parameters_doc.m")

if ~iscell(criteria)
    criteria = {criteria};
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load some of the experimental parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
params = parseExpParams(expParamFile);
baseDir = params.out_dir{1};
useDate = params.date{1};
taskType = params.task{1};
adaptType = params.adaptation_type{1};
arrays = params.arrays;
clear params

dataPath = fullfile(baseDir,useDate);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Loading data to track neurons...')
bl = load(fullfile(dataPath,[taskType '_' adaptType '_BL_' useDate '.mat']));
ad = load(fullfile(dataPath,[taskType '_' adaptType '_AD_' useDate '.mat']));
wo = load(fullfile(dataPath,[taskType '_' adaptType '_WO_' useDate '.mat']));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

saveFile = fullfile(dataPath,[taskType '_' adaptType '_tracking_' useDate '.mat']);

tracking = trackNeurons(criteria,arrays,bl,ad,wo);

% save the new file with classification info
disp(['Saving data to ' saveFile]);
save(saveFile,'-struct','tracking');

