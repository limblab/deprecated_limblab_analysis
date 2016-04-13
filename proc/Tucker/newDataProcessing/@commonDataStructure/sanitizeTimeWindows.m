function sanitizeTimeWindows(cds)
    %this is a method function for the common_data_structure (cds) class, and
    %should be located in a folder '@common_data_structure' with the class
    %definition file and other method files
    %
    %cds.sanitizeTimeWindows() will run through all the fields in the cds
    %and ensure that data exists within a single specified window
    
    %% scan through all continuous data fields and get min and max data times:
    timeVec=[];
    if ~isempty(cds.kin)
        timeVec=[timeVec;min(cds.kin.t),max(cds.kin.t),mode(diff(cds.kin.t))];
    end
    if ~isempty(cds.force)
        timeVec=[timeVec;min(cds.force.t),max(cds.force.t),mode(diff(cds.force.t))];
    end
    if ~isempty(cds.emg)
        timeVec=[timeVec;min(cds.emg.t),max(cds.emg.t),mode(diff(cds.emg.t))];
    end
    if ~isempty(cds.lfp)
        timeVec=[timeVec;min(cds.lfp.t),max(cds.lfp.t),mode(diff(cds.lfp.t))];
    end
    if ~isempty(cds.triggers)
        timeVec=[timeVec;min(cds.triggers.t),max(cds.triggers.t),mode(diff(cds.triggers.t))];
    end
    if ~isempty(cds.analog)
        for i=1:length(cds.analog)
            timeVec=[timeVec;min(cds.analog{i}.t),max(cds.analog{i}.t),mode(diff(cds.analog{i}.t))];
        end
    end
    %% get window where data exists in all continuous fields
    %round each time series to its sig figs
    for i=1:size(timeVec,1)
        %find sig figs of the timestep:
        n=0;
        while round(timeVec(i,3)*10^n)<1;
            n=n+1;
        end
        %use ceil and floor to get accurate window:
        timeVec(i,1)=ceil(timeVec(i,1)*10^n)/10^n;
        timeVec(i,2)=floor(timeVec(i,2)*10^n)/10^n;
    end
    %get the maximum window where all data series are present
    window=[max(timeVec(:,1)),min(timeVec(:,2))];
    meta=cds.meta;
    meta.dataWindow=window;
    set(cds,'meta',meta)
    %% run through all fields and make sure the data only exists between the window:
    if ~isempty(cds.kin)
        set(cds,'kin',cds.kin(cds.kin.t>window(1) & cds.kin.t<window(2),:))
    end
    if ~isempty(cds.force)
        set(cds,'force',cds.force(cds.force.t>window(1) & cds.force.t<window(2),:))
    end
    if ~isempty(cds.emg)
        set(cds,'emg',cds.emg(cds.emg.t>window(1) & cds.emg.t<window(2),:))
    end
    if ~isempty(cds.lfp)
        set(cds,'lfp',cds.lfp(cds.lfp.t>window(1) & cds.lfp.t<window(2),:))
    end
    if ~isempty(cds.triggers)
        set(cds,'triggers',cds.triggers(cds.triggers.t>window(1) & cds.triggers.t<window(2),:))
    end
    if ~isempty(cds.analog)
        for i=1:length(cds.analog)
            analog{i}=cds.analog{i}(cds.analog{i}.t>window(1) & cds.analog{i}.t<window(2),:);
        end
        set(cds,'analog',analog)
    end
    if ~isempty(cds.trials)
        set(cds,'trials',cds.trials(cds.trials.startTime>window(1) & cds.trials.endTime<window(2),:))
    end
    if ~isempty(cds.units)
        %loop through units trimming off all timestamps not in the window
        units=cds.units;
        for i=1:length(cds.units)
            units(i).spikes=units(i).spikes(units(i).spikes.ts>=window(1) &units(i).spikes.ts<=window(2),:);
        end
        set(cds,'units',units)
    end
    evntData=loggingListenerEventData('sanitizeTimeWindows',opData);
    notify(ex,'ranOperation',evntData)
end