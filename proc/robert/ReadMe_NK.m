function [fileHeader,channelIDs,AllData]=ReadMe_NK(pathIn)

% syntax [fileHeader,channelIDs,AllData]=ReadMe_NK(pathIn)
%
% pathIn should be a full path to a .m00 file
%
% THIS FUNCTION WORKS REGARDLESS OF WHAT THE CHANNEL LABELS ARE!!!
% 


%%
fid=fopen(pathIn);
strData=fscanf(fid,'%c');
fclose(fid); clear fid
%%
nCharPerLine = diff([0 find(strData == char(10)) numel(strData)]);
cellData = strtrim(mat2cell(strData,1,nCharPerLine));
clear strData nCharPerLine
%%
fileHeader=cellData{1};
channelsInfo=cellData{2};
TimePoints=str2double(regexp(fileHeader,'(?<=TimePoints=)[0-9]+','match','once'));
numChans=str2double(regexp(fileHeader,'(?<=Channels=)[0-9]+','match','once'));
remainder=channelsInfo;
n=1;
while ~isempty(remainder)
    [token,remainder]=strtok(remainder);
    if ~strcmp(token,'(V)')
        channelIDs{n}=token;
    end
    n=n+1;
end
% if length(channelIDs)~=numChans+1
%     error('error reading number of channels.  check data file.')
% end

% AllData=zeros(TimePoints,numChans);
%%
start_ind=size(cellData,2)-TimePoints;
cellData(start_ind:length(cellData))= ...
    cellfun(@(s) {sscanf(s,'%f',[1 inf])}, ...
    cellData(start_ind:length(cellData)));
% account for spurious extra carriage return at the end
if isempty(cellData{end}), cellData(end)=[]; end
mismatchedLines=find(diff(cellfun(@length,cellData(start_ind:length(cellData)))));
if ~isempty(mismatchedLines)
    % if there are rows that were not the same length as the others, toss a
    % warning, and take them out
    
    warning(['found %d lines in %s that don''t match the rest.\n', ...
        'lines: %s did not match\n and will be removed.'], ...
        length(mismatchedLines),pathIn,num2str(mismatchedLines+start_ind))
    cellData(mismatchedLines+start_ind)=[];
end
AllData=cat(1,cellData{start_ind:length(cellData)});


return

% for KC
AllData(:,cellfun(@isempty,regexpi(channelIDs,'((D|EP)[0-9]+)|DC03')))=[];


