classdef timeSeriesData < matlab.mixin.SetGet
    properties (Access = public, SetObservable = true)
        fc
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
        function dt=timeSeriesData()
            fc=filterConfig();
            set(dt,'fc',fc)
            set(dt,'data',cell2table(cell(0,2),'VariableNames',{'t','data'}))
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
        function set.fc(dt,fc)
            if ~isa(fc,'filterConfig')
                error('dataTable:NotAFilterConfig','the fc field must be an object with the filterConfig class')
            else
                dt.fc=fc;
            end
        end
        
    end
    methods (Static = false)
        %general methods
        function refilter(tsd)
            labels=tsd.data.Properties.VariableNames;
            units=tsd.data.Properties.VariableUnits;
            descriptions=tsd.data.Properties.VariableDescriptions;
            %get all the non-logical columns
            mask=~table2array(varfun(@islogical,tsd(1,:)));
            %refilter the non logical columns:
            aData=decimateData(tsd.data{:,mask},tsd.fdFilterConfig);
            %convert analog data into a table
            aData=array2table(aData,'VariableNames',labels(mask));
            aData.Properties.VariableUnits=units(mask);
            aData.Properties.VariableDescriptions=descriptions(mask);
            aData.Properties.Description=tsd.data.Properties.Description;
            %get logical values on the same time-series as the refiltered
            %data:
            lData=interp1(aData(1,:),tsd.data(:,~mask),tsd.data.t,'nearest');
            
            %if one of our coulmns is the 'good' logical column then expand
            %the range of 'bad' windows to handle filter ringing:
            ind=find(strcmp(labels(~mask),'good'),1);
            if ~isempty(ind)
                %extend 'bad' regions by 4x the period of the cutoff
                %frequency to reduce the impact of ringing artifacts:
                %get the number of points equal to 4x the cutoff period:
                wnd=ceil((4/tsd.fc.cutoff)/mode(diff(lData(:,1))));
                %find the 'bad' windows
                chng=diff(tsd.data{:,ind});
                numInd=length(tsd.data{:,ind});
                badStarts=find(chng==1);
                badEnds=find(chng==-1);
                if badEnds(1)<badStarts(1)
                    badStarts=[1,badStarts];
                end
                if length(badStarts)>length(badEnds)
                    badEnds(end+1)=numInd;
                end
                %expand the bad windows
                badStarts=badStarts-wnd;
                badStarts(badStarts<1)=1;
                badEnds=badEnds+wnd;
                badEnds(badEnds>numInd)=numInd;
                %build a new 'good' vector by pushing 'false' into the new
                %window regions
                for i=1:length(badStarts)
                    tsd.data{badStarts(i):badEnds(i)}=false;
                end
            end
            %convert digital data into a table:
            lData=array2table(lData,'VariableNames',labels(~mask));
            lData.Properties.VariableUnits=units(~mask);
            lData.Properties.VariableDescriptions=descriptions(~mask);
            lData.Properties.Description=tsd.data.Properties.Description;
           
            %use set to put the newly filtered data into the tsd:            
            set(tsd,'data',[aData,lData]);           
            notify(tsd,'refiltered')
        end
        function appendTable(tsd,data,varargin)
            if isempty(varargin)
                if ~isempty(tsd.data)
                    warning('appendTable:NoTimeShift','when attempting to append new data, no time shift was passed. Defaulting to the max of the current data +1s')
                    timeShift=max(tsd.data.t)+1;
                else
                    timeShift=0;
                end
            else
                timeShift=varargin{1};
                if isempty(tsd.data)
                    warning('appendTable:shiftedNewData','applying a time shift to data that is being placed in an empty units field')
                end
                
                if ~isempty(tsd.data) && timeShift<max(tsd.data.t)
                    error('appendTable:timeShiftTooSmall','when attempting to append new data, the specified time shift must be larger than the largest existing time')
                end
            end
            
            if isempty(tsd.data)
                %just put the new dt in the field
                set(tsd,'data',data)
            else
                %get the column index of timestamp or time, whichever this
                %table is using:
                mask=cell2mat({strcmp(data.Properties.VariableNames,'t')});
                data{:,mask}=data{:,mask}+timeShift;
                set(tsd,'data',[tsd.data;data]);
            end
            notify(tsd,'appended')
        end
    end
end