function tracking = trackNeuronsAcrossDays(paramFiles,criteria,saveData)
% TRACKNEURONS  Run empirical KS test to check for stability of neurons
%
%   This function will allow you to track cells across days. Just pass in a
% cell array with paths to however many days you want to track
%
% INPUTS:
%   expParamFiles: (cell array) list of parameter files to use
%   saveData: (bool) whether or not to save the data to a file
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

% for now, just use washout period from each day
%   this is longer in time than baseline but doesn't have motor noise like adaptation

allData = cell(1,length(paramFiles));

for iFile = 1:length(paramFiles)
    expParamFile = paramFiles{iFile};
    
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
    
    disp(['Loading data for ' useDate  '...'])
    data = load(fullfile(dataPath,[taskType '_' adaptType '_WO_' useDate '.mat']));
    
    % compile data into cell array
    allData{iFile} = data;
    clear data tuning;
end

saveFile = fullfile(baseDir,'multiday_tracking.mat');

tracking = trackNeurons(criteria,arrays,allData);

if saveData
    % save the new file with classification info
    disp(['Saving data to ' saveFile]);
    save(saveFile,'tracking');
end



