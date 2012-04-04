function VAFstruct=handControl_decoderPerformance_RDF(inputItem)

% syntax varargout=handControl_decoderPerformance_RDF(inputItem)
%
%              INPUT:
%                   inputItem - can either be left out, or 
%                               a path to the BDF-formatted
%                               .mat file, or a BDF-formatted
%                               struct from the workspace
%                               
%              OUTPUT:
%                   VAFstruct - if specified, will return a 
%                               struct with the following 
%                               fields: name, decoder age, 
%                               vaf
%

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
        else % was a partial path.  Make the same assumptions as below.
            pathToBDF=findBDFonCitadel(pathToBDF,1);
        end
        strFlag=1;
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
for n=1:1000     % assume there are fewer than 1000 files in a folder.  
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
            % should kick out here if it is a spike decoder.  
            decoderType=decoderTypeFromLogFile(nextFile);
            if strcmp(decoderType,'Spike')
                continue
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
                load(pathToDecoderMAT,'H','bestf','bestc')
                fprintf(1,'successfully loaded %s\n',pathToDecoderMAT)
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

if bdfDate < datenum('09-14-2011')
    opts=struct('version',1,'hold_time',0.1);
else
    opts=struct('version',2);
end
% doesn't hurt to calculate, but probably won't get re-saved so dead end
[bdf.path_length,bdf.time_to_target,bdf.hitRate,bdf.hitRate2]=kinematicsHandControl(bdf,opts);

% [workspaceList,~]=dbstack;
% if ~isequal(workspaceList(length(workspaceList)).file,[mfilename,'.m'])
%     % ISN'T being called from the command line
%     assignin('caller','decoder_age',bdf.meta.decoder_age)
% end





% switch variable name since the below is copied from a different batch
% function.
out_struct=bdf; clear bdf
disp('assigning static variables')
% behavior
signal='vel';
sig=out_struct.(signal);
analog_times=sig(:,1);

% assign FPs, offloaded to script so it can be used in other places.
fpAssignScript
% since we are evaluating rather than building a decoder, we want to leave
% all channels intact rather than finding & removing badChannels.  If any
% channels are bad, we want that to be revealed by the poor performance of
% the decoder
disp('static variables assigned')

numfp=size(fp,1);
numsides=1;
Use_Thresh=0; words=[]; emgsamplerate=[]; lambda=1;
disp('done')
% Input parameters to play with.
disp('assigning tunable parameters and building the decoder...')
numlags=10; 
wsz=256; 
nfeat=150;
PolynomialOrder=3; 
smoothfeats=0;
binsize=0.05;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%CROSS-FOLD TESTING%%%%%%%%%%%%%%%%%%%%%%%%%%
folds=10;
Hcell=cell(1,folds);
[Hcell{1:folds}]=deal(H);
[vaf,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~,ytnew,~,~,~,~,~] = ...
    predictionsfromfp6_inputDecoder(sig,signal,numfp,binsize,folds,numlags,numsides, ...
    samprate,fp,fptimes,analog_times,BDFname,wsz,nfeat,PolynomialOrder, ...
    Use_Thresh,Hcell,words,emgsamplerate,lambda,smoothfeats,[bestc; bestf]);


% examine vaf
fprintf(1,'file %s\n',BDFname)
fprintf(1,'decoding %s\n',signal)
fprintf(1,'numlags=%d\n',numlags)
fprintf(1,'wsz=%d\n',wsz)
fprintf(1,'nfeat=%d\n',nfeat)
fprintf(1,'PolynomialOrder=%d\n',PolynomialOrder)
fprintf(1,'smoothfeats=%d\n',smoothfeats)
fprintf(1,'binsize=%.2f\n',binsize)

vaf

formatstr='vaf mean across folds: ';
for k=1:size(vaf,2), formatstr=[formatstr, '%.4f   ']; end
formatstr=[formatstr, '\n'];

fprintf(1,formatstr,mean(vaf,1))
fprintf(1,'overall mean vaf %.4f\n',mean(vaf(:)))

VAFstruct=struct('name',BDFname,'decoder_age',bdfDate-decoderDate, ...
    'vaf',vaf);


% to get predicted position from predicted velocity, could do a simple
% integration or could try to emulate the online case by doing an
% implementation of the adaptive offset procedure.  If we're going to go
% that far, it might be smarter to just do the pseudo-online case, that's
% by far the more fair comparison.  If we're going to do it here, will want
% ytnew.


% make sure we end where we started.
cd(startingPath)