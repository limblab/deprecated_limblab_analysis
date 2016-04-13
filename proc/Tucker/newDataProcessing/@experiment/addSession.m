function addSession(ex,cds)
    %loadSessions is a method of the experiment class, and should be found
    %in the @experiment folder with the main class definition
    %
    %addSession takes adds data from a session indicated in cdsOrPath and
    %loads it into the fields of the experiment. addSession checks whether
    %cdsOrPath is a cds structure or a path, if it is a path, then
    %addSession will load the cds from the specified path, and then add the
    %data to the experiment. If cdsOrPath is a cell array of strings, then
    %addSession will loop through each cell loading the cds from the path
    %in the cell-string and then addign the data to the experiment
    %
    %ddSession will check the ex.meta.has* fields
    %to see what data to load. For example if ex.meta.hasKin==1 and
    %ex.meta.hasEmg==0; then addSession will load kinematics and ignore any
    %emg data in the cds.
        
    if ~isa(cds,'commonDataStructure') 
        if isa(cds,'char')
            cds=load(cds);
        else
            error('addSession:badInput','addSession expected either a cds object or a path to a cds object as input')
        end
    end
    %% meta: 
        m.experimentVersion=ex.meta.experimentVersion;
        m.includedSessions=[ex.meta.includedSessions,{cds.meta.rawFileName}];
        m.mergeDate=[ex.meta.mergeDate,{date()}];
        m.processedWith=ex.meta.processedWith;%this call will be added using callbacks from the events
        m.knownProblems=[ex.meta.knownProblems,{cds.meta.knownProblems}];
        if isempty(ex.meta.fileSepShift)
            m.fileSepShift=1;
        else
            m.fileSepShift=ex.meta.fileSepShift;
        end
        timeShift=ex.meta.duration+ex.meta.fileSepShift-cds.meta.dataWindow(1);
        m.fileSepTime=[ex.meta.fileSepTime;cds.meta.fileSepTime+timeShift];
        m.duration=cds.meta.dataWindow(2)+timeShift;
        if ex.meta.dataWindow(2)==0
            m.dataWindow=cds.meta.dataWindow;
        else
            m.dataWindow=[ex.meta.dataWindow(1),cds.meta.dataWindow(2)+timeShift];
        end
        if strcmp(ex.meta.task,'NoDataLoaded')
            m.task=cds.meta.task;
        elseif strcmp(ex.meta.task,cds.meta.task)
            m.task=ex.meta.task;
        else
            error('addSession:taskMismatch','The existing experiment data and the cds data do not have the same task')
        end
        
        m.hasEmg=ex.meta.hasEmg;
        m.hasLfp=ex.meta.hasLfp;
        m.hasKinematics=ex.meta.hasKinematics;
        m.hasForce=ex.meta.hasForce;
        m.hasAnalog=ex.meta.hasAnalog;
        m.hasUnits=ex.meta.hasUnits;
        m.hasTriggers=ex.meta.hasTriggers;
        m.hasChaoticLoad=ex.meta.hasChaoticLoad;
        m.hasBumps=ex.meta.hasBumps;
        m.hasTrials=ex.meta.hasTrials;
        
        m.numTrials=ex.meta.numTrials+cds.meta.numTrials;
        m.numReward=ex.meta.numReward+cds.meta.numReward;
        m.numAbort=ex.meta.numAbort+cds.meta.numAbort;
        m.numFail=ex.meta.numFail+cds.meta.numFail;
        m.numIncomplete=ex.meta.numIncomplete+cds.meta.numIncomplete;
        set(ex,'meta',m)

    %% kin
    if ex.meta.hasKinematics
        if isempty(cds.kin)
            error('addSession:NoKinematics','cds has no kinematics')
        end
        %load kinematics from cdsOrPath into ex
        ex.kin.appendTable(cds.kin);
    end
    %% force
    if ex.meta.hasForce
        if isempty(cds.force)
            error('addSession:NoForce','cds has no force')
        end
        %load force from cdsOrPath into ex
        ex.force.appendTable(cds.force);
    end
    %% emg
    if ex.meta.hasEmg
        if isempty(cds.emg)
            error('addSession:NoEmg','cds has no emg')
        end
        %load emg from cdsOrPath into ex
        ex.emg.appendTable(cds.emg);
    end
    %% lfp
    if ex.meta.hasLfp
        if isempty(cds.lfp)
            error('addSession:NoLfp','cds has no lfp')
        end
        %load lfp from cdsOrPath into ex
        ex.lfp.appendTable(cds.lfp);
    end
    %% analog
    if ex.meta.hasAnalog
        if isempty(cds.analog)
            error('addSession:NoAnalog','cds has no analog data')
        end
        %load analog from cdsOrPath into ex
        if isempty(ex.analog)
            for i=1:length(cds.analog)
                ex.analog{i}=timeSeriesData();
                addlistener(ex.analog{i},'refiltered',@(src,evnt)ex.dataLoggingCallback(src,evnt));
                addlistener(ex.analog{i},'appended',@(src,evnt)ex.dataLoggingCallback(src,evnt));
                cds.analog{i};
            end
        elseif length(ex.analog)==length(cds.analog)
            for i=1:length(cds.analog)
                %find the sampling frequency of the i'th table of analog in
                %the cds:
                cdsFreq=mode(diff(cds.analog{i}.t));
                %now find the matchting field in ex.analog and append the
                %analog table:
                for j=1:length(ex.analog)
                    exFreq=mode(diff(ex.analog{j}.data));
                    if cdsFreq==exFreq
                        ex.analog{j}.appendData(cds.analog{i});
                        break
                    end
                end
            end
        else
            error('addSession:analogMismatch','The cds does not have the same number of analog fields as the data currently in the experiment')
        end
        for i=1:length(cds.analog)
            ex.analog{i}=timeSeriesData(cds.analog{i});
        end
    end
    %% triggers
    if ex.meta.hasTriggers
        if isempty(cds.triggers)
            error('addSession:NoTriggers','cds has no triggers')
        end
        %load triggers from cdsOrPath into ex
        ex.triggers.appendTable(cds.triggers);      
    end
    %% units
    if ex.meta.hasUnits
        if isempty(cds.units)
            error('addSession:NoUnits','cds has no units')
        elseif ~isempty(ex.units.data) && abs(length(ex.units.data)-length(cds.units))>.1*length(ex.units.data)
            warning('addSession:DifferentNumberUnits','The cds has a substantially different number of units, suggesting that it has been sorted differently than the sessions previously added to this experiment')
        end
        %load units from cdsOrPath into ex
        ex.units.appendData(cds.units);
    end
    %% trials
    if ex.meta.numTrials>0
        if isempty(cds.trials)
            error('addSession:NoTrials','cds has no trials')
        end
        %load trials from cds into ex
        ex.trials.appendTable(cds.trials);
    end
    %% set up logging info and notify event so the listner for the addedSession event can log this operation:
    opData.cdsInfo=cds.meta;
    opData.exInfo.hasEmg=ex.meta.hasEmg;
    opData.exInfo.hasLfp=ex.meta.hasLfp;
    opData.exInfo.hasKinematics=ex.meta.hasKinematics;
    opData.exInfo.hasForce=ex.meta.hasForce;
    opData.exInfo.hasAnalog=ex.meta.hasAnalog;
    opData.exInfo.hasUnits=ex.meta.hasUnits;
    opData.exInfo.hasTriggers=ex.meta.hasTriggers;
    opData.exInfo.hasChaoticLoad=ex.meta.hasChaoticLoad;
    opData.exInfo.hasBumps=ex.meta.hasBumps;
    opData.exInfo.hasTrials=ex.meta.hasTrials;
    evntData=loggingListenerEventData('addSession',opData);
    notify(ex,'ranOperation',evntData)
end