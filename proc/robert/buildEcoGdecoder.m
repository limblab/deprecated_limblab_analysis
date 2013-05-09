%% 1.  set up
if ispc
    cd('E:\personnel\RobertF'), RDFstartup
end
%% 2.  define constants.
%% to start over, without losing important info
% clear everything but the stuff in the next cell? FileName/PathName?
clear FilterIndex H P PB SaveH* Use_Thresh ans best* col feat* fp* freqs 
clear h junk lambda num* parameters save* sig signal states total_samples
clear vaf x CG* bin* cg* folds recon* y* FP* Poly* S* nfeat s* wsz
clear N_KsectionInterp
%% define constants.

SIGNALTOUSE='force';
% SIGNALTOUSE='CG';
% FPIND is the index of all ECoG (fp) signals recorded in the signal array.
%  Not to be confused with the index of fps to use for building the
%  decoder, which is always a game-time decision.
FPIND=1:32;     % this controls which columns of the signal array are valid fp channels.
                % this determines which ones we actually want to use to 
FPSTOUSE=1:16;   % [2:6 8 9 11:15] for ME                                                   %#ok<*NBRAK>
                % build the decoder.  We can change our minds about this
                % one in a later cell, if we so desire.
%%  3. find file(s)
% if running this cell, must want a new file.  If you want to re-load the
% same file, skip this cell and move to the next.
clear FileName PathName
if ~exist('PathName','var')
    [FileName,PathName,FilterIndex] = uigetfile('E:\ECoG_Data\*.dat','MultiSelect','on');
