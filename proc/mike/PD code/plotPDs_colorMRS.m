filelist={'Chewie_Spike_LFP_0902201100','Chewie_Spike_LFP_0902201100','Chewie_Spike_LFP_0906201100',...
    'Chewie_Spike_LFP_0907201100','Chewie_Spike_LFP_0907201100','Chewie_Spike_LFP_0908201100','Chewie_Spike_LFP_0908201100',...
    'Chewie_Spike_LFP_0909201100','Chewie_Spike_LFP_0919201100','Chewie_Spike_LFP_0926201100','Chewie_Spike_LFP_1024201100','Chewie_Spike_LFP_0106201200',...
    'Chewie_Spike_LFP_0117201200','Chewie_Spike_LFP_0130201200','Chewie_Spike_LFP_0215201200','Chewie_Spike_LFP_0217201200',...
    'Chewie_Spike_LFP_0222201200','Chewie_Spike_LFP_0305201200','Chewie_Spike_LFP_0312201200',...
   'Chewie_Spike_LFP_0321201200','Chewie_Spike_LFP_0321201200'}
numlist={'2','3','2','3','4','2','3','5','2','4','7','9','8','2','3','3','3','5','2','2','3'};

for i=1:length(filelist)
 fnam=[filelist{i},numlist{i}]
 load([fnam,'_pdsallchanspos_bs-05wsz256mnpowlogLMP.mat'],'LFPfilesPDs')
    Delt=LFPfilesPDs{1}{1};
    LG1=LFPfilesPDs{1}{2};
    LG2=LFPfilesPDs{1}{3};
confint(:,i)=circ_dist(LG1(:,3),LG1(:,1));
confint2(:,i)=circ_dist(LG2(:,3),LG2(:,1));
confintd(:,i)=circ_dist(Delt(:,3),Delt(:,1));
if i==1
    good1=abs(confint(:,i))<pi/2;
    good2=abs(confint2(:,i))<pi/2;
    goodd=abs(confintd(:,i))<pi/2;
end
chaninds1=chanIDs(good1);
chaninds2=chanIDs(good2);
chanindsd=chanIDs(goodd);
g1c=bestc(bestf==4)';
g2c=bestc(bestf==5)';
dc=bestc(bestf==2)';
for n=1:length(g1c)
g1cc(n)=find(g1c(n)==chanIDs);
end
for n=1:length(g2c)
g2cc(n)=find(g2c(n)==chanIDs);
end
for n=1:length(dc)
dcc(n)=find(dc(n)==chanIDs);
end

gam1dir(:,i)=LG1(good1,2);
gam2dir(:,i)=LG2(good2,2);
deltdir(:,i)=Delt(goodd,2);
end
figure
subplot(2,1,1)
imagesc(gam1dir)
title('PDs, gamma1band')
subplot(2,1,2)
imagesc(confint(good1,:))
title('PD confints')
saveas(gcf,'LFPPDs of Chewie_Spike_LFP090211-032112 gam1band.fig')
figure
subplot(2,1,1)
imagesc(gam2dir)
title('PDs, gamma2band')
subplot(2,1,2)
imagesc(confint2(good2,:))
title('PD confints')
saveas(gcf,'LFPPDs of Chewie_Spike_LFP090211-032112 gam2band.fig')

figure
subplot(2,1,1)
imagesc(deltdir)
title('PDs, delta band')
subplot(2,1,2)
imagesc(confintd(goodd,:))
title('PD confints')
saveas(gcf,'LFPPDs of Chewie_Spike_LFP090211-032112 delta band.fig')

% for i=1:length(filelist)
%     if i
ccg1=corr(gam1dir);