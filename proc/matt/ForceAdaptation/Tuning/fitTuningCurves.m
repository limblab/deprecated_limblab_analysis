function data = fitTuningCurves(data,tuningPeriods,tuningMethod)
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

doPlots = false;

arrays = data.meta.arrays;

if ~iscell(tuningPeriods)
    tuningPeriods = {tuningPeriods};
end

if ~iscell(tuningMethod)
    tuningMethod = {tuningMethod};
end

for iArray = 1:length(arrays)
    useArray = arrays{iArray};
    
    for iMethod = 1:length(tuningMethod)
        for iTune = 1:length(tuningPeriods)
            
            switch lower(tuningMethod{iMethod})
                case 'glm' % fit a GLM model
                    % NOT IMPLEMENTED
                    data.(useArray).tuning.glm.(tuningPeriods{iTune}) = fitTuningCurves_GLM(data,tuningPeriods{iTune},useArray,doPlots);
                    
                otherwise % do regression of cosine model for period specified in tuneType
                    if ~strcmpi(tuningPeriods{iTune},'file')
                        data.(useArray).tuning.(tuningPeriods{iTune}) = fitTuningCurves_Reg(data,tuningPeriods{iTune},tuningMethod,useArray,doPlots);
                    else
                        disp('WARNING: cannot use whole file for this tuning method, so skipping this tuning period input');
                    end
                    
            end
        end
    end
end

end