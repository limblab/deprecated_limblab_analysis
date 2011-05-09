%isolatespikechans by MWS 3/14/11
%This script finds channels that have spikes in one file and not in another
%(ul1(xa) are the indices of the spikes unique to file1, and ul2(xb) are
%the indices of spikes unique to file2
%mod 3/30/11 by MWS to remove filenames (for batching

load(Sfile1)
ul1=unit_list(bdf);
load(Sfile2)
ul2=unit_list(bdf);
[xo,xa,xb]=setxor(ul1,ul2,'rows');

%First do chans with spikes in file1 and not in file2
sings=find((ul1(xa,2)==1));

%load LFP file, adjust chanids for reduced number of channels in LFP file
%(some chans were turned off, so need to shift numbering)
load([file1,'tik emgpred 150 feats lambda1 poly2.mat'],'featMat','y')
clear x
numfeats=size(featMat,2);

% badchans1=[14,79];
% badchans2=[3,5,6,45,51,63,70,72,76,77,78,79,88,92,95,96];   %badchans from file2

badchans2orig=badchans2;
badchans1orig=badchans1;
chanids=ul1(xa(sings))
%Now take the badchans from both files out of chanids
badchans=union(badchans1,badchans2);
for b=length(badchans):-1:1
    bad=find(chanids==badchans(b));
    if ~isempty(bad)
        chanids(bad)=[];
        chanids(bad:end)=chanids(bad:end)-1;
    else
    shiftinds=chanids>badchans(b);
    chanids(shiftinds)=chanids(shiftinds)-1;
    end
end
chmat=repmat(chanids,6,1);
frinds=ones(length(chanids),1);

frmat=[];
for i=1:6
    frmat=[frmat;frinds*i];
end
featind=sub2ind([6 96-length(badchans)],frmat,chmat);
findmat=reshape(featind,[],6);
featindv=reshape(findmat',[],1);

%remove any chans from badchans2 that are already out of file1's
%featMat
for bb=length(badchans1):-1:1
    temp=find(badchans2==badchans1(bb));
    if ~isempty(temp)
    badchans2(temp)=[];
    badchans2(temp:end)=badchans2(temp:end)-1;
    else  %if channel is not bad in file2 but bad in file1, still need to reduce indices by 1 after that channel for file1
        temp=find(badchans2>badchans1(bb));
        badchans2(temp)=badchans2(temp)-1;
    end
end

cleaninds2=setdiff(1:96,badchans2);
bfinds=ones(length(badchans2),1);
bmat=repmat(badchans2',6,1);
bfmat=[];
for b=1:6
    bfmat=[bfmat;bfinds*b];
end
bind=sub2ind([6,94],bfmat,bmat);
bindmat=reshape(bind,[],6);
bfeatv=reshape(bindmat',[],1);
featMat(:,bfeatv)=[];  %Take out the badfeats from file2 in file1's featMat

% load 'E:\Data\Chewie\SpikeLFP\ChewieLFP cleaninds.mat'
% badchans=find(~cleaninds);

x=featMat(:,featindv);

nfeat=length(featindv);
Poly=3;
lambda=1;
binsamprate=10;
[vmean,vaf,vaftr,r2m1,r2sd1,r21,y_pred,y_test,ytnew,xtnew,H,P,featind] = predonlyxy_zs(x,y,Poly,0,lambda,10,1,binsamprate,10,nfeat);


%% Now test those same chans in the 2nd file (no spikes)
load([file2,'tik emgpred 150 feats lambda1 poly2.mat'],'featMat','y')
%Find the bad chans from file1 that were not bad in file2 and take those
%features out of featMat from file2
badchans1=badchans1orig;
badchans2=badchans2orig;

for bb=length(badchans2):-1:1
    temp=find(badchans1==badchans2(bb));
    if ~isempty(temp)
    badchans1(temp)=[];
    badchans1(temp:end)=badchans1(temp:end)-1;
    else  %if channel is not bad in file1 but bad in file2, still need to reduce indices by 1 after that channel for file2
        temp=find(badchans1>badchans2(bb));
        badchans1(temp)=badchans1(temp)-1;
    end
end

bfinds=ones(length(badchans1),1);
bmat=repmat(badchans1',6,1);
bfmat=[];
for b=1:6
    bfmat=[bfmat;bfinds*b];
end
bind=sub2ind([6,size(featMat,2)/6],bfmat,bmat);
bindmat=reshape(bind,[],6);
bfeatv=reshape(bindmat',[],1);
featMat(:,bfeatv)=[];  %Take out the badfeats from file2 in file1's featMat

x=featMat(:,featindv);

[vmean2,vaf2,vaftr,r2m2,r2sd2,r22,y_pred2,y_test2,ytnew2,xtnew2,H2,P2,featind2] = predonlyxy_zs(x,y,Poly,0,lambda,10,1,binsamprate,10,nfeat);

save([file1,'tik emgpred spike chan (no spikes in ',file2num,') decoding ',num2str(nfeat),' feats lambda1 poly2.mat'],'r*','x*','y*','v*','H*','P*','feat*','chan*','bad*')

% load([file1,'tik velpred 150 feats lambda1.mat'],'featMat','y')
% runrandchans
%% Then do chans with spikes in file2 and not in file1
clear x r* v* y* H* 

sings=find((ul2(xb,2)==1));
chanids=ul2(xb(sings))
load([file2,'tik emgpred 150 feats lambda1 poly2.mat'],'featMat','y')
numfeats=size(featMat);

% badchans=79;
% cleaninds=setdiff(1:96,badchans);
% badchans2=[3,5,6,45,51,63,70,72,76,77,78,79,88,92,95,96];
badchans1=badchans1orig;
badchans2=badchans2orig;
% load 'E:\Data\Chewie\SpikeLFP\ChewieLFP cleaninds.mat'
% badchans=find(~cleaninds);

badchans=union(badchans1,badchans2);
for b=length(badchans):-1:1
    bad=find(chanids==badchans(b));
    if ~isempty(bad)
        chanids(bad)=[];
        chanids(bad:end)=chanids(bad:end)-1;
    else
    shiftinds=chanids>badchans(b);
    chanids(shiftinds)=chanids(shiftinds)-1;
    end
end
if ~isempty(chanids)
chmat=repmat(chanids,6,1);
frinds=ones(length(chanids),1);

frmat=[];
for i=1:6
    frmat=[frmat;frinds*i];
end
featind=sub2ind([6 96-length(badchans)],frmat,chmat);
findmat=reshape(featind,[],6);
featindv=reshape(findmat',[],1);
nfeat=length(featindv);

for bb=length(badchans2):-1:1
    temp=find(badchans1==badchans2(bb));
    if ~isempty(temp)
    badchans1(temp)=[];
    badchans1(temp:end)=badchans1(temp:end)-1;
    else  %if channel is not bad in file2 but bad in file1, still need to reduce indices by 1 after that channel for file1
        temp=find(badchans1>badchans2(bb));
        badchans1(temp)=badchans1(temp)-1;
    end
end

bfinds=ones(length(badchans1),1);
bmat=repmat(badchans1',6,1);
bfmat=[];
for b=1:6
    bfmat=[bfmat;bfinds*b];
end
bind=sub2ind([6,size(featMat,2)/6],bfmat,bmat);
bindmat=reshape(bind,[],6);
bfeatv=reshape(bindmat',[],1);
featMat(:,bfeatv)=[];  %Take out the badfeats from file2 in file1's featMat

x=featMat(:,featindv);

[vmean,vaf,vaftr,r2m1,r2sd1,r21,y_pred,y_test,ytnew,xtnew,H,P,featind] = predonlyxy_zs(x,y,Poly,0,lambda,10,1,binsamprate,10,nfeat);
end
%% %
clear x
load([file1,'tik emgpred 150 feats lambda1 poly2.mat'],'featMat','y')
%Find the bad chans from file1 that were not bad in file2 and take those
%features out of featMat from file2
badchans1=badchans1orig;
badchans2=badchans2orig;

for bb=length(badchans1):-1:1
    temp=find(badchans2==badchans1(bb));
    if ~isempty(temp)
    badchans2(temp)=[];
    badchans2(temp:end)=badchans2(temp:end)-1;
    else  %if channel is not bad in file2 but bad in file1, still need to reduce indices by 1 after that channel for file1
        temp=find(badchans2>badchans1(bb));
        badchans2(temp)=badchans2(temp)-1;
    end
end

bfinds=ones(length(badchans2),1);
bmat=repmat(badchans2',6,1);
bfmat=[];
for b=1:6
    bfmat=[bfmat;bfinds*b];
end
bind=sub2ind([6,size(featMat,2)/6],bfmat,bmat);
bindmat=reshape(bind,[],6);
bfeatv=reshape(bindmat',[],1);
featMat(:,bfeatv)=[];  %Take out the badfeats from file2 in file1's featMat

x=featMat(:,featindv);  
%%%%%%%%%r2m2, featind2, H2 are for the non-spike file %%%%%%%%%(always)%%%%%%%%%%%%
[vmean2,vaf2,vaftr,r2m2,r2sd2,r22,y_pred2,y_test2,ytnew2,xtnew2,H2,P2,featind2] = predonlyxy_zs(x,y,Poly,0,lambda,10,1,binsamprate,10,nfeat);
save([file2,'tik emgpred spike chan (no spikes in ',file1num,') decoding ',num2str(nfeat),' feats lambda1 poly2.mat'],'r*','x*','y*','v*','H*','P*','feat*','chan*','bad*')

%% Now run random channel but reverse filenames to keep naming conventions
%% consistent
clear r* v* H P xt* yt* y_* featind*
% ftemp=file1;
% file1=file2;
% file2=ftemp;
% runrandchans