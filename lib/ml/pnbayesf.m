function res = pnbayesf(data, nfolds)
% PNBAYESF -- N-fold cross validation on pnbayes
%
%   RES = PNBAYESF(DATA, NFOLDS) runs PNBAYES on the data in DATA divided
%   into NFOLDS folds.  DATA should contain the category in the first
%   column and the spike counts in the subesquent columns.  RES is a vector
%   of percent correctly predicted

num_trials = size(data,1);
res = zeros(1, nfolds);

for fold = 1:nfolds
    fold_start = (fold-1) * floor(num_trials/nfolds) + 1;
    fold_stop = (fold) * floor(num_trials/nfolds);
    
    if fold == nfolds
        fold_stop = num_trials;
    end
    
    %disp(sprintf('%d - %d', fold_start, fold_stop));
    
    test_fold = 1:num_trials >= fold_start & 1:num_trials <= fold_stop;
    
    training_data   = data( ~test_fold, 2:end );
    training_labels = data( ~test_fold, 1     );
    test_data       = data(  test_fold, 2:end );
    test_labels     = data(  test_fold, 1     );
    
    pred = pnbayes(training_labels, training_data, test_data);
    res(fold) = sum(pred == test_labels') / length(pred);
end

