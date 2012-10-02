function NeuronIDs = getCommonUnits(varargin)


    if ~nargin
        [FileNames, PathNames] = getMultipleFiles();

        if isempty(FileNames)
            NeuronIDs = [];
            return;
        end

        NumFiles = size(FileNames,2);

        all_unit_IDs = cell(1,NumFiles);

        for i=1:NumFiles
            tmpstruct = LoadDataStruct([PathNames{i} FileNames{i}],'binned');
            all_unit_IDs(i) = {tmpstruct.spikeguide};
        end

        matching_units = [];
    else
        NumFiles = nargin;
        all_unit_IDs = cell(1,NumFiles);
        
        for i=1:NumFiles
            tmpstruct = varargin{1};
            all_unit_IDs(i) = {tmpstruct.spikeguide};
        end
    end
        
    for u = 1:size(all_unit_IDs{1},1)
        COMMON_FLAG = 1;
        for f = 2:NumFiles
            if isempty(strmatch(all_unit_IDs{1}(u,:),all_unit_IDs{f},'exact'));
                COMMON_FLAG = 0;
                continue;
            end
        end
        if COMMON_FLAG
            matching_units = [matching_units u];
        end
    end

    NeuronIDs = all_unit_IDs{1}(matching_units,:);
    NeuronIDs = spikeguide2neuronIDs(NeuronIDs);

end