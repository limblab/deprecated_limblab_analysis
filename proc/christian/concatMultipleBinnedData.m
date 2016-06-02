function binnedData = concatMultipleBinnedData(varargin)

[FileName_tmp, PathName] = uigetfile( {'*.mat'}, 'Choose First BinnedData File');
dataPath = PathName;

if ~FileName_tmp
    binnedData = [];
    return;
else
    FileNames = {FileName_tmp; PathName};
end    

[FileName_tmp, PathName] = uigetfile( [dataPath '*.mat'], 'Choose Second BinnedData File');
dataPath = PathName;

if ~FileName_tmp
    binnedData = [];
    return;
else
    FileNames = [FileNames {FileName_tmp; PathName}];
end

MoreFiles = questdlg('Do you want to add another file?');

while strcmp(MoreFiles,'Yes')
    
    [FileNames_tmp, PathName] = uigetfile( [dataPath '*.mat'], 'Add Bin Data File');
    dataPath = PathName;
    
    if ischar(FileNames_tmp) %Num File = 1
            FileNames = [FileNames {FileNames_tmp; PathName}];
    else %user pressed cancel, treat as no more files wanted
        break;
    end
    
    MoreFiles = questdlg('Do you want to add another file?');
end

if nargin
    neuronIDs = varargin{1};
else
    bd = {};
    for i = 1:size(FileNames,2)
        tmp = load([FileNames{2,i} FileNames{1,i}]);
        structname = fieldnames(tmp);
        tmp = tmp.(structname{1});
        bd = [bd;tmp];
    end
    neuronIDs = bd{1}.neuronIDs;
    for i = 2:length(bd)
        neuronIDs = intersect(neuronIDs,bd{i}.neuronIDs,'rows','stable');
%     neuronIDs = getCommonUnits(bd);
    end
end

if strcmp(MoreFiles,'Cancel')
    binnedData = [];
else
    NumFiles = size(FileNames,2);
    
    binnedData = LoadDataStruct([FileNames{2,1} FileNames{1,1}],'binned');
    
    for i = 2:NumFiles
        File2 = LoadDataStruct([FileNames{2,i} FileNames{1,i}],'binned');
        binnedData = concatBinnedData(binnedData, File2, neuronIDs);
    end   
    
end
    
