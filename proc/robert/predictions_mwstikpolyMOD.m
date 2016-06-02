function [vaf, vmean,vsd,y_test,y_pred,varargout] = predictions_mwstikpolyMOD(bdf, signal, ...
	cells, binsize, folds,numlags,numsides,lambda,PolynomialOrder,Use_Thresh,varargin)

% $Id: predictions_mwstikpoly.m 385 2011-02-20 19:05:39Z marc $

%addpath mimo
%addpath spike
%addpath bdf
%v_mws uses find_active_regions_words (reduces timing issues)
%v_mwstik uses ridge (Tikhunov) regression
%USAGE:
%[vaf,vmean,vsd,y_test,y_pred,r2mean,r2sd,r2,vaftr,H,x,y] =...
% predictions_mwstikpoly(bdf,'vel',[],.05,10,10,1,0,0,0,fnam)
%v_mwstikpoly uses ridge AND polynomial
%x is the feature matrix of all features (spiking rates), y is the binned
%output, H is the filter
% Varargins:
% 1: fnam
% 2: emglpf emg low pass filter

emglpf=5; %default 
if ~isempty(varargin)
    fnam=varargin{1};
    if length(varargin)>1
        emglpf=varargin{2};      
    end
    
end
if strcmpi(signal, 'pos')
    y = bdf.pos(:,2:end);
elseif strcmpi(signal, 'vel')
    y = bdf.vel(:,2:3);
elseif strcmpi(signal, 'acc')
    y = bdf.acc(:,2:3);
elseif strcmpi(signal, 'force')
    y = bdf.force(:,2:3);
elseif strcmpi(signal,'emg')
    y=double(bdf.emg.data);
    %Rectify and filter emg

    EMG_hp = 50; % default high pass at 50 Hz
    EMG_lp = emglpf; % default low pass at 10 Hz
    if isfield(bdf.emg,'freq')
        emgsamplerate=bdf.emg.freq;
    elseif isfield(bdf.emg,'samprate')
        emgsamplerate=bdf.emg.samprate;
    elseif exist('fse','var')
        emgsamplerate=fse;
    else
        emgsamplerate=2000; %default
    end
%     [bh,ah] = butter(4, EMG_hp*2/emgsamplerate, 'high'); %highpass filter params
%     [bl,al] = butter(4, EMG_lp*2/emgsamplerate, 'low');  %lowpass filter params
	% 2 pole filters work WAY better on emg
    [bh,ah] = butter(2, EMG_hp*2/emgsamplerate, 'high'); %highpass filter params
    [bl,al] = butter(2, EMG_lp*2/emgsamplerate, 'low');  %lowpass filter params
    tempEMG=y;
    tempEMG = filtfilt(bh,ah,tempEMG); %highpass filter
    tempEMG = abs(tempEMG); %rectify
    y = filtfilt(bl,al,tempEMG); %lowpass filter
    
%     % temporary, add in a bandpass filter from 3-5 Hz (or from 5-10 Hz)
%     [bb,ab]=butter(2,[10 20]/emgsamplerate,'bandpass');
%     y=filtfilt(bb,ab,y);
    
    if isfield(bdf.emg,'ts')
        temg=bdf.emg.ts;
    else
    temg=(1/emgsamplerate):(1/emgsamplerate):(bdf.meta.duration);   %emg time vector
    end
else
    error('Unknown signal requested');
end

if isempty(cells);
    cells = unit_list(bdf);
end

binsamprate=floor(1/binsize); 
% Using binsize ms bins

