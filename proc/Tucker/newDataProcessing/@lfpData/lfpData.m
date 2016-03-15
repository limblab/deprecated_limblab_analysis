classdef lfpData < timeSeriesData
    %sub-class inheriting from timeSeriesData so that lfp specific methods
    % may be added. See the binnedData sub-class for a more eleborate
    % example of a timeSeriesData sub-class. See also the timeSeriesData
    % class definition for inherited properties and methods
    methods (Static = true)
        %constructor
        function lfp=lfpData()
        end
    end
    methods
        %setter methods
    end
    methods (Static = false)
        %general methods        
    end
end