function pathToBDF=findBDFonCitadel(nameIn,suppressDialog)

% syntax pathToBDF=findBDFonCitadel(nameIn,suppressDialog)
%
% looks for a BDF-formatted file on Citadel, making a few assumptions about
% where such things live.

if nargin < 2
    suppressDialog=0;
end

% look for a cache file in the same directory as this function
[~,thisDpath,~]=which('findBDFonCitadel.m');
thisD=dir(thisDpath);
if ~isempty(cellfun(@isempty,regexp({thisD.name}, ...
        'findBDFonCitadel.cache','match','once'))==0)
    % load the path from the cache file instead
    fid=fopen(pathIn);
    strData=fscanf(fid,'%c');
    fclose(fid); clear fid
    
    nCharPerLine = diff([0 find(strData == char(10)) numel(strData)]);
    cellData = strtrim(mat2cell(strData,1,nCharPerLine));
    clear strData nCharPerLine
    
    start_ind=size(cellData,2)-TimePoints;
    cellData(start_ind:length(cellData))= ...
        cellfun(@(s) {sscanf(s,'%f',[1 inf])}, ...
        cellData(start_ind:length(cellData)));
    
    AllData=cat(1,cellData{start_ind:length(cellData)});
    return
end

% if the file name has a .mat extension, keep it.
[~,~,ext]=fileparts(nameIn);

switch ext
    case '.plx'
        nameIn=regexprep(nameIn,'\.plx','.mat');
    case '.nev'
        nameIn=regexprep(nameIn,'\.nev','.mat');
    case '.txt'
         nameIn=regexprep(nameIn,'\.txt','.mat');
    case '.mat'
%         nameIn=nameIn;
    otherwise
        nameIn=[nameIn, '.mat'];
end

CCMbank={'Chewie_8I2','Mini_7H1'};
animal=regexp(nameIn,'Chewie|Mini','match','once');

if ismac
    % automagically, assuming /Volumes is the mount point for data.
    pathToCitadelData=fullfile('/Volumes','data', ...
        CCMbank{cellfun(@isempty,regexp(CCMbank,animal))==0});
    [status,result]=unix(['find ',pathToCitadelData,' -name "',nameIn,'" -print']);
else
    % PC case.  Probably running on GOB/BumbleBeeMan, either during a
    % superBatch run, or stand-alone.  If stand-alone, slightly
    % more likely that the path of the data file in will be
    % citadel than local. If during superBatch, the network copy of the
    % BDF almost certainly won't exist yet.  Either way, assume
    % no local copies of brainReader logs exist.
    [status,result]=dos('net use');
    % if successful, will output something like this:
    %
    %     result =
    %
    %     New connections will be remembered.
    %
    %
    %     Status       Local     Remote                    Network
    %
    %     -------------------------------------------------------------------------------
    %     OK           Y:        \\citadel\limblab         Microsoft Windows Network
    %     OK           Z:        \\citadel\data            Microsoft Windows Network
    %     The command completed successfully.
    %
    % therefore, use the structure to your advantage.
    if status==0
        remoteDriveLetter=[result(regexp(result,'[A-Z](?=:\s+\\\\citadel\\data)')),':'];
    else % take a guess.
        remoteDriveLetter='Z:';
    end
    if isequal(remoteDriveLetter,':')
        error(result)
    end
    pathToCitadelData=fullfile(remoteDriveLetter, ...
        CCMbank{cellfun(@isempty,regexp(CCMbank,animal))==0});
    [status,result]=dos(['cd /d ',pathToCitadelData,' && dir *',nameIn,'* /s /b']);
end
% evaluate, based on results of system commands to find file.
if status==0
    pathToBDF=result;
    pathToBDF(regexp(pathToBDF,sprintf('\n')))='';
else
    % revert to dialog, we couldn't automagically locate the
    % BDF.
    if ~suppressDialog
        [FileName,PathName]=uigetfile('*.mat','select a bdf file');
        pathToBDF=fullfile(PathName,FileName);
    else
        error('file not found: %s\n',nameIn)
    end
end
pathToBDF(regexp(pathToBDF,sprintf('\n')))='';

% save a cache file to speed future searches
% findBDFonCitadel.cache



