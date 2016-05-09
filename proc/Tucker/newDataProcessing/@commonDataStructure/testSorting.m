function testSorting(cds)
    %testSorting is a method of the commonDataStructure class and should be
    %saved in the @commonDataStructure folder with the other methods.
    %
    %testSorting is not intended to be a user accessible function and
    %should only be called by the cds.unitsFromNEV method
    
    error('testSorting:notImplemented','This method is note implemented. We are waiting on ChrisV to finish up some code to have a few intelligent tests before implementing.')
    sortedMask=[cds.units.ID]>0 && [cds.units.ID]<255;
    for i=1:numel(sortedMask)
        if ~sortedMask(i)
            cds.units(i).wellSorted=false;
            continue
        end
        %find other units that are on the same channel:
        chan=cds.units(i).chan;
        chanIdx=find([cds.units.chan]==chan);
        if isempty(chanIdx)
            cds.units(i).wellSorted=false;
            continue
        end
            
        for j=1:numel(chanIdx)
            if i==chanIdx(j)
                %skip comparing the unit to itself
                continue
            end
            %compare cds.units(i) to cds.units(chanIdx(j)) and store the
            %result in cds.units(i).wellSorted;
        end
    end
    
    
end