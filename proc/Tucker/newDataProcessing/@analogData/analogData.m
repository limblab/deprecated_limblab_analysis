classdef analogData < matlab.mixin.SetGet
    properties(SetAccess = public)
        analogFilterConfig%filterconfig
    end
    properties (Access = private)
        data%main data table
    end
    methods (Static = true)
        %constructor
        function analog=analogData()
            set(analog,'analogFilterConfig',filterConfig('poles',8,'cutoff',25,'SR',100));%a high pass butterworth 8poles filter
            analog.data=cell(0,0);
        end
    end
    methods
        %setter methods
        function set.data(analog,data)
            if (~iscell(data) && ~isempty(data))
                error('analog:badFormat','analog must be a cell array, with each cell containing a table of analog data collected at a single frequency')
            else
                analog.data=data;
            end
        end
    end
    methods (Static = false)
        %general methods
        function refilter(analog,cellNum)
            data=analog.data{cellNum};
            data=decimateData(data{:,:},fd.fdFilterConfig);
            data=array2table(data,'VariableNames',fd.data.Properties.VariableNames);
            data.Properties.VariableUnits=fd.data.Properties.VariableUnits;
            data.Properties.VariableDescriptions=fd.data.Properties.VariableDescriptions;
            data.Properties.Description=fd.data.Properties.Description;
            analog.data{cellNum}=data;
        end
    end
end