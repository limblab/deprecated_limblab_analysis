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
MATfiles=FileNames(cellfun(@isempty,regexp(FileNames,'_Spike_LFP.*(?<!poly.*)\.mat'))==0);

%% process the files
for batch_get_plx_ind=1:length(PLXfiles)
    FileName=PLXfiles{batch_get_plx_ind}; 
    if isempty(intersect(regexp(FileName,'.*(?=\.plx)','match','once'), ...
            regexp(MATfiles,'.*(?=\.mat)','match','once')))
        out_struct_kinonly=get_plexon_data_eventsOnly(FileName);
        save(fullfile(PathName,[FileName(1:end-4),'.mat']),'out_struct_kinonly')
        disp('saved out_struct')
    else
        fprintf(1,'%s already exists.\n',[regexp(FileName,'.*(?=\.plx)','match','once'),'.mat'])
        fprintf(1,'loading out_struct...\n')
        load([regexp(FileName,'.*(?=\.plx)','match','once'),'.mat'],'out_struct')
    end
    clear out_struct fp fptimes
end