classdef kinematicData < timeSeriesData
    %sub-class inheriting from timeSeriesData so that kin specific methods
    % may be added. See also the timeSeriesData
    % class definition for inherited properties and methods
    %
    %the kinematicData class is intended to be a field of the experiment
    %class but can be used as a stand-alone object
    
    properties(Access = public)
    end
    properties (Access = private)
    end
    methods (Static = true)
        %constructor
        function kin=kinematicData()
            kin = kin@timeSeriesData(cell2table(cell(0,9),'VariableNames',{'t','still','good','x','y','vx','vy','ax','ay'}));
        end
    end
    methods (Static = true, Access = protected)
        function [isValid,reqLabels,labels]=checkDataLabels(data)
            %implementation of the checkDataLabels method to overload the
            %stub method of the same name defined in the
            %timeSeriesDataClass that only checks for the existence of
            %column 't'
            %
            %checkDataLabels to see if they conform the the required set
            %for this timeSeriesData object.
            isValid=1;
            if isempty(data)
                reqLabels={'t'};
            else
                reqLabels={'t','still','good','x','y','vx','vy','ax','ay'};
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
       refilter(kin)
    end
end