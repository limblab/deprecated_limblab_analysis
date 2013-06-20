function [featMat,y]=calcFeatMat(fp,y,wsz,samprate,binsize,bandsToUse)

% fp must be numfp rows X [samples] columns.
numfp=size(fp,1);
bs=round(binsize*samprate);    %This assumes binsize is in seconds.
numbins=floor(size(fp,2)/bs);   %Number of bins total
fptimes=(1:size(fp,2))/samprate;
analog_times=(1:length(y))/samprate;

% if force, these two will already be identical and so will skip this block
if length(fp)~=length(y)
    stop_time = min(length(y),length(fp))/samprate;
    fptimesadj = analog_times(1):1/samprate:stop_time;
    if fptimes(end)>stop_time   
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

%Align numbins correctly
if length(t)>numbins
    t=t(1:numbins);
end

if t(1)<analog_times(1)
    t(1)=analog_times(1);   %Do this to avoid NaNs when interpolating
end
y=rowBoat(interp1(analog_times,y,t));

LMP=zeros(numfp,length(y));
win=repmat(hanning(wsz),1,numfp); %Put in matrix for multiplication compatibility
tfmat=zeros(wsz,numfp,numbins,'single');
% Notch filter for 60 Hz noise
[b,a]=butter(2,[58 62]/(samprate/2),'stop');
fpf=filtfilt(b,a,double(fp)')';  %fpf is channels X samples
clear fp
for i=1:numbins
    tmp=fpf(:,(bs*(i-1)+1:(bs*(i-1)+wsz)))';    %Make tmp samples X channels
%     if i==1 % to test with BCI2000 code.
%         disp('calculating LMP/tfmat causally for first bin.')
%         tmp(wsz-mod(wsz,bs)+1:end,:)=[];
%         tmp=[zeros(mod(wsz,bs),size(tmp,2)); tmp];
%     end
    LMP(:,i)=mean(tmp',2);
    tmp=win.*tmp;
    tfmat(:,:,i)=fft(tmp,wsz);      %tfmat is freqs X chans X bins
    clear tmp
    if i==1, fprintf(1,'progress: '), end
    if mod(i,floor(numbins/10))==0
        fprintf(1,'%.2f,',i/numbins)
    end
end
clear fpf tftmp
freqs=linspace(0,samprate/2,wsz/2+1);
freqs=freqs(2:end); %remove DC freq(c/w timefreq.m)
fprintf(1,'\nfirst frequency bin at %.3f Hz\n',freqs(1))
assignin('base','freqs',freqs)

% Calculate bandpower
%0.75 factor comes from newtimef (correction for hanning window)
Pmat=tfmat(2:length(freqs)+1,:,:).*conj(tfmat(2:length(freqs)+1,:,:))*0.75;   
clear tfmat
Pmean=mean(Pmat,3); %take mean over all times
PA=10.*(log10(Pmat)-repmat(log10(Pmean),[1,1,numbins]));
% disp('mean PA not being subtracted!!!')
% PA=Pmat; % to test with BCI2000 code
clear Pmat

%% Define freq bands
delta=freqs<4;
mu=((freqs>7) & (freqs<20));
gam1=(freqs>70)&(freqs<115);
gam2=(freqs>130)&(freqs<200);
gam3=(freqs>200)&(freqs<300);
% PB(1,:,:)=LMP;
% PB(2,:,:)=mean(PA(delta,:,:),1);
% PB(3,:,:)=mean(PA(mu,:,:),1);
% PB(4,:,:)=mean(PA(gam1,:,:),1);
% PB(5,:,:)=mean(PA(gam2,:,:),1);
% if samprate>600
%     PB(6,:,:)=mean(PA(gam3,:,:),1);
% end
PBtemp=[];
bndGroups=regexp(bandsToUse,'[0-9]+','match');
bands={'LMP','delta','mu','gam1','gam2','gam3'};
% to attempt to average LMP with anything is inappropriate, and will lead
% to unexpected results, probably errors.
startind=1;
if any(strcmp(bndGroups,'1'))
    PBtemp(1,:,:)=LMP;
    startind=2;
end
for n=startind:length(bndGroups)
    evalstr='PA(';
    bandInds=cellfun(@str2double,regexp(bndGroups{n},'[0-9]','match'));
    for k=1:length(bandInds)
        evalstr=[evalstr, sprintf(' %s | ',bands{bandInds(k)})];
    end, clear k
    evalstr(end-1:end)=''; evalstr=[evalstr,',:,:)'];
    PBtemp(n,:,:)=mean(eval(evalstr),1);
end, clear n startind
PB=PBtemp; clear PBtemp
% for testing with BCI2000 code
% temp=PB(:,:,1); assignin('base','PB',temp)

pbrot=shiftdim(PB,2);
featMat=reshape(pbrot,[],size(PB,1)*size(PB,2));