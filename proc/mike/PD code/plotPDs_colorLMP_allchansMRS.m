
filelist= Chewie_filenames;

for i=1:length(filelist)
 fnam=[filelist{i}]
 try
 load([fnam(1:end-4),'_pdsallchanspos_bs-1wsz100mnpowlogLMPcos.mat'],'LFPfilesPDs')
 catch
     continue
 end
 LMP=LFPfilesPDs{1};
%     LG1=LFPfilesPDs{1}{2};
%     LG2=LFPfilesPDs{1}{3};
% confint(:,i)=circ_dist(LG1(:,3),LG1(:,1));
% confint2(:,i)=circ_dist(LG2(:,3),LG2(:,1));
confintL(:,i)=circ_dist(LMP(:,3),LMP(:,1));
if i==1
%     good1=abs(confint(:,i))<pi/2;
%     good2=abs(confint2(:,i))<pi/2;
    goodL=abs(confintL(:,i))<pi/2;
end
% chaninds1=chanIDs(good1);
% chaninds2=chanIDs(good2);
% chanindsL=chanIDs(goodL);
dummy=1:96;
chanindsL=dummy(goodL);
% g1c=bestc(bestf==4)';
% g2c=bestc(bestf==5)';
Lc=bestc(bestf==1)';
% for n=1:length(g1c)
% g1cc(n)=find(g1c(n)==chanIDs);
% end
% for n=1:length(g2c)
% g2cc(n)=find(g2c(n)==chanIDs);
% end
% for n=1:length(Lc)
% Lcc(n)=find(Lc(n)==chanIDs);
% end

% gam1dir(:,i)=LG1(good1,2);
% gam2dir(:,i)=LG2(good2,2);
LMPdir(:,i)=LMP(goodL,2);
end
figure
% subplot(2,1,1)
% imagesc(gam1dir)
% title('PDs, gamma1band')
% subplot(2,1,2)
% imagesc(confint(good1,:))
% title('PD confints')
% saveas(gcf,'LFPPDs of Chewie_Spike_LFP090211-032112 gam1band.fig')
% figure
% subplot(2,1,1)
% imagesc(gam2dir)
% title('PDs, gamma2band')
% subplot(2,1,2)
% imagesc(confint2(good2,:))
% title('PD confints')
% saveas(gcf,'LFPPDs of Chewie_Spike_LFP090211-032112 gam2band.fig')
% 
% figure
subplot(2,1,1)
imagesc(LMPdir)
title('PDs, LMP')
subplot(2,1,2)
imagesc(confintL(goodL,:))
title('PD confints')
saveas(gcf,'LFPPDs of Chewie_Spike_LFP090211-032112 LMP.fig')


goodLchans=setdiff(chanindsL,badChannels);
narrowgoodL=ismember(chanindsL,goodLchans);    %These are channels that have good tuning and are good channels
DirNGL=ismember(chainindsL(narrowgoodL),Lc);
Ldirect=LMPdir(DirNGL,:);
figure
imagesc(Ldirect)
title('Direct LMP chans only')

for j=1:size(LMPdir,2)
for k=j:size(LMPdir,2)
Cdircirc(j,k)=rho_c(Ldirect(:,j),Ldirect(:,k));
end
end
figure
imagesc(Cdircirc)

for j=1:size(LMPdir,2)
for k=j:size(LMPdir,2)
CCdir(j,k)=corr(Ldirect(:,j),Ldirect(:,k));
end
end
figure
imagesc(CCdir)
