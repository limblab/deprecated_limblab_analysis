function [NeuronPercentile]=HybridNeuronsThatCare(binnedData,H,flag)
% This piece of code plots weights*firing rate for each cell so you can
% determine which cells are important for the decoder

% Put binnedData and the decoder in your workspace

% Take the H variable in your decoder ( the weights ), and get an average
%weight for each neuron. This means taking the average H across all lags
%for each cell

% Set flag to 1 for EMG decoder
% Set flag to 0 for kinematic decoder


neuronIDs = binnedData.neuronIDs;
numOfLags = (length(H)-1)/length(neuronIDs);


% May not need to remove the first weight row! But did it here! ******
H(1,:) = [];
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


for a=1:length(meanHfor1neuron(1,:))
    pullingWeight_all(:,a) = meanHfor1neuron(:,a).*meanSpikeRateData_all;
end

for b=1:length(pullingWeight_all)
    % If it's an EMG decoder, take the max weight among all muscles
    if flag==1
        MaxPullingWeightAcrossEMG(b,1) = max(pullingWeight_all(b,:));
    end
end

if flag==0
MaxPullingWeightAcrossEMG = pullingWeight_all(:,1);
end

% Get the sortedIndex, which tells you the index of the original neurons
[sortedNeurons sortedIndex]=sort(MaxPullingWeightAcrossEMG,'ascend');

% Label each neuron with its place in the distribution (percentile)
for d=1:length(MaxPullingWeightAcrossEMG)
    WhereInTheRankNeuronIs(d,1) =  find(MaxPullingWeightAcrossEMG(d)==sortedNeurons);
    NeuronPercentile(d,1) =  WhereInTheRankNeuronIs(d,1)/(length(sortedNeurons)/100);
end



% Take the 80th percentile
% eightiethpercentile = length(MaxPullingWeightAcrossEMG)-ceil(.8*length(MaxPullingWeightAcrossEMG));
% SortedNeuronsThatCare = sortedNeurons(1:eightiethpercentile);
% SortedNeuronsThatCareNames = neuronIDs(sortedIndex,:);

% Make scatterplot
% figure
% colors = ['g' 'b'];
% for i=1:length(pullingWeight_all(1,:))
% plot(pullingWeight_all(:,i),colors(i))
% hold on
% end

% XForceweights = double(pullingWeight_all(:,1));
% [highWeight, neuronInd]=(findpeaks(XForceweights));
% [sortedHighWeights, dummy] = sort(highWeight,'descend');
% neuronInd = neuronInd(dummy);
% SortedNeuronsThatCare = neuronIDs(neuronInd,:);

end
