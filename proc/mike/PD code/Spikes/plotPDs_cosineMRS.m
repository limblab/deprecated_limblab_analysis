%plotPDs_cosine
%Calculates PDs using cosine fitting (adapted from PD_angle_calc from
%Emily) for multiple files, then plots them
%MWS 7/13/12

% filelist=BDFlist_all([1:58,63:76]);
filelist= Chewie_SpikesDuringLFPBC_Dec1_filenames
numfiles=length(filelist);
badfiles=0; %Those with odd number of spikes
%  SPD=[];
SCactual=[];
%  SCModel=[];    %Spike counts model
nDirs=12;   %12 directions, 30 degree bins
Chewie_SpikesDuringLFP1BC_filenames_ConstSpikeNum = Chewie_SpikesDuringLFPBC_Dec1_filenames;
for i=1:numfiles
%     if i < 83
%         postfix='spikePDs_allchans_bs-1';   %LFP control file
%     else
    postfix='spikePDs_allchans_bs-1cos';
%     end
    if strncmpi(filelist{i},'Chew',4)
        savename=[filelist{i}(1:28),postfix,'.mat'];
        fnam=[filelist{i}(1:28),postfix,'.mat']
    else
        if strncmpi(filelist{i}(17),'0',1)
%             fnam=filewithpath(1:54)     %for Chewie long format (date included) filenames; Chewie is 56
                savename=[filelist{i}(1:27),postfix,'.mat'];
                fnam=savename;
        else
%             fnam=filewithpath(1:46) %For Chewie short format
                savename=[filelist{i}(1:19),postfix,'.mat'];
                fnam=savename;
        end
%         savename=[filelist{i}(1:27),postfix,'.mat'];
%         fnam=[filelist{i}(1:27),postfix,'.mat']
    end
    
    try
        load(fnam,'spike_counts','spikePDs')
    catch
        badfiles=badfiles+1;
        if i >1
            Chewie_SpikesDuringLFP1BC_filenames_ConstSpikeNum((i+1)-badfiles,:) = [];
            continue
        else 
            Chewie_SpikesDuringLFP1BC_filenames_ConstSpikeNum(i,:) = [];
            continue
        end
    end
    
    if i==1
        ul1=spikePDs{1}(:,1:2);
        numspikes=length(spike_counts);
        SPD=zeros(numspikes,numfiles);
        SCModel=zeros(numspikes,nDirs,numfiles);
        %         SCNorm=nan(numspikes,nDirs,numfiles);
    end
    if length(spike_counts)<numspikes
        badfiles=badfiles+1;
        Chewie_SpikesDuringLFP1BC_filenames_ConstSpikeNum(i-badfiles,:) = [];
        continue    %Eliminate files with different number of spikes for simplicity
%     else
%         dnum(i)=getfiledate(filelist{i});
%         ndays(i)=daysact(dnum(1),dnum(i));
    end
    ii=i-badfiles;
    for u=1:numspikes
        [SPD(u,ii),SCModel(u,:,ii),params] = PD_angle_calc12(spike_counts{u});
        if nnz(SCModel(u,:,ii))
            SCNorm(u,:,ii)=SCModel(u,:,ii)/max(SCModel(u,:,ii));
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
        Rtemp=corrcoef(squeeze(SCNorm(:,:,i)),squeeze(SCNorm(:,:,j)));
        RModl(i,j)=Rtemp(1,2);
    end
end

figure
% imagesc(ndays,ndays,RModl)
imagesc(RModl)
title('Correlation Coefficient of Cosine tuning model of spikes')
xlabel('Filenum')
saveas(gcf,'ChewieBCspikes spikePDs cosmodel bs1 corrcoefs.fig')

for i=1:numfiles-badfiles
    inds=setdiff(1:(numfiles-badfiles),i);
    Rmn(i)=mean(RModl(inds,i));
end
figure
plot(Rmn)
xlabel('Filenum')
ylabel('R')
title('Mean CorrCoef of cos tuning model spikes')
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
    bestchans=chnum(60:end)
    BSCN=SCNorm(bestchans,:,:);
    for i=1:size(SCNorm,3)
        for j=1:size(SCNorm,3)
            Rtemp=corrcoef(squeeze(BSCN(:,:,i)),squeeze(BSCN(:,:,j)));
            Rbest25(i,j)=Rtemp(1,2);
        end
    end
    imagesc(Rbest25)
    best10=chnum(76:end);
    BSCN10=SCNorm(best10,:,:);
    for i=1:size(SCNorm,3)
        for j=1:size(SCNorm,3)
            Rtemp=corrcoef(squeeze(BSCN10(:,:,i)),squeeze(BSCN10(:,:,j)));
            Rbest10(i,j)=Rtemp(1,2);
        end
    end
    figure
    imagesc(Rbest10)
    for i=1:size(SCNorm,3)
        inds=setdiff(1:(size(SCNorm,3)),i);
        Rm10n(i)=mean(Rbest10(inds,i));
    end
    figure
    plot(Rm10n)
end

