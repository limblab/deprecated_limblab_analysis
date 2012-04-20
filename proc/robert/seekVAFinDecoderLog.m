function VAF_all=seekVAFinDecoderLog(nameIn)

[pathNameIn,filenameIn,~]=FileParts(nameIn);
if isempty(pathNameIn)
    pathNameIn=findBDFonCitadel(filenameIn);
    animal=regexp(filenameIn,'Chewie|Mini','match','once');
    if strcmp(animal,'Chewie')
        ff='Filter files';
    else
        ff='FilterFiles';
    end
    [pathToDecoderLog,~,~]=FileParts(regexprep(pathNameIn,'BDFs|bdf',ff));
else
    pathToDecoderLog=pathnameIn;
end
    
%     dateIn=regexp(filenameIn,'[0-9]{11}','match','once');
%     if isempty(dateIn)
%         dateIn=regexp(filenameIn,'[0-9]{3}','match','once');
%     end

logText=evalc(['dbtype(''',fullfile(pathToDecoderLog,'decoderOutput.txt'),''')']);
VAF_all=struct('filename',filenameIn,'type','','vaf',[]);

% dayLine=['[0-9]+(?= *file (Chewie|Mini)_Spike_LF(P|PL)_',nameIn,')'];
dayLine=['[0-9]+(?= *file ',filenameIn,')'];

% if length(dayLine) > 3, then analysis is repeated, and we'll have to be 
% smarter (or give up).
dayLineNum=str2num(char(regexp(logText,dayLine,'match')));
for n=1:length(dayLineNum)
    vaf=[];
    lineNumSeek=dayLineNum(n)+1;
    while lineNumSeek<(dayLineNum(n)+30)
        vaf1line=regexp(logText,['(?<=',sprintf('\n'),num2str(lineNumSeek), ...
            ' +)[0-9]\.[0-9]+ +[0-9]\.[0-9]+'],'match','once');
        if ~isempty(vaf1line)
            vaf=[vaf; str2num(vaf1line)];
        end
        lineNumSeek=lineNumSeek+1;
        if size(vaf,1)==10
            % somewhere in between where we started & where we 
            % ended, there will be an indication of which kind of 
            % decoding we were doing.
            if isempty(regexp(logText,['(?<=',sprintf('\n'), ...
                    num2str(dayLineNum(n)),'.*)wsz(?=.*', ...
                    sprintf('\n'),num2str(lineNumSeek),')'],'once'))
                VAF_all=[VAF_all; struct('name',filenameIn,'type','Spike','vaf',vaf)];
            else
                VAF_all=[VAF_all; struct('name',filenameIn,'type','LFP','vaf',vaf)];
            end
            break
        end
    end
end
VAF_all(1)=[];