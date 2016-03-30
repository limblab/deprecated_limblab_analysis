classdef forceData < timeSeriesData 
    %sub-class inheriting from timeSeriesData so that force specific methods
    % may be added. See also the timeSeriesData
    % class definition for inherited properties and methods
    properties(Access = public)
    end
    methods (Static = true)
        %constructor
        function fd=forceData()
            fd = fd@timeSeriesData(cell2table(cell(0,3),'VariableNames',{'t','fx','fy'}));
        end
    end
    methods (Static = true, Access = protected)
        function [isValid,reqLabels,labels]=checkDataLabels(data)
            %implementation of the checkDataLabels method to overlaod the
            %stub method of the same name defined in the
            %timeSeriesData class that only checks for the existence of
            %column 't'
            %
            %checkDataLabels to see if they conform the the required set
            %for this timeSeriesData object.
            isValid=1;
            if isempty(data)
                reqLabels={'t'};
            else
                reqLabels={'t','fx','fy'};
            end
            labels=data.Properties.VariableNames;
            for i=1:length(reqLabels) 
                if isempty(find(strcmp(reqLabels{i},labels),1))
                    isValid=0;
                    return
                end
            end
        end
    end
    methods
        %setter methods
    end
    methods (Static = false)
        %general methods
    end
end