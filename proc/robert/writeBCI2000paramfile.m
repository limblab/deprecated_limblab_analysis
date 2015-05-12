function ParamPathName=writeBCI2000paramfile(ParamPathName,bandsToUse,bestcf,H,P,numlags,wsz,smoothfeats)

% syntax ParamPathName=writeBCI2000paramfile(ParamPathName,bandsToUse,bestcf,H,P,numlags,wsz,smoothfeats))
%
% reads in an existing BCI2000 parameter file, and adds in the
% H,P,bestf,bestc data, so that we no longer have to mess around with
% saving those as text files and then reading them in using file dialogs in
% BCI2000.

% update: loading in as partial .prm file does not work.  Need a working
% brainreader style .prm file template to use.  Will need to have auto in
% right place, samp freq, etc. in right place, transmit channel list filled
% out.  Then do a search/replace in it, as originally planned.

if exist(ParamPathName,'file')~=2
    [FN,PN,FilterIndex] = uigetfile([ParamPathName,'*.*']);
    if ~ischar(PN(1)) && PN==0
        disp('cancelled.')
        return
    else
        ParamPathName=fullfile(PN,FN);
    end
end

fid=fopen(ParamPathName);
strData=fscanf(fid,'%c');
fclose(fid); clear fid
nCharPerLine = diff([0 find(strData == char(10)) numel(strData)]);
cellData = strtrim(mat2cell(strData,1,nCharPerLine));
for n=1:(numel(cellData)-1)
    cellData{n}=[cellData{n},sprintf('\n')];
end
clear strData nCharPerLine

% frequency bands to use
sprintfStr_fbands='Filtering:LFPDecodingFilter matrix FreqBands';
fbandsCell=find(cellfun(@isempty,regexp(cellData,sprintfStr_fbands))==0);
sprintfStr_fbands=[sprintfStr_fbands, '= %d { Low High }'];
f_bands=[0 4; 7 20; 70 115; 130 200; 200 300];
% only match 2-6 in bandsToUse because LMP does not need to be mentioned in
% paramBands at all; it will be silently added if it shows up in bestf.
bandsUsed=regexp(bandsToUse,'[2-6]+','match');
paramBands=[];
for n=1:length(bandsUsed)
    paramBands=[paramBands, f_bands(str2double(bandsUsed{n}(1))-1,1)]; 
    paramBands=[paramBands, f_bands(str2double(bandsUsed{n}(end))-1,2)];
    sprintfStr_fbands=[sprintfStr_fbands, ' %d %d'];
end, clear n
sprintfStr_fbands=[sprintfStr_fbands, ' // Frequency bands to calculate for each channel\n'];
% writeParamsCell={sprintf(sprintfStr_fbands,length(bandsUsed),paramBands)};
cellData{fbandsCell}=sprintf(sprintfStr_fbands,length(bandsUsed),paramBands); 

% bestc, bestf
sprintfStr_bestcf='Filtering:LFPDecodingFilter matrix Classifier';
bestcfCell=find(cellfun(@isempty,regexp(cellData,sprintfStr_bestcf))==0);
sprintfStr_bestcf=[sprintfStr_bestcf, '= %d { bestc bestf }'];
for n=1:size(bestcf,1)
    sprintfStr_bestcf=[sprintfStr_bestcf, ' %d %d'];
