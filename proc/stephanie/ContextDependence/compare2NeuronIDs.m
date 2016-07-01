function [binnedUnitIndex decoderUnitIndex intersect1] = compare2NeuronIDs(neuronIDs,binnedData);

% append the numbers in both columns for (decoder) neuronIDs
for i = 1:length(neuronIDs)
     nDecoder(i,:) = str2num(strcat(num2str(neuronIDs(i,1)),num2str(neuronIDs(i,2))));
end

% append the numbers in both columns for binnedData.neuronIDs
for i = 1:length(binnedData.neuronIDs)
     nBinned(i,:) = str2num(strcat(num2str(binnedData.neuronIDs(i,1)),num2str(binnedData.neuronIDs(i,2))));
end

% Find the common units to both neuronID populations
intersect1 = intersect(nBinned,nDecoder);
intersect2 = intersect(nDecoder,nBinned);

for i = 1:length(intersect1)
    binnedUnitIndex(i,1) = find(nBinned == intersect1(i));
end

for i = 1:length(intersect1)
    decoderUnitIndex(i,1) = find(nDecoder == intersect1(i));
end

end


