% function H = runMIMOpls(X, Y, numlags)

%    USAGE:   H=filMIMOdspls(X,Y,numlags,numsides,fs);
%
%
%    X        : Columnwise inputs  [x1 x2 ...] to the unknown system
%    Y        : Columnwise outputs [y1 y2 ...] to the unknown system
%    numlags  : the number of lags to calculate for all linear filters
%
%
% The returned filter matrix is organized in columns as:
%     H=[h11 h21 h31 ....;
%        h12 h22 h32 ....;
%        h13 h23 h33 ...;
%        ... ... ... ...]
%  Which represents the system:
%  y1=h11*x1 + h12*x2 + h13*x3 + ...
%  y2=h21*x1 + h22*x2 + h33*x3 + ...
%  y3=h31*x1 + h32*x2 + h33*x3 + ...
%Uses pls regression
ncomps=30;     %number of components to use

[numpts,Nin]= size(X);

%Duplicate and shift firing rate to account for time history; each time lag
%is considered as a different input.
%e.g. 10 neurons with 5 time lag = 50 inputs with no time lag
%First subtract off the mean
% X=X-repmat(mean(X,1),numpts,1);
X = DuplicateAndShift(X,10);
X=zscore(X);
y=zscore(y);
%% Now calculate for cross-fold validation
folds=5;
fold_length = floor(length(y) ./ folds);
x_test=cell(folds,1);
y_test=x_test;
y_pred=y_test;
for i = 1:folds
    i
    fold_start = (i-1) * fold_length + 1;
    fold_end = fold_start + fold_length-1;
    
    x_test{i} = X(fold_start:fold_end,:);
    y_test{i} = y(fold_start:fold_end,:);
    
    x_train = [X(1:fold_start,:); X(fold_end:end,:)];
    y_train = [y(1:fold_start,:); y(fold_end:end,:)];
    
    %Build the model (H)
    [XL,yl,XS,YS,H{i},PVAR{i},MSE{i}] = plsregress(x_train,y_train,ncomps,'cv',10,'mcreps',10);
    
    %Now test the model on the remaining fold
    y_pred{i} = x_test{i}*H{i}(2:end,:);    %1st term of H is not needed when using z-scored variables
    
%     vaf(i,:) = 1 - var(y_pred{i} - y_test{i}) ./ var(y_test{i});
    vaf(i,:) = 1 - sum( (y_pred{i}-y_test{i}).^2 ) ./ sum( (y_test{i} - repmat(mean(y_test{i}),length(y_test{i}),1)).^2 );

    for j=1:size(y,2)
        r{i,j}=corrcoef(y_pred{i}(:,j),y_test{i}(:,j));
        if size(r{i,j},2)>1
            r2(i,j)=r{i,j}(1,2)^2;
        else
            r2(i,j)=r{i,j}^2;
        end
    end
    
end

%   H = X\Y;

% end