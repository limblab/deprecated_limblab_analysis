function units = get_unit_list(unit_names,spikeguide)
% INPUT: unit_names: array of strings listing unit names in format 'eeXXuY'
% OUTPUT: index of that unit within the arrays/matrices used in SD analysis

units = zeros(size(unit_names,1),1);
for i = 1:size(unit_names,1)
    
    curr_unit = unit_names(i,:); %string giving unit name
    for j = 1:length(spikeguide)
        if strcmp(spikeguide(j,:),curr_unit)
            units(i) = j;
        end
    end
    
end


