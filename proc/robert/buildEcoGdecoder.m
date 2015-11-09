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
%% 2. to start over, without losing path info
% clear everything but the stuff in the next cell? FileName/PathName?
clear FilterIndex H P PB SaveH* Use_Thresh ans best* col feat* freqs 
clear h junk lambda num* parameters save* sig signal states total_samples
clear vaf x CG* bin* cg* folds recon* y* FP* Poly* S* nfeat s* wsz
clear N_KsectionInterp R badChanF bandsToUse existingFigTags files 
clear YaxLabelStr maxStrLen rangeThresh badChan2F n fp fptimes fpCut*
clear PA Pmat
%% 3. define constants.

SIGNALTOUSE='force';
% SIGNALTOUSE='dfdt';
% SIGNALTOUSE='CG';
% FPIND is the index of all ECoG (fp) signals recorded in the signal array.
%  Not to be confused with the index of fps to use for building the
%  decoder (FPSTOUSE), which is always a game-time decision.
FPIND=1:64;
clear badChanF

%%  4. find file(s)
% if running this cell, must want a new file.  If you want to re-load the
% same file, skip this cell and move to the next.
% clear FileName files
% make it the default that we're loading .dat files
loadDAT=1;
if ~exist('PathName','var')
    if exist('E:\ECoG_Data\','file')==7
        PathName='E:\ECoG_Data\';  
    else
        PathName='/Users/rdflint/work/';
    end
end
% if PathName exists, we'll go back to that same folder by default. If 
% there are only .mat files in this folder, we'll assume
% that one of them is the thing to be loaded in.
if ischar(PathName)
    D=dir(PathName);
    if any(cellfun(@isempty,regexp({D.name},'\.mat'))==0) && ...
            all(cellfun(@isempty,regexp({D.name},'\.dat')))
        loadDAT=0;
    end % if neither .mat nor .dat, this will still defualt to .dat
end, clear D
if loadDAT
    [FileName,PathName,FilterIndex] = uigetfile([PathName,'*.dat'],'MultiSelect','on');
else
    [FileName,PathName,FilterIndex] = uigetfile([PathName,'*.mat']);
end
if iscell(FileName)
    for n=1:length(FileName)
        files(n).name=fullfile(PathName,FileName{n});                       %#ok<*SAGROW>
    end
else
    files.name=fullfile(PathName,FileName);
end
if isnumeric(PathName) && PathName==0
    disp('cancelled.')
    return
else
    cd(PathName)
end

% load into memory
fprintf(1,'loading %s...\n',files.name)
if all(cellfun(@isempty,regexp({files.name},'\.dat','match','once')))==0
    [signal,states,parameters,N]=load_bcidat(files.name);
else
    % only load 1st file if *.mat files are selected.  Multiple *.mat files
    % not yet supported.
    load(files(1).name)
end
fprintf(1,'load complete\n')
samprate=parameters.SamplingRate.NumericValue;
clear N loadDAT
if ~isa(signal,'double'), signal=double(signal); end

%% optional: bandpass raw data.  useful with g.tec signals that have a large offset
[b,a]=butter(2,[0.1 500]/(samprate/2),'bandpass');
signalFilt=filtfilt(b,a,signal(:,FPIND));
signal(:,FPIND)=signalFilt;
clear a b signalFilt

%%  5.  get fp array from signal array
% fp should be numfp X [numSamples].  Scale it by the value it will get in
% BCI2000.  This, in anticipation of building a brain control decoder.
[badChanF,rangeThresh,signalRangeBadLogical,signalRangeLowLogical,fpCutFig,fpCutTimes,fpCut,maxStrLen,fptimes]=fpFromBCI2000(signal,FPIND,samprate,parameters);
% if you want to re-do channel selection after the first CAR, use
% [badChanF,rangeThresh,signalRangeBadLogical,signalRangeLowLogical,fpCutFig,fpCutTimes,fpCut,maxStrLen]=fpFromBCI2000(fp',FPIND,samprate,parameters);

%% 6. Use signalRangeBadLogical to eliminate channels from FPSTOUSE.
% If you don't agree with the auto-estimation, then change 
% signalRangeBadLogical to be something that you think is better.
try 
    newRangeThresh=mean(get(findobj(badChanF,'Color','k','LineStyle','--'),'ydata'));
    if abs(newRangeThresh-rangeThresh)/rangeThresh > 0.01
        disp('Range threshold has changed.  Go back and re-run the previous cell')
    else
        if ~isa(signal,'double'), signal=double(signal); end
        % eliminate the implicit assumption that the FPIND block should start at 1.
        FPSTOUSE=FPIND-min(FPIND)+1;
        FPSTOUSE(signalRangeBadLogical)=[];
        fp=signal(:,FPIND)';
        fp=bsxfun(@times,fp,cellfun(@str2num,parameters.SourceChGain.Value(FPIND)));
        % to get something suitable for pasting into ECoGProjectAllFileInfo.m
        arrayList(FPSTOUSE)
    end
end
%% 7. CAR.  Include only good signals into the CAR, but apply to all signals
%  (except channels zeroed out by the REFA)
fp(~signalRangeLowLogical,:)=bsxfun(@minus,fp(~signalRangeLowLogical,:), ...
    median(fp(FPSTOUSE,:),1)); % FPSTOUSE is where we're including "only good signals into the CAR".
signalRange2=max(fp(~signalRangeLowLogical,:),[],2)- ...
    min(fp(~signalRangeLowLogical,:),[],2);
fpCut=(fp(:,1:100:end))./mean(signalRange2);
if ishandle(fpCutFig)
    figure(fpCutFig)
    cla
else
    fpCutFig=figure;
    fpCutAx=axes('Position',[0.0365    0.0297    0.9510    0.9636], ...
        'XLim',[0 size(fpCut,2)],'Ylim',[0 max(FPIND)+1],'YTick',FPIND);
end
hold on
for n=1:size(fpCut,1)
    if ~isempty(intersect(n,find(signalRangeBadLogical)))
        plot(fpCutTimes,n+fpCut(n,:),'r')
    else
        plot(fpCutTimes,n+fpCut(n,:))
    end
    YaxLabelStr{n}=sprintf(['%02d %',num2str(maxStrLen),'s'],...
        n,parameters.ChannelNames.Value{n});
end, clear n
if exist('fpCutAx','var')==1 && ishandle(fpCutAx)
    set(fpCutAx,'YTickLabel',YaxLabelStr)
end
clear newRangeThresh
% % test the CAR, by re-plotting signalRange.  Compare to the original.
% signalRange2=max(fp,[],2)-min(fp,[],2);
% badChan2F=figureCenter; % set(badChanF,'Position',[121 468 560 420])
% plot(signalRange2,'.','MarkerSize',36)
% signalRangeLowLogical2=signalRange2<1;
% signalRangeHighLogical2=signalRange2 > rangeThresh;
% signalRangeBadLogical2=signalRangeLowLogical2 | signalRangeHighLogical2;
% hold on
% plot(find(signalRangeBadLogical2),signalRange2(signalRangeBadLogical2),'r.','MarkerSize',36)
% plot(get(gca,'Xlim'),[0 0]+rangeThresh,'k--','LineWidth',2)
% try                                                                         %#ok<TRYNC>
%     title(sprintf('%s\nRange of CAR''d fp signals.\nBad channel estimate=red. %d good channels.', ...
%         FileName,nnz(~signalRangeBadLogical2)),'Interpreter','none','FontSize',16)
% end
% set(gca,'box','off','FontSize',16), set(gcf,'Color',[0 0 0]+1)
% if exist('badChanF','var') && ishandle(badChanF)
%     set(gca,'Ylim',get(findobj(badChanF,'Type','Axes'),'Ylim'))
% end
%% 8. CG info & PCA, or force info.
clear sig CG
try                                                                         %#ok<*TRYNC>
    [sig,CG]=getSigFromBCI2000(signal,states,parameters,SIGNALTOUSE);
disp('done')
end
if ~isempty(CG)
    CGrange=max(CG.data,[],1)-min(CG.data,[],1);
    CGcut=CG.data(1:100:end,:)./mean(CGrange);
    CGcutFig=figure; 
    set(CGcutFig,'Units','normalized','OuterPosition',[0 0 1 1])
    set(gca,'NextPlot','add','Position',[0.0374 0.1100 0.9272 0.8611])
    if ~exist('fpCutTimes','var')
        fptimes=(1:size(signal,1))/samprate;
        fpCutTimes=fptimes(1:100:end);
    end
    for n=1:size(CGcut,2)
        plot(fpCutTimes,n+CGcut(:,n))
    end, clear n
    set(gca,'Xlim',[0 fpCutTimes(end)],'Ylim',[0 size(CGcut,2)+1])
else
    if nnz(cellfun(@isempty, ...
            regexpi(parameters.SignalSourceFilterChain.Value(:,1), ...
            'blackrock'))==0) && strcmp(SIGNALTOUSE,'force')
        % This additional Blackrock gain factor is a bit of a fudge-factor 
        % that Nick Halpern(?) warned us about.  He said the signals could 
        % be off by a factor of 4 from what they really were.
        sig(:,2)=sig(:,2)/4;
    end
end
%%  9a. optional: look at smoothed force signal
existingFigTags=get(get(0,'Children'),'Tag');
if ~iscell(existingFigTags), existingFigTags={existingFigTags}; end
if ~ischar(existingFigTags{1}), existingFigTags{1}=''; end
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
%%  9b.  optional add-on to 9a, to actually use the smoothed force
sig=[fptimes', smForce];
%%  9c(i).  optional: look at the CG signal.
figure, set(gcf,'Position',[69 75 864 578])
plot3(sig(10000:100:end,2),sig(10000:100:end,3),sig(10000:100:end,4),'.')
axis vis3d
xlabel('PC1'), ylabel('PC2'), zlabel('PC3')
%%  9c(ii).   or, in case there are 4 PCs
figure, set(gcf,'Position',[69 75 864 578])
plot3(sig(10000:100:end,2),sig(10000:100:end,3),sig(10000:100:end,5),'.')
axis vis3d
xlabel('PC1'), ylabel('PC2'), zlabel('PC5')
%%  10.  new school: pick channels to include/exclude based on cap map
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
%%  11.  set parameters, and build the feature matrix.
if exist('featMat','var') && exist ('sig','var')
    if size(featMat,1)==size(sig,1)
        sig=[fptimes', smForce]; % if you don't want the smoothed force, 
                                 % it will be necessary to re-run cell 8.
    end
end
wsz=512;
% samprate=parameters.SamplingRate.NumericValue; % 24414.0625/24 is the real TDT sample rate
binsize=0.1; % TO CHANGE ANYTHING IN THIS CELL, MUST RE-RUN CELL 5, THEN COME BACK HERE.
bandsToUse='4 5 6';
[featMat,sig]=calcFeatMat(fp,sig,wsz,samprate,binsize,bandsToUse);
% featMat that comes out of here is unsorted!  needs feature
% selection/ranking.
%%  12.  index the fps - can change mind at this point as to which FPs to use.
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

%%  13.  assign parameters.
Use_Thresh=0; lambda=4; 
PolynomialOrder=3; numlags=10; numsides=1; folds=10; 
smoothfeats=0; featShift=0;
nfeat=floor(0.9*size(x,2));
% nfeat=108;
binsamprate=1;  % this is to keep filMIMO from tacking on an unnecessary
                % gain factor of binsamprate to the H weights.
if nfeat > (size(x,1)*size(x,2))
    fprintf(1,'setting nfeat to %d\n',size(x,1)*size(x,2))
    nfeat=size(x,1)*size(x,2);
end
fprintf('\nusing %d features...\n\n',nfeat)
% have to clear bestc,bestf if going from more features to fewer!
clear bestc bestf
%%  14.  evaluate fps offline use cross-validated predictions code.
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
figureCenter(gcf)
% set(gcf,'Position',[121 468 560 420])

%%  15.  plot cross-validated predictions, with some informative text.
% close
figure, set(gcf,'Position',[88 100 1324 420])
col=1;
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

if iscell(H)
    disp('remember to run H=H{bestVAF};')
    disp('unless you plan to create a decoder from the whole file')
end

%% 16. ranked bestc,bestf - display in matlab spreadsheet format.
[bestfRanked,bestcRanked]=ind2sub([length(featind)/length(FPSTOUSE) length(FPSTOUSE)], ...
    featind((1:nfeat)+featShift));
[parameters.ChannelNames.Value(FPSTOUSE(bestcRanked)), num2cell(bestfRanked')];  %#ok<VUNUS>
openvar('ans')
% todo: calculate center of mass for bestfRanked?
% wanted(?): display that shows subplots for each band, with feature R values 
% displayed in a 2D color scale plot.  selected features can be highlighted
% in some way.  Or, only selected features are displayed?  Could have 2
% plots, or else a button that toggles back and forth between showing all
% features and just selected features.  Allows us to look at which bands
% are being more strongly represented, simultaneous with looking at the
% location on the array.


%% 17. prep for auto-save (using writeBCI2000paramfile.m)
%  IT IS AN ERROR TO RUN THIS MORE THAN ONCE.
%  for this, bestc should be in terms of the actual channel 
%  numbers, not indices into FPSTOUSE. 

% This begs the question: how to tell if this part is a redo?  
% Out-of-range error is sufficient proof, but that error does not 
% necessarily have to occur every time on a redo.  It could happen 
% that a redo would not throw that error.  
% Todo: make this determination.  Pre-requisite: be smarter.
bestc=FPSTOUSE(bestc);
% save bestc,bestf,H
bestcf=[rowBoat(bestc), rowBoat(bestf)];
%% 18. auto-save a decoder.  
%  last stage of prep: reduce H if that has not yet occurred.
[H,P,bestc,bestf]=reduceHcell(H,vaf,P,bestc,bestf);

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

if exist('paramPathName','var')==0
    paramPathName='';
end
% TODO: allow passing in of channel names cell array, then within the file
% we should put all those in the transmitChannelList, since that must be
% explicitly stated in a brain control setting.
[paramPathWritten,paramPathName]=writeBCI2000paramfile(paramPathName, ...
    bandsToUse,bestcf,H,P,numlags,wsz,smoothfeats);
fprintf(1,'wrote\n%s\n',paramPathWritten)


%%  19. calculate predictions for the entire file (based on 1 cell?)
% This is valuable for doing online-offline comparison testing.
% 
[H,P,bestc,bestf]=reduceHcell(H,vaf,P,bestc,bestf);
disp('calculating predictions for the file using selected H,P,bestc,bestf...')
[vaf,ytnew,y_pred,bestc,bestf,H,P]=buildModel_ECoG(x,FPSTOUSE,sig,PolynomialOrder,Use_Thresh, ...
    lambda,numlags,numsides,binsamprate,featind,nfeat,smoothfeats,featShift,H,P);


figure, plot(sig((size(sig,1)-size(ytnew,1)+1):end,1),ytnew*40.96+50*40.96)
hold on, plot(sig((size(sig,1)-size(y_pred,1)+1):end,1),y_pred*40.96+50*40.96,'--')
ylabel('cursor position units')
title(sprintf('vaf for the file using this fold: %.4f\n',vaf))

%% Use this only in the unusual situation where you want to re-pick bad
%  channels AFTER doing a CAR.
signalRange=max(fp(:,FPIND),[],1)-min(fp(:,FPIND),[],1);









%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Second-tier code.  Works, but has been superseded by something        %
% above this line.                                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%  18.  saving. old-fashioned way.  saves text files for H, P, bestcf.
% they must be loaded in individually, from within the BCI2000 config
% interface, using 'load matrix' for each one.
% bestc must be re-cast so that it properly indexes the full numel(FPIND)
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



%% 14.  plot results of same-file decoder.
% close
figure, set(gcf,'Position',[88         378        1324         420])
plot(ytnew(:,1)), hold on, plot(y_pred(:,1),'g')
set(gca,'Position',[0.0415    0.1100    0.9366    0.8150])

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% THE CODE BELOW THIS LINE IS EITHER DEPRECATED OR ELSE JUST SELDOM-    %
% USED.  IT MAY STILL WORK OR IT MAY NOT WORK ANYMORE.  NO PROMISES.    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
% old school, fancy graphical solutions for inclusion/exclusion of
% channels.  Bases things on the data instead of just picking them off
% an image and assuming they're good.  Go figure, right?
%%  pick out quality FP channels.  (plus: LP filter force/CAR/other filtering?)
figure, set(gcf,'Position',[88         100        1324         420])
set(gca,'Position',[0.0415    0.1100    0.9366    0.8150])
h1=plot(fptimes,fp(FPSTOUSE,:)');
for n=1:length(h1)
    set(h1(n),'Color',rand(1,3))
end, clear n
legend(regexp(sprintf('ch%d\n',FPSTOUSE),'ch[0-9]+','match')), clear h1

%% second option for plot
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
%% if there are bad channels, try this code to figure out which ones they are...
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
