function [binnedData, varargout] = rand_perm_units(binnedData,pct)
%This function modifies the firing rate of a given % (in:pct) of units
% by permuting the firing rates of pairs of units

sg = binnedData.spikeguide;
sd = binnedData.spikeratedata;

numUnits = size(sg, 1);
if numUnits < 2
    warning('Cannot perform unit permutation with less than 2 units - operation aborted');
    return;
end

numPerm = round(numUnits*pct/(100*2));%  e.g. 10% of 100 units = 100*10/(100*2) = 5 permutations, so 10 units are changed
elec_perm = zeros(numPerm,4);
%elect_perm = [elec_1 unit_1 elec_2 unit_2]

for i = 1:numPerm
    unit_1 = round(numUnits*rand+0.5);
    unit_2   = round(numUnits*rand+0.5);
    while unit_1 == unit_2 %just make sure we don't copy a unit to itself
        unit_2 = round(numUnits*rand+0.5);
    end
    elec_perm(i,1:2) = spikeguide2neuronIDs(sg(unit_1,:));
    elec_perm(i,3:4) = spikeguide2neuronIDs(sg(unit_2,:));

    sd_t = sd(:,unit_1); %copy unit 1 to temp
    sd(:,unit_1) = sd(:,unit_2); %copy unit 2 to unit 1
    sd(:,unit_2) = sd_t; %copy temp to unit 2
end

binnedData.spikeratedata = sd;
varargout{1} = elec_perm;
end