%% 1.  set up
if ispc
    switch machineName
        case 'BumblebeeMan'
            cd('E:\personnel\RobertF'), RDFstartup
        case 'Apu-PC'
            cd('E:\personnel\RobertF'), RDFstartup
        otherwise
            cd('C:\Users\NECALHDEMG\Documents\BCI2000\Matlab code')
            addpath(genpath(pwd))
            addpath('C:\Users\NECALHDEMG\Documents\BCI2000\tools\mex')
    end
end
%% 2. to start over, without losing important info
% clear everything but the stuff in the next cell? FileName/PathName?
clear FilterIndex H P PB SaveH* Use_Thresh ans best* col feat* fp* freqs 
clear h junk lambda num* parameters save* sig signal states total_samples
clear vaf x CG* bin* cg* folds recon* y* FP* Poly* S* nfeat s* wsz
clear N_KsectionInterp R badChanF bandsToUse existingFigTags files rangeThresh
%% define constants.

SIGNALTOUSE='force';
% SIGNALTOUSE='dfdt';
% SIGNALTOUSE='CG';
% FPIND is the index of all ECoG (fp) signals recorded in the signal array.
%  Not to be confused with the index of fps to use for building the
%  decoder, which is always a game-time decision.
FPIND=1:64;     % this controls which columns of the signal array are valid fp channels.
                % this determines which ones we actually want to use to 
                % [2:6 8 9 11:15] for ME                                                   %#ok<*NBRAK>
% FPSTOUSE=[2 3 6 7 8 11 12 16 17 18 19 22 23 26 27 28 29 31 ...
%     32 35 36 39 40 42 43 46 47 49 50 53 54 57 58 60 62 64];
% FPSTOUSE=[4 5 6 9 10 13 14 15 16 20 21 24 25 26 29 33 34 37 38 41 42 44 45 46 47 51 52 55 56 59 61 63];
                % build the decoder.  We can change our minds about this
                % one in a later cell, if we so desire.
