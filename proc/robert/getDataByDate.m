function [CEBorPLX,remoteFolder,destFolder]=getDataByDate(animal,dateNumber,pathOverride)

if ~nargin
    animal=input('name of animal: ','s');
    fprintf(1,'Enter the date to fetch, as a number\n')
    fprintf(1,'hint: use the function today.m, or\n')
    dateNumber=input('datenum(''mm-dd-yyyy'').  Enter: ');
elseif nargin==1
    if ischar(animal) % remembered to keep the animal first
        fprintf(1,'Enter the date to fetch, as a number\n')
        fprintf(1,'hint: use the function today.m, or\n')
        dateNumber=input('datenum(''mm-dd-yyyy'').  Enter now: ');
    else             % got ass-backwards
        dateNumber=animal;
        animal=input('name of animal: ','s');
    end
end

if nargin<3
    pathOverride='';
end

destFolder=['C:\Documents and Settings\Administrator\Desktop\RobertF\data', ...
    filesep,animal];
cd(destFolder)
mkdir(datestr(dateNumber,'mm-dd-yyyy'))
destFolder=[destFolder, filesep, datestr(dateNumber,'mm-dd-yyyy')];
D=dir(destFolder);
% remoteDriveLetter='Y';    % appropriate for offline sorting machine
remoteDriveLetter='Z';      % appropriate for GOB

pathBank={[remoteDriveLetter,':\Chewie_8I2\SpikeLFP'], ...
    [remoteDriveLetter,':\Mini_7H1\', ...
    'Spikes and Local Field Potentials\MiniSpikeLFPL']};

%  [remoteDriveLetter,':\Miller\Chewie_8I2\Nick Datafiles\SD Data'], ...
% todo: add the capability to look in Chewie_8I2\Nick Datafiles\SD Data\<date>
% for the data, and to make sure the .plx files all have _LFP_ somewhere in
% the name.   regexprep(datestr(dateNumber,23),'/','-')
candidatePathInd=find(cellfun(@isempty,regexpi(pathBank,animal))==0);

% for k=1:length(candidatePathInd)
    k=1;
    if isempty(pathOverride)
        chosenPath=pathBank{candidatePathInd(k)};
    else
        chosenPath=pathOverride;
    end
    [status,result]=dos(['dir "',chosenPath,'"']);
% end
if ~status
    datestamps=regexp(result, datestr(dateNumber,'mm/dd/yyyy'));
    returns=regexp(result,sprintf('\n'));
    characterReference=sort([datestamps, returns]);
    
    for n=1:length(datestamps)
        endLine=characterReference(find(characterReference==datestamps(n))+1);
        candidateFileLineText=regexp(result(datestamps(n):endLine),' *','split');
        if ~isempty(regexp(candidateFileLineText{5},'\.[nevs23plx]','once'))
            % only copy over if not already found
            if ~nnz(cellfun(@isempty,regexp({D.name},candidateFileLineText{5}(1:end-1)))==0)
                [status1,~]=dos(['copy "',fullfile(chosenPath, ...
                    candidateFileLineText{5}(1:end-1)),'" "',destFolder,filesep,'"']);
                if ~status1
                    fprintf(1,'%s copied successfully.\n',candidateFileLineText{5}(1:end-1))
                end
            else
                fprintf(1,'%s not copied. found in \n%s\n',candidateFileLineText{5}(1:end-1),destFolder)
            end
        end
    end
    cd(destFolder)
    
    remotePathBank={fullfile([remoteDriveLetter,':'],'Chewie_8I2','BDFs', ...
        regexp(destFolder,'[0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]','match','once')), ...
        fullfile([remoteDriveLetter,':'],'Mini_7H1','bdf', ...
        regexp(destFolder,'[0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]','match','once'))};
    remoteFolder=remotePathBank{cellfun(@isempty,regexpi(remotePathBank,animal))==0};
    if ~isempty(regexp(candidateFileLineText{5},'\.plx','once'))
        CEBorPLX='plx';
    else
        CEBorPLX='ceb';
    end
end
