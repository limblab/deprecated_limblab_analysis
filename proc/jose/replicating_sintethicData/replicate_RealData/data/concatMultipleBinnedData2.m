function binnedData = concatMultipleBinnedData2(neuronIDs)

dataPath = 'C:\Monkey\Keedoo\BinnedData\';

[FileName_tmp, PathName] = uigetfile( [dataPath '*.mat'], 'Choose First BinnedData File');
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

if strcmp(MoreFiles,'Cancel')
    binnedData = [];
else
    NumFiles = size(FileNames,2);
    
    binnedData = LoadDataStruct([FileNames{2,1} FileNames{1,1}],'binned');
    
    for i = 2:NumFiles
        File2 = LoadDataStruct([FileNames{2,i} FileNames{1,i}],'binned');
        binnedData = concatBinnedData2(binnedData, File2, neuronIDs);
    end   
    
    
end
    