if strcmpi(signal,'vel') ||  strcmpi(signal, 'pos') ||  strcmpi(signal, 'acc')
t = bdf.vel(1,1):binsize:bdf.vel(end,1);
end
if strcmpi(signal,'emg')
%     if isfield(bdf.emg,'ts')
%     t = bdf.emg.ts(1):binsize:bdf.emg.ts(end);
    t=temg(1):binsize:temg(end);
    if t(1)<temg(1)
        t(1)=temg(1);   %Do this to avoid NaNs when interpolating
    end
    y=interp1(temg',y,t);   %if y is a nby 4 matrix then interp will work
else
    y = [interp1(bdf.vel(:,1), y(:,1), t); interp1(bdf.vel(:,1), y(:,2), t)]';
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % experimental HPF for binned spike data %%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [bxh,axh] = butter(2, 0.1, 'high'); %highpass filter spike train

x = zeros(length(y), size(cells,1));    % using length() is bad! use size(X,n) instead.
for i = 1:size(cells,1)
    ts = get_unit(bdf, cells(i, 1), cells(i, 2));
    try
        b = train2bins(ts, t);
    catch Merror
        switch Merror.identifier
            case 'MATLAB:UndefinedFunction'
                b=train2bins_mod(ts,t);
            case 'MATLAB:nonLogicalConditional'
                % encountered this before when numel(ts)==1
                b=zeros(size(x(:,i)));
            otherwise
                rethrow(Merror)
        end
    end
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % % experimental HPF for binned spike data %%
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     x(:,i) = filtfilt(bxh,axh,b);
%     if length(ts)/bdf.meta.duration > 0
        x(:,i) = b;
%     end
end



% filter out inactive regions
% Find active regions

if ~strcmpi(signal,'emg')
    q = find_active_regions_words(bdf.words,bdf.vel(:,1));
    q = interp1(bdf.vel(:,1), double(q), t);
else
    q=ones(size(t))';
end

x = x(q==1,:);
y = y(q==1,:);

vaf = zeros(folds,size(y,2));
r2 = zeros(folds,size(y,2));
fold_length = floor(length(y) ./ folds);
    
% raw correlations for determining best neurons/channels
rmat=zeros(size(x,2),size(y,2));
for xind=1:size(x,2)
    for yind=1:size(y,2)
        rmat(xind,yind)=corr(x(:,xind),y(:,yind));
    end
end
assignin('caller','rmat',rmat)

for i = 1:folds
    fold_start = (i-1) * fold_length + 1;
    fold_end = fold_start + fold_length-1;
    
    x_test{i} = x(fold_start:fold_end,:);
    y_test{i} = y(fold_start:fold_end,:);
    
    x_train = [x(1:fold_start,:); x(fold_end:end,:)];
    y_train = [y(1:fold_start,:); y(fold_end:end,:)];
   %% subtract off the mean to reduce offset
%     y_train = y_train - repmat(mean(y_train),size(y_train,1),1);
%     y_test{i}= y_test{i} - repmat(mean(y_test{i}),size(y_test{i},1),1);
%     x_test{i} = x_test{i} - repmat(mean(x_test{i}),size(x_test{i},1),1);
%     x_train = x_train - repmat(mean(x_train),size(x_train,1),1);
%     
    [H{i},v,mcc] = FILMIMO3_tik(x_train, y_train, numlags, numsides,lambda,binsamprate);
    [y_pred{i},xtnew{i},ytnew{i}] = predMIMO3(x_test{i},H{i},numsides,binsamprate,y_test{i});
   
    %%Polynomial section
    P=[];
    T=[];
    patch=[];
    
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
    %%
    vaftr(i,:)=v/100;
%     vaf(i,:) = 1 - var(y_pred{i} - y_test{i}) ./ var(y_test{i});
%     vaf(i,:) = 1 - var(y_pred{i} - ytnew{i}) ./ var(ytnew{i});
	vaf(i,:) = RcoeffDet(y_pred{i},ytnew{i});
    for j=1:size(y,2)
        r{i,j}=corrcoef(y_pred{i}(:,j),ytnew{i}(:,j));
        if size(r{i,j},2)>1
            r2(i,j)=r{i,j}(1,2)^2;
        else
            r2(i,j)=r{i,j}^2;
        end
    end

end

if (vaf(9,1)-vaf(10,1))>0.5
vmean=mean(vaf(1:9,:));
vsd=std(vaf(1:9,:));
else
    vmean=mean(vaf);
    vsd=std(vaf);
end

if (r2(9,1)-r2(10,1))>0.5    %if big disparity in last fold, don't include it in mean
    r2mean=mean(r2(1:9,:));
    r2sd=std(r2(1:9,:));
else
    r2mean=mean(r2);
r2sd=std(r2);
end

% snam=[fnam,signal,' predict tikpoly.mat'];
% save(snam,'v*','x','y*','Poly*','Use*','num*','bin*','H','lambda')

if nargout>5
    varargout{1}=r2mean;
    varargout{2}=r2sd;
    if nargout>7
        varargout{3}=r2;
        if nargout>8
            varargout{4}=vaftr;
            if nargout>9
                varargout{5}=H;
            end
            if nargout>10
                varargout{6}=x;
                varargout{7}=y;
                
                if nargout>12
                    varargout{8}=ytnew;
                    varargout{9}=xtnew;
                    if nargout>14
                        varargout{10}=P;
                    end
                end
            end
        end
    end
    
end

assignin('base','ytnew',ytnew)
assignin('base','y_pred',y_pred)

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

