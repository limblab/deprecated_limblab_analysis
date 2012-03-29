function [vaf, H,varargout] = predictions_mws(bdf, signal, cells, folds)

% $Id$

%addpath mimo
%addpath spike
%addpath bdf
%v_mws uses find_active_regions_words (reduces timing issues) and outputs
%y_pred & y_test

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

% Using 50 ms bins
t = bdf.vel(1,1):.1:bdf.vel(end,1);
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
    y_test{i} = y(fold_start:fold_end,:);
    
    x_train = [x(1:fold_start,:); x(fold_end:end,:)];
    y_train = [y(1:fold_start,:); y(fold_end:end,:)];
    
    [H,v,mcc] = filMIMO3(x_train, y_train, 10, 2, 10);
    y_pred{i} = predMIMO3(x_test,H,2,10,y_test{i});
   
    vaf(i,:) = 1 - var(y_pred{i} - y_test{i}) ./ var(y_test{i});
end
    
%rmpath mimo
%rmpath spike
%rmpath bdf

if nargout>2
    varargout{1}=y_test;
    varargout{2}=y_pred;
end
