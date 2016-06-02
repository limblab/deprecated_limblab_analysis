function pred = pnbayes(labels, training, testing)
% PNBAYES - Trains and evaluates a naive Bayes classifier on Poisson data
%   PRED = PNBAYES(LABELS, TRAINING, TESTING) trains a naive bayes
%       classifer on the features in TRAINING with the categories in
%       LABELS.  TRAINING should be NxM where N is the cardnality of the
%       training set and M is the number of features.  LABELS is 1xN and
%       TESTING is KxM.  Returns PRED a 1xK vector containing the predicted
%       labels of the testing set.

% $Id$

if length(labels) ~= size(training,1)
    error('Training set must have the same number of rows as class labels');
end

if size(training,2) ~= size(testing,2)
    error('Training and testing sets must have the same number of features (columns)');
end

ulbl = unique(labels)';
nfeatures = size(training,2);
ncats = length(ulbl);
ntest = size(testing,1);

% Calculate firing rates from training set
fr = zeros(ncats,nfeatures);
idx = 1;
for cat = ulbl
    for feat = 1:nfeatures
        fr(idx,feat) = mean(training(labels==cat,feat));
    end
    idx = idx+1;
end

p = zeros(ntest,ncats);

for trial = 1:ntest
    for cat = 1:ncats
        lambda = fr(cat,:);
        Fi = testing(trial,:);
        P_fc = exp(-lambda) .* lambda .^ Fi ./ factorial(Fi);
        p(trial,cat) = sum(log(P_fc));
    end
end

ML = zeros(ntest,1);
for trial = 1:ntest
    ML(trial) = find(p(trial,:) == max(p(trial,:)),1);
end

pred = ulbl(ML);

