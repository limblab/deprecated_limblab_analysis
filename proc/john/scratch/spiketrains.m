function[trains] = spiketrains(bdf,unit_indices)

% If unit_indices == 1, trains contains a neuron id followed by timestamps 
% for each unit. i.e.  trains{i} = [channel.unit timestamps];
% If unit_indices ~= 1, there is no channel information.


chan = [];
neur_ind = [];
for i = 1:length(bdf.units)
    
    if bdf.units(i).id(2) ~= 0 && bdf.units(i).id(2) ~= 255
        chan = [chan bdf.units(i).id(1) + bdf.units(i).id(2)./10];
        neur_ind = [neur_ind i];  
    end
    
end

trains = cell(length(neur_ind),1);

for i = 1:length(neur_ind);
    
    if unit_indices ~= 1
        trains{i} = [bdf.units(neur_ind(i)).ts];
    else
        trains{i} = [chan(i); bdf.units(neur_ind(i)).ts];
    end

end


end

