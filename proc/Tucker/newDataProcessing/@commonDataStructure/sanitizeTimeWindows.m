function sanitizeTimeWindows(cds)
    %this is a method function for the common_data_structure (cds) class, and
    %should be located in a folder '@common_data_structure' with the class
    %definition file and other method files
    %
    %cds.sanitizeTimeWindows() will run through all the fields in the cds
    %and ensure that data exists within a single specified window
    
    %% scan through all continuous data fields and get min and max data times:
    timeVec=[];
    if ~isempty(cds.FR)
        timeVec=[timeVec;min(cds.FR.t),max(cds.FR.t),mode(diff(cds.FR.t))];
    end
    if ~isempty(cds.pos)
        timeVec=[timeVec;min(cds.pos.t),max(cds.pos.t),mode(diff(cds.pos.t))];
    end
    if ~isempty(cds.vel)
        timeVec=[timeVec;min(cds.vel.t),max(cds.vel.t),mode(diff(cds.vel.t))];
    end
    if ~isempty(cds.acc)
        timeVec=[timeVec;min(cds.acc.t),max(cds.acc.t),mode(diff(cds.acc.t))];
    end
    if ~isempty(cds.force)
        timeVec=[timeVec;min(cds.force.t),max(cds.force.t),mode(diff(cds.force.t))];
    end
    if ~isempty(cds.EMG)
        timeVec=[timeVec;min(cds.FR.t),max(cds.FR.t),mode(diff(cds.FR.t))];
    end
    if ~isempty(cds.LFP)
        timeVec=[timeVec;min(cds.FR.t),max(cds.FR.t),mode(diff(cds.FR.t))];
    end
    if ~isempty(cds.dataFlags)
        timeVec=[timeVec;min(cds.dataFlags.t),max(cds.dataFlags.t),mode(diff(cds.dataFlags.t))];
    end
    if ~isempty(cds.enc)
        timeVec=[timeVec;min(cds.enc.t),max(cds.enc.t),mode(diff(cds.enc.t))];
    end
    if ~isempty(cds.triggers)
        timeVec=[timeVec;min(cds.triggers.t),max(cds.triggers.t),mode(diff(cds.triggers.t))];
    end
    if ~isempty(cds.analog)

    end
    %% get window where data exists in all continuous fields
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
    window=max(timeVec(:,1),min(timeVec(:,2)));
    meta=cds.meta;
    meta.dataWindow=window;
    set(cds,'meta',meta)
    %% run through all fields and make sure the data only exists between the window:
    if ~isempty(cds.FR)
        set(cds,'FR',cds.FR(cds.FR.t>window(1) & cds.FR.t<window(2),:))
    end
    if ~isempty(cds.pos)
        set(cds,'pos',cds.pos(cds.pos.t>window(1) & cds.pos.t<window(2),:))
    end
    if ~isempty(cds.vel)
        set(cds,'vel',cds.vel(cds.vel.t>window(1) & cds.vel.t<window(2),:))
    end
    if ~isempty(cds.acc)
        set(cds,'acc',cds.acc(cds.acc.t>window(1) & cds.acc.t<window(2),:))
    end
    if ~isempty(cds.force)
        set(cds,'force',cds.force(cds.force.t>window(1) & cds.force.t<window(2),:))
    end
    if ~isempty(cds.EMG)
        set(cds,'EMG',cds.EMG(cds.EMG.t>window(1) & cds.EMG.t<window(2),:))
    end
    if ~isempty(cds.LFP)
        set(cds,'LFP',cds.LFP(cds.LFP.t>window(1) & cds.LFP.t<window(2),:))
    end
    if ~isempty(cds.dataFlags)
        set(cds,'dataFlags',cds.dataFlags(cds.dataFlags.t>window(1) & cds.dataFlags.t<window(2),:))
    end
    if ~isempty(cds.enc)
        set(cds,'enc',cds.enc(cds.enc.t>window(1) & cds.enc.t<window(2),:))
    end
    if ~isempty(cds.triggers)
        set(cds,'triggers',cds.triggers(cds.triggers.t>window(1) & cds.triggers.t<window(2),:))
    end
    if ~isempty(cds.analog)
    end
    if ~isempty(cds.trials)
        set(cds,'trials',cds.trials(cds.trials.startTime>window(1) & cds.trials.endTime<window(2),:))
    end
    if ~isempty(cds.words)
        set(cds,'words',cds.words(cds.words.ts>window(1) & cds.words.ts<window(2),:))
    end
    if ~isempty(cds.databursts)
        set(cds,'databursts',cds.databursts(cds.databursts.ts>window(1) & cds.databursts.ts<window(2),:))
    end
end