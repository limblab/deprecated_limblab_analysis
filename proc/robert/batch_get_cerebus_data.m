% this script operates on a folder that contains 1 or more .nev/.ns3
% file pairs.

%% folder/file info
PathName = uigetdir('C:\Documents and Settings\Administrator\Desktop\RobertF\data\','select folder with data files');
% PathName=pwd;
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
    % if .nev and .ns2/.ns3 differ only by 'sorted' in the .nev filename, they
    % should be considered as still belonging together.  Unfortunately,
    % get_cerebus_data does not understand this, so must alter filenames.
    [~,NEVname,ext,~] = fileparts(FileName);
    if ~isempty(regexp(NEVname,'sorted','once'))
        regexp(NEVname,'sorted','split')
        NS2name=[NEVname,'.ns2'];
        NS3name=[];
    end
    
    bdfEMGonly=EMGpreview_cerebus(FileName);
    save(fullfile(PathName,[FileName(1:end-4),'EMGonly.mat']),'bdfEMGonly','FileName')
    clear bdfEMGonly
    disp('saved EMG preview')
    
    bdf=get_cerebus_data(FileName,1);
    save(fullfile(PathName,[FileName(1:end-4),'.mat']),'bdf','FileName','PathName')
    clear bdf
    disp('saved bdf')
end