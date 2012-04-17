function [featMat,y,t] = makefmatc_causal(fp,fptimes,numfp, binsize,samprate,analog_times,wsz,y)

% samp_fact=1000/samprate;
%% Adjust the size of fp to make sure same number of samples as analog
%% signals

% disp('fp adjust')
% toc
% tic
% dirscript_monk
% load
bs=binsize*samprate;    %This assumes binsize is in seconds.
numbins=floor(length(fptimes)/bs);   %Number of bins total
binsamprate=floor(1/binsize);   %sample rate due to binning (for MIMO input)
% if ~exist('wsz','var')
%     wsz=256;    %FFT window size
% end

% Using binsize ms bins
if length(fp)~=length(y)
    stop_time = min([y(end,1), length(fp)/1000]);
    fptimesadj = analog_times(1):1/samprate:stop_time;
    %          fptimes=1:samp_fact:length(fp);
    if fptimes(end)>stop_time   %If fp is longer than stop_time( need this because of get_plexon_data silly way of labeling time vector)
        fpadj=interp1(fptimes,fp',fptimesadj);
        fp=fpadj';
        clear fpadj
        numbins=floor(length(fptimes)/bs);
    end
end
t = analog_times(1):binsize:analog_times(end);
while ((numbins-1)*bs+wsz)>length(fp)
    numbins=numbins-1;  %if wsz is much bigger than bs, may be too close to end of file
end
%
% %Align numbins correctly
if length(t)>numbins
    t=t(1:numbins);
end

y = interp1(analog_times, y, t);    %This should work for all numbers of outputs as long as they are in columns of y

tic
%% Calculate LMP
win=repmat(hanning(wsz),1,numfp); %Put in matrix for multiplication compatibility
tfmat=zeros(wsz,numfp,numbins,'single');
%% Notch filter for 60 Hz noise
[b,a]=butter(2,[58 62]/(samprate/2),'stop');
fpf=filtfilt(b,a,fp')';  %fpf is channels X samples
clear fp
itemp=1:10;
firstind=find(bs*itemp>wsz,1,'first');
for i=1:numbins
    ishift=i-firstind+1;
    if ishift<=0
        continue
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
t=t(1:numbins);
y(ishift+1:end,:)=[];
clear fpf
freqs=linspace(0,samprate/2,wsz/2+1);
freqs=freqs(2:end); %remove DC freq(c/w timefreq.m)
tvect=(firstind:numbins)*(bs)-bs/2;
disp('3rd part: calculate FFTs')
toc
tic
%% Calculate bandpower
Pmat=tfmat(2:length(freqs)+1,:,:).*conj(tfmat(2:length(freqs)+1,:,:))*0.75;   %0.75 factor comes from newtimef (correction for hanning window)

Pmean=mean(Pmat,3); %take mean over all times
PA=10*(log10(Pmat)-repmat(log10(Pmean),[1,1,numbins]));
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
PB(5,:,:)=mean(PA(gam2,:,:),1);
if samprate>600
    PB(6,:,:)=mean(PA(gam3,:,:),1);
end
% PB has dims freqs X chans X bins

pbrot=shiftdim(PB,2);
featMat=reshape(pbrot,[],size(PB,1)*size(PB,2));
