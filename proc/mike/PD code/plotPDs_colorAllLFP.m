%Need filelist, bestc and bestf for monkey
filelist= ChewieLFP2fileNames(:);

plotOn = 0;


for i=1:length(filelist)
    fnam=[filelist{i}]
    
    try
        load([fnam(1:end-4),'_pdsallchanspos_bs-1wsz100mnpowlogAllFreqcos.mat'],'LFPfilesPDs')
    catch
        continue
    end
    %     try
%         load([fnam(1:end-4),'_pdsallchanspos_bs-1wsz100mnpowlogLMPcos.mat'],'LFPfilesPDs')
%     catch
%         continue
%     end
    LFP_PDs=LFPfilesPDs{1};
    k =1;
    
    for l = 1:length(bestc_bychan)
        
        if bestf_bychan(l) == 1
            continue
        else
            LFP_OnlinePDs(k,i+2) = LFP_PDs{bestf_bychan(l)-1}(bestc_bychan(l),2);
            %LFP_OnlinePDs(k,i+2) = LFP_PDs(bestc_bychan(l),2);
            NonLMPInd(k,:) = [bestf_bychan(l) bestc_bychan(l)];
            LFP_OnlinePDs(k,1) = bestc_bychan(l);
            LFP_OnlinePDs(k,2) = bestf_bychan(l);
            k=k+1;
        end
        
    end
    
    NonLMPIndSorted = sortrows(NonLMPInd,-2);
    
    for n = 1 : size(NonLMPInd,1)
        LFP_PDs{NonLMPIndSorted(n,1)-1}(NonLMPIndSorted(n,2),:) = [];
        %LFP_PDs(NonLMPIndSorted(n,2),:) = [];
    end
    
    if ~exist('LFPOfflinePDs','var')
        LFP_PDs{1}(:,8)=repmat(2,size(LFP_PDs{1},1),1);
        LFP_PDs{2}(:,8)=repmat(3,size(LFP_PDs{2},1),1);
        LFP_PDs{3}(:,8)=repmat(4,size(LFP_PDs{3},1),1);
        LFP_PDs{4}(:,8)=repmat(5,size(LFP_PDs{4},1),1);
        LFP_PDs{5}(:,8)=repmat(6,size(LFP_PDs{5},1),1);
        LFPOfflinePDinfo = cell2mat(LFP_PDs');
        %LFPOfflinePDinfo = LFP_PDs;
        LFPOfflinePDs(:,1) = LFPOfflinePDinfo(:,5);
        LFPOfflinePDs(:,2) = LFPOfflinePDinfo(:,8);
        LFPOfflinePDs(:,i+2) = LFPOfflinePDinfo(:,2);
    else
        LFP_PDs{1}(:,8)=repmat(2,size(LFP_PDs{1},1),1);
        LFP_PDs{2}(:,8)=repmat(3,size(LFP_PDs{2},1),1);
        LFP_PDs{3}(:,8)=repmat(4,size(LFP_PDs{3},1),1);
        LFP_PDs{4}(:,8)=repmat(5,size(LFP_PDs{4},1),1);
        LFP_PDs{5}(:,8)=repmat(6,size(LFP_PDs{5},1),1);
        LFPOfflinePDinfo = cell2mat(LFP_PDs');
        %LFPOfflinePDinfo = LFP_PDs;
        LFPOfflinePDs(:,i+2) = LFPOfflinePDinfo(:,2);
    end
    
end


if plotOn ==1
    figure
    
    LFP_OnlinePDs_Sorted = sortrows(LFP_OnlinePDs,[2 -3]);
    %Chewie
    imagesc(LFPdirSorted(34:end,3:end));figure(gcf);
    
    figure
    LFPOfflinePDsSorted = sortrows(LFPOfflinePDs,[2 -3]);
    imagesc(LFPOfflinePDsSorted(64:end,3:end));figure(gcf);
    
    %Mini
    imagesc(LFPdirSorted(50:end,3:end));figure(gcf);
    figure
    LFPOfflinePDsSorted = sortrows(LFPOfflinePDs,[2 -3]);
    imagesc(LFPOfflinePDsSorted(48:end,3:end));figure(gcf);
    
    
    set(gca,'YTick',[1,5,26,51],'YTickLabel',{'Mu','70-115','130-200','200-300'})
    
    
    
    set(gca,'YTick',[1,96,192,272],'YTickLabel',{'Mu','70-115','130-200','200-300'})
    set(gca,'YTick',[1,91,166,237],'YTickLabel',{'Mu','70-115','130-200','200-300'})
    
end


% subplot(285,1,1)
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
