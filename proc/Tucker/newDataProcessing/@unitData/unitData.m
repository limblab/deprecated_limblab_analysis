classdef unitData < matlab.mixin.SetGet
    properties(SetAccess = public)
    end
    properties (Access = private)
        data%main data table
    end
    methods (Static = true)
        %constructor
        function units=unitData()
            units.data=struct('chan',[],'ID',[],'array',{},'spikes',cell2table(cell(0,2),'VariableNames',{'ts','wave'}));
        end
    end
    methods
        %setter methods
        function set.data(units,data)
            f=@(x) ~isa(x,'table');
            f2=@(x) size(x,2)~=2;
            f3=@(x) isempty(find(strcmp('ts',x.Properties.VariableNames),1));
            f4=@(x) isempty(find(strcmp('wave',x.Properties.VariableNames),1));
            
            if isempty(data) 
                units.units=data;
            elseif ~isstruct(data)
                error('unitData:badFormat','Units must be a struct')
            elseif ~isfield(data,'chan') ||  ~isnumeric([data(:).chan])
                error('unitData:badchanFormat','units must have a field called chan that contains a numeric array of channel numbers')
            elseif ~isfield(data,'ID') || ~isnumeric([data(:).ID])
                error('unitData:badIDFormat','units must have a field called ID that contains a numeric array of the ID numbers')
            elseif ~isfield(data,'array') ||  ~iscellstr({data.array})
                error('unitData:badarrayFormat','units must have a field called array that contains a cell array of strings, where each string specifies the array on which the unit was collected')
            elseif ~isfield(data,'spikes') 
                error('unitData:missingspikes','units must have a field called spikes containing tables of the spike times and waveforms')
            elseif ~isempty({data.spikes}) && (~isempty(find(cellfun(f,{data.spikes}),1)) ...
                    || ~isempty(find(cellfun(f2,{data.spikes}),1)) ...
                    || ~isempty(find(cellfun(f3,{data.spikes}),1)) ...
                    || ~isempty(find(cellfun(f4,{data.spikes}),1)) )
                error('unitData:badFormat','all elements in units.spikes must be tables with 2 columns: ts and wave. ts contains the timestamps of each wave, and wave contains the snippet of the threshold crossing')
            else
                units.data=data;
            end
        end
    end
    methods (Static = false)
        %general methods
        function removeSorting(units,varargin)
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
            
        end
    end
end