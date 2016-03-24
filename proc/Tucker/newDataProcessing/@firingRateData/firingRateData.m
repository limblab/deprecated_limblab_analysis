classdef firingRateData < timeSeriesData
    %sub-class inheriting from timeSeriesData so that FR specific methods
    % may be added. See also the timeSeriesData
    % class definition for inherited properties and methods
    methods (Static = true)
        %constructor
        function fr=firingRateData()
        end
        %callback function
    end
    methods
        %setter methods
        %firing rate dat acurrently inherits set methods for data and fc 
        %from the dataTable class
    end
    methods (Static = false)
        %general methods
    end
end