end, clear n
sprintfStr_bestcf=[sprintfStr_bestcf, ' // bestc, bestf matrix\n'];
cellData{bestcfCell}=sprintf(sprintfStr_bestcf,size(bestcf,1),reshape(bestcf',1,[]));
% writeParamsCell=[writeParamsCell, {sprintf(sprintfStr_bestcf,size(bestcf,1),reshape(bestcf',1,[]))}];

% H
sprintfStr_H='Filtering:LFPDecodingFilter matrix HMatrix';
cellDataHcell=find(cellfun(@isempty,regexp(cellData,sprintfStr_H))==0);
sprintfStr_H=[sprintfStr_H, '= %d { Xwt Ywt }'];
if size(H,2)<2
    H=[zeros(size(H)), H];
end
for n=1:size(H,1)
    for k=1:size(H,2)
        sprintfStr_H=[sprintfStr_H, ' %.4f'];
    end, clear k
end, clear n
sprintfStr_H=[sprintfStr_H, ' // H Matrix\n'];
cellData{cellDataHcell}=sprintf(sprintfStr_H,size(H,1),reshape(H',1,[]));
% writeParamsCell=[writeParamsCell, {sprintf(sprintfStr_H,size(H,1),reshape(H',1,[]))}];

% P
sprintfStr_P='Filtering:LFPDecodingFilter matrix Pmatrix';
cellDataPcell=find(cellfun(@isempty,regexp(cellData,sprintfStr_P))==0);
sprintfStr_P=[sprintfStr_P, '= 2 %d', ...
    repmat(' %f',1,numel(P)), '\n'];
cellData{cellDataPcell}=sprintf(sprintfStr_P,size(P,2),P');
% writeParamsCell=[writeParamsCell, {sprintf(sprintfStr_P,size(P,2),reshape(P',1,[]))}];

% numlags
sprintfStr_numlags='Filtering:LFPDecodingFilter int nBins';
cellDataNumlagsCell=find(cellfun(@isempty,regexp(cellData,sprintfStr_numlags))==0);
sprintfStr_numlags=[sprintfStr_numlags, '= %d 1 %% %% // ', ...
    'The number of bins to save in the data buffer.\n'];
cellData{cellDataNumlagsCell}=sprintf(sprintfStr_numlags,numlags);
% writeParamsCell=[writeParamsCell, {sprintf(sprintfStr_numlags,numlags)}];

% wsz
sprintfStr_wsz='Filtering:LFPDecodingFilter int FFTWinSize';
cellDataWSZcell=find(cellfun(@isempty,regexp(cellData,sprintfStr_wsz))==0);
sprintfStr_wsz=[sprintfStr_wsz, '= %d 1 0 %% // ', ...
    'The window size during the FFT calculation.\n'];
cellData{cellDataWSZcell}=sprintf(sprintfStr_wsz,wsz);
% writeParamsCell=[writeParamsCell, {sprintf(sprintfStr_wsz,wsz)}];

% smoothfeats
sprintfStr_smoothfeats='Filtering:LFPDecodingFilter int MovingAverageWindow';
cellDataSmoothfeatsCell=find(cellfun(@isempty,regexp(cellData,sprintfStr_smoothfeats))==0);
sprintfStr_smoothfeats=[sprintfStr_smoothfeats, '= %d // ', ...
    'Used for feature smoothing. 0=no smoothing.\n'];
cellData{cellDataSmoothfeatsCell}=sprintf(sprintfStr_smoothfeats,smoothfeats);
% writeParamsCell=[writeParamsCell, {sprintf(sprintfStr_smoothfeats,smoothfeats)}];

% now, write out the new parameter file.  tag it with the time of creation
% so that we don't overwrite anything important.
if str2num(regexp(version,'(?<=\(R)[0-9]+(?=[a-z]*\))','match','once')) <= 2007
    [PN,FN,ext,junk]=fileparts(ParamPathName); 
else
    [PN,FN,ext]=fileparts(ParamPathName); 
end

ParamPathName=fullfile(PN, ...
    [FN, regexprep(datestr(now),{':',' '},{'_','_'}),ext]);
    
fid=fopen(ParamPathName,'w');
fprintf(fid,'%c',cellData{:});  % instead of writeParamsCell{:}
fclose(fid); clear fid




% code checker warning suppressions
%#ok<*FNDSB>
%#ok<*AGROW>
%#ok<*ASGLU>
%#ok<*NASGU>















