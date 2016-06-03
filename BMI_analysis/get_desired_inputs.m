function desiredInputs = get_desired_inputs(spikeguide, neuronIDs)

    neuronChannels = spikeguide2neuronIDs(spikeguide);
    numberInputs = size(neuronIDs,1);
    
    for k=1:numberInputs
        temp=neuronIDs(k,:);
        spot=find((neuronChannels(:,1)==temp(1,1)) & (neuronChannels(:,2)==temp(1,2)));
        if isempty(spot)
            desiredInputs = [];
            return;
        end
        desiredInputs(1,k)=spot;
        clear temp spot;
    end