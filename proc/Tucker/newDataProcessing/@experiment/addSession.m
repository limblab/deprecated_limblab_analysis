function addSession(ex,cdsOrPath)
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
        
    if ~isa(cdsOrPath,'commonDataStructure') && isa(cdsOrPath,'char')
        cdsOrPath=load(cdsOrPath);
    else
        error('addSession:badInput','addSession expected either a cds object or a path to a cds object as input')
    end
    %% meta: 
        m.experimentVersion=0;
        m.includedSessions=[ex.meta.includedSessions,{cdsOrPath.meta.rawFileName}];
        m.mergedate=[ex.meta.mergeDate,{date()}];
        m.knownProblems=[ex.meta.knownProblems,{cdsOrPath.meta.knownProblems}];
        if isempty(ex.meta.fileSepShift)
            m.fileSepShift=1;
        else
            m.fileSepShift=ex.meta.fileSepShift;
        end
        m.duration=0;
        m.dataWindow=[ex.meta.dataWindow(1),ex.meta.dataWindow(2)+m.fileSepShift+cds.meta.dataWindow(2)-cds.meta.dataWindow(1)];
        if isempty(ex.meta.fileSepShift)
            m.task=cds.meta.task;
        elseif strcmp(ex.meta.task,cds.meta.task)
            m.task=ex.meta.task;
        else
            error('addSession:taskMismatch','The existing experiment data and the cds data do not have the same task')
        end
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
        ex.kin.appendTable(cdsOrPath.kin);
    end
    %% force
    if ex.meta.hasForce
        if isempty(cds.force)
            error('addSession:NoForce','cds has no force')
        end
        %load force from cdsOrPath into ex
        ex.force.appendTable(cdsOrPath.force);
    end
    %% emg
    if ex.meta.hasEmg
        if isempty(cds.emg)
            error('addSession:NoEmg','cds has no emg')
        end
        %load emg from cdsOrPath into ex
        ex.emg.appendTable(cdsOrPath.emg);
    end
    %% lfp
    if ex.meta.hasLfp
        if isempty(cds.lfp)
            error('addSession:NoLfp','cds has no lfp')
        end
        %load lfp from cdsOrPath into ex
        ex.lfp.appendTable(cdsOrPath.lfp);
    end
    %% analog
    if ex.meta.hasAnalog
        if isempty(cds.analog)
            error('addSession:NoAnalog','cds has no analog data')
        end
        %load analog from cdsOrPath into ex
        ex.analog.appendData(cdsOrPath.analog);
    end
    %% triggers
    if ex.meta.hasTriggers
        if isempty(cds.triggers)
            error('addSession:NoTriggers','cds has no triggers')
        end
        %load triggers from cdsOrPath into ex
        ex.triggers.appendTable(cdsOrPath.triggers);      
    end
    %% units
    if ex.meta.hasUnits
        if isempty(cds.units)
            error('addSession:NoUnits','cds has no units')
        elseif abs(length(ex.units)-length(cdsOrPath.units))>.1*length(ex.units)
            warning('addSession:DifferentNumberUnits','The cds has a substantially different number of units, suggesting that it has been sorted differently than the sessions previously added to this experiment')
        end
        %load units from cdsOrPath into ex
        ex.units.appendData(cdsOrPath.units);
    end
    %% trials
    if ex.meta.hasTrials
        if isempty(cds.trials)
            error('addSession:NoTrials','cds has no trials')
        end
        %load trials from cdsOrPath into ex
        ex.trials.appendTable(cdsOrPath.kin);
    end
    
    ex.addOperation(mfilename,'fullpath')
    
end