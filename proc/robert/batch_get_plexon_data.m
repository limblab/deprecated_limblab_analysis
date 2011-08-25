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
    out_struct=get_plexon_data(FileName);
    save(fullfile(PathName,[FileName(1:end-4),'.mat']),'out_struct')
    % save a cut-down version of the fp array for later inspection
    fpAssignScript
    % puts fpchans, fp, samprate, and fptimes in the workspace 
    [~,nameNoExt,~,~]=fileparts(FileName);
    cutfp(batch_get_plx_ind).name=nameNoExt;
    cutfp(batch_get_plx_ind).data=fp(:,1:500:end);
    cutfp(batch_get_plx_ind).times=fptimes(1:500:end);
    clear out_struct fp fptimes
    disp('saved out_struct')
end
save(fullfile(PathName,'allFPsToPlot.mat'),'cutfp')