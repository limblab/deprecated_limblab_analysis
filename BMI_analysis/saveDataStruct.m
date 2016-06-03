function [FileName,FilePath] = saveDataStruct(struct, DataPath, FileName, type)
    
    switch type
        case 'bdf'
            FilePath = [DataPath filesep 'BDFStructs' filesep];
            out_struct = struct;
        case 'binned'
            FilePath = [DataPath filesep 'BinnedData' filesep];
            binnedData = struct;
        case 'filter'
            FilePath = [DataPath filesep 'SavedFilters' filesep];
            filter = struct;
        case 'RTpred'
            FilePath = [DataPath filesep 'RTPreds' filesep];
            RTPredData = struct;
        case 'OLpred'
            FilePath = [DataPath filesep 'OLPreds' filesep];
            OLPredData = struct;
        otherwise
            disp('Unknown file type');
    end
    clear struct;
    
    if ~isdir(FilePath)
        FilePath = DataPath;
    end
    
    %FileName = fullfile(DataPath, FileName);
     [FileName,FilePath] = uiputfile( fullfile(FilePath,FileName), 'Save file');
     fullfilename = fullfile(FilePath, FileName);

    if isequal(FileName,0)
        disp('The structure was not saved!')
        FileName = 0; FilePath = 0;
    else
        switch type
            case 'bdf'
                save(fullfilename, 'out_struct');
            case 'binned'
                save(fullfilename, 'binnedData');
            case 'filter'
                save(fullfilename, 'filter');
            case 'RTpred'
                save(fullfilename, 'RTPredData');
            case 'OLpred'
                save(fullfilename, 'OLPredData');
        end     
        disp(['File: ', fullfilename,' saved successfully']);
    end
    
end