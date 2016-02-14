function [PB r1 sr featind y t] = MRScalcFeatMat(sig, signal, numfp, ...
    binsize, folds,numlags,numsides,samprate,fp,fptimes,analog_times,fnam,varargin)

% $Id: predictions.m 67 2009-03-23 16:13:12Z brian $
%2013-05-28 Calculates PB, interpolated y (signal being predicted) and
%outputs the highest ranked features

% CalcWhat      - if 1 calculate y only, if 2 PB only, if 3 both.

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
                    if ~isempty(varargin{5})
                        H=varargin{5};
                        if length(varargin)>5
                            words=varargin{6};
                            if length(varargin)>6
                                emgsamplerate=varargin{7};
                                if length(varargin)>7
                                    lambda=varargin{8};
                                    if length(varargin)>8
                                        smoothfeats=varargin{9};
                                        if length(varargin)>9 && ~isempty(varargin{10})
                                            featind=varargin{10};
                                            if length(varargin)>10 && ~isempty(varargin{11})
                                                P=varargin{11};
                                                if length(varargin)>11 && ~isempty(varargin{12})
                                                    featMat = varargin{12};
                                                    if length(varargin)>12 && ~isempty(varargin{13})
                                                        CalcWhat = varargin{13};
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    else
                        words=varargin{6};
                        if length(varargin)>6
                            emgsamplerate=varargin{7};
                            if length(varargin)>7
                                lambda=varargin{8};
                                if length(varargin)>8
                                    smoothfeats=varargin{9};
                                    if length(varargin)>9 && ~isempty(varargin{10})
                                        featind=varargin{10};
                                        if length(varargin)>10 && ~isempty(varargin{11})
                                            featMat = varargin{11};
                                            if length(varargin)>12 && ~isempty(varargin{12})
                                                CalcWhat = varargin{13};
                                            end
                                        end
                                    else
                                        CalcWhat = varargin{13};
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
    y=sig(:,2:3);
elseif strcmpi(signal,'emg')
    y=sig;
    %Rectify and filter emg
    
    EMG_hp = 50; % default high pass at 50 Hz
    EMG_lp = 5; % default low pass at 10 Hz
    if ~exist('emgsamplerate','var')
        emgsamplerate=1000; %default
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
%% Adjust the size of fp to make sure same number of samples as analog
%% signals

disp('fp adjust')
toc
tic
bs=binsize*samprate;    %This assumes binsize is in seconds.
numbins=floor(length(fptimes)/bs);   %Number of bins total
binsamprate=floor(1/binsize);   %sample rate due to binning (for MIMO input)
if ~exist('wsz','var')
    wsz=256;    %FFT window size
end

if exist('CalcWhat','var') == 0
    CalcWhat = 3;
end

if CalcWhat == 1 || CalcWhat == 3
    
    
    PB = [];
    r1 = [];
    sr = []; 
    featind = []; 
    
    %MRS modified 12/13/11
    % Using binsize ms bins
 if length(fp)~=length(y)
    stop_time = min(length(y),length(fp))/samprate;
    if stop_time < 50 % BC case.
        stop_time = min(length(y),length(fp))/binsamprate;
    end
    fptimesadj = analog_times(1):1/samprate:stop_time;
%          fptimes=1:samp_fact:length(fp);
    if fptimes(1) < 1   %If fp is longer than stop_time( need this because of get_plexon_data silly way of labeling time vector)
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

% Find active regions
% if exist('words','var') && ~isempty(words)
%     q = find_active_regions_words(words,analog_times);
% else
    q=ones(1,length(analog_times));   %Temp kludge b/c find_active_regions gives too long of a vector back
% end
q = interp1(analog_times, double(q), t);
    
    disp('2nd part:assign t,y,q')
    toc
    %LMP=zeros(numfp,length(y));
    
    tic
    
end   
    %% Calculate LMP
