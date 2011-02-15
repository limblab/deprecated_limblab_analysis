function [vaf, H] = predictions_mwstik(bdf, signal, cells, folds,varargin)

% $Id$

%addpath mimo
%addpath spike
%addpath bdf
%v_mws uses find_active_regions_words (reduces timing issues)
%v_mwstik uses ridge (Tikhunov) regression
%USAGE: [vaf, H] = predictions_mwstik(bdf, signal,cells,folds,numlags,binsize,lambda)

if nargin>4
    numlags=varargin{1};
    if nargin>5
        binsize=varargin{2};
        if nargin>6
            lambda=varargin{3};
        else
            lambda=1;   %This is factor for ridge regression
        end
    else
        binsize=0.05;
    end
else
    numlags=10;
end

if strcmpi(signal, 'pos')
    y = bdf.pos(:,2:3);
elseif strcmpi(signal, 'vel')
    y = bdf.vel(:,2:3);
elseif strcmpi(signal, 'acc')
    y = bdf.acc(:,2:3);
elseif strcmpi(signal, 'force')
    y = bdf.force(:,2:3);
else
    error('Unknown signal requested');
end

if isempty(cells);
    cells = unit_list(bdf);
end

binsamprate=floor(1/binsize); 
% Using binsize ms bins
t = bdf.vel(1,1):binsize:bdf.vel(end,1);
y = [interp1(bdf.vel(:,1), y(:,1), t); interp1(bdf.vel(:,1), y(:,2), t)]';

x = zeros(length(y), length(cells));
for i = 1:length(cells)
    ts = get_unit(bdf, cells(i, 1), cells(i, 2));
    b = train2bins(ts, t);
    x(:,i) = b;
end

% filter out inactive regions
% Find active regions
q = find_active_regions_words(bdf.words,bdf.vel(:,1));
q = interp1(bdf.vel(:,1), q, t);

x = x(q==1,:);
y = y(q==1,:);

vaf = zeros(folds,2);
%r2 = zeros(folds,2);
fold_length = floor(length(y) ./ folds);
    

for i = 1:folds
    fold_start = (i-1) * fold_length + 1;
    fold_end = fold_start + fold_length-1;
    
    x_test = x(fold_start:fold_end,:);
    y_test = y(fold_start:fold_end,:);
    
    x_train = [x(1:fold_start,:); x(fold_end:end,:)];
    y_train = [y(1:fold_start,:); y(fold_end:end,:)];
    
    [H,v,mcc] = filMIMO3_tik(x_train, y_train, numlags, 2,lambda,binsamprate);
    y_pred = predMIMO3(x_test,H,2,binsamprate,y_test);
   
    vaf(i,:) = 1 - var(y_pred - y_test) ./ var(y_test);
end
    
%rmpath mimo
%rmpath spike
%rmpath bdf


