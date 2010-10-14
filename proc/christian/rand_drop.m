function [binnedData, varargout] = rand_drop(binnedData,pct)

sg = binnedData.spikeguide;
sd = binnedData.spikeratedata;

numUnits = size(sg, 1);
numDrop = round(numUnits*pct/100);
elec = zeros(numDrop,2);

for i = 1:numDrop
    numUnits = size(sg, 1);
    drop_i = round(numUnits*rand+0.5);
    elec(i,:) = spikeguide2neuronIDs(sg(drop_i,:));
    sg = sg( ~(1:size(sg,1)==drop_i), :);
    sd = sd( : , ~(1:size(sd,2)==drop_i));
    
end

binnedData.spikeguide = sg;
binnedData.spikeratedata = sd;
varargout{1} = elec;
end