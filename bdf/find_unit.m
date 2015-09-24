function i=find_unit(bdf,id)
    %index=find_unit(bdf,id)
    %id is a 1x2 vector containing the channel and unit number of the
    %desired unit
    %returns the index in bdf.units where a unit with the specified ID is
    %located
    for i=1:length(bdf.units)
        if 2==sum(bdf.units(i).id==id)
            return
        end
    end
end