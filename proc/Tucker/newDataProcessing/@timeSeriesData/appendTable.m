function appendTable(tsd,data,varargin)
    %this is a method of the timeSeriesData class and should be saved in
    %the @timeSeriesData folder
    %
    %tsd.appendTable(data)
    %appends the table: 'data' to the tsd.data field. If tsd.data is empty,
    %then it will be populated with data. if tsd.data is populated already,
    %then the data input to appendTable must have the same columns as the
    %existing table in tsd.data.
    %tsd.appendTable(data,'key',value)
    %allows the user to define how appendTable operates using key-value
    %pairs. Currently defined keys are:
    %'timeShift':   Allows the user to pass a specific shift in the times
    %               of the new data. Shifts will be applied directly e.g.
    %               passing 1500 will shift the times of the new data by
    %               1500s. If no value is passed, the default shift is the
    %               last time in the existing data +1s
    %'overWrite':   allows the user to overwrite the existing data rather
    %               than tack on to the end of data that already exists.
    %               The value for this key is a bool (e.g. true/false or
    %               1/0)
    if ~isempty(varargin)

        for i=1:2:length(varargin)
            if ~ischar(varargin{i}) || mod(length(varargin),2)>1
                error('appendTable:badKey','additional inputs to the appendTable method must be key-value pairs, with a string as the key')
            end
            switch varargin{i}
                case 'timeShift'
                    timeShift=varargin{i+1};
                case 'overWrite'
                    overWrite=varargin{i+1};
                otherwise
                    error('appendTable:badKeyString',['the key string: ',varargin{i}, 'is not recognized by appendTable'])
            end
        end
    end
    if ~exist('overWrite','var')
        overWrite=false;
    end
    if ~exist('timeShift','var')
        if ~isempty(tsd.data)
%                    warning('appendTable:NoTimeShift','when attempting to append new data, no time shift was passed. Defaulting to the max of the current data +1s')
            timeShift=max(tsd.data.t)+1;
        else
            timeShift=0;
        end
    end            

        if isempty(tsd.data) && exist('timeShift','var') && timeShift~=0
            warning('appendTable:shiftedNewData','applying a time shift to data that is being placed in an empty timeSeriesData.data field')
            mask=cell2mat({strcmp(data.Properties.VariableNames,'t')});
            data{:,mask}=data{:,mask}+timeShift;
        end
        if ~isempty(tsd.data)&& timeShift<max(tsd.data.t)
            error('appendTable:timeShiftTooSmall','when attempting to append new data, the specified time shift must be larger than the largest existing time')
        end


    if isempty(tsd.data) || overWrite
        %just put the new dt in the field
        set(tsd,'data',data)
    else
        %get the column index of timestamp or time, whichever this
        %table is using:
        set(tsd,'data',[tsd.data;data]);
    end
    cfg.timeShift=timeShift;
    cfg.overWrite=overWrite;
    evntData=loggingListenerEventData('appendTable',cfg);
    notify(tsd,'appended',evntData)
end