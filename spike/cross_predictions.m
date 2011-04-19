function [vaf, vaf2, r2] = cross_predictions(bdf_train, bdf_test, signal, cells, folds)
% [vaf, vaf2, r2] = cross_predictions(bdf, signal, cells, folds)
%
% $Id: $

if strcmpi(signal, 'pos')
    y  = bdf_train.pos(:,2:3);
    y2 = bdf_test.pos(:,2:3);
elseif strcmpi(signal, 'vel')
    y  = bdf_train.vel(:,2:3);
    y2 = bdf_test.vel(:,2:3);
elseif strcmpi(signal, 'acc')
    y  = bdf_train.acc(:,2:3);
    y2 = bdf_test.acc(:,2:3);
elseif strcmpi(signal, 'force')
    y  = bdf_train.force(:,2:3);
    y2 = bdf_test.force(:,2:3);
else
    error('Unknown signal requested');
end

if isempty(cells);
    cells = unit_list(bdf_test);
    if ~isequal(cells, unit_list(bdf_train))
        %error('Not same units in both files');
        cells = intersect(cells, unit_list(bdf_train), 'rows');
    end
end

% Using 50 ms bins
t = bdf_train.vel(1,1):.025:bdf_train.vel(end,1);
y = [interp1(bdf_train.vel(:,1), y(:,1), t); interp1(bdf_train.vel(:,1), y(:,2), t)]';

t2 = bdf_test.vel(1,1):.025:bdf_test.vel(end,1);
y2 = [interp1(bdf_test.vel(:,1), y2(:,1), t2); interp1(bdf_test.vel(:,1), y2(:,2), t2)]';

x = zeros(length(y), length(cells));
x2 = zeros(length(y2), length(cells));
for i = 1:length(cells)
    ts = get_unit(bdf_train, cells(i, 1), cells(i, 2));
    b = train2bins(ts, t);
    x(:,i) = b;

    ts = get_unit(bdf_test, cells(i, 1), cells(i, 2));
    b = train2bins(ts, t2);
    x2(:,i) = b;
end

% filter out inactive regions
% Find active regions
q = find_active_regions(bdf_train);
q = interp1(bdf_train.vel(:,1), q, t);

x = x(q==1,:);
y = y(q==1,:);
y = y - repmat(mean(y),length(y),1);

q = find_active_regions(bdf_test);
q = interp1(bdf_test.vel(:,1), q, t2);

x2 = x2(q==1,:);
y2 = y2(q==1,:);
y2 = y2 - repmat(mean(y2),length(y2),1);

vaf = zeros(folds,2);
r2 = zeros(folds,2);
vaf2 = zeros(folds,1);


fold_length = floor(length(y) ./ folds);
fold_length2 = floor(length(y2) ./ folds);

for i = 1:folds
    fold_start = (i-1) * fold_length + 1;
    fold_end = min([fold_start + fold_length, length(y)]);
    
    x_train = [x(1:fold_start,:); x(fold_end:end,:)];
    y_train = [y(1:fold_start,:); y(fold_end:end,:)];
    
    fold_start = (i-1) * fold_length2 + 1;
    fold_end = min([fold_start + fold_length2, length(y2)]);
    
    x_test = x2(fold_start:fold_end,:);
    y_test = y2(fold_start:fold_end,:);
    
    [H,v,mcc] = filMIMO3(x_train, y_train, 20, 2, 20);
    y_pred = predMIMO3(x_test,H,2,20,y_test);
   
    %vaf(i,:) = 1 - var(y_pred - y_test) ./ var(y_test);
    r2(i,:)  = (diag(corr(y_pred,y_test))').^2;
    vaf(i,:) = 1 - sum( (y_pred-y_test).^2 ) ./ sum( (y_test - repmat(mean(y_test),length(y_test),1)).^2 );
    vaf2(i) = 1 - sum( sum((y_pred-y_test).^2) ) ...
        ./ sum( sum((y_test - repmat(mean(y_test),length(y_test),1)).^2) );
end
