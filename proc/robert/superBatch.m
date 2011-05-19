function superBatch(animal,dateNumber)

% syntax superBatch(animal,dateNumber)
% 
% runs as function.

if ~nargin
    % have to run interactively
    CEBorPLX=getDataByDate;
elseif nargin==1
    % still have to run interactively
    getDataByDate(animal)
else
    % can run by remote, if we ever figure that out.
    getDataByDate(animal,dateNumber)
end

if strcmp(CEBorPLX,'ceb')
    batch_get_cerebus_data
    batch_buildLFP_EMGdecoder
else
    % need a batch_get_plexon_data
end