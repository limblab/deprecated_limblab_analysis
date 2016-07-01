function [sortedUnitIndices unitID] = getSortedUnitIndices(out_struct)
% Get the indices for the sorted cells
sortedUnitIndices = []; ind=1;
for a = 1:length(out_struct.units)
    if out_struct.units(1,a).id(2)~=0 && out_struct.units(1,a).id(2)~=255
        sortedUnitIndices(ind,1) = a;
        unitID(ind,:) = str2num(strcat(num2str(out_struct.units(a).id(1)), num2str(out_struct.units(a).id(2))));
        ind = ind+1;
    end
end
    
end