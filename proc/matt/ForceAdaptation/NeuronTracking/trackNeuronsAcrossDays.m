function tracking = trackNeuronsAcrossDays(paramFiles,baseDir,criteria,saveData)
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
%
% !!!!!!!!!!!!!!!
% WARNING: Hard coded right now for M1. Discards PMd if it exists.
% !!!!!!!!!!!!!!!

% for now, just use washout period from each day
%   this is longer in time than baseline but doesn't have motor noise like adaptation

root_dir = criteria.root_dir;

allData = cell(1,length(paramFiles));

for iFile = 1:length(paramFiles)
    expParamFile = paramFiles{iFile};
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Load some of the experimental parameters
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    params = parseExpParams(expParamFile);

    monkey = params.monkey;
    useDate = params.date;
    taskType = params.task;
    adaptType = params.adaptation_type;
    clear params
    
    disp(['Loading data for ' useDate  '...'])
    data = loadResults(root_dir,{monkey, useDate, adaptType, taskType},'data',[],'BL');
    
    % strip away the useless stuff
    data = rmfield(data,'cont');
    data = rmfield(data,'movement_centers');
    data = rmfield(data,'movement_table');
    data = rmfield(data,'trial_table');
    if isfield(data,'PMd')
        data = rmfield(data,'PMd');
    end
    
    % compile data into cell array
    allData{iFile} = data;
    clear data tuning;
end

saveFile = fullfile(baseDir,'multiday_tracking.mat');

tracking = trackNeurons(criteria,allData);

if saveData
    % save the new file with classification info
    disp(['Saving data to ' saveFile]);
    save(saveFile,'tracking');
end



