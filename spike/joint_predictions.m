function [vaf, vaf2, r2] = joint_predictions(bdf1, bdf2, signal, cells, folds)
% [vaf, vaf2, r2] = predictions(bdf, signal, cells, folds)
%
% $Id: predictions.m 374 2011-02-10 04:41:41Z brian $

if strcmpi(signal, 'pos')
    y1 = bdf1.pos(:,2:3);
    y2 = bdf2.pos(:,2:3);
elseif strcmpi(signal, 'vel')
    y1 = bdf1.vel(:,2:3);
    y2 = bdf2.vel(:,2:3);
elseif strcmpi(signal, 'acc')
    y1 = bdf1.acc(:,2:3);
    y2 = bdf2.acc(:,2:3);
elseif strcmpi(signal, 'force')
    y1 = bdf1.force(:,2:3);
    y2 = bdf2.force(:,2:3);
else
    error('Unknown signal requested');
end

if isempty(cells);
    cells = intersect(unit_list(bdf1), unit_list(bdf2), 'rows');
end

% Using 50 ms bins
t1 = bdf1.vel(1,1):.025:bdf1.vel(end,1);
y1 = [interp1(bdf1.vel(:,1), y1(:,1), t1); interp1(bdf1.vel(:,1), y1(:,2), t1)]';
t2 = bdf2.vel(1,1):.025:bdf2.vel(end,1);
y2 = [interp1(bdf2.vel(:,1), y2(:,1), t2); interp1(bdf2.vel(:,1), y2(:,2), t2)]';

y1 = y1 - repmat(mean(y1),length(y1),1);
y2 = y2 - repmat(mean(y2),length(y2),1);
y = [y1;y2];

x1 = zeros(length(y1), length(cells));
x2 = zeros(length(y2), length(cells));
for i = 1:length(cells)
    ts = get_unit(bdf1, cells(i, 1), cells(i, 2));
    b = train2bins(ts, t1);
    x1(:,i) = b;
    
    ts = get_unit(bdf1, cells(i, 1), cells(i, 2));
    b = train2bins(ts, t2);
    x2(:,i) = b;
end

x = [x1; x2];

% filter out inactive regions
% Find active regions
%q1 = find_active_regions(bdf1);
%q1 = interp1(bdf1.vel(:,1), q1, t1);
%q2 = find_active_regions(bdf2);
%q2 = interp1(bdf2.vel(:,1), q2, t2);

%q = [q1 q2];

%x = x(q==1,:);
%y = y(q==1,:);
%y = y - repmat(mean(y),length(y),1);

vaf = zeros(folds,2);
r2 = zeros(folds,2);
vaf2 = zeros(folds,1);

fold_length = floor(length(y) ./ folds);

for i = 1:folds
    fold_start = (i-1) * fold_length + 1;
    fold_end = min([fold_start + fold_length, length(y)]);
    
    x_test = x(fold_start:fold_end,:);
    y_test = y(fold_start:fold_end,:);
    
    x_train = [x(1:fold_start,:); x(fold_end:end,:)];
    y_train = [y(1:fold_start,:); y(fold_end:end,:)];
    
    [H,v,mcc] = filMIMO3(x_train, y_train, 20, 2, 20);
    y_pred = predMIMO3(x_test,H,2,20,y_test);
   
    %vaf(i,:) = 1 - var(y_pred - y_test) ./ var(y_test);
    r2(i,:)  = (diag(corr(y_pred,y_test))').^2;
    vaf(i,:) = 1 - sum( (y_pred-y_test).^2 ) ./ sum( (y_test - repmat(mean(y_test),length(y_test),1)).^2 );
    vaf2(i) = 1 - sum( sum((y_pred-y_test).^2) ) ...
        ./ sum( sum((y_test - repmat(mean(y_test),length(y_test),1)).^2) );
end
