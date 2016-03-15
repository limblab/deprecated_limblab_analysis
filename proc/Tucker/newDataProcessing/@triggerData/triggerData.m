classdef triggerData < timeSeriesData
    %sub-class inheriting from timeSeriesData so that trigger specific 
    %methods may be added. See the binnedData sub-class for a more 
    %eleborate example of a timeSeriesData sub-class. See also the 
    %timeSeriesData class definition for inherited properties and methods
    properties(SetAccess = public)
    end
    properties (Access = private)
    end
    methods (Static = true)
        %constructor
        function triggers=triggerData()
        end
    end
    methods
        %setter methods
    end
    methods (Static = false)
        %general methods
    end
end