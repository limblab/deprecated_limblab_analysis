% this script operates on a folder that contains 1 or more .nev/.ns3
% file pairs.

%% folder/file info
if exist('PathName','var')~=1
    PathName = uigetdir('C:\Documents and Settings\Administrator\Desktop\RobertF\data\','select folder with data files');
end
if sum(double(PathName))==0 || exist(PathName,'dir')~=7
    disp('folder not valid.  aborting...')
    return
end
cd(PathName)
Files=dir(PathName);
Files(1:2)=[];
FileNames={Files.name};
NEVfiles=FileNames(cellfun(@isempty,regexp(FileNames,'\.nev'))==0);
MATfiles=FileNames(cellfun(@isempty,regexp(FileNames,'EFP.*(?<!poly.*)\.mat'))==0);

%% process the files
for n=1:length(NEVfiles)
    FileName=NEVfiles{n};
    if isempty(intersect(regexp(FileName,'.*(?=\.nev)','match','once'), ...
            regexp(MATfiles,'.*(?=\.mat)','match','once')))
        % if .nev and .ns2/.ns3 differ only by 'sorted' in the .nev filename, they
        % should be considered as still belonging together.  Unfortunately,
        % get_cerebus_data does not understand this, so must alter filenames.
        [~,NEVname,ext,~] = fileparts(FileName);
        if ~isempty(regexp(NEVname,'sorted','once'))
            regexp(NEVname,'sorted','split')
            NS2name=[NEVname,'.ns2'];
            NS3name=[];
        end
        %     bdfEMGonly=EMGpreview_cerebus(FileName);
        %     save(fullfile(PathName,[FileName(1:end-4),'EMGonly.mat']),'bdfEMGonly','FileName')
        %     clear bdfEMGonly
        %     disp('saved EMG preview')
        fprintf(1,'loading %s...\n',NEVname)
        out_struct=get_cerebus_data(FileName,1);
        save(fullfile(PathName,[FileName(1:end-4),'.mat']),'out_struct','FileName','PathName')
        clear out_struct
        disp('saved out_struct')
    else
        fprintf(1,'%s already exists.  Skipping...\n',[regexp(FileName,'.*(?=\.nev)','match','once'),'.mat'])
    end
end