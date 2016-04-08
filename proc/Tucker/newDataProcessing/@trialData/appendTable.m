function appendTable(trials,data,varargin)
    %appendTable is a method of the trialData class. This method
    %takes a trials table from a cds object and either inserts it
    %into an empty trialData object, or appends it to the end of an
    %existing trialData object. 
    %
    %appendTable will look for columns with Time in the
    %VariableName property, e.g. startTime, endTime, goCueTime etc.
    %and will add an offset to these trials. The user may specify
    %the offset as a third argument to appendTable, or appendTable
    %will use the largest value in the stopTime column

    %sanity check that existing trials and new trials have the same
    %columns:
    if ~isempty(trials.data) && ~isempty(setdiff(trials.data.Properties.VariableNames,data.Properties.VariableNames))
        disp(['existing columns: ',])
        error('appendTable:differentColumns','The existing trial data and the new data MUST have the same columns')
    end
    %establish the mask that we use to select time columns
    mask=~cellfun('isempty',strfind(data.Properties.VariableNames,'Time'));

    if isempty(varargin)
        if ~isempty(trials.data)
            timeShift=max(trials.data.endTime)+1;
        else
            timeShift=[];
        end
    else
        timeShift=varargin{1};
        if isempty(trials.data)
            warning('appendTable:shiftedNewData','applying a time shift to data that is being placed in an empty trialData.data field')
        end

        if ~isempty(trials.data) && timeShift<max(trials.data.endTime)
            error('appendTable:timeShiftTooSmall','when attempting to append new data, the specified time shift must be larger than the largest existing time')
        end
    end
    if ~isempty(timeShift)
        data{:,mask}=data{:,mask}+timeShift;
    end
    if ~isempty(trials.data)
        %incriment the trial number in data so that the new trials
        %start counting at the end of the old trials
        data.number=data.number+max(trials.data.number)+1;
    end
    if isempty(trials.data)
        %just put the new trials in the field
        set(trials,'data',data)
    else
        %get the column index of time columns:
        set(trials,'data',[trials.data;data]);
    end
    trialInfo.added.numTrials=size(data,1);
    trialInfo.trialData.numTrials=size(trials.data,1);
    
    evntData=loggingListenerEventData('appendTable',trialInfo);
    notify(trials,'appended',evntData)
end