%%  3. find file(s)
% if running this cell, must want a new file.  If you want to re-load the
% same file, skip this cell and move to the next.
clear FileName files
if ~exist('PathName','var')
    if exist('E:\ECoG_Data\','file')==7
        PathName='E:\ECoG_Data\';
    else
        PathName='C:\Users\NECALHDEMG\Documents\BCI2000\data\';
    end
end
[FileName,PathName,FilterIndex] = uigetfile([PathName,'*.dat'],'MultiSelect','on');
if iscell(FileName)
    for n=1:length(FileName), files(n).name=fullfile(PathName,FileName{n}); end
else
    files.name=fullfile(PathName,FileName);
end
if isnumeric(PathName) && PathName==0
    disp('cancelled.')
    return
end
cd(PathName)
%  4.  load into memory
fprintf(1,'loading %s...\n',files.name)
[signal,states,parameters,N]=load_bcidat(files.name);
fprintf(1,'load complete\n')
samprate=parameters.SamplingRate.NumericValue;
clear N
if ~isa(signal,'double'), signal=double(signal); end
%%  5a.  get fp array from signal array
% fp should be numfp X [numSamples].  Scale it by the value it will get in
% BCI2000.  This, in anticipation of building a brain control decoder.
signalRange=max(signal(:,FPIND),[],1)-min(signal(:,FPIND),[],1);
badChanF=figureCenter; % set(badChanF,'Position',[121 468 560 420])
plot(signalRange,'.','MarkerSize',36)
signalRangeLowLogical=signalRange<1;
% for median range calculation, include everything except the zeros.
rangeThresh=median(signalRange(~signalRangeLowLogical))+ ...
    2*iqr(signalRange(~signalRangeLowLogical));    % for TMSi
%      0.5*std(signalRange(~signalRangeLowLogical));   % for Blackrock (with 32 crap chans)

signalRangeHighLogical=signalRange > rangeThresh;
signalRangeBadLogical=signalRangeLowLogical | signalRangeHighLogical;
hold on
plot(find(signalRangeBadLogical),signalRange(signalRangeBadLogical),'r.','MarkerSize',36)
plot(get(gca,'Xlim'),[0 0]+rangeThresh,'k--','LineWidth',2)
try                                                                         %#ok<TRYNC>
    title(sprintf('%s\nRange of raw signals.\nBad channel estimate=red. %d good channels.', ...
        FileName,nnz(~signalRangeBadLogical)),'Interpreter','none','FontSize',16)
end
set(gca,'box','off','FontSize',16), set(gcf,'Color',[0 0 0]+1)
% also, plot a cut-down version of the raw fp signals.
% first, scale the signals so that they will appear 
% separated by a nice amount.
fpCut=(signal(1:100:end,FPIND)')./mean(signalRange); 
% so as to scale nicely for plotting
fpCutFig=figure; set(fpCutFig,'Units','normalized','OuterPosition',[0 0 1 1])
fpCutAx=axes('Position',[0.0319    0.0297    0.9556    0.9636], ...
    'XLim',[0 size(fpCut,2)],'Ylim',[0 max(FPIND)+1],'YTick',FPIND);
hold on
maxStrLen=max(cellfun(@numel,parameters.ChannelNames.Value(FPIND)));
for n=1:size(fpCut,1)
    if ~isempty(intersect(n,find(signalRangeBadLogical)))
        plot(n+fpCut(n,:),'r')
    else
        plot(n+fpCut(n,:))
    end
    YaxLabelStr{n}=sprintf(['%02d %',num2str(maxStrLen),'s'],...
        n,parameters.ChannelNames.Value{n});
end, clear n
set(fpCutAx,'YTickLabel',YaxLabelStr)
figure(badChanF)

%% Use signalRangeBadLogical to eliminate channels from FPSTOUSE.
% If you don't agree with the auto-estimation, then change 
% signalRangeBadLogical to be something that you think is better.
% this code also resets the flag FPSTOUSE_been_reset
if ~isa(signal,'double'), signal=double(signal); end
FPSTOUSE=FPIND;
FPSTOUSE(signalRangeBadLogical)=[];
fp=(signal(:,FPIND)').* ...
    repmat(cellfun(@str2num,parameters.SourceChGain.Value(FPIND)),1,size(signal,1));
fptimes=(1:size(fp,2))/samprate;
%% CAR.  Include only good signals into the CAR, but apply to all signals
%  (except channels zeroed out by the REFA)
fp(~signalRangeLowLogical,:)=bsxfun(@minus,fp(~signalRangeLowLogical,:), ...
    mean(fp(FPSTOUSE,:),1));
signalRange=max(fp(~signalRangeLowLogical,:),[],2)- ...
    min(fp(~signalRangeLowLogical,:),[],2);
fpCut=(fp(FPIND,1:100:end))./mean(signalRange);
if ishandle(fpCutFig)
    figure(fpCutFig)
    cla
else
    fpCutFig=figure;
    fpCutAx=axes('Position',[0.0319    0.0297    0.9556    0.9636], ...
        'XLim',[0 size(fpCut,2)],'Ylim',[0 max(FPIND)+1],'YTick',FPIND);
end
hold on
for n=1:size(fpCut,1)
    if ~isempty(intersect(n,find(signalRangeBadLogical)))
        plot(n+fpCut(n,:),'r')
    else
        plot(n+fpCut(n,:))
    end
    YaxLabelStr{n}=sprintf(['%02d %',num2str(maxStrLen),'s'],...
        n,parameters.ChannelNames.Value{n});
end, clear n
set(fpCutAx,'YTickLabel',YaxLabelStr)

%% CG info & PCA, or force info.
clear sig CG
[sig,CG]=getSigFromBCI2000(signal,states,parameters,SIGNALTOUSE);
disp('done')

if ~isempty(CG)
    CGrange=max(CG.data,[],1)-min(CG.data,[],1);
    CGcut=CG.data(1:100:end,:)./mean(CGrange);
    CGcutFig=figure; 
    set(CGcutFig,'Units','normalized','OuterPosition',[0 0 1 1])
    set(gca,'NextPlot','add','Position',[0.0374 0.1100 0.9272 0.8611])
    for n=1:size(CGcut,2)
        plot(n+CGcut(:,n))
    end, clear n
    set(gca,'Xlim',[0 size(CGcut,1)],'Ylim',[0 size(CGcut,2)+1])
end

%%  5b. optional: look at smoothed force signal
existingFigTags=get(get(0,'Children'),'Tag');
if ~iscell(existingFigTags), existingFigTags={existingFigTags}; end
if ~isstr(existingFigTags{1}), existingFigTags{1}=''; end
if ~any(cellfun(@isempty,regexp(existingFigTags,'smForceFigure'))==0)
    smForceFigure=figureCenter; set(smForceFigure,'Tag','smForceFigure')
    plot(sig(:,1),sig(:,2)), hold on
else
    figureCenter(findobj(0,'Tag','smForceFigure'))
    % comment out delete line, and optionally change color below, to 
    % add new views of different smoothing factors, instead of replacing
    % the current one.
    delete(findobj(gca,'Color','g'))    
end
smForce=smooth(sig(:,2),51);
plot(sig(:,1),smForce,'g','LineWidth',1.5)
% to add: targets from the run, so we can see which ones were hit
% successfully and which were not.  Also, tags that show eventCodes?  Was
% going to be useful for EEGLAB but maybe we don't care if we're not going
% to use EEGLAB.
%%  5b(i).  optional add-on to 5b, to actually use the smoothed force
sig=[fptimes', smForce];
%%  6.  new school: pick channels to include/exclude based on cap map
% FPSTOUSE=1:64; % just in case it comes in handy
elNames=parameters.ChannelNames.Value(FPIND); % change FPIND to FPSTOUSE, to keep selections.
elNames(signalRangeBadLogical)= ...
    regexp(sprintf('%s - bad signal,', ...
    elNames{signalRangeBadLogical}),'[A-Z].*?signal(?=,)','match');
% since adding 'bad signal' to the pre-selected bad channels, that string
% will be included in FPuseList IF one of the pre-selected bad channels
% ends up getting selected.  Then, that channel won't be included in
% FPSTOUSE anyway, since it won't match anything in
% parameters.ChannelNames.Value
if ~exist('FPSREMOVED','var'), FPSREMOVED=false(size(FPIND)); end
FPuseList=selectEEGelectrodes4(elNames,elNames(signalRangeBadLogical | FPSREMOVED));
FPSTOUSE=find(ismember(parameters.ChannelNames.Value,FPuseList));
% channels that were selected out by hand, using the GUI
FPSREMOVED=(~ismember(FPIND,FPSTOUSE) & ~signalRangeBadLogical);
%%  7.  set parameters, and build the feature matrix.
if exist('featMat','var') && exist ('sig','var')
    if size(featMat,1)==size(sig,1)
        sig=[fptimes', smForce]; % if you don't want the smoothed force, 
                                 % it will be necessary to re-run 5b.
    end
end
wsz=512;
samprate=parameters.SamplingRate.NumericValue; % 24414.0625/24 is the real TDT sample rate
binsize=0.1; % TO CHANGE ANYTHING IN THIS CELL, MUST RE-RUN CELL 5, THEN COME BACK HERE.
bandsToUse='1 2 3 4 5 6';
[featMat,sig]=calcFeatMat(fp,sig,wsz,samprate,binsize,bandsToUse);
% featMat that comes out of here is unsorted!  needs feature
% selection/ranking.
%%  8.  index the fps - can change mind at this point as to which FPs to use.
% FPSTOUSE=33:48;
clear x
numBands=length(regexp(bandsToUse,'[0-9]+'));
x=zeros(size(featMat,1),length(FPSTOUSE)*numBands);
% there is a tricky interplay between x and FPSTOUSE, because x is used to
% calculate H, and H must take into account 3 things:
%   -which channels are meant to serve as inputs
%   -of those, which channels score high (& therefore are part of
%    bestc,bestf)
%
for n=1:length(FPSTOUSE)
    x(:,(n-1)*numBands+1:n*numBands)= ...
        featMat(:,(FPSTOUSE(n)-1)*numBands+1:FPSTOUSE(n)*numBands);
end, clear n
% If a bad channel needs to be taken out, consider using the spatial filter to
% do it.  Currently it's not in either of the brain control setups (force
% or Triangle) but it could be added.  Alternately, just ensure it doesn't
% show up in bestc (using FPSTOUSE in order to eliminate the channel).

%%  9.  assign parameters.
Use_Thresh=0; lambda=6; 
PolynomialOrder=3; numlags=10; numsides=1; folds=10; 
smoothfeats=0; featShift=0;
nfeat=floor(0.9*size(x,2));
binsamprate=1;  % this is to keep filMIMO from tacking on an unnecessary
                % gain factor of binsamprate to the H weights.
if nfeat > (size(x,1)*size(x,2))
    fprintf(1,'setting nfeat to %d\n',size(x,1)*size(x,2))
    nfeat=size(x,1)*size(x,2);
end
fprintf('\nusing %d features...\n\n',nfeat)
% have to clear bestc,bestf if going from more features to fewer!
clear bestc bestf
%%  10.  evaluate fps offline use cross-validated predictions code.
% because this is so sensitive to # of features, we should really do a
% whole feature-dropping curve here.  Possibly an entire exploration of the
% parameter space; since featMat does not have to be re-calculated, it
% could probably be done fairly quickly.  However, if smoothfeat is one of
% the parameters that we plan to vary, then some kind of
% variable-time-constant smoothing filter will have to be implemented
% in 2D with the number of features in a fast parameter exploration.
disp('evaluating feature matrix using selected ECoG channels')
[vaf,ytnew,y_pred,bestc,bestf,featind,H,P]=predonlyxy_ECoG(x,FPSTOUSE,sig, ...
    PolynomialOrder,Use_Thresh,lambda,numlags,numsides,binsamprate,folds,nfeat,smoothfeats,featShift); %#ok<*NASGU,*ASGLU>
fprintf(1,'file %s\n',FileName)
fprintf(1,'decoding %s\n',SIGNALTOUSE)
fprintf(1,'numlags=%d\n',numlags)
fprintf(1,'wsz=%d\n',wsz)
fprintf(1,'nfeat=%d of a possible %d (%.1f%%)\n',nfeat,size(featMat,2),100*nfeat/size(featMat,2))
fprintf(1,'PolynomialOrder=%d\n',PolynomialOrder)
fprintf(1,'smoothfeats=%d\n',smoothfeats)
fprintf(1,'binsize=%.2f\n',binsize)
fprintf(1,'using bands %s ',bandsToUse), fprintf(1,'\n')
vaf                                                                                          %#ok<NOPTS>
fprintf(1,'mean vaf across folds: ')
fprintf(1,'%.4f\t',mean(vaf))
fprintf(1,'\n')
set(gcf,'Position',[121 468 560 420])

%%  11.  plot cross-validated predictions, with some informative text.
% close
figure, set(gcf,'Position',[88 100 1324 420])
col=2;
if exist('folds','var')==0, folds=10; end
for n=1:folds
    leftEdge=(n-1)*length(ytnew{1}(:,col))+1;
    rightEdge=n*length(ytnew{1}(:,col));
    hold on
    plot(leftEdge:rightEdge,ytnew{n}(:,col),leftEdge:rightEdge,y_pred{n}(:,col),'g')
    if n==1, set(gca,'Position',[0.0415    0.1100    0.9366    0.8150]), end
    plot([0 0]+rightEdge,get(gca,'Ylim'),'LineStyle','--','Color',[0 0 0]+0.25)
    text(leftEdge+(rightEdge-leftEdge)/2,max(get(gca,'Ylim')),sprintf('vaf=\n%.3f',vaf(n,col)),...
        'VerticalAlignment','top','HorizontalAlignment','center')
end, clear n leftEdge rightEdge

txtH=findobj(gca,'Type','text');
for n=1:length(txtH)
    tmp=get(txtH(n),'Position'); tmp(2)=max(get(gca,'Ylim')); 
    set(txtH(n),'Position',tmp)
end, clear n tmp txtH

dottedH=findobj(gca,'LineStyle','--');
for n=1:length(dottedH)
    yData=get(dottedH(n),'ydata');
    yData(2)=max(get(gca,'Ylim'));
    set(dottedH(n),'ydata',yData)
end, clear n dottedH

if exist('PolynomialOrder','var')
    title(sprintf('%s: real (blue) and predicted (green).  P^%d, mean_{vaf}=%.4f \\pm %.4f, %d features', ...
        regexprep(FileName,'_','-'),PolynomialOrder,mean(vaf(:,col)),std(vaf(:,col)),nfeat))
else
    title(sprintf('real (blue) and predicted (green).  mean_{vaf}=%.4f, %d features', ...
        mean(vaf(:,col)),nfeat))
end

%% ranked bestc,bestf
[bestfRanked,bestcRanked]=ind2sub([length(featind)/length(FPSTOUSE) length(FPSTOUSE)], ...
    featind((1:nfeat)+featShift));
[parameters.ChannelNames.Value(FPSTOUSE(bestcRanked)), num2cell(bestfRanked')]; 
openvar('ans')
% center of mass for bestfRanked

%%  12.  build a decoder.
% at this point, bestc & bestf are sorted by channel, while featind is
% still sorted by feature correlation rank.
disp('calculating H,bestc,bestf using a single fold...')
[vaf,ytnew,y_pred,bestc,bestf,H,P]=buildModel_ECoG(x,FPSTOUSE,sig,PolynomialOrder,Use_Thresh, ...
    lambda,numlags,numsides,binsamprate,featind,nfeat,smoothfeats);

vaf                                                                                                 %#ok<NOPTS>
fprintf(1,'mean vaf across folds: ')
fprintf(1,'%.4f\t',mean(vaf))
fprintf(1,'\n')
close
%%  13.  saving.
% bestc must be re-cast so that it properly indexes the full 32-channel
% possible array of FPSTOUSE.  Keep MATLAB's 1-based indexing, it will be
% adjusted once loaded into BCI2000.
bestc=FPSTOUSE(bestc);
% save bestc,bestf,H
bestcf=[rowBoat(bestc), rowBoat(bestf)];
if size(H,2)<2
    H=[zeros(size(H)), H];
end
% if size(H,2)>2
%     % until we get smarter...
%     disp('only using 1st two columns of H...')
%     H(:,3:end)=[];
% end
if size(P,1)<2
    P=[zeros(size(P)); P];
end

% save in a more human-readable format.
[SaveHname,SaveHpath,junk]= ...
    uiputfile(fullfile(PathName,'*.txt'),'Save H As', ...
    [regexp(files(1).name,'.*(?=\.dat)','match','once'),'_H.txt']);
clear junk
if isnumeric(SaveHpath) && SaveHpath==0
    disp('cancelled.')
    return
end
[junk1,junk2,ext]=FileParts(SaveHname); clear junk*
if isempty(ext)
    SaveHname=[SaveHname,'.txt'];
end
% save in a more human-readable format.
% open file in write format (Windows text file = 'wt')
fid=fopen(fullfile(SaveHpath,SaveHname),'wt');
for n=1:size(H,1)
    for k=1:(size(H,2)-1)
        fprintf(fid,'%.5f\t',H(n,k));
    end, clear k
    fprintf(fid,'%.5f\n',H(n,end));
end, clear n
fclose(fid); clear fid
fprintf(1,'%s\nsaved.\n',fullfile(SaveHpath,SaveHname))
% save [bestc, bestf] matrix
saveCF_file=['bestcf',regexp(SaveHname,'(?<=H).*','match','once')];
fid=fopen(fullfile(SaveHpath,saveCF_file),'wt');
for n=1:length(bestc)
    fprintf(fid,'%d\t%d\n',[bestc(n) bestf(n)]);
end, clear n
fclose(fid); clear fid
fprintf(1,'%s\nsaved.\n',fullfile(SaveHpath,saveCF_file))

saveP_file=['P',regexp(SaveHname,'(?<=H).*','match','once')];
fid=fopen(fullfile(SaveHpath,saveP_file),'wt');
for n=1:size(P,1)
    for k=1:(size(P,2)-1)
        fprintf(fid,'%.5f\t',P(n,k));
    end, clear k
    fprintf(fid,'%.5f\n',P(n,end));
end, clear n
fprintf(1,'%s\nsaved.\n',fullfile(SaveHpath,saveP_file));
fclose(fid); clear fid

if ~isempty(CG)         
    % if this is a CG recording, save mean,std info in human-readable
    % format.
    saveCGinfo_file=['CG', regexp(SaveHname,'(?<=H).*','match','once')];
    fid=fopen(fullfile(SaveHpath,saveCGinfo_file),'wt');
    for n=1:(length(CG.mean)-1)
        fprintf(fid,'%.5f\t',CG.mean(n));   % save mean info
    end
    fprintf(fid,'%.5f\n',CG.mean(end));     % last element
    for n=1:(length(CG.std)-1)
        fprintf(fid,'%.5f\t',CG.std(n));    % save std info
    end, clear n
    fprintf(fid,'%.5f\n',CG.std(end));      % last element
    fprintf(1,'%s\nsaved.\n',fullfile(SaveHpath,saveCGinfo_file));
    fclose(fid); clear fid
end


%%
% get parameter file to overwrite
% write out new parameter file; tag filename with today's date
if ~ischar(ParamPathName(1)) && ParamPathName==0
    disp('cancelled.')
    return
end
fid=fopen(fullfile(ParamPathName,ParamFileName));
strData=fscanf(fid,'%c');
fclose(fid); clear fid
nCharPerLine = diff([0 find(strData == char(10)) numel(strData)]);
cellData = strtrim(mat2cell(strData,1,nCharPerLine));
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
    paramBands=[paramBands, f_bands(str2double(bandsUsed{n}(1))-1,1)];          %#ok<AGROW>
    paramBands=[paramBands, f_bands(str2double(bandsUsed{n}(end))-1,2)];        %#ok<AGROW>
    sprintfStr_fbands=[sprintfStr_fbands, ' %d %d'];                            %#ok<AGROW>
end, clear n
sprintfStr_fbands=[sprintfStr_fbands, ' // Frequency bands to calculate for each channel'];
cellData{fbandsCell}=sprintf(sprintfStr_fbands,length(bandsUsed),paramBands);

% bestc, bestf
sprintfStr_bestcf='Filtering:LFPDecodingFilter matrix Classifier';
bestcfCell=find(cellfun(@isempty,regexp(cellData,sprintfStr_bestcf))==0);
sprintfStr_bestcf=[sprintfStr_bestcf, '= %d { bestc bestf }'];
for n=1:size(bestcf,1)
    sprintfStr_bestcf=[sprintfStr_bestcf, ' %d %d'];                           %#ok<AGROW>
end, clear n
sprintfStr_bestcf=[sprintfStr_bestcf, ' // bestc, bestf matrix'];
cellData{bestcfCell}=sprintf(sprintfStr_bestcf,size(bestcf,1),reshape(bestcf',1,[]));

% H
sprintfStr_H='Filtering:LFPDecodingFilter matrix HMatrix';
cellDataHcell=find(cellfun(@isempty,regexp(cellData,sprintfStr_H))==0);
sprintfStr_H=[sprintfStr_H, '= %d { Xwt Ywt }'];
if size(H,2)<2
    H=[zeros(size(H)), H];
end
for n=1:size(H,1)
    for k=1:size(H,2)
        sprintfStr_H=[sprintfStr_H, ' %.4f'];                                   %#ok<AGROW>
    end, clear k
end, clear n
sprintfStr_H=[sprintfStr_H, ' // H Matrix'];
cellData{cellDataHcell}=sprintf(sprintfStr_H,size(H,1),reshape(H',1,[]));

% P
sprintfStr_P='Filtering:LFPDecodingFilter matrix Pmatrix';
cellDataPcell=find(cellfun(@isempty,regexp(cellData,sprintfStr_P))==0);
sprintfStr_P=[sprintfStr_P, '= 2 %d', repmat(' 0.0',1,PolynomialOrder), ...
    repmat(' %.4f',1,PolynomialOrder)];
cellData{cellDataPcell}=sprintf(sprintfStr_P,PolynomialOrder,P);

% numlags
sprintfStr_numlags='Filtering:LFPDecodingFilter int nBins';
cellDataNumlagsCell=find(cellfun(@isempty,regexp(cellData,sprintfStr_numlags))==0);
sprintfStr_numlags=[sprintfStr_numlags, '=%d 1 %% %% // ', ...
    'The number of bins to save in the data buffer.'];
cellData{cellDataNumlagsCell}=sprintf(sprintfStr_numlags,numlags);

% wsz
sprintfStr_wsz='Filtering:LFPDecodingFilter int FFTWinSize';
cellDataWSZcell=find(cellfun(@isempty,regexp(cellData,sprintfStr_wsz))==0);
sprintfStr_wsz=[sprintfStr_wsz, '=%d 1 0 %% // ', ...
    'The window size during the FFT calculation.'];
cellData{cellDataWSZcell}=sprintf(sprintfStr_wsz,wsz);

% smoothfeats
sprintfStr_smoothfeats='Filtering:LFPDecodingFilter int MovingAverageWindow';
cellDataSmoothfeatsCell=find(cellfun(@isempty,regexp(cellData,sprintfStr_smoothfeats))==0);
sprintfStr_smoothfeats=[sprintfStr_smoothfeats, '=%d // ', ...
    'Used for feature smoothing. 0=no smoothing.'];
cellData{cellDataSmoothfeatsCell}=sprintf(sprintfStr_smoothfeats,smoothfeats);

% now, write out the new parameter file.  tag it with the time of creation
% so that we don't overwrite anything important.

fid=fopen(fullfile(ParamPathName,[ParamFileName, ...
    regexprep(datestr(now),{':',' '},{'_','_'})]),'w');
fprintf(fid,'%c',cellData{:});
fclose(fid); clear fid


% save(fullfile('C:\Program Files (x86)\BCI 2000 v3\parms\Human_Experiment_Params_v3\decoders', ...
%     [regexp(FileName,'.*(?=\.dat)','match','once'),'_H.txt']),'H','-ascii','-tabs','-double')
% save(fullfile('C:\Program Files (x86)\BCI 2000 v3\parms\Human_Experiment_Params_v3\decoders', ...
%     [regexp(FileName,'.*(?=\.dat)','match','once'),'_bestcf.txt']),'bestcf','-ascii','-tabs','-double')

%% 14.  plot results of same-file decoder.
% close
figure, set(gcf,'Position',[88         378        1324         420])
plot(ytnew(:,1)), hold on, plot(y_pred(:,1),'g')
set(gca,'Position',[0.0415    0.1100    0.9366    0.8150])




%%
% old school, fancy graphical solutions for inclusion/exclusion of
% channels.  Bases things on the data instead of just picking them off
% an image and assuming they're good.  Go figure, right?
%%  6a. pick out quality FP channels.  (plus: LP filter force/CAR/other filtering?)
figure, set(gcf,'Position',[88         100        1324         420])
set(gca,'Position',[0.0415    0.1100    0.9366    0.8150])
h1=plot(fptimes,fp(FPSTOUSE,:)');
for n=1:length(h1)
    set(h1(n),'Color',rand(1,3))
end, clear n
legend(regexp(sprintf('ch%d\n',FPSTOUSE),'ch[0-9]+','match')), clear h1

%% 6b. second option for plot
scaleFactor=mean(max(fp(FPSTOUSE,:),[],2)-min(fp(FPSTOUSE,:),[],2));
figure, set(gcf,'Position',[88 100 1324 420],'Color',[0 0 0]+1)
set(gca,'Position',[0.0415 0.0571 0.9366 0.9190])
h2=plot(fptimes(1:10:end),bsxfun(@plus,(1:length(FPSTOUSE))*scaleFactor,fliplr(fp(FPSTOUSE,1:10:end)')));
% h2=plot(fptimes(1:10:end),bsxfun(@plus,(1:length(FPSTOUSE))*scaleFactor,fp(FPSTOUSE,1:10:end)'));
axis tight
for n=1:length(h2)
    set(h2(n),'Color',rand(1,3), ...
        'Tag',parameters.ChannelNames.Value{FPSTOUSE(length(FPSTOUSE)-n+1)})
end, clear n
set(gca,'YTick',scaleFactor*(1:length(FPSTOUSE)))
set(gca,'YTickLabel',flipud(parameters.ChannelNames.Value(FPSTOUSE)), ...
    'TickLength',[0.001 0.025],'box','off')
% set(gca,'YTickLabel',parameters.ChannelNames.Value(FPSTOUSE))

% for simple numeric list, instead
% set(gca,'YTickLabel',regexp(sprintf('%d ',1:64),'[0-9]+(?= )','match'))
% legend(regexp(sprintf('ch%d\n',FPSTOUSE),'ch[0-9]+','match'))
%% 6c. if there are bad channels, try this code to figure out which ones they are...
% this works for either plot because it uses gco.  Just dock it, to make
% sure it is the current plot when you run the cell.
% step 1: zoom in and select with the plot edit tool!  Then, 
FPSTOUSE(FPSTOUSE==find(strcmp(parameters.ChannelNames.Value,get(gco,'Tag'))))=[];
% deprecated, for use with legended plot
% FPSTOUSE(ismember(FPSTOUSE,str2double(regexp(get(gco,'DisplayName'),'(?<=ch)[0-9]+','match','once'))))=[];
delete(gco)
% legend('off')
% legend(regexp(sprintf('ch%d\n',FPSTOUSE),'ch[0-9]+','match'))

%% other graphical fanciness.  useful for searching for patterns by eye,
%  once the features have been calculated (i.e. following cell 7)
figure, set(gcf,'Position',[88         100        1324         420])
set(gca,'Position',[0.0415 0.1100 0.9366 0.8150])
imagesc(bsxfun(@rdivide,x,max(x,[],1))')
% imagesc(x')
hold on
gain=size(x,2)/(max(sig(:,2))-min(sig(:,2)));
plot(sig(:,2)*(-1)*gain+(gain*max(sig(:,2))),'k','LineWidth',3), clear gain

%% alternate way of exploring the feature space: do a sweep.  May take
%  a few minutes.
%  NOT PRACTICAL FOR DAY-OF ANALYSIS
infoStruct=struct('path',fullfile(PathName,FileName),'montage',[],'force',1);
infoStruct.montage={FPSTOUSE,[],[],[]};
paramStructIn=struct('PolynomialOrder',3,'folds',11,'numlags',10,'wsz',256, ...
    'nfeat',6:12:(6*length(FPSTOUSE)),'smoothfeats',unique([0 5:10:55 11:10:51]), ...
    'binsize',0.05,'fpSingle',0,'zscore',0,'lambda',[0 1 2:2:10]);
VAFstruct=batchAnalyzeECoGv6(infoStruct,'force','MS',paramStructIn);


% At this point, a decision must be made as to whether it will be best to
% take one of these H's, or try calculating one on the entire file.
