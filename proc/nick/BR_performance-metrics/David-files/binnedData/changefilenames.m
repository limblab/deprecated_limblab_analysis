function changefilenames(inserted_text)
% Inserts the string 'inserted_text' into the file names of selected .mat
% files.
%
% SUGGESTED ARGUMENT: '_binned'
%
% This code was written for changing .mat file names for bdfs that have
% been binned with 'convertBatch2Binned' or 'convertBDF2Binned'
%% Initialization

dataPath = uigetdir;

[FileNames,bdfPath] = uigetfile([dataPath '\*.mat'],'Select binned BDF .mat files', 'MultiSelect', 'on');
    if ~bdfPath
        disp('User action cancelled.');
        return;
    end

savePath = dataPath;

if iscell(FileNames)
    numFiles = size(FileNames,2);
elseif ischar(FileNames);
    numFiles = 1;
    FileNames = {FileNames};
end        

%% Import, rename, and save data

new_name_end = strcat(inserted_text,'.mat');
for i=1:numFiles
    if strcmp(FileNames{i}(end-3:end),'.mat')
        mat_FileNames(:,i) = strrep(FileNames(:,i), '.mat', new_name_end);
    else
        disp(sprintf('Wrong file type selected: %s not a .mat file',FileNames{:,1}));
    end
end  

for i=1:numFiles
    disp(sprintf('Renaming %s...', FileNames{:,i} ));
    full_path = [bdfPath '\' FileNames{:,i}];
    var = open(full_path);
    disp(sprintf('Saving .mat structure %s...',mat_FileNames{:,i}));
    save([savePath '\' mat_FileNames{:,i} ], 'var');
    disp('Done.');
end


