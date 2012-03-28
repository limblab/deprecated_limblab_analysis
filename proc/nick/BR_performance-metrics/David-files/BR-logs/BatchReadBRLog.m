function BatchReadBRLog
% Lets you select a range of BR logs (originally saved as .txt files, then
% manually converted to .xls or .xlsx files), then it reads them into .mat files and
% saves them in their original directory


%% Initialization

dataPath = uigetdir;

[FileNames,logPath] = uigetfile([dataPath '\*.xls'],'Open .xls BR Logs', 'MultiSelect', 'on');
    if ~logPath
        disp('User action cancelled.');
        return;
    end

savePath = dataPath;
% savePath = uigetdir([logPath '\..\..'], 'Select destination directory for .mat files');
%     if ~savePath
%         disp('User action cancelled.');
%         return;
%     end

if iscell(FileNames)
    numFiles = size(FileNames,2);
elseif ischar(FileNames);
    numFiles = 1;
    FileNames = {FileNames};
end        

%% Import, rename, and save data

for i=1:numFiles
    if strcmp(FileNames{i}(end-3:end),'.xls')
        mat_FileNames(:,i) = strrep(FileNames(:,i), '.xls', '.mat');
    else
        mat_FileNames(:,i) = strrep(FileNames(:,i), '.xlsx', '.mat');
    end
end  

for i=1:numFiles
    disp(sprintf('Converting %s to .mat structure...', FileNames{:,i} ));
    full_path = [logPath '\' FileNames{:,i}];
    [logData,n] = read_data(full_path);
    disp(sprintf('Saving .mat structure %s...',mat_FileNames{:,i}));
    save([savePath '\' mat_FileNames{:,i} ], 'logData');
    disp('Done.');
end


%% Internal Functions


function [data,n] = read_data(filename)
%Filename is a log file with an .xls or .xlsx extension. This function
%will not work if "Plexon recording startup" string does not indicate
%start of brain control data.
%data is a cell array with as many numerical array entries as there are
%corresponding plexon recordings
%columns of each numerical array contain the following information:
%1 - x position
%2 - y position
%3 - x velocity
%4 - y velocity
%5 - state probability (posture/movement)
%n is the number of corresponding plexon recordings
[num,text,raw] = xlsread(filename); 
x = strmatch('Plexon recording startup',text);  %Indices of beginnings of cursor data recording in raw
n = size(x,1);  %number of recordings
numStart=[];    %numStart indicates the number of rows in raw before the first numerical entry occurs
for i = 1:size(raw,1),
    for j = 1:size(raw,2),
        if isnumeric(raw{i,j})==1&&isnan(raw{i,j})==0,
            numStart = i-1;
            break
        end
    end
    if numStart == i-1,
        break
    end
end
data = cell(1,n);
for i = 1:n,    %loop to store cursor data
    if i <n,
        data{1,i} = num(x(i)-numStart+1:x(i+1)-numStart-1,[3:6 8]); %for all but the last recording, stores data from first line after 'plexon recording startup' string until the line before the next one 
    else
        data{1,i} = num(x(i)-numStart+1:size(num,1),[3:6 8]);   %for last entry, stores data until end of log
    end
end


