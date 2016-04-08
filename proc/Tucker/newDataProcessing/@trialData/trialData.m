classdef trialData < matlab.mixin.SetGet
    %note trialData is not a member of the timeSeriesData superclass 
    %because it is not a timeseries.
    properties(SetAccess = public)
    end
    properties (SetAccess = protected, GetAccess = public, SetObservable = true)
        data%main data table
    end
    methods (Static = true)
        %constructor
        function trials=trialData()
        end
    end
    events
        appended
    end
    methods
        %setter methods
        function set.data(trials,data)
            if ~istable(data) || size(data,2)<3 ...
                    || isempty(find(strcmp(data.Properties.VariableNames,'number'),1)) ...
                    || isempty(find(strcmp(data.Properties.VariableNames,'startTime'),1)) ...
                    || isempty(find(strcmp(data.Properties.VariableNames,'endTime'),1))
                
                error('trialData:badFormat','data must be a table with at least 2 columns. The first column t, is the time of each sample.')
            else
                trials.data=data;
            end
        end
    end
    methods (Static = false)
        %general methods
        appendTable(trials,table,varargin)
    end
end