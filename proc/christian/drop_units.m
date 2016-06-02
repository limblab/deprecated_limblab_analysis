function [binnedData] = drop_units(binnedData,units)

sg = binnedData.spikeguide;
sd = binnedData.spikeratedata;

dui = FindMatchingNeurons(sg,units);

for i = 1:length(dui)
    sg = sg( ~(1:size(sg,1)==dui(i)), :);
    sd = sd( : , ~(1:size(sd,2)==dui(i)) );
end

binnedData.spikeguide = sg;
binnedData.spikeratedata = sd;