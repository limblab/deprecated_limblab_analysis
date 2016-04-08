function removeSorting(units,varargin)
    %this is a method function of the unitData class and should be found in
    %the @unitData folder.
    %
    %strips sorting from units.data. A list of units can be passed,
    %and sorting will be stripped only for those units. In this
    %case the list will be a cell array. each row of the cell array
    %will be a pair of cells indicating the array ID and list of
    %channels to remove sorting, e.g.: [{'Rt_M1},{[1:96]}]

    if ~isempty(varargin)
        temp=varargin{1};
        arrayIDs=temp(:,1);
        chans=temp(:,2);
    else
        arrayIDs=unique({units.data.array});
        for i=1:length(arrayIDs)
            arrayMask=strcmp({units.array},arrayIDs{i});
            chans(i,1)={unique(units(arrayMask).chan)};
        end
        chans=unique(cell2mat({units.data.chan}));
    end
    for i=1:length(arrayIDs)
        for j=1:length(chans{i})
            chanList=chans{i};
            %find a list of indexes with this arrayID and channel
            arrayMask=strcmp({units.array},arrayIDs{i});
            chanMask=cell2mat({units.chan}==chanList{j});
            mask=arrayMask & chanMask;
            %now merge these into one entry in the units field and
            %then delete the original entries:
            unsortedUnit.chan=chanList{j};
            unsortedUnit.ID=0;
            unsortedUnit.arrayID=arrayIDs{i};
            unsortedUnit.spikes=[];
            idx=find(mask);
            for k=1:length(idx)
                unsortedUnit.spikes=[unsortedUnits.spikes; units.spikes(idx(k))];
                units.spikes(idx(k))=[];
            end
            units=[units;unsortedUnit];
        end
    end
    %% notify the event so listners can log this operation:
    evntData=loggingListenerEventData('removeSorting',[]);
    notify(units,'removedSorting',evntData)
end