function spikeguide = neuronIDs2spikeguide(neuronIDs)   
    numberinputs = size(neuronIDs,1);
    spikeguide = char(zeros(numberinputs,6));
    
    for i=1:numberinputs
        spikeguide(i,:) = sprintf('ee%02du%1d', neuronIDs(i,1),neuronIDs(i,2));
    end
end