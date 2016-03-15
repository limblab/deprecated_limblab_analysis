classdef analogData < matlab.mixin.SetGet
    properties(SetAccess = public)
    end
    properties (SetAccess = private, GetAccess = public)
        data%main data table
    end
    methods (Static = true)
        %constructor
        function analog=analogData()
            analog.data={timeSeriesData()};
        end
    end
    methods
        %setter methods
        function set.data(analog,data)
            if (~iscell(data) && ~isempty(data))
                error('analog:badFormat','analog must be a cell array, with each cell containing a table of analog data collected at a single frequency')
            else
                for i=1:length(data)
                    %check that each cell contains an object of the dataTable type
                    if ~isa(data{i},'timeSeriesData')
                        error('analogData:NotATimeSeries',['all cells in data must contain objects of the dataTable class. cell: ',num2str(i),' contains an object of the: ',class(data{i}),' type'])
                    end
                end
                analog.data=data;
            end
        end
    end
    methods (Static = false)
        %general methods
    end
end