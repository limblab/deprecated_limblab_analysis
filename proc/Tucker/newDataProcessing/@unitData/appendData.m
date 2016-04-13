function appendData(units,data,varargin)
    %this is a method function of the unitData class and should be found in
    %the @unitData folder.
    %
    %accepts the units field from a cds and appends the data onto
    %the current units structure. appendUnits uses the value in
    %offset to time shift all the spikes of the new data
    %
    %this method skips using set(units,'data',units) calls because
    %that would result in duplicating the whole data field of the
    %units object. Instead units.data.spikes fields are set
    %one at a time, by direct reference

    if nargin>3
        error('appendData:tooManyInputs','appendData accpts up to 3 imputs')
    end

    if ~isempty(varargin)
        offset=varargin{1};
    else
        offset=[];
    end

    %if units is empty, simply fill it
    if isempty(units.data)
        if ~isempty(offset) && offset>0
            %this case is here to make the unit times behave the
            %same way as timeSeriesData times in the case where the
            %user passes an offset. In theory this case should
            %never be used
            warning('appendData:shiftedNewData','applying a time shift to data that is being placed in an empty unitData.data field')
            for i=1:length(data)
                data(i).spikes.t=data(i).spikes.t+offset;
            end
        end

        set(units,'data',data)
    else
        %sanity checks:
        %do we have the same arrays?
        diffArrays=setdiff({units.data.array},{data.array});
        if ~isempty(diffArrays)
            error('appendUnits:differentArrays',['this unitData has the following array(s): ',strjoin(unique({units.data.array}),','), ' while the new units structure has the following array(s): ',strjoin(unique({data.array}),',')])
        end

        %do we have the same unit set?
        diffUnits=setdiff([cell2mat({units.data.chan}),cell2mat({units.data.ID})],[cell2mat({data.chan}),cell2mat({data.ID})]);
        if ~isempty(diffUnits)
            warning('appendUnits:differentUnits',['the new units field has ',num2str(numel(diffUnits)),'different units from the units in this unitData structure'])                
        end
        %is offset larger than the biggest value in the original
        %data?
        f=@(x) max(x.ts);
        maxUnitsTime=max(cellfun(f,{units.data.spikes}));
        if isempty(offset)
            offset=maxUnitsTime+1;
        end
        if maxUnitsTime>offset
            error('appendUnits:inadequateOffset','The offset for timestamps must be larger than the maximum timestamp in the existing data. Suggest using the duration of existing timeseries data like kinematics to estimate an offset.');
        end
        %ok we passed the sanity checks, now update the time of all
        %the spikes by adding offset, and append data to units

        %build tables with the channel, unitID, and array to
        %server as unique keys for the old and new unitdata
        unitsKey=table([units.data.chan]',[units.data.ID]',char({units.data.array}'),'VariableNames',{'chan','ID','array'});
        dataKey=table([data.chan]',[data.ID]',char({data.array}'),'VariableNames',{'chan','ID','array'});
        %now handle the stuff in dataKey that's in unitsKey:
        [inBoth,inBothIdx]=ismember(dataKey,unitsKey);
        %directly assign elements of units.data, rather than
            %using set so we can avoid copying the whole units.data
            %field and wasting a bunch of memory. This is still
            %really slow, but I can't figure out how to correct it
            %given the structure of our units data.
        for i=1:length(inBoth)
            if inBoth(i)
                data(i).spikes.ts=data(i).spikes.ts+offset;
                units.data(inBothIdx(i)).spikes=[ units.data(inBothIdx(i)).spikes ; data(i).spikes ];
            end
        end
        %now handle the stuff that's only in the dataKey
        inDataOnly=find(~inBoth);
        if ~isempty(inDataOnly)
            units.data(end+1:end+1+length(inDataOnly))=data(inDataOnly);
        end
    end
    uInfo.added.numUnits=numel([data.ID]);
    uInfo.added.numChan=numel(unique([data.chan]));
    uInfo.added.hasSorting=~isempty(find([data.ID]>0 & [data.ID]<255,1,'first'));
    uInfo.inUnits.numUnits=numel([units.data.ID]);
    uInfo.inUnits.numChan=numel(unique([units.data.chan]));
    uInfo.inUnits.hasSorting=~isempty(find([units.data.ID]>0 & [units.data.ID]<255,1,'first'));

    evntData=loggingListenerEventData('appendData',uInfo);
    notify(units,'appended',evntData)
end