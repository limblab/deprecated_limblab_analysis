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
        out_struct=get_plexon_data(FileName,'noforce','noeye','verbose');
        save(fullfile(PathName,[FileName(1:end-4),'.mat']),'out_struct')
        disp('saved out_struct')
    else
        fprintf(1,'%s already exists.\n',[regexp(FileName,'.*(?=\.plx)','match','once'),'.mat'])
        fprintf(1,'loading out_struct...\n')
        load([regexp(FileName,'.*(?=\.plx)','match','once'),'.mat'],'out_struct')
    end
    % save a cut-down version of the fp array for later inspection
    fprintf(1,'building fp array\n')
    fpAssignScript
    % puts fpchans, fp, samprate, and fptimes in the workspace 
    cutfp(batch_get_plx_ind).name=regexp(FileName,'.*(?=\.plx)','match','once');
    cutfp(batch_get_plx_ind).data=fp(:,1:500:end);
    cutfp(batch_get_plx_ind).times=fptimes(1:500:end);
    clear out_struct fp fptimes
end
if exist('cutfp','var')==1
    save(fullfile(PathName,'allFPsToPlot.mat'),'cutfp')
end