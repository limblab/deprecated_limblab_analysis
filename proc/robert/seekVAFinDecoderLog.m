function VAF_all=seekVAFinDecoderLog(nameIn)

[pathNameIn,filenameIn,~]=FileParts(nameIn);
if isempty(pathNameIn)
    pathNameIn=findBDFonCitadel(filenameIn);
    [pathToDecoderLog,~,~]=FileParts(regexprep(pathNameIn,{'BDFs','bdf'},{'Filter files','FilterFiles'}));
else
    pathToDecoderLog=pathnameIn;
end

% from ReadMe_NK.m
fid=fopen(fullfile(pathToDecoderLog,'decoderOutput.txt'));
strData=fscanf(fid,'%c');
fclose(fid);

nCharPerLine = diff([0 find(strData == char(10)) numel(strData)]);
cellData = strtrim(mat2cell(strData,1,nCharPerLine));
cellData(cellfun(@isempty,cellData))=[];

dayLineNum=find(cellfun(@isempty,regexp(cellData,['(?<=file )',filenameIn],'match','once'))==0,1,'first');

start_ind=1;
cellData(start_ind:length(cellData))=cellfun(@(s) {sscanf(s,'%f',[1 2])},cellData(start_ind:length(cellData)));
vafLineNum=find(cellfun(@length,cellData)==2);
vafLineNumStart=find(vafLineNum > dayLineNum,1,'first');
vaf=cellData(vafLineNum([vafLineNumStart vafLineNumStart+find(diff(vafLineNum(vafLineNumStart:end))==1,9,'first')]));
VAF_all=cat(1,vaf{:});

return

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
        vaf1line=regexp(logText,['(?<=',sprintf('\n'),num2str(lineNumSeek),' +)[0-9]\.[0-9]+ +[0-9]\.[0-9]+'],'match','once');
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
                VAF_all=[VAF_all; struct('filename',filenameIn,'type','Spike','vaf',vaf)];
            else
                VAF_all=[VAF_all; struct('filename',filenameIn,'type','LFP','vaf',vaf)];
            end
            break
        end
    end
end
VAF_all(1)=[];