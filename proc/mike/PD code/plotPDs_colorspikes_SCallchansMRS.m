Filelist = dir(cd)
files = {Filelist.name}


for i = 1 :length(Mini_SpikeBC_filenames)
    
    filelist{i} = files(cellfun(@isempty,(regexp({Filelist.name},Mini_SpikeBC_filenames{i}(1,1:end-4))))== 0);
    
end

c=[];
zeromat=0;
for i=1:length(filelist)
    SPD=[];
    %   postfix='spikePDs_allchans_bs-05';   %LFP control file
    
    fnam = cell2mat(filelist{i});
    if ~exist(fnam,'file')
        SPDdir(:,i)=0;
        SPDmd(:,i)=0;
        confintS(:,i)=pi;
        continue
    end
    load(fnam,'spikePDs')
    SPD=spikePDs{1}(:,3:end);
    if i==1
        ul1=spikePDs{1}(:,1:2);
    else
        ul2=spikePDs{1}(:,1:2);
        [c,ia,ib]=setxor(ul1,ul2,'rows');    %
        if ~isempty(ia)     %if there are more channels in ul1 than ul2
            disp(['removing channels ',num2str(c(:,1)')])
            %             SPDdir(ia,i)=0;
            %             SPDmd(ia,i)=0;
            count=1;
            for jj=1:length(ia)
                ia(jj)=ia(jj)-count;        %need to do this to insert the correct rows into SPD
                count=count+1;
            end
            SPD=insertrows(SPD,0,ia);
        end
    end
    
    if size(SPD,1) == 84
        confintS(:,i)=circ_dist(SPD(:,3),SPD(:,1));
        SPDdir(:,i)=SPD(:,2);
        SPDmd(:,i)=SPD(:,4);
    else
        confintS(:,i) = zeros(84,1)
        SPDdir(:,i)= zeros(84,1);
        SPDmd(:,i)= zeros(84,1);
    end
    if i==1
        goodS=abs(confintS(:,i))<pi/3;
    end
    
end
SPDdirall=SPDdir;
SPDmdall=SPDmd;
SPDdir=SPDdir(goodS,:);
SPDmd=SPDmd(goodS,:);
%Compute dates
for i=1:length(filelist)
    dnum(i)=getfiledate(cell2mat(Mini_SpikeBC_filenames(i,2)));
    ndays(i)=daysact(dnum(1),dnum(i));
end

figure
% figure
subplot(2,1,1)
imagesc(ndays,1:size(SPDdir,1),SPDdir)
title('PDs of spikes for Spike Brain control files')
xlabel('Day number')
subplot(2,1,2)
imagesc(confintS(goodS,:))
title('PD confints')
saveas(gcf,'spikePDs of Chewie_LFPdecoder2_files.fig')

Sdirect=SPDdir;

for j=1:size(SPDdir,2)
    for k=j:size(SPDdir,2)
        Cdircirc(j,k)=rho_c(Sdirect(:,j),Sdirect(:,k));
    end
end
figure
imagesc(ndays,ndays,Cdircirc)
title('Circular correlation coeff')

for j=1:size(SPDdir,2)
    for k=j:size(SPDdir,2)
        CCdir(j,k)=corr(Sdirect(:,j),Sdirect(:,k));
    end
end
figure
imagesc(CCdir)
title('linear corr coeff')

figure
imagesc(ndays,size(SPDdir,1),SPDmd)
title('Spike modulation depth')

