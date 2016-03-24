classdef emgData < timeSeriesData
    %sub-class inheriting from timeSeriesData so that emg specific methods
    % may be added. See also the timeSeriesData
    % class definition for inherited properties and methods
    methods (Static = true)
        %constructor
        function emg=emgData()
        end
    end
    methods (Static = false)
        %general methods
        function rectify(emg)
            tmp=emg.data;
            tmp{:,2:end}=abs(tmp{:,2:end});
            set(emg,'data',tmp)
        end
    end
end