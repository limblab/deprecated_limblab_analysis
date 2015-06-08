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
win=repmat(hann(wsz),1,numfp); %Put in matrix for multiplication compatibility
tfmat=zeros(wsz,numfp,numbins,'single');
% Notch filter for 60 Hz noise
[b,a]=butter(2,[58 62]/(samprate/2),'stop');
fpf=filtfilt(b,a,double(fp)')';  %fpf is channels X samples
clear fp
% preparing to make bins causal
itemp=1:100;
firstind=find(bs*itemp>wsz,1,'first');
freqs=linspace(0,samprate/2,wsz/2+1);
freqs=freqs(2:end); %remove DC freq(c/w timefreq.m)
fprintf(1,'\nfirst frequency bin at %.3f Hz\n',freqs(1))
assignin('base','freqs',freqs)
Pmean=zeros(numel(2:length(freqs)+1),numfp);
databuf=zeros(numfp,wsz);
for i=1:numbins
    if nnz(databuf)~=0
        % shift buffer values leftwards
        databuf(:,1:(wsz-bs))=databuf(:,(1:(wsz-bs))+bs);
    end
    % read in new values into rightmost part of databuf
    databuf(:,(wsz-bs+1):wsz)=fpf(:,((i-1)*bs+1):(bs*i));
    % next 2 lines are to make it causal
    % ishift=i-firstind+1;
    % if ishift <= 0, continue, end
    % tmp=fpf(:,(bs*i-wsz+1:bs*i))';                %Make tmp samples X channels
    % LMP(:,ishift)=mean(tmp',2);
    LMP(:,i)=mean(databuf,2);
    % tmp=fpf(:,(bs*(i-1)+1:(bs*(i-1)+wsz)))';    %Make tmp samples X channels
    % LMP(:,i)=mean(tmp',2);
    % tmp=win.*tmp;
    % tfmat=fft(tmp,wsz);   %tfmat is freqs X chans X bins
    % tfmat(:,:,i)=fft(tmp,wsz);      %tfmat is freqs X chans X bins
    tfmat=fft(win.*databuf',wsz);
    % clear tmp
    % Pmat(:,:,ishift)=tfmat(2:length(freqs)+1,:).*conj(tfmat(2:length(freqs)+1,:))*0.75;
    Pmat(:,:,i)=tfmat(2:length(freqs)+1,:).*conj(tfmat(2:length(freqs)+1,:))*0.75;
    clear tfmat
    % Pmean=Pmean+(squeeze(Pmat(:,:,ishift))-Pmean)/ishift;
    Pmean=Pmean+(squeeze(Pmat(:,:,i))-Pmean)/i;
    % PA(:,:,ishift)=10.*(log10(squeeze(Pmat(:,:,ishift)))-log10(Pmean));
    PA(:,:,i)=10.*(log10(squeeze(Pmat(:,:,i)))-log10(Pmean));
    if i==1, fprintf(1,'progress: '), end
    if mod(i,floor(numbins/10))==0
        fprintf(1,'%.2f,',i/numbins)
    end
end
% % clean up tfmat to account for cutting off the firstind bins
% tfmat(:,:,(ishift+1:end))=[];
% numbins=numbins-firstind+1;
% if size(LMP,2)>numbins
%     LMP(:,numbins+1:end)=[];
% end
% if size(y,1)>numbins
%     y(numbins+1:end,:)=[];
% end

clear fpf

% % Calculate bandpower
% %0.75 factor comes from newtimef (correction for hanning window)
% Pmat=tfmat(2:length(freqs)+1,:,:).*conj(tfmat(2:length(freqs)+1,:,:))*0.75;   
% clear tfmat
% % instead of doing it this way:
% % Pmean=mean(Pmat,3); %take mean over all times
% % implement a mean calculation that is true to how it would be done if it
% % were dong online.  
% 
% PA=10.*(log10(Pmat)-repmat(log10(Pmean),[1,1,numbins]));                    %#ok<*NASGU>
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