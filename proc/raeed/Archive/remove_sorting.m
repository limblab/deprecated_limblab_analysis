function bdf_nosort=remove_sorting(bdf)
    %removes the unit sorting from a bdf. This function takes all spikes
    %that are sorted into units and adds them to unit 0 (unsorted spikes)
    
    %copy the bdf for the output and erase the old spike data
    bdf_nosort=bdf;
    bdf_nosort.units=[];
    
    
    %get a list of all the valid channels
    ul = unit_list(bdf,1);
    
    
    
    channel_list=sort(unique(ul(:,1)));
        
    %for each channel 
    for i=1:length(channel_list)
        %find all the units
        list=[];
        for j=1:length(bdf.units)
            if bdf.units(1,j).id(1)==channel_list(i)
                list=[list j];
            elseif bdf.units(1,j).id(1)>channel_list(i)
                continue
            end
        end
        %put all units for the channel into unit 0 of the ouput bdf
        bdf_nosort.units(1,i).id=[channel_list(i),0];
        bdf_nosort.units(1,i).ts=[];
        for k=1:length(list)
            bdf_nosort.units(1,i).ts=[bdf_nosort.units(1,i).ts;bdf.units(1,list(k)).ts];
        end
        bdf_nosort.units(1,i).ts=sort(bdf_nosort.units(1,i).ts);
    end
    
    
end