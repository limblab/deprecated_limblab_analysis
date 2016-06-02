function bdf_nosort=remove_sorting(bdf)
    %removes the unit sorting from a bdf. This function takes all spikes
    %that are sorted into units and adds them to unit 0 (unsorted spikes)
    
    %copy the bdf for the output and erase the old spike data
    bdf_nosort=bdf;
    bdf_nosort.units=[];
    
    
    %get a list of all the channels
    channel_list=-1*ones(length(bdf.units),1);
    for i=1:length(bdf.units)
        channel_list(i)=bdf.units(1,i).id(1);
    end
    channel_list=sort(unique(channel_list));
        
    %for each channel 
    for i=1:length(channel_list)
        %find all the units
        unit_list=[];
        for j=1:length(bdf.units)
            if bdf.units(1,j).id(1)==channel_list(i) && bdf.units(1,j).id(2)~=255
                unit_list=[unit_list j];
            elseif bdf.units(1,j).id(1)>channel_list(i)
                continue
            end
        end
        %put all units for the channel into unit 0 of the ouput bdf
        bdf_nosort.units(1,i).id=[channel_list(i),0];
        bdf_nosort.units(1,i).ts=[];
        for k=1:length(unit_list)
            bdf_nosort.units(1,i).ts=[bdf_nosort.units(1,i).ts;bdf.units(1,unit_list(k)).ts];
        end
        bdf_nosort.units(1,i).ts=sort(bdf_nosort.units(1,i).ts);
    end
    
    for i=length(bdf.units):-1:1
        if isempty(bdf.units(i).ts)
            bdf.units(i)=[];
        end
    end
end