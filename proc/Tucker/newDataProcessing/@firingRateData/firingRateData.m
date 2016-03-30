classdef firingRateData < matlab.mixin.SetGet
    properties(SetAccess = public)
    end
    properties (Access = private)
        data%main data table
    end
    methods (Static = true)
        %constructor
        function fr=firingRateData()
            fr.data=cell(0,0);
        end
    end
    methods
        %setter methods
        function set.data(fr,data)
            if ~istable(data) || size(data,2)>=1
                error('firingRateData:badFormat','data must be a table with at least 2 columns. The first column t, is the time of each sample.')
            else
                fr.data=data;
            end
        end
    end
    methods (Static = false)
        %general methods
        
    end
end