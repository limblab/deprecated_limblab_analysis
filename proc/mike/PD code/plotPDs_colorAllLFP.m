
filelist= Mini_LFP_BC_Decoder1_filenames(:,1);


for i=1:length(filelist)
    fnam=[filelist{i}]
    
    load([fnam(1:end-4),'_pdsallchanspos_bs-1wsz100mnpowlogAllFreqcos.mat'],'LFPfilesPDs')
    %load([fnam(1:end-4),'_pdsallchanspos_bs-1wsz100mnpowlogLMPcos.mat'],'LFPfilesPDs')
    
    LFPOnlinepds=LFPfilesPDs{1};
    k =1;
    
    for l = 1:length(bestc)
    
        if bestf(l) == 1
            continue
        else
            LFPdir(k,i+2) = LFPOnlinepds{bestf(l)-1}(bestc(l),2);
            NonLMPInd(k,:) = [bestf(l) bestc(l)];
            LFPdir(k,1) = bestc(l);
            LFPdir(k,2) = bestf(l);
            k=k+1;
        end
        
    end
    
    NonLMPIndSorted = sortrows(NonLMPInd,-2);
    
    for n = 1 : size(NonLMPInd,1)
        LFPOnlinepds{NonLMPIndSorted(n,1)-1}(NonLMPIndSorted(n,2),:) = [];
    end
    
    if ~exist('LFPOfflinePDs','var')
        LFPOnlinepds{1}(:,8)=repmat(2,size(LFPOnlinepds{1},1),1);
        LFPOnlinepds{2}(:,8)=repmat(3,size(LFPOnlinepds{2},1),1);
        LFPOnlinepds{3}(:,8)=repmat(4,size(LFPOnlinepds{3},1),1);
        LFPOnlinepds{4}(:,8)=repmat(5,size(LFPOnlinepds{4},1),1);
        LFPOnlinepds{5}(:,8)=repmat(6,size(LFPOnlinepds{5},1),1);
        LFPOfflinePDinfo = cell2mat(LFPOnlinepds');
        LFPOfflinePDs(:,1) = LFPOfflinePDinfo(:,5);
        LFPOfflinePDs(:,2) = LFPOfflinePDinfo(:,8);
        LFPOfflinePDs(:,i+2) = LFPOfflinePDinfo(:,2);
    else
        LFPOnlinepds{1}(:,8)=repmat(2,size(LFPOnlinepds{1},1),1);
        LFPOnlinepds{2}(:,8)=repmat(3,size(LFPOnlinepds{2},1),1);
        LFPOnlinepds{3}(:,8)=repmat(4,size(LFPOnlinepds{3},1),1);
        LFPOnlinepds{4}(:,8)=repmat(5,size(LFPOnlinepds{4},1),1);
        LFPOnlinepds{5}(:,8)=repmat(6,size(LFPOnlinepds{5},1),1);
        LFPOfflinePDinfo = cell2mat(LFPOnlinepds');
        LFPOfflinePDs(:,i+2) = LFPOfflinePDinfo(:,2);
    end 
    
end
figure

LFPdirSorted = sortrows(LFPdir(1:79,:),[2 -3]);
imagesc(LFPdirSorted(50:79,3:end));figure(gcf);

set(gca,'YTick',[1,17],'YTickLabel',{'130-200','200-300'})

figure
LFPOfflinePDsSorted = sortrows(LFPOfflinePDs,[2 -3]);
imagesc(LFPOfflinePDsSorted(48:end,3:end));figure(gcf);

set(gca,'YTick',[1,96,192,272],'YTickLabel',{'Delta','70-115','130-200','200-300'})


% subplot(2,1,1)
% imagesc(LMPdir)
% title('PDs, LMP')
% subplot(2,1,2)
% imagesc(confintL(goodL,:))
% title('PD confints')
% saveas(gcf,'LFPPDs of Chewie_Spike_LFP090211-032112 LMP.fig')
% 
% 
% goodLchans=setdiff(chanindsL,badChannels);
% narrowgoodL=ismember(chanindsL,goodLchans);    %These are channels that have good tuning and are good channels
% DirNGL=ismember(chainindsL(narrowgoodL),Lc);
% Ldirect=LMPdir(DirNGL,:);
% figure
% imagesc(Ldirect)
% title('Direct LMP chans only')
% 
% for j=1:size(LMPdir,2)
%     for k=j:size(LMPdir,2)
%         Cdircirc(j,k)=rho_c(Ldirect(:,j),Ldirect(:,k));
%     end
% end
% figure
% imagesc(Cdircirc)
% 
% for j=1:size(LMPdir,2)
%     for k=j:size(LMPdir,2)
%         CCdir(j,k)=corr(Ldirect(:,j),Ldirect(:,k));
%     end
% end
% figure
% imagesc(CCdir)
