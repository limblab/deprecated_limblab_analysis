function [CEBorPLX,remoteFolder,destFolder]=getDataByDateMRS(animal,dateNumber)

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

destFolder=['C:\Documents and Settings\Administrator\Desktop\ChewieData\Spike LFP Pos Decoder', ...
    filesep,animal];
cd(destFolder)
mkdir(datestr(dateNumber,'mm-dd-yyyy'))
destFolder=[destFolder, filesep, datestr(dateNumber,'mm-dd-yyyy')];
D=dir(destFolder);
% remoteDriveLetter='Y';    % appropriate for offline sorting machine
%remoteDriveLetter='Z';     % appropriate for GOB
remoteDriveLetter='C';

pathBank={%[remoteDriveLetter,':\Miller\Chewie_8I2\SpikeLFP'], ...
    %[remoteDriveLetter,':\Miller\Mini_7H1\', ...
    %'Spikes and Local Field Potentials\MiniSpikeLFPL']};
    [remoteDriveLetter,':\Documents and Settings\Administrator\Desktop\',...
    'ChewieData\Spike LFP Pos Decoder'],...
    [remoteDriveLetter,':\Documents and Settings\Administrator\Desktop\',...
    'ChewieData\Spike LFP Pos Decoder']};
    
%  [remoteDriveLetter,':\Miller\Chewie_8I2\Nick Datafiles\SD Data'], ...
% todo: add the capability to look in Chewie_8I2\Nick Datafiles\SD Data\<date>
% for the data, and to make sure the .plx files all have _LFP_ somewhere in
% the name.   regexprep(datestr(dateNumber,23),'/','-')
candidatePathInd=find(cellfun(@isempty,regexpi(pathBank,animal))==0);

% for k=1:length(candidatePathInd)
    k=1;
    chosenPath=pathBank{candidatePathInd(k)};
    [status,result]=dos(['dir "',chosenPath,'"']);
% end
if ~status
    datestamps=regexp(result,'[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]');
    returns=regexp(result,sprintf('\n'));
    characterReference=sort([datestamps, returns]);
    q = 5;
    for n=1:length(datestamps)
        endLine=characterReference(find(characterReference==datestamps(n))+1);
        candidateFileLineText=regexp(result(datestamps(n):endLine),' *','split');
            if ~isempty(regexp(candidateFileLineText{q},'\.[nevs23plx]','once'))
                [OpenedFileName, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~,DateTime]...
                = plx_information(fullfile(chosenPath,candidateFileLineText{q}(1:end-1)))
                if datenum(DateTime(1:10))==datenum(dateNumber)
                    % only copy over if not already found
                    if ~nnz(cellfun(@isempty,regexp({D.name},candidateFileLineText{q}(1:end-1)))==0)
                        [status1,~]=dos(['copy "',fullfile(chosenPath, ...
                            candidateFileLineText{q}(1:end-1)),'" "',destFolder,filesep,'"']);
                        if ~status1
                            fprintf(1,'%s copied successfully.\n',candidateFileLineText{q}(1:end-1))
                        end
                    else
                        fprintf(1,'%s not copied. found in \n%s\n',candidateFileLineText{q}(1:end-1),destFolder)
                    end
                end
                
                if ~isempty(regexp(candidateFileLineText{q},'\.plx','once'))
                    CEBorPLX='plx';
                else
                    CEBorPLX='ceb';
                end
            end
        end
    end
    cd(destFolder)
    
    remotePathBank={fullfile([remoteDriveLetter,':'],'Miller','Chewie_8I2','BDFs', ...
        regexp(destFolder,'[0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]','match','once')), ...
        fullfile([remoteDriveLetter,':'],'Miller','Mini_7H1','bdf', ...
        regexp(destFolder,'[0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]','match','once'))};
    remoteFolder=remotePathBank{cellfun(@isempty,regexpi(remotePathBank,animal))==0};
end
