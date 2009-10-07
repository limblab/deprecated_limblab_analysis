function [vaf,vmean,vsd,y_test,y_pred,H] = predictionsfromBDF2(bdf, signal, cells, binsize, folds,numlags,varargin)

% $Id: predictions.m 67 2009-03-23 16:13:12Z brian $

%addpath mimo
%addpath spike
%addpath bdf
%revised version has binsize input
%V2 allows output of filters for stability comparison

tic

if strcmpi(signal, 'pos')
    y = bdf.pos(:,2:3);
elseif strcmpi(signal, 'vel')
    y = bdf.vel(:,2:3);
elseif strcmpi(signal, 'acc')
    y = bdf.acc(:,2:3);
elseif strcmpi(signal, 'force')
    y = bdf.force(:,2:3);
elseif strcmpi(signal, 'emg')
    EMGname = char(zeros(1,8));
    %     numEMGs = length(bdf.emg.emgnames);
    emgguide = char(zeros(numEMGs,length(EMGname)));
    %     emgtimebins = starttime*emgsamplerate+1:stoptime*emgsamplerate;
    y = bdf.emg.data(:,2:numEMGs);
    EMG_hp = 50; % default high pass at 50 Hz
    EMG_lp = 10; % default low pass at 10 Hz
    [bh,ah] = butter(4, EMG_hp*2/emgsamplerate, 'high'); %highpass filter params
    [bl,al] = butter(4, EMG_lp*2/emgsamplerate, 'low');  %lowpass filter params

else
    error('Unknown signal requested');
end

if isempty(cells);
    cells = unit_list(bdf);
end

samprate=1/binsize;

% Using binsize ms bins
if ~strcmpi(signal, 'emg')
    t = bdf.vel(1,1):binsize:bdf.vel(end,1);
    y = [interp1(bdf.vel(:,1), y(:,1), t); interp1(bdf.vel(:,1), y(:,2), t)]';
    % filter out inactive regions
    % Find active regions
    q = find_active_regions(bdf);
    q = interp1(bdf.vel(:,1), q, t);

else
    %if predicting emgs, need different sample rate
    t = bdf.emg.data(1,1):binsize:bdf.emg.data(end,1);
    y = [interp1(bdf.emg.data(:,1), y(:,1), t); interp1(bdf.emg.data(:,1), y(:,2), t)]';
    % filter out inactive regions
    % Find active regions
    q = find_active_regions(bdf);
    q = interp1(bdf.emg.data(:,1), q, t);

end

x = zeros(length(y), length(cells));

for i = 1:length(cells)
    ts = get_unit(bdf, cells(i, 1), cells(i, 2));
    b = train2bins(ts, t);
    x(:,i) = b;
end

x = x(q==1,:);
y = y(q==1,:);

vaf = zeros(folds,2);
%r2 = zeros(folds,2);
fold_length = floor(length(y) ./ folds);

x_test=cell(folds,1);
y_test=x_test;
y_pred=y_test;
for i = 1:folds
    fold_start = (i-1) * fold_length + 1;
    fold_end = fold_start + fold_length;

    x_test{i} = x(fold_start:fold_end,:);
    y_test{i} = y(fold_start:fold_end,:);

    x_train = [x(1:fold_start,:); x(fold_end:end,:)];
    y_train = [y(1:fold_start,:); y(fold_end:end,:)];
    if isempty(varargin)
        
    [H{i},v,mcc] = filMIMO3(x_train, y_train, numlags, 2,samprate);
    i
    else
        H=varargin{1};
    end
    y_pred{i} = predMIMO3(x_test{i},H{i},2,samprate,y_test{i});

    vaf(i,:) = 1 - var(y_pred{i} - y_test{i}) ./ var(y_test{i});

end
vmean=mean(vaf(1:9,:));
vsd=std(vaf(1:9,:),0,1);
toc
%rmpath mimo
%rmpath spike
%rmpath bdf
figure
plot(y_test{1}(:,1))
hold
plot(y_pred{1}(:,1),'r')

