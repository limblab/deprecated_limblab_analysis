function BDFlist=findBDF_withControl(animal,dayIn,controlType)

% syntax BDFlist=findBDF_withControl(animal,dayIn,controlType)
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

% switching to citadel-based...
if 0
    % currently implementing the assumption that citadel is the location of
    % the most recent information re: kinStruct.mat files
    switch lower(machineName)
        case 'gob'
            kinStructPath=fullfile('C:\Documents and Settings\Administrator\Desktop\RobertF\data', ...
                animal,dayIn,'kinStruct.mat');
        case 'bumblebeeman'
            kinStructPath=fullfile('E:\personnel\RobertF\monkey_analyzed', ...
                animal,dayIn,'kinStruct.mat');
        otherwise
            error('can not determine path to data files on %s',machineName)
    end
end

pathBank={'Chewie_8I2','Mini_7H1'};
ff={'Filter files','FilterFiles'};
animus=cellfun(@isempty,regexp(pathBank,animal))==0;
kinStructPath=fullfile('Z:',pathBank{animus},ff{animus},dayIn,'kinStruct.mat');
    
if exist(kinStructPath,'file')==2
    load(kinStructPath)
    BDFlist={kinStruct(cellfun(@isempty,regexp({kinStruct.control},controlType))==0).name};
else
    [pathStrBAD,filenameBAD,~,~]=FileParts(kinStructPath);
    error('findBDF_withControl:nokinStruct','file not found: %s\nlooked in %s', ...
        filenameBAD,pathStrBAD)
end

return
% backup
[~,nearestBCfile]=decoderPathFromBDF(out_struct);
% something like this...
pathToBR=regexprep(nearestBCfile,'filter files','brainreader logs/online')
bdf.meta.control=decoderTypeFromLogFile(pathToBR);
