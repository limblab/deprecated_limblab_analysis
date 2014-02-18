function [vafall,vmean,vsd,y_test,y_pred,varargout] =  predictionsfromSpikeByFPphase(sig, signal, numfp, ...
    binsize, folds,numlags,numsides,samprate,fp,fptimes,analog_times,fnam,varargin)

% $Id: predictions.m 67 2009-03-23 16:13:12Z brian $
%2009-07-10 Marc predicts MIMO from field potentials

% Need better documentation here.

%samprate is the fp sampling rate (don't need sig sampling rate since we
%have analog_time_base for that

%binsize is in seconds

%samprate is the fp sampling rate

% Polynomial order is the order of polynomial to use.

% Use_Thresh: default is 0 (no threshold); setting to 1 uses a threshold
% to determine how to fit the polynomial (but not to decode with it).

% numsides: should be 1 for causal predictions (2 for acausal).

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
                                        if length(varargin)>12 && ~isempty(varargin{13})
                                            bdf =varargin{13};
                                            if length(varargin)>13 && ~isempty(varargin{14})
                                                cells = varargin{14};
                                                %                                                 if length(varargin)>9 && ~isempty(varargin{10})
                                                %                                                     featind=varargin{10};
                                                %                                                     if length(varargin)>10 && ~isempty(varargin{11})
                                                %                                                         P=varargin{11};
                                                %                                                         if length(varargin)>11 && ~isempty(varargin{12})
                                                %                                                             featMat = varargin{12};
                                                %                                                         end
                                                %                                                     end
                                                %                                                 end
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
                                    if length(varargin)>12 && ~isempty(varargin{13})
                                        bdf =varargin{13};
                                        if length(varargin)>13 && ~isempty(varargin{14})
                                            cells = varargin{14};
                                            %                                             if length(varargin)>9 && ~isempty(varargin{10})
                                            %                                                 featind=varargin{10};
                                            %                                                 if length(varargin)>10 && ~isempty(varargin{11})
                                            %                                                     featMat = varargin{11};
                                            %                                                 end
                                            %                                             end
                                        end
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

%MRS modified 12/13/11
% Using binsize ms bins
if length(fp)~=length(y)
    stop_time = min(length(y),length(fp))/samprate;
    if stop_time < 50 % BC case.
        stop_time = min(length(y),length(fp))/binsamprate;
    end
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
% if exist('words','var') && ~isempty(words)
%     q = find_active_regions_words(words,analog_times);
% else
%     q=ones(1,length(analog_times));   %Temp kludge b/c find_active_regions gives too long of a vector back
% end
% q = interp1(analog_times, double(q), t);

disp('2nd part:assign t,y,q')
toc
%LMP=zeros(numfp,length(y));

tic

%win=repmat(hanning(wsz),1,numfp); %Put in matrix for multiplication compatibility

%% Notch filter for 60 Hz noise;
% Replace fp with a white noise signal
fp = randi([-2048 2048],96,length(fptimesadj));

[b0,a0]=butter(2,[58 62]/(samprate/2),'stop');
fpf=filtfilt(b0,a0,fp');
clear fp

%% Bandpass filter all interesting freqs
freqs = [4 8 12 20:10:300];
b = zeros(length(freqs),5);
a = zeros(length(freqs),5);
tfmat=zeros(1,numfp,size(fpf,1),'single'); %numfp

for c = 1:size(freqs,2)
    
    if c == 1
        [b1,a1]=butter(2,4/(samprate/2),'low');
        tfmat(1,:,:)=reshape(hilbert(filtfilt(b1,a1,fpf)),1,96,size(fpf,1));
        beep
        
    elseif c > 1
        
        [b,a]=butter(2,[freqs(c-1) freqs(c)]/(samprate/2));
        tfmat(1,:,:)=reshape(hilbert(filtfilt(b,a,fpf)),1,96,size(fpf,1));
        
    end
    
    %tfmat(:,:,(ishift+1:end))=[];
    PhaseMat = angle(tfmat);
    clear tfmat a b
    if c==1||c==7||c==12||c== 17||c==22||c==27||c==32
        PhaseMAT = reshape(squeeze(PhaseMat),size(PhaseMat,2)*size(PhaseMat,3),1);
        hist(PhaseMAT)
    end
    %      mean(mean(real(tfmat(:,1:10,:)).^2))
    
    tic
    [p_i] = findPhaseIndex(PhaseMat);
    toc
    
    %     if c >1
    %     save(['PhaseInfo_',num2str(freqs(c-1)),'-',num2str(freqs(c)),'_Chewie'],'p_i','PhaseMat')
    %     elseif c==1
    %     save(['PhaseInfo_','0-4','_Chewie'],'p_i','PhaseMat')
    %     end
    
    clear PhaseMat
    %% Bin Spikes and match to FP matrix
    
    x = zeros(size(fpf,1), 1); % num chans = 96
    
    for i = 1:length(cells)
        if cells(i,1) ~= 0
            ts = get_unit(bdf, cells(i, 1), cells(i, 2));
            b = train2bins(ts,fptimesadj);
            if cells(i,1) < 65
                x(:,cells(i,1)+32) = b;
            else
                x(:,cells(i,1)-64) = b;
            end
        else
            x(:,i) = zeros(length(y),1);
        end
    end
    
    % Don't think I need this since hilbert doesn't require any any points
    % to be cut off
    % x((ishift+1:end),:)=[];
    
    %% Now cut off appropriate bins in signal and time vector used for
    %% predictions
    
    %     firstind=find(bs*itemp>wsz,1,'first');
    %     for i=1:numbins
    %         ishift=i-firstind+1;
    %         if ishift<=0
    %             continue
    %         end
    %     end
    % Don't think I need this since hilbert doesn't require any any points
    % to be cut off
    % t=t(1:length(t)-firstind+1);
    % y(ishift+1:end,:)=[];
    % q(:,ishift+1:end)=[];
    
    %% Now loop and do predictions for all phases
    %   for c = 1:size(p_i,1)
    for u = 1:size(p_i{1},2)
        
        xTemp = x;
        %% Zero spike bins that are out of phase
        % Take coherent phase indices for all bins of this freq (c) - phase (u)
        % pair and convert to matrix (InPhaseIndex) to apply to binned spike
        % matrix (x)
        InPhaseIndex = reshape(p_i{1}(:,u,1:end),96,size(fpf,1))'; % 96
        
        % Here is the step where incoherent spike bins are zeroed
        xTemp(InPhaseIndex==0) = 0;
        
        xTempBin = zeros(size(y,1),size(fpf,2));
        % Now bin spikes for predictions
        for bin = 1:size(y,1)%numbins
            
            xTempBin(bin,:) = sum(xTemp(bs*(bin-1)+1:bs*bin,:));
            
        end
        clear InPhaseIndex
        % Keep track of number of spikes of each unit for each phase/freq
        % pair
        TotalSpikes_PerUnit(c,u,:) = sum(xTempBin);
        
        % Remove units that have no coherent spikes
        if nnz(sum(xTempBin)) ~= size(xTempBin,2)
            
            xTempBin(:,(sum(xTempBin) == 0)==1) = [];
            
        end
        
        % Keep track of number of units with coherent spikes for each
        % phase/freq
        TotalUnits(c,u) = size(xTempBin,2);
        
        y = y; % (q==1,:); -- this is the step where In_Active_regions are removed
        % Not sure if I should consider replacing this with a more appropriate
        % trial selection paradigm
        
        % Now do predictions with all units with respective coherent spike
        % bins
        vaf = zeros(folds,size(y,2));
        r2 = zeros(folds,2);
        fold_length = floor(length(y) ./ folds);
        
        x_test=cell(folds,1);
        y_test=x_test;
        y_pred=y_test;
        
        if ~exist('lambda','var')
            lambda=1;
        end
        for i = 1:folds
            if folds > 1
                fold_start = (i-1) * fold_length + 1;
                fold_end = fold_start + fold_length-1;
                
                x_test{i} = xTempBin(fold_start:fold_end,:);
                y_test{i} = y(fold_start:fold_end,:);
                
                x_train = [xTempBin(1:fold_start,:); xTempBin(fold_end:end,:)];
                y_train = [y(1:fold_start,:); y(fold_end:end,:)];
                
            else
                
                x_test{i} = xTempBin;
                y_test{i} = y;
                x_train = xTempBin;
                y_train = y;
                % Did this for testing
                %                 x_test{i} = [1:size(xTempBin,1)]'; %xTempBin
                %                 y_test{i} = repmat(1:size(y,1),2,1)'; % y
                %                 x_train = [1:size(xTempBin,1)]'; % xTempBin
                %                 y_train = repmat(1:size(y),2,1)'; % y
            end
            %%
            %%Try z-score instead of mean sub
            %     y_train = zscore(y_train);
            %     y_test{i} = zscore(y_test{i});
            %     x_train = zscore(x_train);
            %     x_test{i} = zscore(x_test{i});
            
            %If a decoder does not exist, create one
            if ~exist('H','var')
                [H{i,c,u},v,mcc] = FILMIMO3_tik(x_train, y_train, numlags, numsides,lambda, 1); %binsamprate = 1
                i
            end
            
            %If inputting a decoder with only one fold, convert to cell array and
            %replicate to match number of folds
            if exist('H','var') && ~iscell(H)
                H = num2cell(H, [1 2]);
                H = repmat(H,folds,1);
            end
            
            %Continue filling H if creating a decoder
            if exist('H','var')
                [H{i,c,u},v,mcc] = FILMIMO3_tik(x_train, y_train, numlags, numsides,lambda,1); %binsamprate = 1
                i
            end
            
            %binsamprate - Make sure H was built with the same binsamprate as used
            %for predictions
            
            if ~exist('featMat','var')
                [y_pred{i},xtnew{i},ytnew{i}] = predMIMO3(x_test{i},H{i,c,u},numsides,1,y_test{i}); %binsamprate = 1
            else
                [y_pred{i},xtnew{i},ytnew{i}] = predMIMO3(x_test{i},H{i,c,u},numsides,10,y_test{i});
            end
            
            %             if exist('P','var') && size(P,1) == 1
            %                 y_pred{i} = y_pred{i} + repmat(P,size(y_pred{i},1),1);
            %                 disp('Adding offset')
            %             end
            %ytnew and xtnew are shifted by the length of the filter since the
            %first fillen time period is garbage prediction & gets thrown out in
            %predMIMO3 (9-24-10)
            
            %             if exist('PolynomialOrder','var') && ~exist('P','var') && PolynomialOrder~=0
            %
            %                 P=[];
            %                 T=[];
            %                 patch = [];
            %
            %                 %%%Find a Wiener Cascade Nonlinearity
            %                 for z=1:size(y_pred{i},2)
            %                     if Use_Thresh
            %                         %Find Threshold
            %                         T_default = 1.25*std(y_pred{i}(:,z));
            %                         [T(z,1), T(z,2), patch(z)] = findThresh(ytnew{i}(:,z),y_pred{i}(:,z),T_default);
            %                         IncludedDataPoints = or(y_pred{i}(:,z)>=T(z,2),y_pred{i}(:,z)<=T(z,1));
            %
            %                         %Apply Threshold to linear predictions and Actual Data
            %                         PredictedData_Thresh = y_pred{i}(IncludedDataPoints,z);
            %                         ActualData_Thresh = ytnew{i}(IncludedDataPoints,z);
            %
            %                         %Replace thresholded data with patches consisting of 1/3 of the data to find the polynomial
            %                         Pred_patches = [ (patch(z)+(T(z,2)-T(z,1))/4)*ones(1,round(length(nonzeros(IncludedDataPoints))*4)) ...
            %                             (patch(z)-(T(z,2)-T(z,1))/4)*ones(1,round(length(nonzeros(IncludedDataPoints))*4)) ];
            %                         Act_patches = mean(ytnew{i}(~IncludedDataPoints,z)) * ones(1,length(Pred_patches));
            %
            %                         %Find Polynomial to Thresholded Data
            %                         [P(z,:)] = WienerNonlinearity([PredictedData_Thresh; Pred_patches'], ...
            %                             [ActualData_Thresh; Act_patches'], PolynomialOrder,'plot');
            %
            %
            %                         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %                         %%%%%% Use only one of the following 2 lines:
            %                         %
            %                         %   1-Use the threshold only to find polynomial, but not in the model data
            %                         T=[]; patch=[];
            %                         %
            %                         %   2-Use the threshold both for the polynomial and to replace low predictions by the predefined value
            %                         %                 y_pred{i}(~IncludedDataPoints,z)= patch(z);
            %                         %
            %                         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %                     else
            %                         %Find and apply polynomial
            %                         % MRS added 4/24/12 - Transpose P to match how brainreader
            %                         % accepts P
            %                         [P(z,:)] = WienerNonlinearity(y_pred{i}(:,z), ytnew{i}(:,z), PolynomialOrder);
            %                     end
            %                     y_pred{i}(:,z) = P(z,1)*y_pred{i}(:,z).^3 + P(z,2)*y_pred{i}(:,z).^2 +...
            %                         P(z,3)*y_pred{i}(:,z);
            %
            %                     y_pred{i}(:,z) = y_pred{i}(:,z) - mean(y_pred{i}(:,z));
            %                     ytnew{i}(:,z) = ytnew{i}(:,z)- mean(ytnew{i}(:,z));
            %                 end
            %
            %             end
            
            %     vaf(i,:) = 1 - var(y_pred{i} - y_test{i}) ./ var(y_test{i});
            if exist('v','var')
                vaftr(i,:)=v/100; %Divide by 100 because v is in percent
            end
            
            
            vaf(i,:) = RcoeffDet(y_pred{i},ytnew{i})
            %Old way to calculate vaf->1 - var(y_pred{i} - ytnew{i}) ./ var(ytnew{i});
            
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
        
        %% Extract appropriate metrics here
        beep
        
        vafall{c,u} = vaf;
        vmean(c,u,:)=mean(vaf);
        vsd{c,u}=std(vaf,0,1);
        r2all{c,u} = r2;
        r2mean(c,u,:)=mean(r2);
        r2sd{c,u}=std(r2);
        
        clear xTempBin
        
    end
    
    
end






disp('5th part: do predictions')




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
        varargout{3}=r2all;
        if nargout>8
            if exist('vaftr','var')
                varargout{4}=vaftr;
            else
                varargout{4}=[];
            end
            
            if nargout>9
                varargout{5}=TotalUnits;%bestf;
                varargout{6}=TotalSpikes_PerUnit;%bestc;
                if nargout>11
                    varargout{7}=[];%PhaseMat;%H;
                end
                if nargout>12
                    varargout{8}=H;%bestPB;
                    %                     if nargout>13
                    %                         %if outputting the whole PB matrix, put it in
                    %                         %different dimensions: bins X (freqs*chans). Each
                    %                         %column will be samples for one freq-chan
                    %                         %combination, ordered by (f1c1,f2c1,f3c1...f6c1
                    %                         %f1c2...)'
                    %                         if ~exist('featMat','var')
                    %                             pbrot=shiftdim(PB,2);
                    %                             featMat=reshape(pbrot,[],size(PB,1)*size(PB,2));
                    %                             featMat=featMat(q==1,:);
                    %                         end
                    %                         varargout{9}=x;   %featMat contains ALL features
                    %                         varargout{10}=y;
                    %                         varargout{11}=featMat;
                    %                         if nargout>16
                    %                             varargout{12}=ytnew;
                    %                             varargout{13}=xtnew;
                    %                             varargout{14}=t;
                    %                             if nargout>19
                    %                                 if exist('P','var')
                    %                                     varargout{15} = P;
                    %                                 else
                    %                                     varargout{15} = 0;
                    %                                 end
                    %                                 varargout{16}=featind;
                    %                                 %MRS modified 12/13/11
                    %                                 if nargout>21 && exist('sr','var')
                    %                                     varargout{17}=sr;
                    %                                 end
                    %                             end
                    %                         end
                    %                     end
                end
            end
        end
    end
    
end

end
