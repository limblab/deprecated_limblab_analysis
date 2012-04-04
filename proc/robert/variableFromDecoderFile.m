function variableFromDecoderFile(varargin)

% syntax EXvariable=variableFromDecoderFile(inputFile,decoderType,getvar);
%
% inputFile can be a full path or just a name.  If just a name, will want
% to search on citadel/data share.  Make sure it's mounted ahead of time.
%
%   getvar is the name of a variable(s) to retrieve.  can pass 'all', to
%   retrieve all variables.

inputFile=varargin{1};
decoderType=varargin{2};

if exist(inputFile,'file')==2
    filename=inputFile;
else
    % strip out a possible extension
    [~,filename,~]=fileparts(inputFile);
    
    CCMbank={'Chewie_8I2','Mini_7H1'};
    animal=regexp(filename,'Chewie|Mini','match','once');
    switch animal
        case 'Chewie'
            ff='Filter files';
        case 'Mini'
            ff='FilterFiles';
    end
    switch lower(decoderType)
        case 'lfp'
            decodeStr='poly';
        case 'spike'
            decodeStr='-spike';
    end
    if ismac
        % automagically, assuming /Volumes is the mount point for data.
        pathToCitadelData=fullfile('/Volumes','data', ...
            CCMbank{cellfun(@isempty,regexp(CCMbank,animal))==0},ff);
        [status,result]=unix(['find "',pathToCitadelData,'" -name *',filename,...
            decodeStr,'* -print']);
    else
        % PC case.  assume GOB.  Drive letter is Z:
        remoteDriveLetter='Z:';
        pathToCitadelData=fullfile(remoteDriveLetter, ...
            CCMbank{cellfun(@isempty,regexp(CCMbank,animal))==0},ff);
        [status,result]=dos(['cd /d ',pathToCitadelData,' && dir *',filename,...
            decodeStr,'* /s /b']);
    end
    if status
        error(['system call error: ',result])
    else
        result(regexp(result,sprintf('\n')))=[];
    end
    if status==0 && exist(result,'file')==2
        filename=result;
    end
end

if strcmp(varargin{3},'all')
    S=load(filename);
    names=fieldnames(S);
    for n=1:length(names)
        assignin('caller',names{n},S.(names{n}))
    end
else
    for n=1:(nargin-2)
        load(filename,varargin{n+2})
        assignin('caller',varargin{n+2},eval(varargin{n+2}))
    end
end

