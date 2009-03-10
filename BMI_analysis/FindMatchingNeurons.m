
function [matchingInputs] = FindMatchingNeurons(spikeguide, neuronIDs)

numberinputs=size(spikeguide,1);
neuronChannels=zeros(numberinputs,2);
for k=1:numberinputs
    temp=deblank(spikeguide(k,:));
    I = findstr(temp, 'u');
    neuronChannels(k,1)=str2double(temp(1,3:(I-1)));
    neuronChannels(k,2)=str2double(temp(1,(I+1):size(temp,2)));
    clear temp I
end

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