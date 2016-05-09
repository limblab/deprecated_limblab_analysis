function metaFromNEVNSx(cds,opts)
    %this is a method function for the common_data_structure (cds) class, and
    %should be located in a folder '@common_data_structure' with the class
    %definition file and other method files
    %
    %metaFromNEVNSx populates the cds.meta field using data pulled from the
    %NEVNSx object. If this is the first data loaded into the cds, then the
    %cds.meta fields will be populated de-novo. otherwise, some fields will
    %be made into arrays to contain the initial data, and the data from the
    %new NEVNSx
    

    % source info
    meta.cdsVersion=cds.meta.cdsVersion;
    meta.rawFileName=cds.NEV.MetaTags.Filename;
    meta.dataSource='NEVNSx';
    meta.array=opts.array;

    meta.knownProblems=cds.meta.knownProblems;

    %timing
    meta.dateTime=opts.dateTime;
    meta.duration=cds.NEV.MetaTags.DataDurationSec;

    meta.task=opts.task;
    meta.lab=opts.labNum;
    meta.monkey=opts.monkey;
    
    %data info:
    meta.hasEmg=~isempty(cds.emg);
    meta.hasLfp=~isempty(cds.lfp);
    meta.hasKinematics=~isempty(cds.kin);
    meta.hasForce=~isempty(cds.force);
    meta.hasAnalog=~isempty(cds.analog);
    meta.hasUnits=~isempty(cds.units);
    meta.hasTriggers=~isempty(cds.triggers);
    meta.hasBumps=~isempty(find(strcmp('bumpTime',cds.trials.Properties.VariableNames),1));
    meta.hasChaoticLoad=logical(opts.hasChaoticLoad);
    
    sortedMask=[cds.units.ID]>0 & [cds.units.ID]<255;
    meta.numSorted=sum(sortedMask);
    meta.hasSorting=meta.numSorted>0;
    wellSortedMask=[cds.units.wellSorted];
    meta.numWellSorted=sum(wellSortedMask);
    meta.numDualUnits=0;
    chanList=unique([cds.units.chan]);
    for i=1:numel(chanList)
        if find([cds.units.chan]==chanList(i) & sortedMask) %%add well sorted check later...
            meta.numDualUnits=meta.numDualUnits+1;
        end
    end
    
    meta.percentStill=sum(cds.kin.still)/size(cds.kin.still,1);
    meta.stillTime=meta.percentStill*meta.duration;
    meta.dataWindow=[0 meta.duration];
    %find the real data Window:
    if meta.hasEmg
        meta.dataWindow=[max(meta.dataWindow(1),cds.emg.t(1)),min(meta.dataWindow(2),cds.emg.t(end))];
    end
    if meta.hasLfp
        meta.dataWindow=[max(meta.dataWindow(1),cds.lfp.t(1)),min(meta.dataWindow(2),cds.lfp.t(end))];
    end
    if meta.hasKinematics
        meta.dataWindow=[max(meta.dataWindow(1),cds.kin.t(1)),min(meta.dataWindow(2),cds.kin.t(end))];
    end
    if meta.hasForce
        meta.dataWindow=[max(meta.dataWindow(1),cds.force.t(1)),min(meta.dataWindow(2),cds.force.t(end))];
    end
    if meta.hasAnalog
        for j=1:length(cds.analog)
            meta.dataWindow=[max(meta.dataWindow(1),cds.analog{j}.t(1)),min(meta.dataWindow(2),cds.analog{j}.t(end))];
        end
    end
    
    meta.numTrials=size(cds.trials,1);
    meta.numReward=numel(strmatch('R',cds.trials.result));
    meta.numAbort=numel(strmatch('A',cds.trials.result));
    meta.numFail=numel(strmatch('F',cds.trials.result));
    meta.numIncomplete=numel(strmatch('I',cds.trials.result));
    
    meta.aliasList=cds.aliasList;

    %put new meta structure into cds.meta
    set(cds,'meta',meta)
    %log the update to cds.meta
    evntData=loggingListenerEventData('metaFromNEVNSx',[]);
    notify(cds,'ranOperation',evntData)
end