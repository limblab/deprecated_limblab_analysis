function [vaf, vmean,vsd,y_test,y_pred,varargout] = predictions_mwstikpoly(bdf, signal, cells, binsize, folds,numlags,numsides,lambda,PolynomialOrder,Use_Thresh,varargin)

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
if length(varargin)>0
    fnam=varargin{1};
    if length(varargin)>1
        emglpf=varargin{2}; 
        if ~isempty(varargin{3})
            H=varargin{3};
            if ~isempty(varargin{4})
                P=varargin{4};
                if ~isempty(varargin{5})
                    neuronIDs=varargin{5};
                end
            end
        elseif ~isempty(varargin{4})
                P=varargin{4};
        elseif ~isempty(varargin{5})
                neuronIDs=varargin{5};
        end
    end
    
end

if strcmpi(signal,'pos')
    y = bdf.pos(:,2:3);
elseif strcmpi(signal, 'vel')
    y = bdf.vel(:,2:3);
elseif strcmpi(signal, 'acc')
    y = bdf.acc(:,2:3);
elseif strcmpi(signal, 'force')
    y = bdf.force(:,2:3);
elseif strcmpi(signal,'emg')
    y=bdf.emg.data(:,2:end);
    %Rectify and filter emg

    EMG_hp = 50; % default high pass at 50 Hz
    EMG_lp = emglpf; % default low pass at 10 Hz
    if isfield(bdf.emg,'emgfreq')
        emgsamplerate=bdf.emg.emgfreq;
    elseif isfield(bdf.emg,'samprate')
        emgsamplerate=bdf.emg.samprate;
    elseif exist('fse','var')
        emgsamplerate=fse;
    else
        emgsamplerate=2000; %default
    end
    [bh,ah] = butter(2, EMG_hp*2/emgsamplerate, 'high'); %highpass filter params
    [bl,al] = butter(2, EMG_lp*2/emgsamplerate, 'low');  %lowpass filter params
    tempEMG=y;
    tempEMG = filtfilt(bh,ah,tempEMG); %highpass filter
    tempEMG = abs(tempEMG); %rectify
    y = filtfilt(bl,al,tempEMG); %lowpass filter
    if isfield(bdf.emg,'ts')
        temg=bdf.emg.ts;
    else
    temg=(1/emgsamplerate):(1/emgsamplerate):(bdf.meta.duration);   %emg time vector
    end
else
    error('Unknown signal requested');
end

k=1;
if exist('neuronIDs','var')
    if isempty(cells);
    cells = unit_list(bdf);
    if size(cells,1) > size(neuronIDs,1) 
        newcells = zeros(size(neuronIDs,1),2);
        for i = 1:size(neuronIDs,1)
            for j = 1:size(cells,1)
                if cells(j,:) == neuronIDs(i,:)
                    newcells(i,:) = neuronIDs(i,:);
                end
            end
        end
    else
        newcells = zeros(size(cells,1),2);
        for i = 1:size(cells,1)
            for j = 1:size(neuronIDs,1)
                if (cells(i,1) == neuronIDs(j,1)) && (cells(i,2) == neuronIDs(j,2)) && (j <= size(cells,1))
                    newcells(j,:) = neuronIDs(j,:);
                end
            end
        end
    end

    for j = 1:size(newcells,1)
        if exist('H','var')  && newcells(j,1) == 0;
            H((j-1)*10+1:(j-1)*10+10,:) = zeros(10,2);
        end     
    end

    if exist('H','var') && size(cells,1) < size(neuronIDs,1)
        H = H(1:size(newcells,1)*10,:);
    end

    clear cells
    cells = newcells;
    end
