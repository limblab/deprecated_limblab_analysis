function W = getLDAcoeffs(modelData)
% Calculate classification coefficients from model data

window = 0.500; % in seconds (for spike averaging) should match training

bin = double(modelData.timeframe(2) - modelData.timeframe(1));
window_bins = floor(window/bin);

training_set = zeros(length(modelData.timeframe),length(modelData.spikeguide));
group = zeros(length(training_set),1);

for x = window_bins:length(modelData.timeframe)
    training_set(x,:) = sum(modelData.spikeratedata(x-(window_bins-1):x,:),1);

    if modelData.velocbin(x,3) > 8
        group(x) = 1;
    end
end

[~,~,~,~,LDAcoeff] = classify(training_set(window_bins,:),training_set(window_bins:end,:),group(window_bins:end),'linear');

W = LDAcoeff(1,2).linear;
