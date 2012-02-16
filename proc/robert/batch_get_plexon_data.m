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
MATfiles=FileNames(cellfun(@isempty,regexp(FileNames,'_Spike_LFP.*(?<!poly.*|-spike.*)\.mat'))==0);
allFiles=[MATfiles, PLXfiles];
% if 'no extension' version is necessary, use:
% allFiles=regexp([MATfiles, PLXfiles],'.*(?=\.plx|\.mat)','match','once');
%% process the files
% if length(PLXfiles)==0, then allFPsToPlot will never be created.
for batch_get_plx_ind=1:length(allFiles)
    FileName=allFiles{batch_get_plx_ind}; 
    % the following is a strange if statement, but it comes of wanting the
    % ability to piece together directories of data, some of which are .plx
    % and some of which are .mat, and the desire to have an
    % FPsallToPlot.mat that represents them all.  Therefore, regardless of
    % whether it was originally in PLXfiles or MATfiles, check it against
    % MATfiles (with no extension).  everything in MATfiles will obviously
    % match, but that's okay; we want it to get sent to the else.
    % Everything that's in PLX files AND in MATfiles, will also match, and
    % get sent to the else.  only .plx files that don't match MATfiles
    % will get processed in the if.
    if isempty(intersect(regexp(FileName,'.*(?=\.plx|\.mat)','match','once'), ...
            regexp(MATfiles,'.*(?=\.mat)','match','once')))
        out_struct=get_plexon_data(FileName,'noforce','noeye','verbose');
        save(fullfile(PathName,[FileName(1:end-4),'.mat']),'out_struct')
        % the following line, sadly, does not work.  MATLAB gives a warning
        % about insufficient file permissions, and goes on without doing
        % anything.
%         delete(FileName)
        disp('saved out_struct')
    else
        fprintf(1,'%s already exists.\n',[regexp(FileName,'.*(?=\.plx|\.mat)','match','once'),'.mat'])
        fprintf(1,'loading out_struct...\n')
        load([regexp(FileName,'.*(?=\.plx|\.mat)','match','once'),'.mat'],'out_struct')
    end
    % save a cut-down version of the fp array for later inspection
    fprintf(1,'building fp array\n')
    fpAssignScript
    % puts fpchans, fp, samprate, and fptimes in the workspace 
    cutfp(batch_get_plx_ind).name=regexp(FileName,'.*(?=\.plx|\.mat)','match','once');
    cutfp(batch_get_plx_ind).data=fp(:,1:500:end);
    cutfp(batch_get_plx_ind).times=fptimes(1:500:end);
    clear out_struct fp fptimes
end
if exist('cutfp','var')==1
    % since the indexed item was changed to allFiles from PLXfiles, it is
    % necessary to account for the possibilities of repeats in cutfp, as
    % the script will cycle through all the .plx files, and all the .mat
    % files with a bdf struct, and create a cutfp entry for each of them.
    % Duplicates are unwise, not useful, and cause problems later on down
    % the line, so remove them here.
    [~,uniqueInd,~]=unique({cutfp.name});
    cutfp=cutfp(uniqueInd);
    save(fullfile(PathName,'allFPsToPlot.mat'),'cutfp')
end