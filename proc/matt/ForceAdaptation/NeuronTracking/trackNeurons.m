function tracking = trackNeurons(criteria,arrays,varargin)
% TRACKNEURONS  Run empirical KS test to check for stability of neurons
%
%   This function will allow you to track cells across files, sessions, or
% days to determine if the same neurons exist. For each unit, an empirical
% null set is built using the units on every other electrode and used to do
% a statistical confirmation of the ISI distribution and waveforms.
%
% INPUTS:
%   arrays: name of array to use (M1 vs PMd etc)
%   varargin: data structs, if length==1 assumes it is already packaged as a cell
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

if length(varargin) == 1
    varargin = varargin{1};
end

dataPath = varargin{1}.meta.out_directory;
useDate = varargin{1}.meta.recording_date;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load some of the analysis parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
paramFile = fullfile(dataPath, [ useDate '_analysis_parameters.dat']);
params = parseExpParams(paramFile);
confLevel = str2double(params.tracking_confidence_level{1});
clear params;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for iArray = 1:length(arrays)
    currArray = arrays{iArray};
    
    data = cellfun(@(x) x.(currArray),varargin,'UniformOutput',false);
    
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
    
    tracking.(currArray) = KS_p(criteria,data, 1-confLevel);
    
end
