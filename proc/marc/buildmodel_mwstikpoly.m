function [vaf, vmean,vsd,y_test,y_pred,varargout] = buildmodel_mwstikpoly(bdf, signal, cells, binsize, buildfrac,numlags,numsides,lambda,PolynomialOrder,Use_Thresh,varargin)

% $Id: predictions.m 184 2010-03-15 16:30:46Z brian $

%addpath mimo
%addpath spike
%addpath bdf
%v_mws uses find_active_regions_words (reduces timing issues)
%v_mwstik uses ridge (Tikhunov) regression
%USAGE:
%[vaf,vmean,vsd,y_test,y_pred,r2mean,r2sd,r2,vaftr,H,x,y] =...
% buildmodel_mwstikpoly(bdf,'vel',[],.05,10,10,1,0,0,0,fnam)
%v_mwstikpoly uses ridge AND polynomial
%x is the feature matrix of all features (spiking rates), y is the binned
%output, H is the filter
% Varargins:
% 1: fnam
% 2: emglpf emg low pass filter
%buildfrac is the fraction of the file to use in building the model

emglpf=5; %default 
if length(varargin)>0
    fnam=varargin{1};
    if length(varargin)>1
        emglpf=varargin{2};      
    end
    
end
if strcmpi(signal, 'pos')
    y = bdf.pos(:,2:3);
elseif strcmpi(signal, 'vel')
    y = bdf.vel(:,2:3);
elseif strcmpi(signal, 'acc')
    y = bdf.acc(:,2:3);
elseif strcmpi(signal, 'force')
    y = bdf.force(:,2:3);
elseif strcmpi(signal,'emg')
    y=bdf.emg.data;
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
    [bh,ah] = butter(4, EMG_hp*2/emgsamplerate, 'high'); %highpass filter params
    [bl,al] = butter(4, EMG_lp*2/emgsamplerate, 'low');  %lowpass filter params
    tempEMG=y;
    tempEMG = filtfilt(bh,ah,tempEMG); %highpass filter
    tempEMG = abs(tempEMG); %rectify
    y = filtfilt(bl,al,tempEMG); %lowpass filter
    temg=(1/emgsamplerate):(1/emgsamplerate):(bdf.meta.duration);   %emg time vector
else
    error('Unknown signal requested');
end

if isempty(cells);
    cells = unit_list(bdf);
end

binsamprate=floor(1/binsize); 
% Using binsize ms bins

t = bdf.vel(1,1):binsize:bdf.vel(end,1);

if strcmpi(signal,'emg')
    if t(1)<temg(1)
        t(1)=temg(1);   %Do this to avoid NaNs when interpolating
    end
    y=interp1(temg',y,t);   %if y is a nby 4 matrix then interp will work
else
y = [interp1(bdf.vel(:,1), y(:,1), t); interp1(bdf.vel(:,1), y(:,2), t)]';
end

x = zeros(length(y), length(cells));
for i = 1:length(cells)
    ts = get_unit(bdf, cells(i, 1), cells(i, 2));
    b = train2bins(ts, t);
    x(:,i) = b;
end

% filter out inactive regions
% Find active regions

if ~strcmpi(signal,'emg')
q = find_active_regions_words(bdf.words,bdf.vel(:,1));
q = interp1(bdf.vel(:,1), q, t);
else
    q=ones(size(t))';
end

x = x(q==1,:);
y = y(q==1,:);

vaf = zeros(size(y,2));
r2 = zeros(size(y,2));
fold_length = floor(length(y) .* buildfrac);    %buildfrac is a fraction
    

% for i = 1:buildfrac
    fold_start = fold_length + 1;
    fold_end = length(y);
    
    x_test = x(fold_start:fold_end-150,:);
    y_test = y(fold_start:fold_end-150,:);
    
    x_train = x(1:fold_start,:);
    y_train = y(1:fold_start,:);
%     
    [H,v,mcc] = filMIMO3_tik(x_train, y_train, numlags, numsides,lambda,binsamprate);
%     xt= detrend(x_test, 'constant');    %subtract off the mean for testing
%     yt= detrend(y_test, 'constant'); 
xt=x_test; yt=y_test;
    [y_pred,xtnew,ytnew] = predMIMO3(xt,H,numsides,binsamprate,yt);
   
    %% Polynomial section
    P=[];
    T=[];
    patch = [];
    
    if PolynomialOrder
        %%%Find a Wiener Cascade Nonlinearity
        for z=1:size(y_pred,2)
            if Use_Thresh            
                %Find Threshold
                T_default = 1.25*std(y_pred(:,z));
                [T(z,1), T(z,2), patch(z)] = findThresh(ytnew(:,z),y_pred(:,z),T_default);
                IncludedDataPoints = or(y_pred(:,z)>=T(z,2),y_pred(:,z)<=T(z,1));

                %Apply Threshold to linear predictions and Actual Data
                PredictedData_Thresh = y_pred(IncludedDataPoints,z);
                ActualData_Thresh = ytnew(IncludedDataPoints,z);

                %Replace thresholded data with patches consisting of 1/3 of the data to find the polynomial 
                Pred_patches = [ (patch(z)+(T(z,2)-T(z,1))/4)*ones(1,round(length(nonzeros(IncludedDataPoints))*4)) ...
                                 (patch(z)-(T(z,2)-T(z,1))/4)*ones(1,round(length(nonzeros(IncludedDataPoints))*4)) ];
                Act_patches = mean(ytnew(~IncludedDataPoints,z)) * ones(1,length(Pred_patches));

                %Find Polynomial to Thresholded Data
                [P(z,:)] = WienerNonlinearity([PredictedData_Thresh; Pred_patches'], [ActualData_Thresh; Act_patches'], PolynomialOrder,'plot');
                
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%% Use only one of the following 2 lines:
                %
                %   1-Use the threshold only to find polynomial, but not in the model data
                T=[]; patch=[];                
                %
                %   2-Use the threshold both for the polynomial and to replace low predictions by the predefined value
%                 y_pred(~IncludedDataPoints,z)= patch(z);
                %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            else
                %Find and apply polynomial
                [P(z,:)] = WienerNonlinearity(y_pred(:,z), ytnew(:,z), PolynomialOrder);
            end
            y_pred(:,z) = polyval(P(z,:),y_pred(:,z));
        end
    end
    %%
    vaftr=v/100;
%     vaf(i,:) = 1 - var(y_pred - y_test) ./ var(y_test);
    vaf = 1 - var(y_pred - ytnew) ./ var(ytnew);
    for j=1:size(y,2)
        r{j}=corrcoef(y_pred(:,j),ytnew(:,j));
        if size(r{j},2)>1
            r2(j)=r{j}(1,2)^2;
        else
            r2(j)=r{j}^2;
        end
    end

% end

% if vaf(10,1)<0
% vmean=mean(vaf(1:9,:));
% vsd=std(vaf(1:9,:));
% else
    vmean=mean(vaf);
    vsd=std(vaf);
% end

% if (r2(9,1)-r2(10,1))>.5    %if big disparity in last fold, don't include it in mean
%     r2mean=mean(r2(1:9,:));
%     r2sd=std(r2(1:9,:));
% else
    r2mean=mean(r2);
r2sd=std(r2);
% end

snam=[fnam,signal,' predict tikpoly.mat'];
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

