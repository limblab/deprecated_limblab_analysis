%Need filelist, bestc and bestf for monkey
filelist= Mini_LFP1filenames_Reduced_Valid(:,1);

plotOn = 1;


for i=1:length(filelist)
    fnam=[filelist{i}]
    
    try
        load([fnam(1:end-4),'_pdsallchanspos_bs-1wsz150mnpowlogLMP_and_AllFreqcos.mat'],...
            'LFPfilesPDs','LFPfilesLMP_PDs')
    catch
        continue
    end
    %     try
%         load([fnam(1:end-4),'_pdsallchanspos_bs-1wsz100mnpowlogLMPcos.mat'],'LFPfilesPDs')
%     catch
%         continue
%     end
    LMP_PDs = LFPfilesLMP_PDs{1};
    LFP_PDs = LFPfilesPDs{1};
    
    k =1;
    
    for l = 1:length(bestc_bychan)
        
        if bestf_bychan(l) == 1
            LFP_OnlinePDs(k,i+2) = LMP_PDs{bestf_bychan(l)-1}(bestc_bychan(l),2);
            
            LFP_OnlinePDs(k,1) = bestc_bychan(l);
            LFP_OnlinePDs(k,2) = bestf_bychan(l);
            k=k+1;
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
        LMP_PDs{1}(:,8)=ones(size(LMP_PDs{1},1),1);
        LFP_PDs{1}(:,8)=repmat(2,size(LFP_PDs{1},1),1);
        LFP_PDs{2}(:,8)=repmat(3,size(LFP_PDs{2},1),1);
        LFP_PDs{3}(:,8)=repmat(4,size(LFP_PDs{3},1),1);
        LFP_PDs{4}(:,8)=repmat(5,size(LFP_PDs{4},1),1);
        LFP_PDs{5}(:,8)=repmat(6,size(LFP_PDs{5},1),1);
        LFPOfflinePDinfo = cell2mat([LMP_PDs; LFP_PDs']);
        %LFPOfflinePDinfo = LFP_PDs;
        LFPOfflinePDs(:,1) = LFPOfflinePDinfo(:,5);
        LFPOfflinePDs(:,2) = LFPOfflinePDinfo(:,8);
        LFPOfflinePDs(:,i+2) = LFPOfflinePDinfo(:,2);
    else
        LMP_PDs{1}(:,8)=ones(size(LMP_PDs{1},1),1);
        LFP_PDs{1}(:,8)=repmat(2,size(LFP_PDs{1},1),1);
        LFP_PDs{2}(:,8)=repmat(3,size(LFP_PDs{2},1),1);
        LFP_PDs{3}(:,8)=repmat(4,size(LFP_PDs{3},1),1);
        LFP_PDs{4}(:,8)=repmat(5,size(LFP_PDs{4},1),1);
        LFP_PDs{5}(:,8)=repmat(6,size(LFP_PDs{5},1),1);
        LFPOfflinePDinfo = cell2mat([LMP_PDs; LFP_PDs']);
        %LFPOfflinePDinfo = LFP_PDs;
        LFPOfflinePDs(:,i+2) = LFPOfflinePDinfo(:,2);
    end
    
end


if plotOn ==1
    figure
    
    LFP_OnlinePDs_Sorted = sortrows(LFP_OnlinePDs,[2 -3]);
    imagesc(LFP_OnlinePDs_Sorted(:,3:end));figure(gcf);
    
    [C ia] = unique(LFP_OnlinePDs_Sorted(:,2));
    set(gca,'YTick',ia,'YTickLabel',{'LMP','Delta','Mu','70-115','130-200','200-300'})
    
    figure
    LFP_OfflinePDs_Sorted = sortrows(LFPOfflinePDs,[2 -3]);
    imagesc(LFPOfflinePDsSorted(:,3:end));figure(gcf);

    [C ia] = unique(LFP_OfflinePDs_Sorted(:,2));
    set(gca,'YTick',ia,'YTickLabel',{'LMP','Delta','Mu','70-115','130-200','200-300'})

end

% for i=1:length(filelist)
%  fnam=[filelist{i},numlist{i}]
%  load([fnam,'_pdsallchanspos_bs-05wsz256mnpowlogLMP.mat'],'LFPfilesPDs')
%     LMP=LFPfilesPDs{1};
% %     LG1=LFPfilesPDs{1}{2};
% %     LG2=LFPfilesPDs{1}{3};
% % confint(:,i)=circ_dist(LG1(:,3),LG1(:,1));
% % confint2(:,i)=circ_dist(LG2(:,3),LG2(:,1));
% confintL(:,i)=circ_dist(LMP(:,3),LMP(:,1));
% if i==1
% %     good1=abs(confint(:,i))<pi/2;
% %     good2=abs(confint2(:,i))<pi/2;
%     goodL=abs(confintL(:,i))<pi/2;
% end
% % chaninds1=chanIDs(good1);
% % chaninds2=chanIDs(good2);
% chanindsL=chanIDs(goodL);
% % g1c=bestc(bestf==4)';
% % g2c=bestc(bestf==5)';
% Lc=bestc(bestf==1)';
% % for n=1:length(g1c)
% % g1cc(n)=find(g1c(n)==chanIDs);
% % end
% % for n=1:length(g2c)
% % g2cc(n)=find(g2c(n)==chanIDs);
% % end
% for n=1:length(Lc)
% Lcc(n)=find(Lc(n)==chanIDs);
% end
% 
% % gam1dir(:,i)=LG1(good1,2);
% % gam2dir(:,i)=LG2(good2,2);
% LMPdir(:,i)=LMP(goodL,2);
% end

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
