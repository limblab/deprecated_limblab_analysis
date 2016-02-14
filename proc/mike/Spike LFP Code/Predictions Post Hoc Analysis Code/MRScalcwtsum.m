function [Wf, Wc,Wt]=MRScalcwtsum(H,nlags,nfbands,nchan,bestf,bestc)
%calcwtsum
if iscell(H) == 0
    H = {H(:,:)};
end

FRM=zeros(nfbands,size(H{1},2));
FRTM=zeros(nfbands,nlags,size(H{1},2));
CM=zeros(nchan,size(H{1},2));
TM=zeros(nlags,size(H{1},2));
if length(bestf)>length(H{1})/nlags
    bestf=bestf(1:length(H{1})/nlags);
     bestc=bestc(1:length(H{1})/nlags);
end
%% Freq analysis
for i=1:length(H)
    H1=H{i};
    H1r=reshape(H1,nlags,[],2);
    H1r_f=squeeze(sum(abs(H1r),1));
    
    %Sum for each frequency band
    for f=1:nfbands
        frind(f,:)=(bestf==f);
        frsum(f,:)=sum(H1r_f(frind(f,:),:),1);
%        fr_t_sum(f,:,:)=squeeze(sum(abs(H1r(:,frind(f,:),:)),2));
    end
    
    tot=sum(frsum,1);
%    total_t = sum(fr_t_sum,2);
    frmean(:,1)=frsum(:,1)/tot(1);
    frmean(:,2)=frsum(:,2)/tot(2);
%     for i = 1 : nlags
%         fr_tmean(:,i,1) = fr_t_sum(:,i,1)./total_t(:,1,1);
%         fr_tmean(:,i,2) = fr_t_sum(:,i,2)./total_t(:,1,2);
%     end
    FRM=FRM+frmean;
%     FRTM = FRTM+fr_tmean;
    
    %% Channel analysis
    for c=1:nchan
        chind(c,:)=(bestc==c);
        chsum(c,:)=sum(H1r_f(chind(c,:),:),1);
    end
    totc=sum(chsum,1);
    chmean(:,1)=chsum(:,1)/totc(1);
    chmean(:,2)=chsum(:,2)/totc(2);  
    CM=CM+chmean;
    
    
    %% Time bin analysis
%     for t=1:nlags
    Tsum=squeeze(sum(abs(H1r),2));
    tmean= Tsum ./ repmat(sum(Tsum,1),nlags,1);
    
    if size(tmean,1) > size(tmean,2)
        tmean = tmean';
    end
    
    TM=TM+tmean;
end

Wf=FRM/length(H);
%Wft = FRTM/length(H);
Wc=CM/length(H);
Wt=TM/length(H);
