function [vaf,vmean,vsd,y_test,y_pred,varargout] = predictionsfromfp6_alphabeta_only(sig, signal, numfp, binsize, folds,numlags,numsides,samprate,fp,fptimes,analog_times,fnam,varargin)

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
    EMG_lp = 5; % default low pass at 10 Hz
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

% Using binsize ms bins
if length(fp)~=length(y)
    stop_time = min(length(y),length(fp))/samprate;
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

% Find active regions
if exist('words','var') && ~isempty(words)
    q = find_active_regions_words(words,analog_times);
else
    q=ones(1,length(analog_times));   %Temp kludge b/c find_active_regions gives too long of a vector back
end
q = interp1(analog_times, q, t);

disp('2nd part:assign t,y,q')
toc
LMP=zeros(numfp,length(y));

tic
%% Calculate LMP
win=repmat(hanning(wsz),1,numfp); %Put in matrix for multiplication compatibility
tfmat=zeros(wsz,numfp,numbins,'single');
%% Notch filter for 60 Hz noise
[b,a]=butter(2,[58 62]/(samprate/2),'stop');
fpf=filtfilt(b,a,double(fp)')';  %fpf is channels X samples
% clear fp
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
tvect=(1:numbins)*(bs)-bs/2;
disp('3rd part: calculate FFTs')
toc
tic
%% Calculate bandpower
Pmat=tfmat(2:length(freqs)+1,:,:).*conj(tfmat(2:length(freqs)+1,:,:))*0.75;   %0.75 factor comes from newtimef (correction for hanning window)

Pmean=mean(Pmat,3); %take mean over all times
PA=10.*(log10(Pmat)-repmat(log10(Pmean),[1,1,numbins]));
clear Pmat

%Define freq bands
delta=freqs<4;
mu=((freqs>7) & (freqs<20));
alphabeta=(freqs>=20) & (freqs<70);
gam1=(freqs>70)&(freqs<115);
gam2=(freqs>130)&(freqs<200);
gam3=(freqs>200)&(freqs<300);
PB(1,:,:)=LMP;
PB(2,:,:)=mean(PA(delta,:,:),1);
PB(3,:,:)=mean(PA(mu,:,:),1);
PB(4,:,:)=mean(PA(alphabeta,:,:),1);
% formerly PB(4,:,:)
PB(5,:,:)=mean(PA(gam1,:,:),1);
% formerly PB(5,:,:)
PB(6,:,:)=mean(PA(gam2,:,:),1);
% formerly PB(6,:,:)
if samprate>600
PB(7,:,:)=mean(PA(gam3,:,:),1);
end

% isolate powerbands for individual-band analysis.  Most times this will
% remain commented.
PB([1:3 5:7],:,:)=[];


% PB has dims freqs X chans X bins
disp('4th part: calculate bandpower')
toc
tic
%% Select best Nfeat freq band/channel combos based on R2 value c/w 1st component
%%of y

if ~exist('nfeat','var')
    nfeat=100;
end
if ~verLessThan('matlab','7.7.0') || size(y,2)>1 
    for c=1:size(PB,2)
        for f=1:size(PB,1)
            rt1=corrcoef(y(:,1),squeeze(PB(f,c,:)));
            if size(y,2)>1                  %%%%% NOTE: MODIFIED THIS 1/10/11 to use ALL outputs in calculating bestfeat (orig modified 12/13/10 for 2 outputs)
                rsum=abs(rt1);
                for n=2:size(y,2)
                    rtemp=corrcoef(y(:,n),squeeze(PB(f,c,:)));
                    rsum=rsum+abs(rtemp);
                end
                rt=rsum/n;
%                 rt=(abs(rt1)+abs(rt2))/2;
            else
                rt=rt1;
            end
            if size(rt,2)>1
            r(f,c)=rt(1,2);    %take absolute value of r
            else
                r(f,c)=abs(rt);
            end
        end
    end
else %if older versions than 2008 (7.7.0), corrcoef outputs a scalar; in newer versions it outputs matrix for vectors
    for c=1:size(PB,2)
        for f=1:size(PB,1)
            rt1=corrcoef(y(:,1),squeeze(PB(f,c,:)));
            if size(y,2)>1
               rsum=abs(rt1);
                for n=2:size(y,2)
                    rtemp=corrcoef(y(:,n),squeeze(PB(f,c,:)));
                    rsum=rsum+abs(rtemp);
                end
                rt=rsum/n;
            else
                rt=rt1;
            end

            r(f,c)=abs(rt);    %take absolute value of r
        end
    end
end
r1=reshape(r,1,[]);
r1(isnan(r1))=0;    %If any NaNs, set them to 0 to not mess up the sorting
[sr,featind]=sort(r1,'descend');
[bestf,bestc]=ind2sub(size(r),featind(1:nfeat));
bestPB=single(zeros(nfeat,length(y)));
clear r     %clear this so we can reuse r later on
for i=1:nfeat
    bestPB(i,:)=PB(bestf(i),bestc(i),:);
end

%% convert x to freq bands
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
%% continue with predictions
x = x(q==1,:);
y = y(q==1,:);

vaf = zeros(folds,size(y,2));
r2 = zeros(folds,2);
fold_length = floor(length(y) ./ folds);

fprintf(1,'fold ')

x_test=cell(folds,1);
y_test=x_test;
y_pred=y_test;
if ~exist('lambda','var')
lambda=1;
end

% reorder x so that it's cast back into the arrangemnt in which it will
% ultimately be evaluated online: that of cells and bands.
[~,sortInd]=sortrows([rowBoat(bestc), rowBoat(bestf)]);
% the default operation of sortrows is to sort first on column 1, then do a
% secondary sort on column 2, which is exactly what we want, so we're done.
x=x(:,sortInd);

for i = 1:folds
    fold_start = (i-1) * fold_length + 1;
    fold_end = fold_start + fold_length-1;

    x_test{i} = x(fold_start:fold_end,:);
    y_test{i} = y(fold_start:fold_end,:);

    x_train = [x(1:fold_start,:); x(fold_end:end,:)];
    y_train = [y(1:fold_start,:); y(fold_end:end,:)];

    %%
    %%Try z-score instead of mean sub
%     y_train = zscore(y_train);
%     y_test{i} = zscore(y_test{i});
%     x_train = zscore(x_train);
%     x_test{i} = zscore(x_test{i});

    if length(varargin)<5 || ~iscell(varargin{5})                              % binsamprate
        [H{i},v,mcc] = FILMIMO3_tik(x_train, y_train, numlags, numsides,lambda,1);
%         [H{i},v,mcc]=filMIMO3(x_train,y_train,numlags,numsides,1);
        fprintf(1,'%d,',i)
    end                                                               % binsamprate
    [y_pred{i},xtnew{i},ytnew{i}] = predMIMO3(x_test{i},H{i},numsides,1,y_test{i});
    %ytnew and xtnew are shifted by the length of the filter since the
    %first fillen time period is garbage prediction & gets thrown out in
    %predMIMO3 (9-24-10)
           P=[];    
    T=[];
    patch = [];
    
    if PolynomialOrder
        %%%Find a Wiener Cascade Nonlinearity
        for z=1:size(y_pred{i},2)
            if Use_Thresh            
                %Find Threshold
                T_default = 1.25*std(y_pred{i}(:,z));
                [T(z,1), T(z,2), patch(z)] = findThresh(ytnew{i}(:,z),y_pred{i}(:,z),T_default);
                IncludedDataPoints = or(y_pred{i}(:,z)>=T(z,2),y_pred{i}(:,z)<=T(z,1));

                %Apply Threshold to linear predictions and Actual Data
                PredictedData_Thresh = y_pred{i}(IncludedDataPoints,z);
                ActualData_Thresh = ytnew{i}(IncludedDataPoints,z);

                %Replace thresholded data with patches consisting of 1/3 of the data to find the polynomial 
                Pred_patches = [ (patch(z)+(T(z,2)-T(z,1))/4)*ones(1,round(length(nonzeros(IncludedDataPoints))*4)) ...
                                 (patch(z)-(T(z,2)-T(z,1))/4)*ones(1,round(length(nonzeros(IncludedDataPoints))*4)) ];
                Act_patches = mean(ytnew{i}(~IncludedDataPoints,z)) * ones(1,length(Pred_patches));

                %Find Polynomial to Thresholded Data
                [P(z,:)] = WienerNonlinearity([PredictedData_Thresh; Pred_patches'], [ActualData_Thresh; Act_patches'], PolynomialOrder,'plot');
                
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%% Use only one of the following 2 lines:
                %
                %   1-Use the threshold only to find polynomial, but not in the model data
                T=[]; patch=[];                
                %
                %   2-Use the threshold both for the polynomial and to replace low predictions by the predefined value
%                 y_pred{i}(~IncludedDataPoints,z)= patch(z);
                %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            else
                %Find and apply polynomial
                [P(z,:)] = WienerNonlinearity(y_pred{i}(:,z), ytnew{i}(:,z), PolynomialOrder);
            end
            y_pred{i}(:,z) = polyval(P(z,:),y_pred{i}(:,z));
        end
    end

%     vaf(i,:) = 1 - var(y_pred{i} - y_test{i}) ./ var(y_test{i});
    vaftr(i,:)=v/100; %Divide by 100 because v is in percent
%     vaf(i,:) = 1 - var(y_pred{i} - ytnew{i}) ./ var(ytnew{i});
%     vaf(i,:) = 1 - sum( (y_pred{i}-ytnew{i}).^2 ) ./ sum( (ytnew{i} - repmat(mean(ytnew{i}),length(ytnew{i}),1)).^2 );
    vaf(i,:)=RcoeffDet(y_pred{i},ytnew{i});
    for j=1:size(y,2)
        r{i,j}=corrcoef(y_pred{i}(:,j),ytnew{i}(:,j));
%         
%     for j=1:size(y,2)
%         r{i,j}=corrcoef(y_pred{i}(:,j),y_test{i}(:,j));
        if size(r{i,j},2)>1
            r2(i,j)=r{i,j}(1,2)^2;
        else
            r2(i,j)=r{i,j}^2;
        end
    end
    %
    %     rx{i}=corrcoef(y_pred{i}(:,1),y_test{i}(:,1));
    %     if size(y,2)>1
    %         ry{i}=corrcoef(y_pred{i}(:,2),y_test{i}(:,2));
    %         r2y(i)=ry{i}(1,2)^2;
    %         r2x(i)=rx{i}(1,2)^2;
    %     else
    %         r2x(i)=rx{i}^2;
    %     end
    %


end
disp('5th part: do predictions')


vmean=mean(vaf);
vsd=std(vaf,0,1);
vaftrm=mean(vaftr);
r2mean=mean(r2);
r2sd=std(r2);

toc

figure
plot(ytnew{1}(:,1))
hold
plot(y_pred{1}(:,1),'r')

snam=[fnam,signal,' pred ',num2str(nfeat),' feats ',num2str(wsz),' wsz lambda ',num2str(lambda),'.mat'];
% save(snam,'r2*','v*','best*','x*','y*','nfeat','Poly*','Use*','num*','bin*','H','lambda','wsz')

if nargout>5
    varargout{1}=r2mean;
    varargout{2}=r2sd;
    if nargout>7
        varargout{3}=r2;
        if nargout>8
            varargout{4}=vaftr;
            if nargout>9
                varargout{5}=bestf;
                varargout{6}=bestc;
                if nargout>11
                    varargout{7}=H;
                end
                if nargout>12
                    varargout{8}=bestPB;
                    if nargout>13
                        %if outputting the whole PB matrix, put it in
                        %different dimensions: bins X (freqs*chans). Each
                        %column will be samples for one freq-chan
                        %combination, ordered by (f1c1,f2c1,f3c1...f6c1
                        %f1c2...)'
                        pbrot=shiftdim(PB,2);
                        featMat=reshape(pbrot,[],size(PB,1)*size(PB,2));
                        featMat=featMat(q==1,:);
                        varargout{9}=x;   %featMat contains ALL features 
                        varargout{10}=y;
                        varargout{11}=featMat;
                        if nargout>16
                            varargout{12}=ytnew;
                            varargout{13}=xtnew;
                            varargout{14}=t;
                            if nargout>19
                                varargout{15}=P;
                                varargout{16}=featind;
                                if nargout>21
                                    varargout{17}=sr;
                                end
                            end
                        end
                    end
                end
            end
        end
    end

end

function [Tinf, Tsup, patch] = findThresh(ActualData,LinPred,T)

    thresholding = 1;
    h = figure;
    xT = [0 length(LinPred)];
    offset = mean(LinPred)-mean(ActualData);
    LinPred = LinPred-offset;
    Tsup=mean(LinPred)+T;
    Tinf=mean(LinPred)-T;
    patch = mean(ActualData);
    
        while thresholding
            hold off; axis('auto');
            plot(ActualData,'b');
            hold on;
            plot(LinPred,'r');
            plot(xT,[Tsup Tsup],'k--',xT,[Tinf Tinf],'k--');
            legend('Actual Data', 'Linear Fit','Threshold');
            axis('manual');
            reply = input(sprintf('Redefine High Threshold? [%g] : ',Tsup));
            if ~isempty(reply)
                Tsup = reply;
            else
                thresholding=0;
            end
        end
        thresholding=1;
        while thresholding
            axis('auto');
            hold off;
            plot(ActualData,'b');
            hold on;
            plot(LinPred,'r');
            plot(xT,[Tsup Tsup],'k--',xT,[Tinf Tinf],'k--');
            legend('Actual Data', 'Linear Fit','Threshold');
            axis('manual');
            reply = input(sprintf('Redefine Low Threshold? [%g] : ',Tinf));
            if ~isempty(reply)
                Tinf = reply;
            else
                thresholding=0;
            end
        end
        thresholding=1;
        while thresholding
            axis('auto');
            hold off;
            plot(ActualData,'b');
            hold on;
            plot(LinPred,'r');
            plot(xT,[Tsup Tsup],'k--',xT,[Tinf Tinf],'k--', xT,[patch patch],'g');
            legend('Actual Data', 'Linear Fit','Threshold');
            axis('manual');
            reply = input(sprintf('Redefine Threshold Value? [%g] : ',patch));
            if ~isempty(reply)
                patch = reply;
            else
                thresholding=0;
            end
        end
        Tsup = Tsup+offset;
        Tinf = Tinf+offset;
        patch = patch+offset;
        
    close(h);
end
end
