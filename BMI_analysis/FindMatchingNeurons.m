
function [matchingInputs] = FindMatchingNeurons(spikeguide, neuronIDs)

%This function returns an array of indices. The array
%indicates the corresponding index in spikeguide for
%each neuronIDs channel

neuronChannels=spikeguide2neuronIDs(spikeguide);

numberinputs=size(neuronIDs,1);
matchingInputs = zeros(1,numberinputs);

for k=1:numberinputs
    temp=neuronIDs(k,:);
    spot=find((neuronChannels(:,1)==temp(1,1)) & (neuronChannels(:,2)==temp(1,2)));
    if ~isempty(spot) %neuron in the filter is found in data, we have a match
        matchingInputs(1,k)=spot; %the k-th neuron of the filter corresponds to index 'spot' in data
    %else : the return value of matching input remains at zero
    end
    clear temp spot
end