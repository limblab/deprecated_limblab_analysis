%plotPDs_cosine
%Calculates PDs using cosine fitting (adapted from PD_angle_calc from
%Emily) for multiple files, then plots them
%vlmp is for LMP data only
%MWS 7/13/12

% filelist=BDFlist_all([1:58,63:76]);
% filelist=BDFlistshort;
numfiles=length(filelist);
badfiles=0; %Those with odd number of LMP
%  SPD=[];
SCactual=[];
%  SCModel=[];    %Spike counts model
nDirs=12;   %12 directions, 30 degree bins
for i=1:numfiles
    postfix='_pdsallchanspos_bs-1wsz100mnpowlogLMPcos';   %LFP control file
    if strncmpi(filelist{i},'Chew',4)
        savename=[filelist{i}(1:28),postfix,'.mat'];
        fnam=[filelist{i}(1:28),postfix,'.mat']
    else
        if strncmpi(filelist{i}(17),'0',1)
%             fnam=filewithpath(1:54)     %for Mini long format (date included) filenames; Chewie is 56
                savename=[filelist{i}(1:27),postfix,'.mat'];
                fnam=savename;
        else
%             fnam=filewithpath(1:46) %For Mini short format
                savename=[filelist{i}(1:19),postfix,'.mat'];
                fnam=savename;
        end
%         savename=[filelist{i}(1:27),postfix,'.mat'];
%         fnam=[filelist{i}(1:27),postfix,'.mat']
    end
    
    load(fnam,'LMPcounts')
    if i==1
        numLMP=length(LMPcounts);
        SPD=zeros(numLMP,numfiles);
        SCModel=zeros(numLMP,nDirs,numfiles);
        %         SCNorm=nan(numLMP,nDirs,numfiles);
    end
    if length(LMPcounts)<numLMP
        badfiles=badfiles+1;
        continue    %Eliminate files with different number of LMP for simplicity
%     else
%         dnum(i)=getfiledate(filelist{i});
%         ndays(i)=daysact(dnum(1),dnum(i));
    end
    ii=i-badfiles;
    for u=1:numLMP
        [SPD(u,ii),SCModel(u,:,ii),params] = PD_angle_calc12(LMPcounts{u});
        if nnz(SCModel(u,:,ii))
            SCNorm(u,:,ii)=SCModel(u,:,ii)/abs(max(SCModel(u,:,ii)));
        else
            SCNorm(u,:,ii)=SCModel(u,:,ii);
        end
    end
    
end
%Take out the columns with NaNs (those which were skipped because of
%badfiles
% SCNorm(isnan(SCNorm))=[];
for i=1:(numfiles-badfiles)
    for j=1:(numfiles-badfiles)
%         Rtemp=corrcoef(squeeze(SCNorm(:,:,i)),squeeze(SCNorm(:,:,j)));
Rtemp=corrcoef(squeeze(SCModel(:,:,i)),squeeze(SCModel(:,:,j)));
        RModl(i,j)=Rtemp(1,2);
    end
end

figure
% imagesc(ndays,ndays,RModl)
imagesc(RModl)
title('Correlation Coefficient of Cosine tuning model of LMP')
xlabel('Filenum')
saveas(gcf,'ChewieBCLFP LMPPDs cosmodel bs1 corrcoefs.fig')

for i=1:numfiles-badfiles
    inds=setdiff(1:(numfiles-badfiles),i);
    Rmn(i)=mean(RModl(inds,i));
end
figure
plot(Rmn)
xlabel('Filenum')
ylabel('R')
title('Mean CorrCoef of cos tuning model LMP')

if exist('H','var') %if H matrix is loaded
    H1=H(:,1:2);
    nlags=10;
    H1r=reshape(H1,nlags,[],2);
    H1r_f=squeeze(sum(abs(H1r),1));
    totc=sum(H1r_f,1)
    chmean(:,1)=H1r_f(:,1)/totc(1)
    chmean(:,2)=H1r_f(:,2)/totc(2);
    chmax=max(chmean,[],2);
    [chs,chnum]=sort(chmax);
    
    bestchans=bestc(chnum(end-24:end));
%     BSCN=SCNorm(bestchans,:,:);
    BSC=SCModel(bestchans,:,:);
    for i=1:numfiles-badfiles
        for j=1:numfiles-badfiles
            Rtemp=corrcoef(squeeze(BSC(:,:,i)),squeeze(BSC(:,:,j)));
            Rbest25(i,j)=Rtemp(1,2);
        end
    end
    imagesc(Rbest25)
    best10=bestc(chnum(end-9:end));
%     BSCN10=SCNorm(best10,:,:);
    BSC10=SCModel(best10,:,:);
    for i=1:numfiles-badfiles
        for j=1:numfiles-badfiles
            Rtemp=corrcoef(squeeze(BSC10(:,:,i)),squeeze(BSC10(:,:,j)));
            Rbest10(i,j)=Rtemp(1,2);
        end
    end
    figure
    imagesc(Rbest10)
    for i=1:numfiles-badfiles
        inds=setdiff(1:(numfiles-badfiles),i);
        Rm10n(i)=mean(Rbest10(inds,i));
    end
    figure
    plot(Rm10n)
    saveas(gcf,'ChewieLFPBCdecoder1 LMPcostuning MeanCC best10 nonnormalized LMPs.fig')
end
