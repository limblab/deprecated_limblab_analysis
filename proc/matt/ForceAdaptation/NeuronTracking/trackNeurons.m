function tracking = trackNeurons(expParamFile)
% TRACKNEURONS  Run empirical KS test to check for stability of neurons
%
%   This function will allow you to track cells across files, sessions, or
% days to determine if the same neurons exist. For each unit, an empirical
% null set is built using the units on every other electrode and used to do
% a statistical confirmation of the ISI distribution and waveforms.
%
% INPUTS:
%   expParamFile: (string) path to file containing experimental parameters
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
% Load some of the analysis parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
paramFile = fullfile(dataPath, [ useDate '_analysis_parameters.dat']);
params = parseExpParams(paramFile);
confLevel = str2double(params.confidence_level{1});
clear params;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Loading data to track neurons...')
load(fullfile(dataPath,[taskType '_' adaptType '_BL_' useDate '.mat']),'data');
bl = data;
load(fullfile(dataPath,[taskType '_' adaptType '_AD_' useDate '.mat']),'data');
ad = data;
load(fullfile(dataPath,[taskType '_' adaptType '_WO_' useDate '.mat']),'data');
wo = data;
clear data tuning;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

saveFile = fullfile(dataPath,[taskType '_' adaptType '_tracking_' useDate '.mat']);

for iArray = 1:length(arrays)
    currArray = arrays{iArray};
    
    data = {bl.(currArray), ...
            ad.(currArray), ...
            wo.(currArray)};
    
    sg = cell(length(data),1);
    for i = 1:length(data)
        sg{i} = data{i}.unit_guide;
    end
    
    % find units that are not common to all
    badUnits = checkUnitGuides(sg);
    
    % remove those indices
    for i = 1:length(sg)
        data{i}.unit_guide = setdiff(data{i}.unit_guide, badUnits, 'rows');
    end
    
    disp(['Comparing cells for ' currArray '...'])
    
    tracking.(currArray) = KS_p(data, (1-confLevel).^2);
    
end

% save the new file with classification info
disp(['Saving data to ' saveFile]);
save(saveFile,'tracking');

