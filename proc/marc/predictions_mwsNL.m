function [vaf,vmean,vsd,y_test,y_pred,varargout] = predictions_mwsNL(bdf, signal, cells, folds, binsize,numsides, varargin)

%modified from predictions.m, this is for spike predictions
%addpath mimo
%addpath spike
%addpath bdf
%v_mws uses find_active_regions_words (reduces timing issues) and outputs
%y_pred & y_test
%7/21/10 added emg prediction
%coflag is 1 if centerout,0 if randomwalk
%v_mwsNL uses nonlinearity

%  Usage: [vaf,vmean,vsd,y_test,y_pred,r2mean,r2sd,r2,vaftr,H] =...
% predictions_mws(bdf,'vel',[],10,.05,0)
% [vaf,vmean,vsd,y_test,y_pred,r2mean,r2sd,r2,vaftr,H] =...
% predictions_mwsNL(bdf,'emg',[],10,.05,1,0)

if nargin>6
    coflag=varargin{1};
else
    coflag=0;
end
if nargin>7
    PolynomialOrder=varargin{2};    %for Wiener Nonlinear cascade
    if nargin>8
        Use_Thresh=varargin{3};
    else
        Use_Thresh=0;
    end
else
    PolynomialOrder=0;
    Use_Thresh=0;
end

numlags=10;
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
    EMG_lp = 10; % default low pass at 10 Hz
    emgsamplerate=bdf.emg.freq;
        [bh,ah] = butter(4, EMG_hp*2/emgsamplerate, 'high'); %highpass filter params
        [bl,al] = butter(4, EMG_lp*2/emgsamplerate, 'low');  %lowpass filter params
        tempEMG=y;
            tempEMG = filtfilt(bh,ah,tempEMG); %highpass filter
            tempEMG = abs(tempEMG); %rectify
            y = filtfilt(bl,al,tempEMG); %lowpass filter

else
    error('Unknown signal requested');
end

if isempty(cells);
    cells = unit_list(bdf);
end

% Using 50 ms bins
t = bdf.vel(1,1):binsize:bdf.vel(end,1);
if strcmpi(signal, 'vel') || strcmpi(signal, 'pos') || strcmpi(signal, 'acc')
    y = [interp1(bdf.vel(:,1), y(:,1), t); interp1(bdf.vel(:,1), y(:,2), t)]';
elseif strcmpi(signal,'emg')
    emgsamprate=bdf.emg.freq;
    if ~isfield(bdf.emg,'ts')
        temg=(0:(length(y)-1))/emgsamprate;
    else
        temg=bdf.emg.ts;
    end
    for i=1:size(y,2)
        ytmp(:,i) = interp1(temg(:),y(:,i), t);
    end
    y=ytmp;
    clear ytmp
else
    %Need to implement for force prediction
end

x = zeros(length(y), length(cells));
for i = 1:length(cells)
    ts = get_unit(bdf, cells(i, 1), cells(i, 2));
    b = train2bins(ts, t);
    x(:,i) = b;
end

% filter out inactive regions
% Find active regions
if coflag
    %     if strcmpi(signal,'emg')
    %         q=ones(1,length(temg));
    %     else
    q=ones(1,length(bdf.vel));
    q = interp1(bdf.vel(:,1), q, t);
    %     end
else
    q = find_active_regions_words(bdf.words,bdf.vel(:,1));
    q = interp1(bdf.vel(:,1), q, t);
end

%%
binsamprate=floor(1/binsize);   %bin sampling rate
x = x(q==1,:);
y = y(q==1,:);

vaf = zeros(folds,size(y,2));
%r2 = zeros(folds,2);
fold_length = floor(length(y) ./ folds);

for i = 1:folds
    fold_start = (i-1) * fold_length + 1;
    fold_end = fold_start + fold_length-1;

    x_test = x(fold_start:fold_end,:);
    y_test{i} = y(fold_start:fold_end,:);

    x_train = [x(1:fold_start,:); x(fold_end:end,:)];
    y_train = [y(1:fold_start,:); y(fold_end:end,:)];

    %% subtract off the mean to reduce offset
    y_train = y_train - repmat(mean(y_train),size(y_train,1),1);
    y_test{i}= y_test{i} - repmat(mean(y_test{i}),size(y_test{i},1),1);
    x_test = x_test - repmat(mean(x_test),size(x_test,1),1);
    x_train = x_train - repmat(mean(x_train),size(x_train,1),1);
    %%
    
    [H,v,mcc] = FILMIMO3(x_train, y_train, numlags, numsides, binsamprate);
    y_pred{i} = PREDMIMO3(x_test,H,numsides,numlags,y_test{i});

        P=[];    
    T=[];
    patch = [];
    
    if PolynomialOrder
        %%%Find a Wiener Cascade Nonlinearity
        for z=1:size(y_pred{i},2)
            if Use_Thresh            
                %Find Threshold
                T_default = 1.25*std(y_pred{i}(:,z));
                [T(z,1), T(z,2), patch(z)] = findThresh(y_test{i}(:,z),y_pred{i}(:,z),T_default);
                IncludedDataPoints = or(y_pred{i}(:,z)>=T(z,2),y_pred{i}(:,z)<=T(z,1));

                %Apply Threshold to linear predictions and Actual Data
                PredictedData_Thresh = y_pred{i}(IncludedDataPoints,z);
                ActualData_Thresh = y_test{i}(IncludedDataPoints,z);

                %Replace thresholded data with patches consisting of 1/3 of the data to find the polynomial 
                Pred_patches = [ (patch(z)+(T(z,2)-T(z,1))/4)*ones(1,round(length(nonzeros(IncludedDataPoints))*4)) ...
                                 (patch(z)-(T(z,2)-T(z,1))/4)*ones(1,round(length(nonzeros(IncludedDataPoints))*4)) ];
                Act_patches = mean(y_test{i}(~IncludedDataPoints,z)) * ones(1,length(Pred_patches));

                %Find Polynomial to Thresholded Data
                [P(z,:)] = WienerNonlinearity([PredictedData_Thresh; Pred_patches'], [ActualData_Thresh; Act_patches'], PolynomialOrder,'plot');
                
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%% Use only one of the following 2 lines:
                %
                %   1-Use the threshold only to find polynomial, but not in the model data
%                 T=[]; patch=[];                
                %
                %   2-Use the threshold both for the polynomial and to replace low predictions by the predefined value
                y_pred{i}(~IncludedDataPoints,z)= patch(z);
                %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            else
                %Find and apply polynomial
                [P(z,:)] = WienerNonlinearity(y_pred{i}(:,z), y_test{i}(:,z), PolynomialOrder);
            end
            y_pred{i}(:,z) = polyval(P(z,:),y_pred{i}(:,z));
        end
    end

    
    vaf(i,:) = 1 - var(y_pred{i} - y_test{i}) ./ var(y_test{i});
    vaftr(i,:)=v/100; %Divide by 100 because v is in percent
    for j=1:size(y,2)
        r{i,j}=corrcoef(y_pred{i}(:,j),y_test{i}(:,j));
        if size(r{i,j},2)>1
            r2(i,j)=r{i,j}(1,2)^2;
        else
            r2(i,j)=r{i,j}^2;
        end
    end
end

vmean=mean(vaf(1:10,:));
vsd=std(vaf(1:10,:),0,1);
vaftrm=mean(vaftr);
r2mean=mean(r2);
r2sd=std(r2);

if nargout>2
    varargout{1}=y_test;
    varargout{2}=y_pred;
end

figure
plot(y_test{1}(:,1))
hold
plot(y_pred{1}(:,1),'r')

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