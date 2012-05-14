
%% set up, and define globals.
if ispc
    cd('E:\monkey data\RobertF'), RDFstartup
end

SIGNALTOUSE='force';
% FPIND is the index of all ECoG (fp) signals recorded in the signal array.
%  Not to be confused with the index of fps to use for building the
%  decoder, which is always a game-time decision.
FPIND=1:32;

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
% this is where we'll get the CG info & do the PCA (function?)

sig=getSigFromBCI2000(signal,parameters,SIGNALTOUSE);
%% set parameters, and build the feature matrix.  go ahead and include all the fps.
wsz=256;
samprate=1000;
binsize=0.05;
[featMat,sig]=calcFeatMat(fp,sig,wsz,samprate,binsize);
% featMat that comes out of here is unsorted!  needs feature
% selection/ranking.
%% index the fps 
FPSTOUSE=17:32;
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
% or Triangle) but it could be added.

%% assign parameters.
Use_Thresh=0; lambda=1; 
PolynomialOrder=3; numlags=10; numsides=1; binsamprate=floor(1/0.05); folds=10; nfeat=75;
if nfeat>(size(featMat,1)*size(featMat,2))
    fprintf(1,'setting nfeat to %d\n',size(featMat,1)*size(featMat,2))
    nfeat=size(featMat,1)*size(featMat,2);
end
%% evaluate fps offline use cross-validated predictions code.
disp('evaluating feature matrix using selected ECoG channels')
[vaf,ytnew,y_pred,bestc,bestf,featind,H]=predonlyxy_ECoG(x,FPSTOUSE,sig,PolynomialOrder,Use_Thresh,lambda,numlags,numsides,binsamprate,folds,nfeat);
vaf
fprintf(1,'mean vaf across folds: ')
fprintf(1,'%.4f\t',mean(vaf,1))
fprintf(1,'\n')
%%
% close
figure, set(gcf,'Position',[88         378        1324         420])
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
title(sprintf('real (blue) and predicted (green).  P^{%d}, mean_{vaf}=%.4f', ...
    PolynomialOrder,mean(vaf(:,col))))

%% (don't forget to choose the best fps) build a decoder and save.
% at this point, bestc & bestf are sorted by channel, while featind is
% still sorted by feature correlation rank.
[vaf,ytnew,y_pred,bestc,bestf,H]=buildModel_ECoG(x,FPSTOUSE,sig,PolynomialOrder,Use_Thresh, ...
    lambda,numlags,numsides,binsamprate,featind,nfeat);
%%
% bestc must be re-cast so that it properly indexes the full 32-channel
% possible array of FPSTOUSE.  Keep MATLAB's 1-based indexing, it will be
% adjusted once loaded into BCI2000.
bestc=FPSTOUSE(bestc);
% save bestc,bestf,H
bestcf=[rowBoat(bestc), rowBoat(bestf)];
if size(H,2)<2
    H=[zeros(size(H)), H];
end
save(fullfile('C:\Program Files (x86)\BCI 2000 v3\parms\Human_Experiment_Params_v3\decoders', ...
    [regexp(FileName,'.*(?=\.dat)','match','once'),'_H.txt']),'H','-ascii','-tabs','-double')
save(fullfile('C:\Program Files (x86)\BCI 2000 v3\parms\Human_Experiment_Params_v3\decoders', ...
    [regexp(FileName,'.*(?=\.dat)','match','once'),'_bestcf.txt']),'bestcf','-ascii','-tabs','-double')

%%
close
figure, set(gcf,'Position',[88         378        1324         420])
plot(ytnew(:,1)), hold on, plot(y_pred,'g')
set(gca,'Position',[0.0415    0.1100    0.9366    0.8150])
