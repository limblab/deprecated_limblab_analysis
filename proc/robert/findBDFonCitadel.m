function pathToBDF=findBDFonCitadel(nameIn,suppressDialog)

% syntax pathToBDF=findBDFonCitadel(nameIn,suppressDialog)
%
% looks for a BDF-formatted file on Citadel, making a few assumptions about
% where such things live.
%
% UPDATE: 11/25/2013
%       findBDFonCitadel.m now saves a cache file, findBDFonCitadel.cache
%       each time a BDF file is successfully found.  This is a text file
%       with one path per line.  Files that have been found previously
%       and are stored in the cache will have their path returned from
%       the file instead of re-searching.  This should speed up the finding
%       process dramatically for such repeat searches.
%
%       Note: NEVER, EVER commit findBDFonCitadel.cache to any SVN
%       repository.  The function will create it automatically in the local
%       folder where findBDFonCitadel.m lives.  The path to citadel in
%       general (the drive letter in particular) will change from machine
%       to machine, so it is a LARGE ERROR to move this cache file around.
%       Just let each machine create its own file in its own good time.
% UPDATE: MRS 5/10/2014
%       Cache was returning wrong file path, tried automating a rudimentary 
%       fix.

% todo: if the cache file has grown too big, lop off the oldest 
% saved results

if nargin < 2
    suppressDialog=0;
end

% look for a cache file in the same directory as this function
[thisDpath,~,~]=fileparts(which('findBDFonCitadel.m'));
thisD=dir(thisDpath);
if nnz(cellfun(@isempty,regexp({thisD.name}, ...
        'findBDFonCitadel.cache','match','once'))==0)
    % load the path from the cache file instead
    fid=fopen(fullfile(thisDpath,'findBDFonCitadel.cache'));
    strData=fscanf(fid,'%c');
    fclose(fid); clear fid
    
    nCharPerLine = diff([0 find(strData == char(10)) numel(strData)]);
    cellData = strtrim(mat2cell(strData,1,nCharPerLine));
    clear strData nCharPerLine

    pathToBDFind=find(cellfun(@isempty,regexp(cellData,nameIn))==0);
    if ~isempty(pathToBDFind)
        pathToBDF=cellData{pathToBDFind};
        pathToBDF(regexp(pathToBDF,sprintf('\n')))='';
        % MRS added 5/10/2014 check on cache path, drive letter was
        % incorrect, automating a fix
        if exist(pathToBDF,'file') == 0
            if strcmp(pathToBDF(1),'Y') == 1
                % try to change drive letter to other common possibility
                pathToBDF(1) = 'Z';
            else
                pathToBDF(1) = 'Y';
            end
            % If this doesn't fix the problem, then return
            if exist(pathToBDF,'file') == 2
            % returning here will preclude repeats appearing in the cache file.
            return
            end
        end
    end
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

CCMbank={'Chewie_8I2','Mini_7H1','Jaco_8I1'};
animal=regexp(nameIn,'Chewie|Mini|Jaco','match','once');

if ismac
    % automagically, assuming /Volumes is the mount point for data.
    pathToCitadelData=fullfile('/Volumes','data', ...
        CCMbank{cellfun(@isempty,regexp(CCMbank,animal))==0});
    [status,result]=unix(['find ',pathToCitadelData,' -name "',nameIn,'" -print']);
else
    remoteDriveLetter=[citadelDriveLetter,'Z:'];
    if isequal(remoteDriveLetter,':') || isempty(remoteDriveLetter)
        error('problem with citadelDriveLetter.m')
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
fid=fopen(fullfile(thisDpath,'findBDFonCitadel.cache'),'a');
fprintf(fid,'%s\n',pathToBDF);
fclose(fid);