else
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
    y=interp1(temg',y,t);   %if y is a n by 4 matrix then interp will work
else
y = [interp1(bdf.vel(:,1), y(:,1), t); interp1(bdf.vel(:,1), y(:,2), t)]';
end

x = zeros(length(y), length(cells));
for i = 1:length(cells)
    if cells(i,1) ~= 0
        ts = get_unit(bdf, cells(i, 1), cells(i, 2));
        b = train2bins(ts, t);
        x(:,i) = b;
    else
        x(:,i) = zeros(length(y),1);
    end
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
t = t(:,q==1)';

vaf = zeros(folds,size(y,2));
r2 = zeros(folds,size(y,2));
fold_length = floor(length(y) ./ folds);
    
t_final = zeros(length(t)-9*folds,1);

for i = 1:folds
    fold_start = (i-1) * fold_length + 1;
    fold_end = fold_start + fold_length-1;
    
    x_test{i} = x(fold_start:fold_end,:);
    y_test{i} = y(fold_start:fold_end,:);
    
    t_fold = t(fold_start+9:fold_end);
    t_final(fold_start-9*(i-1):fold_end-9*i) = t_fold;
    
    x_train = [x(1:fold_start,:); x(fold_end:end,:)];
    y_train = [y(1:fold_start,:); y(fold_end:end,:)];
   %% subtract off the mean to reduce offset
%     y_train = y_train - repmat(mean(y_train),size(y_train,1),1);
%     y_test{i}= y_test{i} - repmat(mean(y_test{i}),size(y_test{i},1),1);
%     x_test{i} = x_test{i} - repmat(mean(x_test{i}),size(x_test{i},1),1);
%     x_train = x_train - repmat(mean(x_train),size(x_train,1),1);
%   
    if ~exist('H','var')
    [H{i},v,mcc] = FILMIMO3_tik(x_train, y_train, numlags, numsides,lambda,binsamprate);
    end
    %If a decoder does not exist, create one
       
    if exist('H','var') && ~iscell(H)
        H = num2cell(H, [1 2]);
        H = repmat(H,folds,1);
    end
    %If inputting a decoder with only one fold, convert to cell array and
    %replicate to match number of folds
    
    if exist('H','var') && length(H) < i
        [H{i},v,mcc] = FILMIMO3_tik(x_train, y_train, numlags, numsides,lambda,binsamprate);
        i
    end
    
    [y_pred{i},xtnew{i},ytnew{i}] = predMIMO3(x_test{i},H{i},numsides,binsamprate,y_test{i});
   
    %%Polynomial section
               
    T=[];
    patch = [];
    
    if  PolynomialOrder
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
                if exist('P','var')
                [P(z,:)] = WienerNonlinearity([PredictedData_Thresh; Pred_patches'], [ActualData_Thresh; Act_patches'], PolynomialOrder,'plot');
                end
                
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
            elseif ~exist('P','var')
                %Find and apply polynomial
                [P(z,:)] = WienerNonlinearity(y_pred{i}(:,z), ytnew{i}(:,z), PolynomialOrder);
            end
            y_pred{i}(:,z) = polyval(P(:,z),y_pred{i}(:,z));
        end
    end
    %%
    if exist('v','var')
    vaftr(i,:)=v/100;
    end
%     vaf(i,:) = 1 - var(y_pred{i} - y_test{i}) ./ var(y_test{i});
%     vaf(i,:) = 1 - var(y_pred{i} - ytnew{i}) ./ var(ytnew{i});
    vaf(i,:)=RcoeffDet(y_pred{i},ytnew{i});

    for j=1:size(y,2)
        r{i,j}=corrcoef(y_pred{i}(:,j),ytnew{i}(:,j));
        if size(r{i,j},2)>1
            r2(i,j)=r{i,j}(1,2)^2;
        else
            r2(i,j)=r{i,j}^2;
        end
    end

end

t_final = t_final(t_final~=0,1);

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
            if exist('vaftr','var')
                varargout{4}=vaftr;
            else
                varargout{4}=[];
            end
            
            if nargout>9
                varargout{5}=H;
            end
            if nargout>10
                varargout{6}=x;
                varargout{7}=y;
                
                if nargout>12
                    varargout{8}=ytnew;
                    varargout{9}=xtnew;
                    if exist('P','var') && nargout>14
                        varargout{10}=P;
                    else
                        varargout(10)={0};
                    end
                    
                    if nargout>15
                        varargout{11}=t_final;
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

