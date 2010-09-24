function [vaf,vmean,vsd,y_test,y_pred,varargout] = predictions_mws(bdf, signal, cells, folds, binsize,numsides,varargin)

%modified from predictions.m, this is for spike predictions
%addpath mimo
%addpath spike
%addpath bdf
%v_mws uses find_active_regions_words (reduces timing issues) and outputs
%y_pred & y_test
%7/21/10 added emg prediction
%coflag is 1 if centerout,0 if randomwalk

%  Usage: [vaf,vmean,vsd,y_test,y_pred,r2mean,r2sd,r2,vaftr,H] =...
% predictions_mws(bdf,'vel',[],10,.05,0)
%numsides=1 means causal, 2 is acausal

if nargin>6
    coflag=varargin{1};
else
    coflag=0;
end
if nargin>7
    PolynomialOrder=varargin{2};    %for Wiener Nonlinear cascade
else
    PolynomialOrder=0;
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

    [H,v,mcc] = filMIMO3(x_train, y_train, 10, numsides, 10);
    y_pred{i} = predMIMO3(x_test,H,numsides,10,y_test{i});

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
                if nargout>10
                    varargout{6}=x;
                    if nargout>11
                        varargout{7}=y;
                    end
                end
            end
        end
    end

end