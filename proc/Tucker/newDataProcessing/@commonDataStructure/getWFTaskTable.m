function getWFTaskTable(cds,times)
    %this is a method function for the common_data_structure (cds) class, and
    %should be located in a folder '@common_data_structure' with the class
    %definition file and other method files
    %
    %cds.getWFTaskTable(times)
    %getWFTaskTable returns no value, instead it populates the trials field
    %of the cds assuming the task is a wrist flexion task. Takes a single
    %input:times, which is a table with 4 columns: number, startTime,
    %endTime, and result. These times define the start and stop of trials
    %as indicated by the state words for trial start and trial end. the
    %result code will be a character 'R':reward 'A':abort 'F':fail
    %'I':incomplete.

    if ~strcmp(cds.meta.task,'WF')
        warning('getWFTaskTable:NotWFTask','The task in the cds is not set to WF. The task table code will fail to run if this is not actually a WF data set. ' )
    end

    % Isolate the individual word timestamps
    wordOTOn = hex2dec('40'); 
    OTOnWords = cds.words.ts( bitand(hex2dec('f0'),cds.words.word) == wordOTOn);
    OTOnCodes = cds.words.word( bitand(hex2dec('f0'),cds.words.word) == wordOTOn);
    wordGo = hex2dec('31');
    goCues = cds.words.ts(cds.words.word == wordGo);
    wordCatch = hex2dec('32');
    catchWords= cds.words.ts(cds.words.word==wordCatch);
    wordAdapt = hex2dec('B0');
    adaptWords= cds.words.ts(cds.words.word==wordAdapt);

    burst_size = size(cds.databursts.db,2);
    numTrials=numel(times.number);
    
    targetCorners=nan(numTrials,4);
    targetCenters=nan(numTrials,2);
    OTTimeList=nan(numTrials,1);
    OTDirList=nan(numTrials,1);
    goTime=nan(numTrials,1);
    targetID=nan(numTrials,1);
    catchFlag=nan(numTrials,1);
    adaptFlag=nan(numTrials,1);
    
    for trial = 1:numTrials

        % Outer target
        idxOT = find(OTOnWords > times.startTime(trial) & OTOnWords < times.endTime(trial), 1, 'first');
        if isempty(idxOT)
            OTTime = nan;
            OTDir = nan;
        else
            OTTime = OTOnWords(idxOT);
            OTDir = bitand(hex2dec('0f'), OTOnCodes(idxOT));
        end

        dbidx = find(cds.databursts.ts > times.startTime(trial) & cds.databursts.ts<times.endTime(trial), 1, 'first');
        
        % Target location
        targetLoc = cds.databursts.db(dbidx,2)(burst_size-15:end);
        targetLoc = bytes2float(targetLoc, 'little')';
        
        % catch
        idxCatch = find(catchWords > times.startTime(trial) & catchWords < times.endTime(trial), 1, 'first');
        if isempty(idxCatch)
            isCatch = 0;
        else
            isCatch = 1;
        end   
        
        % Go cue ts
        idxGo = find(goCues > times.startTime(trial) & goCues < times.endTime(trial), 1, 'first');
        if isempty(idxGo)
            if isempty(idxCatch)
                goCue = nan;
            else
                goCue = catchWords(idxCatch);
            end
        else
            goCue = goCues(idxGo);
        end

       % Adapt
        idxAdapt = find(adaptWords > times.startTime(trial) & adaptWords < times.endTime(trial), 1, 'first');
        if isempty(idxAdapt)
            isAdapt = 0;
        else
            isAdapt = 1;
        end       

        % Build arrays
            targetCorners(trial,:)=targetLoc;    % Coordinates of outer target corners
            targetCenters(trial,:)=[targetLoc(1)+targetLoc(3),targetLoc(2)+targetLoc(4)]/2;%center coordinates of outer target 
            OTTimeList(trial)=OTTime;     % Timestamp of OT On event
            OTDirList(trial)=OTDir;     % Timestamp of OT On event
            goTime(trial)=goCue;      % Timestamp of Go Cue
            targetID(trial)=target;   % Target ID based on location
            catchFlag(trial)=isCatch;  % whether or not trial is a catch trial
            adaptFlag(trial)=isAdapt;  % whether or not trial is an adaptation trial
    end

    %build table:
    trialsTable=table(OTTimeList,goTime,targetID,targetCorners,targetCenters,OTDirList,catchFlag,adaptFlag,...
                    'VariableNames',{'tgtOn','goCue','tgtID','tgtCorners','tgtCtr','tgtDir','catch','adapt'});
    
    trialsTable.Properties.VariableUnits={'s','s','int','cm','cm','deg','bool','bool'};
    trialsTable.Properties.VariableDescriptions={'outer target onset time','go cue time','ID number of outer target','x-y pairs for upper left and lower right target corners','flag indicating if the trial was a catch trial','flag indicating if the trial was an adaptation trial'};
    trialsTable=[times,trialsTable];
    trialsTable.Properties.Description='Trial table for the WF task';
    
    %cds.setField('trials',trialsTable)
    set(cds,'trials',trialsTable)
    cds.addOperation(mfilename('fullpath'))
end