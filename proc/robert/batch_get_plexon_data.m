% this script operates on a folder that contains 1 or more .plx files

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
PLXfiles=FileNames(cellfun(@isempty,regexp(FileNames,'\.plx'))==0);

%% process the files
for batch_get_plx_ind=1:length(PLXfiles)
    FileName=PLXfiles{batch_get_plx_ind};
    % don't worry about pairing .nev/.ns2[3] files
%     [~,PLXname,ext,~] = fileparts(FileName);
%     if ~isempty(regexp(NEVname,'sorted','once'))
%         regexp(NEVname,'sorted','split')
%         NS2name=[NEVname,'.ns2'];
%         NS3name=[];
%     end    
    bdf=get_plexon_data(FileName);
    save(fullfile(PathName,[FileName(1:end-4),'.mat']),'out_struct')
    clear out_struct
    disp('saved out_struct')
end