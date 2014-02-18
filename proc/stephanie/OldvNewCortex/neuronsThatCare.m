neuronsThatCare
% This piece of code plots weights*firing rate for each cell so you can
% determine which cells are important for the decoder

% Put binnedData and the decoder in your workspace

% Take the H variable in your decoder ( the weights ), and get an average
%weight for each neuron. This means taking the average H across all lags
%for each cell

numOfLags = (length(H)-1)/length(neuronIDs);

% May not need to remove the first weight row! But did it here! ******
%H(1,:) = [];
counter = 1;
for i = 1:length(neuronIDs-1)
    allHfor1neuron = H(counter:counter+9,:);
    meanHfor1neuron(i,:) = mean(allHfor1neuron);
    counter = counter+10;
end
meanHfor1neuron = abs(meanHfor1neuron);

meanSpikeRateData = mean(binnedData.spikeratedata(:, 1:length(binnedData.spikeratedata(1,:))))';

for i=1:length(meanHfor1neuron(1,:))
pullingWeight(:,i) = meanHfor1neuron(:,i).*meanSpikeRateData;
end

figure
colors = ['r' 'm' 'g' 'b' 'c' 'k'];
for i=1:length(pullingWeight(1,:))
plot(pullingWeight(:,i),colors(i))
hold on
end


