function [adaptC,adaptR,bestf,bestc] = adaptModel_fp_KF(sig,signal,numfp,binsize,~,~,samprate,fp,fptimes,analog_times,fnam,varargin)

% $Id: predictions.m 67 2009-03-23 16:13:12Z brian $
%2009-07-10 Marc predicts MIMO from field potentials
%addpath mimo
%addpath spike
%addpath bdf
%revised version has binsize input
%v4hum is for human subjects (or any with slow sig sampling rate. Doesn't interpolate fp
%but rather PB, later..
% v4hum also includes numsides, which is 1 if causal/ 2 if acausal
%v4all is for humans and monkeys, includes emg pred and outputs r2 as 2d
%array
%v5all is the same as 4all but adds Tikhunov regularization

%samprate is the fp sampling rate (don't need sig sampling rate since we
%have analog_time_base for that
%binsize is in seconds
%%%% Usage (for cyberglove):
% [vaf,vmean,vsd,y_test,y_pred,r2mean,r2sd,r2,vaftr,bestf,bestc,H,bestfeat,x,y,ytnew,xtnew] =...
% predictionsfromfp5all(vel,'vel',64,0.1,10,10,1,samprate,...
% fp,fptimes,analog_times,fnam,wsz,nfeat,PolynomialOrder,Use_Thresh,H,words,emgsamplerate,lambda);

%samprate is the fp sampling rate

%Polynomial order is the order of polynomial to use. Use_Thresh: default is
%0 (no threshold); setting to 1 uses a threshold to determine how to fit
%the polynomial (but not to decode with it). 
%numsides should be 1 for causal predictions (2 for acausal).

%modified 9/24/10 to get rid of 1st samples the length of the filter and to
%not remove the mean in this function (since FILMIMO does that already)
%modified 10/5/10 to add lambda as an input

%v6 (6/24/11) does not remove DC component in calculating fft and also does
%not subtract the mean from each time window before calculating fft

tic
if length(varargin)>0
    wsz=varargin{1};
    if length(varargin)>1
        nfeat=varargin{2};
        if length(varargin)>2 
            PolynomialOrder=varargin{3};    %for Wiener Nonlinear cascade
            if length(varargin)>3
                Use_Thresh=varargin{4};
                if length(varargin)>4 
                    if iscell(varargin{5})
                        H=varargin{5};
                        if length(varargin)>5
                            words=varargin{6};
                            if length(varargin)>6
                                emgsamplerate=varargin{7};
                                 if length(varargin)>7
                                     lambda=varargin{8};
                                     if length(varargin)>8
                                         smoothfeats=varargin{9};
                                     end
                                 end
                            end
                        end
                    else
                        words=varargin{5};
                        if length(varargin)>5
                            emgsamplerate=varargin{6};
                            if length(varargin)>6
                                lambda=varargin{7};
                                if length(varargin)>7
                                    smoothfeats=varargin{8};
                                    if length(varargin)>8
                                        A=varargin{9};
                                        C=varargin{10};
                                        Q=varargin{11};
                                        R=varargin{12};
                                        bestc=varargin{13};
                                        bestf=varargin{14};
                                        targets=varargin{15};
                                    end
                                end
                            end
                        end
                    end
                end                   
            else
                Use_Thresh=0;
            end
        else
            PolynomialOrder=0;
            Use_Thresh=0;
        end
%         words=varargin{3};
    end
end
if ~exist('smoothfeats','var')
    smoothfeats=0;  %default to no smoothing
end

if (strcmpi(signal,'vel') || (strcmpi(signal,'pos')) || (strcmpi(signal,'acc')))
    y=sig(:,2:end);
elseif strcmpi(signal,'emg')
    y=sig;
    %Rectify and filter emg

    EMG_hp = 50; % default high pass at 50 Hz
    EMG_lp = 5; % default low pass at 5 Hz
    if ~exist('emgsamplerate','var')
        emgsamplerate=2000; %default
    end

    [bh,ah] = butter(2, EMG_hp*2/emgsamplerate, 'high'); %highpass filter params
    [bl,al] = butter(2, EMG_lp*2/emgsamplerate, 'low');  %lowpass filter params
    tempEMG=y;
    tempEMG = filtfilt(bh,ah,tempEMG); %highpass filter
    tempEMG = abs(tempEMG); %rectify
    y = filtfilt(bl,al,tempEMG); %lowpass filter
%     if ~exist('temg','var')
%         temg=1/emgsamplerate:(1/emgsamplerate):(length(sig)*(samprate/emgsamplerate));
%     end
else
    y=sig;
end
samp_fact=1000/samprate;
% Adjust the size of fp to make sure same number of samples as analog
% signals

disp('fp adjust')
toc
tic
bs=binsize*samprate;    %This assumes binsize is in seconds.
numbins=floor(length(fptimes)/bs);   %Number of bins total
binsamprate=floor(1/binsize);   %sample rate due to binning (for MIMO input)
if ~exist('wsz','var')
    wsz=256;    %FFT window size
end

% Using binsize ms bins
if length(fp)~=length(y)
    stop_time = min(length(y),length(fp))/binsamprate; % THIS IS DIFFERENT FROM STOCK buildModel_fp
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

%Align numbins correctly
if length(t)>numbins
    t=t(1:numbins);
end
%     y = [interp1(bdf.vel(:,1), y(:,1), t); interp1(bdf.vel(:,1), y(:,2), t)]';
% if size(y,2)>1
if t(1)<analog_times(1)
    t(1)=analog_times(1);   %Do this to avoid NaNs when interpolating
end
y = interp1(analog_times, y, t);    %This should work for all numbers of outputs as long as they are in columns of y

if size(y,1)==1
    y=y(:); %make sure it's a column vector
end

% % Find active regions
% if exist('words','var') && ~isempty(words)
%     q = find_active_regions_words(words,analog_times);
% else
    q=ones(1,length(analog_times));   %Temp kludge b/c find_active_regions gives too long of a vector back
% end
% q = interp1(analog_times, double(q), t);

disp('2nd part:assign t,y,q')
toc
LMP=zeros(numfp,length(y));

tic
% Calculate LMP
win=repmat(hanning(wsz),1,numfp); %Put in matrix for multiplication compatibility
tfmat=zeros(wsz,numfp,numbins,'single');
% Notch filter for 60 Hz noise
[b,a]=butter(2,[58 62]/(samprate/2),'stop');
fpf=filtfilt(b,a,double(fp)')';  %fpf is channels X samples
clear fp
for i=1:numbins
    %     LMP(:,i)=mean(fpf(:,bs*(i-1)+1:bs*i),2);
    tmp=fpf(:,(bs*(i-1)+1:(bs*(i-1)+wsz)))';    %Make tmp samples X channels
    LMP(:,i)=mean(tmp',2);
    %     tmp=tmp-repmat(mean(tmp,1),wsz,1);
    %     tmp=detrend(tmp);
    tmp=win.*tmp;
    tfmat(:,:,i)=fft(tmp,wsz);      %tfmat is freqs X chans X bins
    %     =tftmp(2:(wsz/2+1),:);
    clear tmp
end
clear fpf tftmp
freqs=linspace(0,samprate/2,wsz/2+1);
freqs=freqs(2:end); %remove DC freq(c/w timefreq.m)
% tvect=(1:numbins)*(bs)-bs/2;
disp('3rd part: calculate FFTs')
toc
tic
% Calculate bandpower
Pmat=tfmat(2:length(freqs)+1,:,:).*conj(tfmat(2:length(freqs)+1,:,:))*0.75;   %0.75 factor comes from newtimef (correction for hanning window)

Pmean=mean(Pmat,3); %take mean over all times
% Pmean=ones(size(Pmean)); % uncomment to not subtract the mean (testing purposes).
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
PB(5,:,:)=mean(PA(gam2,:,:),1);
if samprate>600
PB(6,:,:)=mean(PA(gam3,:,:),1);
end

% PB has dims freqs X chans X bins
disp('4th part: calculate bandpower')
toc
tic

for i=1:nfeat
    bestPB(i,:)=PB(bestf(i),bestc(i),:);
end

% convert x to freq bands
if exist('PB','var')
    numfreq=size(PB,1); %#frequency bands
else
    numfreq=0;
end
%No need to interpolate bestPB because both it and y have numbins length
% [x,mu,sigma]=zscore(bestPB');
x=bestPB';

if smoothfeats > 0
    xtemp=smooth(x(:),smoothfeats);      %sometimes smoothing features helps
	x=reshape(xtemp,size(x));
end
disp('5th part: select best features')
disp(['selected best ',num2str(nfeat),' features, time: '])
toc
tic
% continue with predictions
% x = x(q==1,:);
% y = y(q==1,:);

% % from here, different from predictionsfromfp6.m
% vaf = zeros(1,size(y,2));
% r2 = zeros(1,2);
% fold_length = length(y);
% 
% x_test=cell(1,1);
% y_test=x_test;
% y_pred=y_test;
% if ~exist('lambda','var')
% 	lambda=1;
% end

% reorder x so that it's cast back into the arrangemnt in which it will
% ultimately be evaluated online: that of cells and bands.
[~,sortInd]=sortrows([rowBoat(bestc), rowBoat(bestf)]);
% the default operation of sortrows is to sort first on column 1, then do a
% secondary sort on column 2, which is exactly what we want, so we're done.
x=x(:,sortInd);

% above this point, should stay the same as buildModel_fp.m
% now, implement the Kalman filter instead of the Wiener filter.
% appending ones after the pos/vel was something that Amy did in order to
% account for non-zero mean firing rates of neurons.  PB (and therefore x)
% should be zero mean?  check out why any feature would have non-zero mean.

% This would be what I would classically do.
% [A, C, Q, R] = train_kf([y, ones(size(y,1),1)],x);
% ...however, this leads to Q and R matrices that are of less than 
% full rank.  In particular, Q ends up being 4 rather than 5 and R
% ends up somewhere around 139 instead of 150.  Eliminating the 
% appended 1s column takes care of Q (Amy O's stated reason for adding
% this column in the first place was to account for nonzero basline 
% firing rates in the neurons; however, we're dealing with continuous
% time signals that should in theory at least, have zero mean.
% To keep R as full rank, we want to limit x to around 100(?) features
% instead of 150
disp('6th part: retrain Kalman matrices')
tic
[adaptC,adaptR]=adapt_kf(x',y(1,:)',Q,A,C,Q,R,targets,binsize,words);
toc
% with these values, the model would be
% y(t) = A*y(t-1) + w(t)
% x(t) = C*y(t) + q(t)
% where
% w(t) ~ N(0,Q)
% q(t) ~ N(0,R)
