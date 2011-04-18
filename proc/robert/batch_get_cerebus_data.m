% this script operates on a folder that contains 1 or more .nev/.ns3
% file pairs.

%% folder/file info
PathName = uigetdir('C:\Documents and Settings\Administrator\Desktop\RobertF\data\','select folder with data files');
if sum(double(PathName))==0 || exist(PathName,'dir')~=7
    disp('folder not valid.  aborting...')
    return
end
cd(PathName)
Files=dir(PathName);
Files(1:2)=[];
FileNames={Files.name};
NEVfiles=FileNames(cellfun(@isempty,regexp(FileNames,'\.nev'))==0);

%% process the files
for n=1:length(NEVfiles)
    FileName=NEVfiles{n};
    
    bdfEMGonly=EMGpreview_cerebus(FileName);
    save(fullfile(PathName,[FileName(1:end-4),'EMGonly.mat']),'bdfEMGonly','FileName')
    clear bdfEMGonly
    disp('saved EMG preview')
    
    bdf=get_cerebus_data(FileName,1);
    save(fullfile(PathName,[FileName(1:end-4),'.mat']))
    clear bdf
    disp('saved bdf')
end