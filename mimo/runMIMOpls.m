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
ncomps=100;     %number of components to use

[numpts,Nin]= size(X);

%Duplicate and shift firing rate to account for time history; each time lag
%is considered as a different input.
%e.g. 10 neurons with 5 time lag = 50 inputs with no time lag
%First subtract off the mean
% X=X-repmat(mean(X,1),numpts,1);
X=zscore(X);
x = DuplicateAndShift(X,10);

%% Now calculate for cross-fold validation
folds=10;
fold_length = floor(length(y) ./ folds);
x_test=cell(folds,1);
y_test=x_test;
y_pred=y_test;
tic
for i = 1:folds
    i
    fold_start = (i-1) * fold_length + 1;
    fold_end = fold_start + fold_length-1;
    
    x_test{i} = x(fold_start:fold_end,:);
    y_test{i} = y(fold_start:fold_end,:);

    x_train = [x(1:fold_start,:); x(fold_end:end,:)];
    y_train = [y(1:fold_start,:); y(fold_end:end,:)];
%     x_trm = mean(x_train,1);
%     y_trm = mean(y_train,1);
%     x_tr0 = x_train - repmat(
%     
    xmeanTrain{i} = mean(x_train);
    ymeanTrain{i} = mean(y_train);
    X0train = bsxfun(@minus, x_train, xmeanTrain{i});
    Y0train = bsxfun(@minus, y_train, ymeanTrain{i});
    
    % Get and center the test data relative to the TRAINING data
      xt0{i} = bsxfun(@minus, x_test{i}, xmeanTrain{i});
    yt0{i} = bsxfun(@minus, y_test{i}, ymeanTrain{i});

    %Build the model (H)
%     [XL,yl,XS,YS,H{i},PCTVAR,MSE,stats{i}] = plsregress(X0train,Y0train,ncomps);
    [XL,YL,XS,YS,Weights{i}] = simpls2(X0train,Y0train,ncomps);
    beta = Weights{i}*YL';
    H{i} = [ymeanTrain{i} - xmeanTrain{i}*beta; beta];

    %Now test the model on the remaining fold
    y_pred{i} = [ones(size(xt0{i},1),1) xt0{i}]*H{i};
%      [H2{i},v,mcc] = FILMIMO3_tik(XS, y_train, 10, 1,0,10);
% [y_pred2{i},xtnew2{i},ytnew2{i}] = predMIMO3(x_test{i},H{i},1,10,y_test{i});

%      [y_predM{i},xtnew{i},ytnew{i}] = predMIMO3(x_test{i},H{i},numsides,binsamprate,y_test{i});

%     vaf(i,:) = 1 - var(y_pred{i} - y_test{i}) ./ var(y_test{i});
    vaf(i,:) = 1 - sum( (y_pred{i}-yt0{i}).^2 ) ./ sum( (yt0{i} - repmat(mean(yt0{i}),length(yt0{i}),1)).^2 );

    for j=1:size(y,2)
        r{i,j}=corrcoef(y_pred{i}(:,j),yt0{i}(:,j));
        if size(r{i,j},2)>1
            r2(i,j)=r{i,j}(1,2)^2;
        else
            r2(i,j)=r{i,j}^2;
        end
    end
    
end
toc

%% test
clear beta

tic
for i=1:10
    fold_start = (i-1) * fold_length + 1;
    fold_end = fold_start + fold_length-1;
    x_test{i} = x(fold_start:fold_end,:);
    y_test{i} = y(fold_start:fold_end,:);
    x_train = [x(1:fold_start,:); x(fold_end:end,:)];
    y_train = [y(1:fold_start,:); y(fold_end:end,:)];
    for c=1:100
%         beta{c}=stats{i}.W(:,1:c) * yl(:,1:c)';
        beta{c}=Weights{i}(:,1:c)*YL(:,1:c)';
        beta{c}=[mean(y_train)-mean(x_train,1)*beta{c};beta{c}];
        yp{c}=[ones(size(x_test{i},1),1) x_test{i}]*beta{c};
        for j=1:size(y,2)
            rc{c}=corrcoef(yp{c}(:,j),y_test{i}(:,j));
            r2(i,c,j)=rc{c}(1,2)^2;
        end
    end
end

toc
%   H = X\Y;

% end