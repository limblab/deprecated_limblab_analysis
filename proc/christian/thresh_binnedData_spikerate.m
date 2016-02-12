function bd = thresh_binnedData_spikerate(binnedData,min_firing_rate)

idx = find(mean(binnedData.spikeratedata)>= min_firing_rate);

bd= binnedData;
bd.spikeratedata = binnedData.spikeratedata(:,idx);
bd.neuronIDs     = binnedData.neuronIDs(idx,:);
