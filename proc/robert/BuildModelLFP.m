function [filter, varargout]=BuildModelLFP(fp, dataPath, fillen, binsize, ...
    PolynomialOrder, varargin)
    
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
    stop_time = min(length(y),length(fp))/samprate;
    fptimesadj = analog_times(1):1/samprate:stop_time;
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
fpf=filtfilt(b,a,fp')';  %fpf is channels X samples
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

if smoothfeats
    xtemp=smooth(x(:),21);      %sometimes smoothing features helps
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



% Calculate the filter

    numlags= round(fillen/binsize); %%%Designate the length of the filters/number of time lags
    % round helps getting rid of floating point error but care should
    % be taken in making sure fillen is a multiple of binsize.
    numsides=1;     %%%For a one-sided or causal filter

    Inputs = binnedData.spikeratedata(:,desiredInputs);

    %Uncomment next block to use PCs as inputs for predictions
    if 0

        [PCoeffs,Inputs] = princomp(zscore(Inputs));
        Inputs = Inputs(:,1:numPCs);
    end
        
    Outputs = [bdf.pos];
    OutNames = []; % labels?
        
    %%%The following calculates the linear filters (H) that relate the inputs and outputs
    [H,v,mcc]=filMIMO3(Inputs,Outputs,numlags,numsides,1);
    
% Then, add non-linearity if applicable
    fs=1;    
    [PredictedData,spikeDataNew,ActualDataNew]=predMIMO3(Inputs,H,numsides,fs,Outputs);
    
    P=[]; T=[]; patch=[];    
    if PolynomialOrder
        %%%Find a Wiener Cascade Nonlinearity
        for z=1:size(PredictedData,2)
            if Use_Thresh            
                %Find Threshold
                T_default = 1.25*std(PredictedData(:,z));
                [T(z,1), T(z,2), patch(z)] = findThresh(ActualDataNew(:,z),PredictedData(:,z),T_default);
                IncludedDataPoints = or(PredictedData(:,z)>=T(z,2),PredictedData(:,z)<=T(z,1));

                %Apply Threshold to linear predictions and Actual Data
                PredictedData_Thresh = PredictedData(IncludedDataPoints,z);
                ActualData_Thresh = ActualDataNew(IncludedDataPoints,z);

                %Replace thresholded data with patches consisting of 1/3 of the data to find the polynomial 
                Pred_patches = [ (patch(z)+(T(z,2)-T(z,1))/4)*ones(1,round(length(nonzeros(IncludedDataPoints))*4)) ...
                                 (patch(z)-(T(z,2)-T(z,1))/4)*ones(1,round(length(nonzeros(IncludedDataPoints))*4)) ];
                Act_patches = mean(ActualDataNew(~IncludedDataPoints,z)) * ones(1,length(Pred_patches));

                %Find Polynomial to Thresholded Data
                [P(z,:)] = WienerNonlinearity([PredictedData_Thresh; Pred_patches'], [ActualData_Thresh; Act_patches'], PolynomialOrder,'plot');
                
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%% Use only one of the following 2 lines:
                %
                %   1-Use the threshold only to find polynomial, but not in the model data
%                 T=[]; patch=[];                
                %
                %   2-Use the threshold both for the polynomial and to replace low predictions by the predefined value
                PredictedData(~IncludedDataPoints,z)= patch(z);
                %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            else
                %Find and apply polynomial
                [P(z,:)] = WienerNonlinearity(PredictedData(:,z), ActualDataNew(:,z), PolynomialOrder);
            end
            PredictedData(:,z) = polyval(P(z,:),PredictedData(:,z));
        end
    end
  
%% Outputs

    filter = struct('neuronIDs', neuronIDs, 'H', H, 'P', P, 'T',T,'patch',patch,'outnames', OutNames,'fillen',fillen, 'binsize', binsize);

    if Use_PrinComp
        filter.PC = PCoeffs(:,1:numPCs);
    end
    
    if nargout > 1
         PredData = struct('preddatabin', PredictedData, 'timeframe', ...
			 binnedData.timeframe(numlags:end),'spikeratedata',spikeDataNew, ...
			 'outnames',OutNames,'spikeguide',binnedData.spikeguide, ...
			 'vaf',RcoeffDet(PredictedData,ActualDataNew),'actualData',ActualDataNew);
        varargout(1) = {PredData};
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
