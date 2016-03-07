classdef lfpData <matlab.mixin.SetGet
    properties(Access = public)
        lfpFilterConfig%filterconfig
    end
    properties (Access = private)
        data%main data table
    end
    methods (Static = true)
        %constructor
        function lfp=lfpData()
            set(lfp,'lfpFilterConfig',filterConfig('poles',4,'cutoff',[3 500],'SR',2000));%a band pass butterworth 4poles at each corner
            lfp.data=cell2table(cell(0,2),'VariableNames',{'t','lfp'});
        end
    end
    methods
        %setter methods
        function set.lfpFilterConfig(lfp,data)
            if ~isa(data,'filterConfig')
                error('lfpFilterConfig:badFormat','lfpFilterConfig must be a filterConfig object')
            else
                lfp.lfpFilterConfig=data;
            end
        end
        function set.data(lfp,data)
            if ~istable(data) || isempty(find(strcmp('t',data.Properties.VariableNames),1)) 
                error('lfp:badFormat','lfp must be a table with a column t indicating the times of each row')
            else
                lfp.data=data;
            end
        end
    end
    methods (Static = false)
        %general methods
        function refilter(lfp)
            data=decimateData(lfp.data{:,:},lfp.fdFilterConfig);
            data=array2table(data,'VariableNames',lfp.data.Properties.VariableNames);
            data.Properties.VariableUnits=lfp.data.Properties.VariableUnits;
            data.Properties.VariableDescriptions=lfp.data.Properties.VariableDescriptions;
            data.Properties.Description=lfp.data.Properties.Description;
            set(lfp,'data',data);           
        end
        
    end
end