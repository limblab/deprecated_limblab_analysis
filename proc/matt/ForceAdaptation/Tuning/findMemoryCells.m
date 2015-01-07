function findMemoryCells(params,arrays)
% FINDMEMORYCELLS  Compares tuning of cells to classify their behavior
%
%   This function uses the tuning made by fitTuningCurves to classify them
% based on their tuning behavior before, during, and after learning. There
% are the following types:
%       Kinematic (AAA, id=1) : no change with perturbation
%       Dynamic   (ABA, id=2)   : changes in response to the perturbation
%       Memory I  (ABB, id=3)  : changes with perturbation and hold tuning
%       Memory II (AAB, id=4) : changes when perturbation is removed
%       Other     (ABC, id=5)     : Different tuning in every epoch
%
% INPUTS:
%   expParamFile: (string) path to file containing experimental parameters
%   outDir: (string) directory for output
%   paramSetName: (string) Name of the parameter file
%   compMethod: (string) (optional) 'diff' or 'overlap', method of sig
%
% OUTPUTS:
%   classes: (struct) output with field for each array and tuning period
%
% NOTES:
%   - This function requires several bits of pre-processing
%       1) Create a data struct from the Cerebus files (makeDataStruct)
%       2) Fit tuning for neurons, regression and nonparametric recommended (fitTuningCurves)
%   - This function will automatically write the struct to a file, too
%   - See "experimental_parameters_doc.m" for documentation on expParamFile
%   - Analysis parameters file must exist (see "analysis_parameters_doc.m")

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load some of the experimental parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
root_dir = params.outDir; % we want to load from the output directory of makeDataStruct
paramSetName = params.paramSetName;

useDate = params.exp.date{1};
taskType = params.exp.task{1};
adaptType = params.exp.adaptation_type{1};
monkey = params.exp.monkey{1};

tuneWindows = params.tuning.tuningPeriods;
tuneMethods = params.tuning.tuningMethods;
doRandSubset = params.tuning.doRandSubset;
classifierBlocks = params.classes.classifierBlocks;
compMethod = params.classes.sigCompareMethod;

disp('Loading data to classify cells...')
data = loadResults(root_dir,{monkey, useDate, adaptType, taskType},'data',[],'BL');

tracking = loadResults(root_dir,{monkey, useDate, adaptType, taskType},'tracking');

for iMethod = 1:length(tuneMethods)
    % nonparametric tuning requires a different method for comparison
    % for regression or GLM, loop along the periods
    for iPeriod = 1:length(tuneWindows)
        % only glm can use the full file tuning
        if strcmpi(tuneWindows{iPeriod},'file') && ~strcmpi(tuneMethods{iMethod},'glm')
            warning(['File tuning not supported for ' tuneMethods{iMethod} ' method...']);
        else
            % loop along the arrays
            for iArray = 1:length(arrays)
                useArray = arrays{iArray};
                disp(['Using ' useArray '...']);
                
                t = loadResults(root_dir,{monkey, useDate, adaptType, taskType},'tuning',[],useArray,paramSetName,tuneMethods{iMethod},tuneWindows{iWindow});
                
                % if an older classification exists, delete it so we can start fresh
                if isfield(t,'classes')
                    t = rmfield(t,'classes');
                end
                
                % can do this for multiple sets of blocks
                for iBlock = 1:size(classifierBlocks,1)
                    disp(['Classifying for set of blocks #' num2str(iBlock) ': [' num2str(classifierBlocks(iBlock,:)) ']...']);
                    if strcmpi(tuneMethods{iMethod},'nonparametric')
                        warning(['Classification not supported for ' tuneMethods{iMethod} ' method...']);
                        
                        cellClass = [];
                        % get cells that are significantly tuned in all epochs
                        %   first column is PDs, second is MDs
                        [istuned, sg] = excludeCells(params,data,t.tuning,tracking,useArray);
                        tunedCells = sg(all(istuned,2),:);
                        disp(['There are ' num2str(length(tunedCells)) ' cells tuned in all epochs...']);
                        
                        s(iBlock).classes = cellClass;
                        s(iBlock).sg = sg;
                        s(iBlock).istuned = istuned;
                        s(iBlock).tuned_cells = tunedCells;
                    else
                        if doRandSubset
                            [cellClass,~] = classifyCells(params,t.tuning(classifierBlocks(iBlock,:)),tuneMethods{iMethod},compMethod,[1,2,3]);
                        else
                            [cellClass,~] = classifyCells(params,t.tuning,tuneMethods{iMethod},compMethod,classifierBlocks(iBlock,:));
                        end
                        
                        % get cells that are significantly tuned in all epochs
                        %   first column is PDs, second is MDs
                        [istuned, sg] = excludeCells(params,data,t.tuning,tracking,useArray);
                        tunedCells = sg(all(istuned,2),:);
                        disp(['There are ' num2str(length(tunedCells)) ' cells tuned in all epochs...']);
                        
                        s(iBlock).classes = cellClass;
                        s(iBlock).sg = sg;
                        s(iBlock).istuned = istuned;
                        s(iBlock).tuned_cells = tunedCells;
                        s(iBlock).params = params;
                        
                        % make sure there's no ambiguity about which set this is
                        s(iBlock).params.classes.classifierBlocks = classifierBlocks(iBlock,:);
                    end
                end
                t.classes = s;
                
                % save the new file with classification info
                disp(['Saving data to ' tuningFile]);
                save(tuningFile,'-struct','t');
            end
        end
    end
end



