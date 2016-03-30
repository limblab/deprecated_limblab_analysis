classdef forceData <matlab.mixin.SetGet
    properties(Access = public)
        fdFilterConfig%filterconfig
        data%main data table
    end
    methods (Static = true)
        %constructor
        function fd=forceData()
            set(fd,'kinFilterConfig',filterConfig('poles',8,'cutoff',25,'SR',100));%a low pass butterworth 
            fd.data=cell2table(cell(0,7),'VariableNames',{'t','x','y','vx','vy','fx','fy','still','good'});
        end
    end
    methods
        %setter methods
        function set.fdFilterConfig(kin,fc)
            if ~isa(fc,'filterConfig')
                error('kinFilterConfig:badFormat','kinFilterConfig must be a filterConfig object')
            else
                kin.kinFilterConfig=fc;
            end
        end
        function set.data(fd,data)
            if ~istable(data) || size(data,2)~=7 ...
                    || isempty(find(strcmp('t',data.Properties.VariableNames),1)) ...
                    || isempty(find(strcmp('fx',data.Properties.VariableNames),1)) ...
                    || isempty(find(strcmp('fy',data.Properties.VariableNames),1))
                error('forceData:badFormat','data must be a table with at least 3 columns: t, fx, fy. t is the time of each sample, and (fx,fy)is the cartesian force. ')
            else
                fd.data=data;
            end
        end
    end
    methods (Static = false)
        %general methods
        function refilter(fd)
            data=decimateData(fd.data{:,:},fd.fdFilterConfig);
            data=array2table(data,'VariableNames',fd.data.Properties.VariableNames);
            data.Properties.VariableUnits=fd.data.Properties.VariableUnits;
            data.Properties.VariableDescriptions=fd.data.Properties.VariableDescriptions;
            data.Properties.Description=fd.data.Properties.Description;
            set(fd,'data',data);           
        end
        
    end
end