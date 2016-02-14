function [PB t y] = calculateBandPower(wsz, numfp, numbins, samprate, fp, binsize, y, t)

bs=binsize*samprate;
%% Calculate LMP
win=repmat(hanning(wsz),1,numfp); %Put in matrix for multiplication compatibility
tfmat=zeros(wsz,numfp,numbins,'single');
%% Notch filter for 60 Hz noise
[b,a]=butter(2,[58 62]/(samprate/2),'stop');
fpf=filtfilt(b,a,fp')';  %fpf is channels X samples
clear fp
itemp=1:257;
firstind=find(bs*itemp>wsz,1,'first');
for i=1:numbins
    ishift=i-firstind+1;
    if ishift<=0
        continue
    elseif ishift == 1
        LMP=zeros(numfp,length(y)-firstind+1);
    end
    %     LMP(:,i)=mean(fpf(:,bs*(i-1)+1:bs*i),2);
    tmp=fpf(:,(bs*i-wsz+1:bs*i))';    %Make tmp samples X channels
    LMP(:,ishift)=mean(tmp',2);
    %     tmp=tmp-repmat(mean(tmp,1),wsz,1);
    %     tmp=detrend(tmp);
    tmp=win.*tmp;
    tfmat(:,:,ishift)=fft(tmp,wsz);      %tfmat is freqs X chans X bins
    clear tmp tftmp
end
%Now need to clean up tfmat to account for cutting off the firstind bins
tfmat(:,:,(ishift+1:end))=[];
numbins=numbins-firstind+1;

% t=t(1:numbins-firstind+1);
t(ishift+1:end)= [];
y(ishift+1:end,:)=[];
clear fpf
freqs=linspace(0,samprate/2,wsz/2+1);
freqs=freqs(2:end); %remove DC freq(c/w timefreq.m)
tvect=(firstind:numbins)*(bs)-bs/2;


disp('3rd part: calculate FFTs')
%% Calculate bandpower
% remove DC component of frequency vector
Pmat=tfmat(2:length(freqs)+1,:,:).*conj(tfmat(2:length(freqs)+1,:,:))*0.75;
Pmean=mean(Pmat,3); %take mean over all times
PA=10.*(log10(Pmat)-repmat(log10(Pmean),[1,1,numbins]));
clear Pmat

%Define freq bands
delta=freqs<4;
mu=((freqs>7) & (freqs<20));
gam1=(freqs>70)&(freqs<115);
gam2=(freqs>130)&(freqs<200);
gam3=(freqs>200)&(freqs<300);
PB(1,:,:)=LMP;
PB(2,:,:)=mean(PA(delta,:,:),1);
PB(3,:,:)=mean(PA(mu,:,:),1);
PB(4,:,:)=mean(PA(gam1,:,:),1);
%MRS 8/31/11
PB(5,:,:)=mean(PA(gam2,:,:),1);
if samprate>600
    PB(6,:,:)=mean(PA(gam3,:,:),1);
end