classdef emgData <matlab.mixin.SetGet
    properties(SetAccess = public)
        emgFilterConfig%filterconfig
    end
    properties (Access = private)
        data%main data table
    end
    methods (Static = true)
        %constructor
        function emg=emgData()
            set(emg,'emgFilterConfig',filterConfig('poles',4,'cutoff',[10 500],'SR',2000));%a band pass butterworth 4poles at each corner
            emg.data=cell2table(cell(0,2),'VariableNames',{'t','emg'});
        end
    end
    methods
        %setter methods
        function set.emgFilterConfig(emg,data)
            if ~isa(data,'filterConfig')
                error('emgFilterConfig:badFormat','emgFilterConfig must be a filterConfig object')
            else
                emg.emgFilterConfig=data;
            end
        end
        function set.data(emg,data)
            if ~istable(data) || isempty(find(strcmp('t',data.Properties.VariableNames),1)) 
                error('emg:badFormat','emg must be a table with a column t indicating the times of each row')
            else
                emg.data=data;
            end
        end
    end
    methods (Static = false)
        %general methods
        function refilter(emg)
            data=decimateData(emg.data{:,:},emg.fdFilterConfig);
            data=array2table(data,'VariableNames',emg.data.Properties.VariableNames);
            data.Properties.VariableUnits=emg.data.Properties.VariableUnits;
            data.Properties.VariableDescriptions=emg.data.Properties.VariableDescriptions;
            data.Properties.Description=emg.data.Properties.Description;
            set(emg,'data',data);           
        end
        function rectify(emg)
            emg.data{:,2:end}=abs(emg.data{:,2:end});
        end
    end
end