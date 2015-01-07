function tracking = trackNeurons(params,varargin)
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load some of the analysis parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
arrays = params.exp.arrays;
criteria = params.tracking.criteria;
confLevel = params.tracking.trackingConfidenceLevel;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~iscell(criteria)
    criteria = {criteria};
end

for iArray = 1:length(arrays)
    currArray = arrays{iArray};
    
    data = cellfun(@(x) x.(currArray),varargin,'UniformOutput',false);
    
    sg = cell(length(data),1);
    for i = 1:length(data)
        sg{i} = data{i}.sg;
    end
    
%     % find units that are not common to all
%     badUnits = checkUnitGuides(sg);
%     
%     % remove those indices
%     for i = 1:length(sg)
%         data{i}.sg = setdiff(data{i}.sg, badUnits, 'rows');
%     end
    
    disp(['Comparing cells for ' currArray '...'])
    
    tracking.(currArray) = KS_p(criteria,data, 1-confLevel);
    
end