if CalcWhat == 2 || CalcWhat == 3
    
    win=repmat(hanning(wsz),1,numfp); %Put in matrix for multiplication compatibility
    tfmat=zeros(wsz,numfp,numbins,'single');
    %% Notch filter for 60 Hz noise
    [b,a]=butter(2,[58 62]/(samprate/2),'stop');
    fp=filtfilt(b,a,fp')';  %fpf is channels X samples
    fpf =fp;
    clear fp
    itemp=1:numlags;
    if numlags < 5
        itemp = 1:6;
    end
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
    t=t(firstind:end);
    y(1:firstind-1,:)=[];
    q(:,ishift+1:end)=[];
    clear fpf
    freqs=linspace(0,samprate/2,wsz/2+1);
    freqs=freqs(2:end); %remove DC freq(c/w timefreq.m)
    tvect=(firstind:numbins)*(bs)-bs/2;
    
    disp('3rd part: calculate FFTs')
    toc
    tic
    %% Calculate bandpower
    % remove DC component of frequency vector
    Pmat=tfmat(2:length(freqs)+1,:,:).*conj(tfmat(2:length(freqs)+1,:,:))*0.75;
    %0.75 factor comes from newtimef (correction for hanning window)
    
    % Pmean=mean(Pmat,3); %take mean over all times
    % instead of taking the mean over all times, calculate a running average
    % (more similar to how BrainReader does it).  To use filter, must rearrange
    % so that time is the first dimension
    % Pmean=shiftdim(Pmat,2);
    % now shift back to original dimensions
    Pmean=mean(Pmat,3); %take mean over all times
    PA=10.*(log10(Pmat)-repmat(log10(Pmean),[1,1,numbins]));
    clear Pmat
    
    %Define freq bands
    delta=freqs<4;
    mu=((freqs>7) & (freqs<20));
    gam0=(freqs>30)&(freqs<50);
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
    PB(7,:,:)=mean(PA(gam0,:,:),1);
    % PB has dims freqs X chans X bins
    disp('4th part: calculate bandpower')
    toc
    tic
    
%     PB = PB(:,:,q==1);
%     y = y(q==1,:);
  
%     if ~verLessThan('matlab','7.7.0') || size(y,2)>1
%         for c=1:size(PB,2)
%             for f=1:size(PB,1)
%                 rt1=corrcoef(y(:,1),squeeze(PB(f,c,:)));
%                 if size(y,2)>1                  %%%%% NOTE: MODIFIED THIS 1/10/11 to use
%                     % ALL outputs in calculating bestfeat
%                     % (orig modified 12/13/10 for 2 outputs)
%                     rsum=abs(rt1);
%                     for n=2:size(y,2)
%                         rtemp=corrcoef(y(:,n),squeeze(PB(f,c,:)));
%                         rsum=rsum+abs(rtemp);
%                     end
%                     rt=rsum/n;
%                     %                 rt=(abs(rt1)+abs(rt2))/2;
%                 else
%                     rt=rt1;
%                 end
%                 r(f,c)=rt(1,2);    %take absolute value of r
%             end
%         end
%     else  % if older versions than 2008 (7.7.0), corrcoef outputs a scalar;
%         % in newer versions it outputs matrix for vectors
%         for c=1:size(PB,2)
%             for f=1:size(PB,1)
%                 rt1=corrcoef(y(:,1),squeeze(PB(f,c,:)));
%                 if size(y,2)>1
%                     rsum=abs(rt1);
%                     for n=2:size(y,2)
%                         rtemp=corrcoef(y(:,n),squeeze(PB(f,c,:)));
%                         rsum=rsum+abs(rtemp);
%                     end
%                     rt=rsum/n;
%                 else
%                     rt=rt1;
%                 end
%                 
%                 r(f,c)=abs(rt);    %take absolute value of r
%             end
%         end
%     end
%     r1=reshape(r,1,[]);
%     r1(isnan(r1))=0;    %If any NaNs, set them to 0 to not mess up the sorting
%     
%     [sr,featind]=sort(r1,'descend');
end
end

