function [binnedData] = perm_units(binnedData,unit_pairs)

sg = binnedData.spikeguide;
sd = binnedData.spikeratedata;

changed_units_1 = FindMatchingNeurons(sg,unit_pairs(:,1:2));
changed_units_2 = FindMatchingNeurons(sg,unit_pairs(:,3:4));

for i = 1:size(unit_pairs,1)
    sd_t = sd(:,changed_units_1(i)); %copy unit 1 to temp
    sd(:,changed_units_1(i)) = sd(:,changed_units_2(i)); %copy unit 2 to unit 1
    sd(:,changed_units_2(i)) = sd_t; %copy temp to unit 2
end

binnedData.spikeratedata = sd;