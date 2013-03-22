function [pathToDecoderMAT,fileChosenPath]=decoderPathFromBDF(inputItem)

% syntax [pathToDecoderMAT,fileChosenPath]=decoderPathFromBDF(inputItem)
%
%              INPUT:
%                   inputItem - a path to the BDF-formatted
%                               .mat file, or a BDF-formatted
%                               struct from the workspace.  Could be 
%                               a hand-control file.
%              OUTPUT:
%                   pathToDecoderMAT - the path to the decoder used for
%                                      any brain-control file on that same
%                                      day.
%                   fileChosen       - path the file that ended up being
%                                      identified as the closest BC file.
%
% this version takes a path name or a bdf (from which it will deduce a path
% name), then (if inputDecoder is not supplied, it will find the nearest 
% file chronologically that was under brain control (currently
% only works with LFP control), and load the decoder used for that brain
% control session.  It will then re-evaluate the HC data contained in the bdf
% using the predictions code, passing in the existing H matrix and bestc, 
% bestf variables.
%
% THIS FILE MAKES NO DETERMINATION WHETHER THE INPUT BDF WAS HAND CONTROL
% OR BRAIN CONTROL.  Some hand control files have BR logs that were
% recorded for testing, or offline comparison, or another reason.  If the
% file that is input has a corresponding BR log, that will be used.  Only
% if the file that is input does not have a BR log will it go looking for
% nearby files.
%
% modified 5/26/2012 - was not setting the strFlag properly.  TODO: use a
% function that checks an argument to see if it is a bdf struct or rather a
% path (full or just a name) to a bdf-struct.  Regardless of which, it
% returns the bdf-struct.  If a partial path is given, then that will guide
% the choice of whether a local copy of bdf-struct or a remote copy is the
% one loaded.  

startingPath=pwd;
% VAFstruct=struct('name','','decoder_age',[],'vaf',[]);

if ~nargin                      % dialog for bdf
    [FileName,PathName]=uigetfile('*.mat','select a bdf file');
    pathToBDF=fullfile(PathName,FileName);
    strFlag=1;
else
    if ischar(inputItem) % path to bdf is input
        pathToBDF=inputItem;
        if exist(pathToBDF,'file')==2
            load(pathToBDF)
            if exist('bdf','var')~=1
                if exist('out_struct','var')~=1
                    error(['neither ''bdf'' or ''out_struct'' was found.\n', ...
                        'if %s\n contains a properly formatted bdf structure, \n', ...
                        'load it manually, and pass it as an argument.\n'],pathToBDF)
                else
                    bdf=out_struct;
                    clear out_struct
                    varName='out_struct';
                end
            else
                varName='bdf';
            end     % if we make it to this point we know the variable bdf exists.
            strFlag=0;
        else % was a partial path.  Make the same assumptions as below.
            pathToBDF=findBDFonCitadel(pathToBDF,1);
            strFlag=1;
        end
    else                % bdf has been passed in.
        bdf=inputItem;
        clear inputItem
        varName=inputname(1);
        pathToBDF=findBDFonCitadel(bdf.meta.filename);
        strFlag=0;
    end
end

% strip out trailing CR, if present.
pathToBDF(regexp(pathToBDF,sprintf('\n')))='';

if strFlag
    load(pathToBDF)
    if exist('bdf','var')~=1
        if exist('out_struct','var')~=1
            error(['neither ''bdf'' or ''out_struct'' was found.\n', ...
                'if %s\n contains a properly formatted bdf structure, \n', ...
                'load it manually, then pass it as an argument.\n'])
        else
            bdf=out_struct;
            clear out_struct
            varName='out_struct';
        end
    else
        varName='bdf';
    end     % if we make it to this point we know the variable bdf exists.
end
    
[BDFpathStr,BDFname,~]=fileparts(pathToBDF);
if ispc
    fsep=[filesep filesep]; % because regexp chokes on 1 backslash
else
    fsep=filesep;
end

% get the path to the next-higher-number file that's in that same folder.
% Identify the sequence of numbers at the end of the file name.  Check 
% if there is a BR log file.
decoderDate=NaN;
% assume there are fewer than 1000 files in a folder.  Use n=0 to check the
% current file, in case a brain-control file is handed in.
for n=0:900
    fileToCheck{1}=['*',num2str(str2double(regexp(BDFname,'(?<=.*_)[0-9]+','match','once'))+n),'*'];
    % if going up doesn't work, try going down.
    fileToCheck{2}=['*',num2str(str2double(regexp(BDFname,'(?<=.*_)[0-9]+','match','once'))-n),'*'];
    % as n increases, the recording number should oscillate around the
    % original file's number until it hits a number where there's a 
    % BR log file, or until n reaches 1000.
    pathToBR=regexprep(BDFpathStr,regexpi(BDFpathStr, ...
        ['(?<=',fsep,')','bdfs*(?=',fsep,')'],'match','once'), ...
        ['BrainReader logs',fsep,'online']);
    % just in case
    pathToBR(regexp(pathToBR,sprintf('\n')))='';

    for k=1:2
        if ismac
            [status,nextFile]=unix(['find "',pathToBR,'" -name "', ...
                fileToCheck{k},'" -print']);
        else % PC case.  already know pathToBDF
            [status,nextFile]=dos(['cd /d ',pathToBR,' && dir ', ...
                fileToCheck{k},' /s /b']);
        end
        nextFile(regexp(nextFile,sprintf('\n')))='';
        if status==0 && exist(nextFile,'file')==2
            if nargout > 1
                fileChosenPath=nextFile;
            end
            % should kick out here if it is a spike decoder.  WHY????
            decoderType=decoderTypeFromLogFile(nextFile);
            if strcmp(decoderType,'Spike')
%                 continue
            end
            fid=fopen(nextFile);
            % should be the first line.
            modelLine=fgetl(fid);
            if ~isempty(regexp(modelLine,'Predictions made.*with model:', 'once'))
                decoderFile=regexp(modelLine,'/','split');
                decoderFile=decoderFile(end-1:end);
                decoderFile{2}(end)=[];
            else
                error('%s is not a valid BrainReader log file.\n',nextFile)
            end
            fclose(fid);
            
            animal=regexp(pathToBDF,'Chewie|Mini','match','once');
            switch animal
                case 'Chewie'
                    ff='Filter files';
                case 'Mini'
                    ff='FilterFiles';
            end
            pathToDecoderMAT=regexprep(BDFpathStr,regexpi(BDFpathStr, ...
                ['(?<=',fsep,')','bdfs*(?=',fsep,')'],'match','once'),ff);
            
            pathToDecoderMAT=fullfile(regexprep(pathToDecoderMAT, ...
                '[0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]',decoderFile{1}),decoderFile{2});
            
            if exist(pathToDecoderMAT,'file')==2
%                 load(pathToDecoderMAT,'H','bestf','bestc')
%                 fprintf(1,'successfully loaded %s\n',pathToDecoderMAT)
                decoderDate=decoderDateFromLogFile(nextFile,1);
                break
            end
        end
    end
    if ~isnan(decoderDate)
        break
    end
end
if n == 1000
    error('file not found: %s\n',BDFpathStr)
end

bdfDate=datenum(regexp(bdf.meta.datetime,'\s*[0-9]+/\s*[0-9]+/[0-9]+','match','once'));

% [workspaceList,~]=dbstack;
% if ~isequal(workspaceList(length(workspaceList)).file,[mfilename,'.m'])
%     % ISN'T being called from the command line
%     assignin('caller','decoder_age',bdf.meta.decoder_age)
% end

% make sure we end where we started.
cd(startingPath)