%%
% empty

%% set up, and define constants.
if ispc
    cd('E:\personnel\RobertF'), RDFstartup
end

SIGNALTOUSE='force';
% SIGNALTOUSE='CG';
% FPIND is the index of all ECoG (fp) signals recorded in the signal array.
%  Not to be confused with the index of fps to use for building the
%  decoder, which is always a game-time decision.
FPIND=1:32;     % this controls which columns of the signal array are valid fp channels.
FPSTOUSE=1:16;  % this determines which ones we actually want to use to 
                % build the decoder.  We can change our minds about this
                % one in a later cell, if we so desire.
%% find file, set up environment.
if ~exist('PathName','var')
    [FileName,PathName,FilterIndex] = uigetfile('E:\ECoG_Data\*.dat');
end
if isnumeric(PathName) && PathName==0
    disp('cancelled.')
    return
end
cd(PathName)
%% load into memory
fprintf(1,'loading %s...\n',FileName)
[signal,states,parameters,N]=load_bcidat(fullfile(PathName,FileName));
fprintf(1,'load complete\n')
clear N
%% get fp array from signal array
fp=signal(:,FPIND)'; % fp should be numfp X [numSamples]
% this is where we'll get the CG info & do the PCA
sig=getSigFromBCI2000(signal,states,parameters,SIGNALTOUSE);
% fudge factor has to be applied because BCI2000 internal processing to 
% translate to screen coords.  Currently only works for force.
p=polyfit(sig(:,2),double(states.CursorPosY),1);
sig(:,2)=polyval(p,sig(:,2))*100/4096;
%% set parameters, and build the feature matrix.  go ahead and include all the fps.
wsz=256;
samprate=1000;
binsize=0.05;
[featMat,sig]=calcFeatMat(fp,sig,wsz,samprate,binsize);
% featMat that comes out of here is unsorted!  needs feature
% selection/ranking.
%% index the fps - can change mind at this point as to which FPs to use.
FPSTOUSE=1:16;
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

%% assign parameters.
Use_Thresh=0; lambda=1; 
PolynomialOrder=0; numlags=10; numsides=1; binsamprate=1; folds=10; nfeat=70;
if nfeat>(size(featMat,1)*size(featMat,2))
    fprintf(1,'setting nfeat to %d\n',size(featMat,1)*size(featMat,2))
    nfeat=size(featMat,1)*size(featMat,2);
end
fprintf('\nusing %d features...\n\n',nfeat)
% have to clear bestc,bestf if going from more features to fewer!
clear bestc bestf
%% evaluate fps offline use cross-validated predictions code.
disp('evaluating feature matrix using selected ECoG channels')
[vaf,ytnew,y_pred,bestc,bestf,featind,H]=predonlyxy_ECoG(x,FPSTOUSE,sig,PolynomialOrder,Use_Thresh,lambda,numlags,numsides,binsamprate,folds,nfeat);
vaf
fprintf(1,'mean vaf across folds: ')
fprintf(1,'%.4f\t',mean(vaf))
fprintf(1,'\n')
%%
% close
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
    PolynomialOrder,mean(vaf(:,1)),nfeat))
% At this point, a decision must be made as to whether it will be best to
% take one of these H's, or try calculating one on the entire file.

%% (don't forget to choose the best fps) build a decoder and save.
% at this point, bestc & bestf are sorted by channel, while featind is
% still sorted by feature correlation rank.
disp('calculating H,bestc,bestf using a single fold...')
[vaf,ytnew,y_pred,bestc,bestf,H]=buildModel_ECoG(x,FPSTOUSE,sig,PolynomialOrder,Use_Thresh, ...
    lambda,numlags,numsides,binsamprate,featind,nfeat);

vaf
fprintf(1,'mean vaf across folds: ')
fprintf(1,'%.4f\t',mean(vaf))
fprintf(1,'\n')
%% saving.  scroll down for last plot.
% bestc must be re-cast so that it properly indexes the full 32-channel
% possible array of FPSTOUSE.  Keep MATLAB's 1-based indexing, it will be
% adjusted once loaded into BCI2000.
bestc=FPSTOUSE(bestc);
% save bestc,bestf,H
bestcf=[rowBoat(bestc), rowBoat(bestf)];
if size(H,2)<2
    H=[zeros(size(H)), H];
end
if size(H,2)>2
    % until we get smarter...
    disp('only using 1st two columns of H...')
    H(:,3:end)=[];
end
% save in a more human-readable format.
[SaveHname,SaveHpath,junk]= ...
    uiputfile('E:\ECoG_Data\','Save H As','H.txt');
if isnumeric(SaveHpath) && SaveHpath==0
    disp('cancelled.')
    return
end
% save in a more human-readable format.
% open file in write format (Windows text file = 'wt')
fid=fopen(fullfile(SaveHpath,SaveHname),'wt');
for n=1:size(H,1)
    for k=1:(size(H,2)-1)
        fprintf(fid,'%.5f\t',H(n,k));
    end
    fprintf(fid,'%.5f\n',H(n,end));
end
fclose(fid);
fprintf(1,'%s\nsaved.\n',fullfile(SaveHpath,SaveHname))
% save [bestc, bestf] matrix
fid=fopen(fullfile(SaveHpath,['bestcf.txt']),'wt');
for n=1:length(bestc)
    fprintf(fid,'%d\t%d\n',[bestc(n) bestf(n)]);
end
fclose(fid);
fprintf(1,'%s\nsaved.\n',fullfile(SaveHpath,['bestcf.txt']))


% save(fullfile('C:\Program Files (x86)\BCI 2000 v3\parms\Human_Experiment_Params_v3\decoders', ...
%     [regexp(FileName,'.*(?=\.dat)','match','once'),'_H.txt']),'H','-ascii','-tabs','-double')
% save(fullfile('C:\Program Files (x86)\BCI 2000 v3\parms\Human_Experiment_Params_v3\decoders', ...
%     [regexp(FileName,'.*(?=\.dat)','match','once'),'_bestcf.txt']),'bestcf','-ascii','-tabs','-double')

%%
% close
figure, set(gcf,'Position',[88         378        1324         420])
plot(ytnew(:,1)), hold on, plot(y_pred(:,1),'g')
set(gca,'Position',[0.0415    0.1100    0.9366    0.8150])
