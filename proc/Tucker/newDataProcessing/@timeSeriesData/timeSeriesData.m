classdef timeSeriesData < matlab.mixin.SetGet
    properties (Access = public, SetObservable = true)
        filterConfig
    end
    properties (SetAccess = protected, GetAccess = public, SetObservable = true)
        data
    end
    events
        refiltered
        appended
    end
    methods (Static = true)
        %constructor
        function tsd=timeSeriesData(varargin)
            fc=[];
            data=[];
            if ~isempty(varargin)
                for i=1:length(varargin)
                    if isa(varargin{i},'filterConfig')
                        fc=varargin{i};
                    elseif isa(varargin{i},'table')
                        data=varargin{i};
                    end
                end
            end
            if isempty(fc)
            fc=filterConfig();
            end
            if isempty(data)
                data=cell2table(cell(0,2),'VariableNames',{'t','data'});
            end
            set(tsd,'filterConfig',fc)
            set(tsd,'data',data)
        end
    end
    methods (Static = true, Access = protected)
        function [isValid,reqLabels,labels]=checkDataLabels(data)
            %this is a stub function intended to be copied over to
            %sub-classes of timeSeriesData. Simply copy this function as a
            %method of the sub-class, and expand the reqLabels as needed.
            %The results of this function are only called by the 
            %
            %checkDataLabels to see if they conform the the required set
            %for this timeSeriesData object.
            isValid=1;
            reqLabels={'t'};
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
        %set methods
        function set.data(tsd,data)
            if ~istable(data)
                error('dataTable:NotATable','The data field of the dataTable class must be an object of the table class')
            end
            [isValid,reqLabels,labels]=tsd.checkDataLabels(data);
            if ~isValid
                error('timeSeriesData:BadLabelList',['this sub-class of timeSeriesData requires the following labels: ',strjoin(reqLabels,','),' and you provided the following labels: ',strjoin(labels,',')])
            else
                tsd.data=data;
            end
        end
        function set.filterConfig(tsd,fc)
            if ~isa(fc,'filterConfig')
                error('dataTable:NotAFilterConfig','the filterConfig field must be an object with the filterConfig class')
            else
                tsd.filterConfig=fc;
            end
        end
        
    end
    methods (Static = false)
        %general methods
        refilter(tsd)
        appendTable(tsd,data,varargin)
    end
end