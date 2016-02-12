function spikes = get_spikes_from_neuronIDs(binnedData,neuronIDs)
    num_ts      = size(binnedData.spikeratedata,1);
    num_neur    = size(neuronIDs,1);
    spikes      = zeros(num_ts,num_neur);
    
    [matched_id,bd_idx,nID_idx] = intersect(binnedData.neuronIDs,neuronIDs,'rows');
    
    spikes(:,nID_idx) = binnedData.spikeratedata(:,bd_idx);
    
    if size(matched_id,1) < num_neur
        warning('some specified neuron IDs could not be found in the data');
    end
end