function [beta_amp,betaphase,SPcounts,gam1_amp,gam1phase,SPcountsG1,gam2_amp,...
    gam2phase,SPcountsG2,SCphasebeta,SCphasegam1,SCphasegam2] = spikeLFPcoupl_PLX(bdf,samprate,binsize)
%This function creates a featMat using bandpass filtering to calculate
%power in different freq bands
% samp_fact=1000/samprate;
%% Adjust the size of fp to make sure same number of samples as analog
%% signals
% vPLX is for plexon recorded files (need to account for shift of 32
% channels in LFPs

bs=binsize*samprate;    %This assumes binsize is in seconds.
fp=cell2mat(bdf.raw.analog.data)';
fp=circshift(fp,64);            %Shift plexon files by 64 to make sure spikes line up with LFPs
fptimes=(1:length(fp))/samprate;
ul=unit_list(bdf);
bdf.raw.analog.data=[];
% numbins=floor(length(fptimes)/bs);   %Number of bins total
% binsamprate=floor(1/binsize);   %sample rate due to binning (for MIMO input)
% while ((numbins-1)*bs+wsz)>length(fp)
%     numbins=numbins-1;  %if wsz is much bigger than bs, may be too close to end of file
% end
%% Calculate LMP

%% Notch filter for 60 Hz noise
[b,a]=butter(2,[58 62]/(samprate/2),'stop');
fpf=filtfilt(b,a,double(fp'))';  %fpf is channels X samples
clear fp

[b2,a2]=butter(2,4/(samprate/2),'low');
[b3,a3]=butter(2,[4 8]/(samprate/2));
[b4,a4]=butter(2,[13 25]/(samprate/2));
[b5,a5]=butter(2,[70 110]/(samprate/2));
[b6,a6]=butter(2,[130 200]/(samprate/2));

% delta=filtfilt(b2,a2,fpf')';  %fpf is channels X samples
% theta=filtfilt(b3,a3,fpf')';  %fpf is channels X samples
beta=filtfilt(b4,a4,fpf')';  %fpf is channels X samples
gam1=filtfilt(b5,a5,fpf')';  %fpf is channels X samples
gam2=filtfilt(b6,a6,fpf')';  %fpf is channels X samples
clear fpf
%Downsample to 1 khz for simplicity

samp_fact=samprate/1000;
if samp_fact>1 && ~mod(samp_fact,1)
%     delta=downsample(delta',samp_fact)';
%     theta=downsample(theta',samp_fact)';
    beta=downsample(beta',samp_fact)';
    gam1=downsample(gam1',samp_fact)';
    gam2=downsample(gam2',samp_fact)';
end
nbins=50;
Npoints=floor(length(beta)/nbins);
beta=beta(:,1:Npoints*nbins);
% theta=theta(:,1:Npoints*nbins);
gam1=gam1(:,1:Npoints*nbins);
gam2=gam2(:,1:Npoints*nbins);

beta_amp=zeros(length(ul),nbins);
% theta_amp=beta_amp;
gam1_amp=beta_amp;
gam2_amp=beta_amp;
SPcounts=beta_amp;
SPcountsth=beta_amp;
SPcountsG1=beta_amp;
SPcountsG2=beta_amp;
spike=zeros(1,length(beta));
%% For each unit, determine spike-freq relationships
for u=1:length(ul)
    spike=zeros(1,length(beta));
    [ spiketemp, t ] = train2bins( bdf.units(u).ts, .001 );
    if length(spiketemp)<length(spike)
    spike(1:length(spiketemp))=spiketemp;       %use this to keep spike the same length as beta
    else
        spike=spiketemp(1:length(spike));   %if spiketemp is longer than beta
    end
    BETAH(:,u)=hilbert(beta(ul(u,1),:)');
%     THETAH(:,u)=hilbert(theta(ul(u,1),:)');
    GAM1H(:,u)=hilbert(gam1(ul(u,1),:)');
    GAM2H(:,u)=hilbert(gam2(ul(u,1),:)');
     
    betaA=abs(BETAH(:,u))/mean(abs(BETAH(:,u)));
    betaP=angle(BETAH(:,u));
%     thetaA=abs(THETAH(:,u))/mean(abs(THETAH(:,u)));
%     thetaP=angle(THETAH(:,u));
    gam1A=abs(GAM1H(:,u))/mean(abs(GAM1H(:,u)));
    gam1P=angle(GAM1H(:,u));
    gam2A=abs(GAM2H(:,u))/mean(abs(GAM2H(:,u)));
    gam2P=angle(GAM2H(:,u));
    
    M2=[betaA spike'];
    M2s=sortrows(M2,1);     %First sort spikes by amplitudes
    M3=reshape(M2s,[Npoints nbins 2]);
    M4=[betaP spike'];
    M4s=sortrows(M4,1);     %Then sort by phases
    M5=reshape(M4s,[Npoints nbins 2]);
    beta_amp(u,:)=mean(M3(:,:,1));
    SPcounts(u,:)= (1000/(Npoints))*sum(M3(:,:,2));
    betaphase(u,:)=mean(M5(:,:,1));
    SCphasebeta(u,:)=(1000/(Npoints))*sum(M5(:,:,2));
    
%     M2=[thetaA spike'];
%     M2s=sortrows(M2,1);
%     M3=reshape(M2s,[Npoints nbins 2]);
%     theta_amp(u,:)=mean(M3(:,:,1));
%     SPcountsth(u,:)= (1000/(Npoints))*sum(M3(:,:,2));
%     M4=[thetaP spike'];
%     M4s=sortrows(M4,1);
%     M5=reshape(M4s,[Npoints nbins 2]);
%     thetaphase(u,:)=mean(M5(:,:,1));
%     SCphasetheta(u,:)=(1000/(Npoints))*sum(M5(:,:,2));
    
    M2=[gam1A spike'];
    M2s=sortrows(M2,1);
    M3=reshape(M2s,[Npoints nbins 2]);
    gam1_amp(u,:)=mean(M3(:,:,1));
    SPcountsG1(u,:)= (1000/(Npoints))*sum(M3(:,:,2));
    M4=[gam1P spike'];
    M4s=sortrows(M4,1);
    M5=reshape(M4s,[Npoints nbins 2]);
    gam1phase(u,:)=mean(M5(:,:,1));
    SCphasegam1(u,:)=(1000/(Npoints))*sum(M5(:,:,2));
    
    M2=[gam2A spike'];
    M2s=sortrows(M2,1);
    M3=reshape(M2s,[Npoints nbins 2]);
    gam2_amp(u,:)=mean(M3(:,:,1));
    SPcountsG2(u,:)= (1000/(Npoints))*sum(M3(:,:,2));
    M4=[gam2P spike'];
    M4s=sortrows(M4,1);
    M5=reshape(M4s,[Npoints nbins 2]);
    gam2phase(u,:)=mean(M5(:,:,1));
    SCphasegam2(u,:)=(1000/(Npoints))*sum(M5(:,:,2));
end

%%
% Nplots=floor(length(ul)/16);

for u=1:length(ul)
    if (mod(u,16)-1)==0
        figure
        suptitle('Amplitude')
    end
    if mod(u,16)
    subplot(4,4,mod(u,16))
    else
        subplot(4,4,16)
    end
    plot(beta_amp(u,:),SPcounts(u,:),'k.')
    hold on
%     plot(theta_amp(u,:),SPcountsth(u,:),'m.')
    plot(gam1_amp(u,:),SPcountsG1(u,:),'g.')
    plot(gam2_amp(u,:),SPcountsG2(u,:),'r.')
end

%% Plot phase dependency
for u=1:length(ul)
    if (mod(u,16)-1)==0
        figure
        suptitle('Phase')
    end
    if mod(u,16)
    subplot(4,4,mod(u,16))
    else
        subplot(4,4,16)
    end
    plot(betaphase(u,:),SCphasebeta(u,:),'k.')
    hold on
%     plot(thetaphase(u,:),SCphasetheta(u,:),'m.')
    plot(gam1phase(u,:),SCphasegam1(u,:),'g.')
    plot(gam2phase(u,:),SCphasegam2(u,:),'r.')
end

%%
% compute combined phase-amplitude plot

% M=[gam1A(1:900000,22) gam1P(1:900000,22) spike(1:900000)'];
% M1=sortrows(M,1);
% M2=reshape(M1,[],100,3);
% for j=1:100
% M2s(:,j,:)=sortrows(squeeze(M2(:,j,:)),2);
% end
% for j=1:90
% phval(j,:)=mean(M2s((j-1)*100+1:j*100,:,2),1);
% spct(j,:)=mean(M2s((j-1)*100+1:j*100,:,3),1);
% end
% ampval=mean(M2s(:,:,1));
% phave=mean(phval,2)
% figure
% imagesc(phave,ampval,spct)

