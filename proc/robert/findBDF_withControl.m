function [BDFlist,datenames]=findBDF_withControl(animal,dayIn,controlType)

% syntax [BDFlist,datenames]=findBDF_withControl(animal,dayIn,controlType);
%
% takes a day, finds the kinStruct, and identifies all the
% files of the given control type that were included.
% 
%           INPUTS:
%                   animal      - 'Chewie' or 'Mini'
%                   dayIn       - format mm-dd-yyyy
%                   controlType - 'LFP', 'Spike', or 'hand'
% 
%           OUTPUTS:

% TODO: backup. In the case of no kinStruct, should load all available BDFs,
% do tiresome calculation(?), figure out controlType.  
% see code below the return statement

% switching to citadel-based.  Commented 06/20/2012 following deactivation
% several months before.  Ready to delete soon...
% % currently implementing the assumption that citadel is the location of
% % the most recent information re: kinStruct.mat files
% switch lower(machineName)
%     case 'gob'
%         kinStructPath=fullfile('C:\Documents and Settings\Administrator\Desktop\RobertF\data', ...
%             animal,dayIn,'kinStruct.mat');
%     case 'bumblebeeman'
%         kinStructPath=fullfile('E:\personnel\RobertF\monkey_analyzed', ...
%             animal,dayIn,'kinStruct.mat');
%     otherwise
%         error('can not determine path to data files on %s',machineName)
% end

pathBank={'Chewie_8I2','Mini_7H1'};
ff={'Filter files','FilterFiles'};
animus=cellfun(@isempty,regexp(pathBank,animal))==0;
kinStructPath=fullfile('Z:',pathBank{animus},ff{animus},dayIn,'kinStruct.mat');
    
if exist(kinStructPath,'file')==2
    load(kinStructPath)
    BDFlist={kinStruct(cellfun(@isempty,regexp({kinStruct.control},controlType))==0).name};
    if find(animus)==2 && nargin>1
        % if animal is Mini, and if recording is before mid-February(?), this
        % will be important: give a datename list that corresponds to
        % BDFlist.  First, find date in kinStructPath.
        datestring=regexprep(regexp(kinStructPath,'[0-9]{2}-[0-9]{2}-[0-9]{4}','match','once'),'-','');
        for m=1:length(kinStruct)
            filenames{m}=kinStruct(m).name;
            datenames{m}=['Mini_Spike_LFPL_',datestring,sprintf('%03d',m),'.mat'];
        end
    end
else
    [pathStrBAD,filenameBAD,~,~]=FileParts(kinStructPath);
    error('findBDF_withControl:nokinStruct','file not found: %s\nlooked in %s', ...
        filenameBAD,pathStrBAD)
end
if find(animus)==2 && nargin>1
    datenames(ismember(filenames,BDFlist)==0)=[];
else
    datenames=cell(size(BDFlist));
end

% backup
% [~,nearestBCfile]=decoderPathFromBDF(out_struct);
% something like this...
% pathToBR=regexprep(nearestBCfile,'filter files','brainreader logs/online')
% bdf.meta.control=decoderTypeFromLogFile(pathToBR);
