function WdotX = calcWdotXfromBinned(binnedSpikes, W)

X = zeros(size(binnedSpikes,1)-9, length(W));
for time = 1:size(X,1)
    for neuron = 1:size(binnedSpikes,2)
        for index = 0:9
            X(time,neuron*10-index) = binnedSpikes(time+index,neuron); % most recent time bins appear above previous ones
        end
    end
end

% for time = 1:size(X,1)
%        X(time,:) = sum(binnedSpikes(time:time+9,:),1);
% end

WdotX = X*W;