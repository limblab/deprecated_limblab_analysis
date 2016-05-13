function removeSorting(units,varargin)
    %this is a method function of the unitData class and should be found in
    %the @unitData folder.
    %
    %strips sorting from units.data. A list of units can be passed,
    %and sorting will be stripped only for those units. In this
    %case the list will be a cell array. each row of the cell array
    %will be a pair of cells indicating the array ID and list of
    %channels to remove sorting, e.g.: [{'Rt_M1},{[1:96]}]

    for i=1:2:numel(varargin)
        switch varargin{i}
            case 'IDs'
                if iscell(varargin{i+1})
                    arrayIDs=varargin{i+1};
                else
                    arrayIDs={varargin{i+1}};
                end
            case 'chans'
                if iscell(varargin{i+1})
                    chans=varargin{i+1};
                else
                    chans={varargin{i+1}};
                end
            case 'ignoreInvalid'
                ignoreInvalid=varargin{i+1};
            otherwise
                if ~ischar(varargin{i})
                    error('removeSorting:badKey',['all keys must be strings. Input #:',num2str(i),' should be a key, but is not a string'])
                else
                    error('removeSorting:invalidKey',['the key: ',varargin{i},' is not recognized'])
                end
        end
    end
    if ~exist('ignoreInvalid','var')
        ignoreInvalid=true;
    end
    if ~exist('arrayIDs','var')
        arrayIDs=unique({units.data.array});
    end
    if ~exist('chans','var')
        for i=1:length(arrayIDs)
            arrayMask=strcmp({units.data.array},arrayIDs{i});
            chans{i,1}=unique([units.data(arrayMask).chan]);
        end
        %chans=unique(cell2mat({units.data.chan}));
    end
    removeIdx=[];
    for i=1:length(arrayIDs)
        chanList=chans{i};
        arrayMask=strcmp({units.data.array},arrayIDs{i});
        for j=1:length(chans{i})
            %find a list of indexes with this arrayID and channel
            chanMask=[units.data.chan]==chanList(j);
            mask=arrayMask & chanMask;
            %now merge these into one entry in the units field and
            %then delete the original entries:
            idx=find(mask);
            saveIdx=[];
            spikes=[];
            for k=1:length(idx)
                if units.data(idx(k)).ID==255 && ignoreInvalid
                    continue
                end
                spikes=[spikes;units.data(idx(k)).spikes];
                if units.data(idx(k)).ID~=0;
                    removeIdx=[removeIdx,idx(k)];
                else
                    saveIdx=idx(k);
                end
            end
            if ~isempty(saveIdx)
                units.data(saveIdx).spikes=spikes;
            end
        end
    end
    units.data(removeIdx)=[];
    %% notify the event so listners can log this operation:
    evntData=loggingListenerEventData('removeSorting',[]);
    notify(units,'removedSorting',evntData)
end