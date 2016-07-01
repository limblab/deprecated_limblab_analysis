function [SortedNeuronsThatCare pullingWeight_all] = neuronsThatCare1SetofWeights(binnedData, H, numOfLags, emgInd)
% This piece of code plots weights*firing rate for each cell so you can
% determine which cells are important for the decoder

% Put binnedData and the decoder in your workspace

% Take the H variable in your decoder ( the weights ), and get an average
%weight for each neuron. This means taking the average H across all lags
%for each cell

%numOfLags = (length(H)-1)/length(neuronIDs);
%numOfLags=10;
%emgInd = 10;
neuronIDs = binnedData.neuronIDs;


% May not need to remove the first weight row! But did it here! ******
%H(1,:) = [];
% counter = 1;
% H=abs(H);
% for i = 1:length(neuronIDs)
%     allHfor1neuron = H(counter:counter+9,:);
%     meanHfor1neuron(i,:) = mean(allHfor1neuron);
%     counter = counter+10;
% end
% meanHfor1neuron = abs(meanHfor1neuron);

counter = 1;
H=abs(H);
for i = 1:length(neuronIDs)
    allHfor1neuron = H(counter:counter+9,:);
    meanHfor1neuron(i,:) = mean(allHfor1neuron);
    counter = counter+10;
end
meanHfor1neuron = abs(meanHfor1neuron);


% Get the meanSpikeRate for each neuron averaged over the entirety of the
% recording file
meanSpikeRateData_all = mean(binnedData.spikeratedata(:, 1:length(binnedData.spikeratedata(1,:))))';
% Get the meanSpikeRate for each neuron averaged over go_cue to end of
% trial




for i=1:length(meanHfor1neuron(1,:))
pullingWeight_all(:,i) = meanHfor1neuron(:,i).*meanSpikeRateData_all;
end

% figure
% colors = ['g' 'b'];
% for i=1:length(pullingWeight_all(1,:))
% plot(pullingWeight_all(:,i),colors(i))
% hold on
% end

XForceweights = double(pullingWeight_all(:,1));
[highWeight, neuronInd]=(findpeaks(XForceweights));
[sortedHighWeights, dummy] = sort(highWeight,'descend');
neuronInd = neuronInd(dummy);
SortedNeuronsThatCare = neuronIDs(neuronInd,:);

