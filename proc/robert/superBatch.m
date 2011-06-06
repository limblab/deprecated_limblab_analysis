function superBatch(animal,dateNumber)

% syntax superBatch(animal,dateNumber)
% 
% runs as function.

if ~nargin
    % have to run interactively
    [CEBorPLX,remoteFolder,~]=getDataByDate;
elseif nargin==1
    % still have to run interactively
    [CEBorPLX,remoteFolder,~]=getDataByDate(animal);
else
    % can run by remote, if we ever figure that out.
    [CEBorPLX,remoteFolder,~]=getDataByDate(animal,dateNumber);
end

PathName=pwd;
if strcmp(CEBorPLX,'ceb')
    batch_get_cerebus_data % runs as script.  uses PathName
    % put .mat files on the data server in an appropriate folder
    % put EMGonly files 
    batch_buildLFP_EMGdecoder
else
    % need a batch_get_plexon_data
end
% copy the newly deposited files into appropriate location on citadel.
D=dir(PathName);
copyfile([regexp(D(find(cellfun(@isempty,regexp({D.name},'[A-Za-z]+(?=[0-9]+\.mat)'))==0,1,'first')).name, ...
    '[A-Za-z]+(?=[0-9]+\.mat)','match','once'),'*.mat'],remoteFolder)
copyfile('LFP_EMGdecoder_results.txt',remoteFolder)

% remove the local copies, except for the EMGonly files