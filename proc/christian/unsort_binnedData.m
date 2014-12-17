function binnedData = unsort_binnedData(binnedData)

spikes = zeros(size(binnedData.spikeratedata,1),96);

for i = 1:96
    all_u_from_ch = find(binnedData.neuronIDs,i);
    spikes(:,i) = sum(binnedData.spikeratedata(:,all_u_from_ch),2);
end

binnedData.spikeratedata = spikes;
binnedData.neuronIDs = [(1:96)' zeros(96,1)];
binnedData.spikeguide = neuronIDs2spikeguide(binnedData.neuronIDs);