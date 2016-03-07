classdef kinematicData < matlab.mixin.SetGet
    properties(Access = public)
        kinFilterConfig%filterconfig
    end
    properties (Access = private)
        data%main data table
    end
    methods (Static = true)
        %constructor
        function kin=kinematicData()
            set(kin,'kinFilterConfig',filterConfig('poles',8,'cutoff',25,'SR',100));%a low pass butterworth 
            kin.data=cell2table(cell(0,7),'VariableNames',{'t','x','y','vx','vy','fx','fy','still','good'});
        end
    end
    methods
        %setter methods
        function set.kinFilterConfig(kin,fc)
            if ~isa(fc,'filterConfig')
                error('kinFilterConfig:badFormat','kinFilterConfig must be a filterConfig object')
            else
                kin.kinFilterConfig=fc;
            end
        end
        function set.data(kin,data)
            if ~istable(data) || size(data,2)~=7 ...
                    || isempty(find(strcmp('t',data.Properties.VariableNames),1)) ...
                    || isempty(find(strcmp('still',data.Properties.VariableNames),1)) ...
                    || isempty(find(strcmp('good',data.Properties.VariableNames),1))...
                    || isempty(find(strcmp('x',data.Properties.VariableNames),1)) ...
                    || isempty(find(strcmp('y',data.Properties.VariableNames),1))...
                    || isempty(find(strcmp('vx',data.Properties.VariableNames),1)) ...
                    || isempty(find(strcmp('vy',data.Properties.VariableNames),1))...
                    || isempty(find(strcmp('ax',data.Properties.VariableNames),1)) ...
                    || isempty(find(strcmp('ay',data.Properties.VariableNames),1))
                error('kin:badFormat','kin must be a table with 7 columns: t, x, y, vx, vy, ax, and ay. t is the time of each sample, and (x,y), (vx,vy), (ax,ay) are the position velocity and acceleration respectively. ')
            else
                kin.data=data;
            end
        end
    end
    methods (Static = false)
        %general methods
        function refilter(kin)
            data=decimateData(kin.data{:,:},kin.kinFilterConfig);
            stillIdx=strcmp(kin.data.Properties.VariableNames,'still');
            goodIdx=strcmp(kin.data.Properties.VariableNames,'good');
            data(:,stillIdx)=ceil(data(:,stillIdx));
            data(:,goodIdx)=floor(data(:,goodIdx));
            data=array2table(data,'VariableNames',kin.data.Properties.VariableNames);
            data.Properties.VariableUnits=kin.data.Properties.VariableUnits;
            data.Properties.VariableDescriptions=kin.data.Properties.VariableDescriptions;
            data.Properties.Description=kin.data.Properties.Description;
            set(kin,'data',data);           
        end
        
    end
end