end
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
%%  4.  load into memory
fprintf(1,'loading %s...\n',files.name)
[signal,states,parameters,N]=load_bcidat(files.name);
fprintf(1,'load complete\n')
samprate=parameters.SamplingRate.NumericValue;
clear N
%%  5.  get fp array from signal array
% fp should be numfp X [numSamples].  Scale it by the value it will get in
% BCI2000.  This, in anticipation of building a brain control decoder.
fp=(signal(:,FPIND)').* ...
    repmat(cellfun(@str2num,parameters.SourceChGain.Value(FPIND)),1,size(signal,1));
fptimes=(1:size(fp,2))/samprate;
% this is where we'll get the CG info & do the PCA
clear sig CG
[sig,CG]=getSigFromBCI2000(signal,states,parameters,SIGNALTOUSE);
disp('done')
%% pick out quality FP channels.  (plus: LP filter force/CAR/other filtering?)
figure, set(gcf,'Position',[88         100        1324         420])
set(gca,'Position',[0.0415    0.1100    0.9366    0.8150])
h1=plot(fptimes,fp(FPSTOUSE,:)');
for n=1:length(h1)
    set(h1(n),'Color',rand(1,3))
end, clear n
legend(regexp(sprintf('ch%d\n',FPSTOUSE),'ch[0-9]+','match')), clear h1

%% second option for plot
scaleFactor=mean(max(fp(FPSTOUSE,:),[],2)-min(fp(FPSTOUSE,:),[],2))                             %#ok<NOPTS>
figure, set(gcf,'Position',[88         100        1324         420])
set(gca,'Position',[0.0415    0.1100    0.9366    0.8150])
h2=plot(fptimes,bsxfun(@plus,(1:length(FPSTOUSE))*scaleFactor,fp(FPSTOUSE,:)'));
for n=1:length(h2)
    set(h2(n),'Color',rand(1,3))
end, clear n
legend(regexp(sprintf('ch%d\n',FPSTOUSE),'ch[0-9]+','match')), clear h2
%% if there are bad channels, try this code to figure out which ones they are...
% this works for either plot because it uses gco.  Just dock it, to make
% sure it is the current plot when you run the cell.
% step 1: zoom in and select with the plot edit tool!  Then, 
FPSTOUSE(ismember(FPSTOUSE,str2double(regexp(get(gco,'DisplayName'),'(?<=ch)[0-9]+','match','once'))))=[];
delete(gco)
legend('off')
legend(regexp(sprintf('ch%d\n',FPSTOUSE),'ch[0-9]+','match'))
disp('done')
%%  6.  set parameters, and build the feature matrix.
wsz=256;
samprate=24414.0625/24; % real TDT sample rate
binsize=0.05;
[featMat,sig]=calcFeatMat(fp,sig,wsz,samprate,binsize);
% featMat that comes out of here is unsorted!  needs feature
% selection/ranking.
%%  7.  index the fps - can change mind at this point as to which FPs to use.
% FPSTOUSE=33:48;
clear x
x=zeros(size(featMat,1),length(FPSTOUSE)*6);
% there is a tricky interplay between x and FPSTOUSE, because x is used to
% calculate H, and H must take into account 3 things:
%   -which channels are meant to serve as inputs
%   -of those, which channels score high (& therefore are part of
%    bestc,bestf)
%
for n=1:length(FPSTOUSE)
    x(:,(n-1)*6+1:n*6)=featMat(:,(FPSTOUSE(n)-1)*6+1:FPSTOUSE(n)*6);
end, clear n
% If a bad channel needs to be taken out, consider using the spatial filter to
% do it.  Currently it's not in either of the brain control setups (force
% or Triangle) but it could be added.  Alternately, just ensure it doesn't
% show up in bestc (using FPSTOUSE in order to eliminate the channel).
figure, set(gcf,'Position',[88         100        1324         420])
set(gca,'Position',[0.0415    0.1100    0.9366    0.8150])
imagesc(bsxfun(@rdivide,x,max(x,[],1))')
% imagesc(x')
hold on
gain=size(x,2)/(max(sig(:,2))-min(sig(:,2)));
plot(sig(:,2)*(-1)*gain+(gain*max(sig(:,2))),'k','LineWidth',3), clear gain
%%  8.  assign parameters.
Use_Thresh=0; lambda=1; 
PolynomialOrder=3; numlags=10; numsides=1; folds=10; nfeat=24; smoothfeats=140; featShift=20;
binsamprate=1;  % this is to keep filMIMO from tacking on an unnecessary
                % gain factor of binsamprate to the H weights.
if nfeat>(size(featMat,1)*size(featMat,2))
    fprintf(1,'setting nfeat to %d\n',size(featMat,1)*size(featMat,2))
    nfeat=size(featMat,1)*size(featMat,2);
end
fprintf('\nusing %d features...\n\n',nfeat)
% have to clear bestc,bestf if going from more features to fewer!
clear bestc bestf
%%  9.  evaluate fps offline use cross-validated predictions code.
% because this is so sensitive to # of features, we should really do a
% whole feature-dropping curve here.  Possibly an entire exploration of the
% parameter space; since featMat does not have to be re-calculated, it
% could probably be done fairly quickly.  However, if smoothfeat is one of
% the parameters that we plan to vary, then some kind of
% variable-time-constant smoothing filter will have to be implemented
% in 2D with the number of features in a fast parameter exploration.
disp('evaluating feature matrix using selected ECoG channels')
[vaf,ytnew,y_pred,bestc,bestf,featind,H]=predonlyxy_ECoG(x,FPSTOUSE,sig, ...
    PolynomialOrder,Use_Thresh,lambda,numlags,numsides,binsamprate,folds,nfeat,smoothfeats,featShift); %#ok<*NASGU,*ASGLU>
vaf                                                                                          %#ok<NOPTS>
fprintf(1,'mean vaf across folds: ')
fprintf(1,'%.4f\t',mean(vaf))
fprintf(1,'\n')
%%  10.  plot cross-validated predictions, with some informative text.
close
figure, set(gcf,'Position',[88         100        1324         420])
col=1;
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
title(sprintf('real (blue) and predicted (green).  P^{%d}, mean_{vaf}=%.4f, %d features', ...
    PolynomialOrder,mean(vaf(:,col)),nfeat))
% At this point, a decision must be made as to whether it will be best to
% take one of these H's, or try calculating one on the entire file.

%%  11.  build a decoder and save.
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
%%  12.  saving.
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

% save(fullfile('C:\Program Files (x86)\BCI 2000 v3\parms\Human_Experiment_Params_v3\decoders', ...
%     [regexp(FileName,'.*(?=\.dat)','match','once'),'_H.txt']),'H','-ascii','-tabs','-double')
% save(fullfile('C:\Program Files (x86)\BCI 2000 v3\parms\Human_Experiment_Params_v3\decoders', ...
%     [regexp(FileName,'.*(?=\.dat)','match','once'),'_bestcf.txt']),'bestcf','-ascii','-tabs','-double')

%%
% close
figure, set(gcf,'Position',[88         378        1324         420])
plot(ytnew(:,1)), hold on, plot(y_pred(:,1),'g')
set(gca,'Position',[0.0415    0.1100    0.9366    0.8150])
