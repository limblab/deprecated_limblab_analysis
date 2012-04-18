function BDFlist=findBDF_withControl(animal,dayIn,controlType)

% syntax BDFlist=findBDF_withControl(dayIn,controlType)
%
% takes a day, finds the kinStruct, and identifies all the
% files of the given control type that were included.
% 
%           INPUTS:
%                   animal      - 'Chewie' or 'Mini'
%                   dayIn       - format mm-dd-yyyy
%                   controlType - 'LFP', 'Spike', or 'hand'

% TODO: backup. In the case of no kinStruct, should load all available BDFs,
% do tiresome calculation(?), figure out controlType.  
% see code below the return statement

% Going to need to do on GOB because, 1) the featMat-generating code 
% needs to run on GOB, and 2) the kinStruct's on GOB are the freshest 
% (due to addToKinStruct.m modifying the local copy of kinStruct.m but 
% not necessarily the network copy).
kinStructPath=fullfile('C:\Documents and Settings\Administrator\Desktop\RobertF\data', ...
    animal,dayIn,'kinStruct.mat');
if exist(kinStructPath,'file')==2
    load(kinStructPath)
    BDFlist={kinStruct(cellfun(@isempty,regexp({kinStruct.control},controlType))==0).name};
else
    [pathStrBAD,filenameBAD,~,~]=FileParts(kinStructPath);
    error('file not found: %s\nlooked in %s',filenameBAD,pathStrBAD)
end

return
% backup
[~,nearestBCfile]=decoderPathFromBDF(out_struct);
% something like this...
pathToBR=regexprep(nearestBCfile,'filter files','brainreader logs/online')
bdf.meta.control=decoderTypeFromLogFile(pathToBR);
