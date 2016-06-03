function correctedPreds = rankSumPred(trainingPreds, trainingData, preds)
%   correctedPreds = rankSumPred(trainingPreds, trainingData, preds)
%
%   Builds a rank order mapping from TRAININGPREDS to TRAININGDATA and
%   generates CORRECTEDPREDS from the projection of PREDS based on that
%   mapping.
%
%   CORRECTEDPREDS - corrected predictions.
%   TRAININGPREDS - predictions from training set.
%   TRAININGDATA - real data from training set.
%   PREDS - predictions to be re-mapped.

if (size(trainingPreds,2) ~= size(preds,2)) ||...
   (size(trainingData,2) ~= size(preds,2))
    disp('Matrices must have same number of columns.')
    return
elseif (size(trainingPreds,1) ~= size(trainingData,1))
    disp('Training Preds and Data must have same number of rows')
    return
end

input = sort(trainingPreds,1);
output = sort(trainingData,1);
figure; plot(output,input,'.')
correctedPreds = zeros(size(preds));

for col = 1:size(preds,2)
    for x = 1:size(preds,1)
        below = find(input(:,col) < preds(x,col), 1, 'last');
        above = find(input(:,col) > preds(x,col), 1, 'first');

        if isempty(below) % interpolate based on lowest 2 inputs
            correctedPreds(x,col) = ...
            (output(2,col) - output(1,col)) / ...
            (input(2,col) - input(1,col)) * ...
            (preds(x,col) - input(1,col)) + ...
            output(1,col);

        elseif isempty(above) % interpolate based on highest 2 inputs
            correctedPreds(x,col) = ...
            (output(end,col) - output(end-1,col)) / ...
            (input(end,col) - input(end-1,col)) * ...
            (preds(x,col) - input(end-1,col)) + ...
            output(end-1,col);

        elseif (above - below == 1) % interpolate based on below and above
            correctedPreds(x,col) = ...
            (output(above,col) - output(below,col)) / ...
            (input(above,col) - input(below,col)) * ...
            (preds(x,col) - input(below,col)) + ...
            output(below,col);

        else % calculate mean output of all inputs with same value
            correctedPreds(x,col) = mean(output(below+1:above-1,col));
        end % if isempty(below)
    end % for x = 1:size(preds,1)
end % for col = 1:size(preds,2)
end
