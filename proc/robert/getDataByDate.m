function [CEBorPLX,remoteFolder,destFolder]=getDataByDate(animal,dateNumber)

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

destFolder=['C:\Documents and Settings\Administrator\Desktop\RobertF\data', ...
    filesep,animal];
cd(destFolder)
mkdir(datestr(dateNumber,'mm-dd-yyyy'))
destFolder=[destFolder, filesep, datestr(dateNumber,'mm-dd-yyyy')];

% remoteDriveLetter='Y';    % appropriate for offline sorting machine
remoteDriveLetter='Z';      % appropriate for GOB

pathBank={[remoteDriveLetter,':\Miller\Chewie_8I2\SpikeLFP'], ...
    [remoteDriveLetter,':\Miller\Mini_7H1\', ...
    'Spikes and Local Field Potentials\MiniSpikeLFPL']};

chosenPath=pathBank{cellfun(@isempty,regexpi(pathBank,animal))==0};

[status,result]=dos(['dir "',chosenPath,'"']);

if ~status
    datestamps=regexp(result, datestr(dateNumber,'mm/dd/yyyy'));
    returns=regexp(result,sprintf('\n'));
    characterReference=sort([datestamps, returns]);
    
    for n=1:length(datestamps)
        endLine=characterReference(find(characterReference==datestamps(n))+1);
        candidateFileLineText=regexp(result(datestamps(n):endLine),' *','split');
        if ~isempty(regexp(candidateFileLineText{5},'\.[nevs23plx]','once'))
            [status1,~]=dos(['copy "',fullfile(chosenPath, ...
                candidateFileLineText{5}(1:end-1)),'" "',destFolder,filesep,'"']);
            if ~status1
                fprintf(1,'%s copied successfully.\n',candidateFileLineText{5}(1:end-1))
            end
        end
    end
    cd(destFolder)
    
    remotePathBank={fullfile([remoteDriveLetter,':'],'Miller','Chewie_8I2','BDFs', ...
        regexp(destFolder,'[0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]','match','once')), ...
        fullfile([remoteDriveLetter,':'],'Miller','Mini_7H1','bdf', ...
        regexp(destFolder,'[0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]','match','once'))};
    remoteFolder=remotePathBank{cellfun(@isempty,regexpi(remotePathBank,animal))==0};
    if ~isempty(regexp(candidateFileLineText{5},'\.plx','once'))
        CEBorPLX='plx';
    else
        CEBorPLX='ceb';
    end
end
