function getCOTaskTable(cds,times)
    %this is a method function for the common_data_structure (cds) class, and
    %should be located in a folder '@common_data_structure' with the class
    %definition file and other method files
    %
    %computes the trial variables for the CO task and composes the trial
    %table in the cds using the task variables and the generic trial times
    %passed in from the calling function. This is intended to be called by 
    %the getTrialTable method of the cds class, rather than directly by a
    %user
    
    %get our word timing for changes in the state machine:
    % Isolate the individual word timestamps
    bumpWordBase = hex2dec('50');
    bumpTimes = cds.words.ts(cds.words.word >= (bumpWordBase) & cds.words.word <= (bumpWordBase+5))';
    bumpCodes = cds.words.word(cds.words.word >= (bumpWordBase) & cds.words.word <= (bumpWordBase+5))';

    word_ot_on = hex2dec('40');
    otOnTimes = cds.words.ts( bitand(hex2dec('f0'),cds.words.word) == word_ot_on, 1);
    otOnCodes = cds.words.word( bitand(hex2dec('f0'),cds.words.word) == word_ot_on, 2);
    
    wordGo = hex2dec('31');
    goCues = cds.words.ts(cds.words.word == wordGo, 1);
    
    %preallocate our trial variables:
    numTrials=numel(times.number);
    tgtOnTimeList=-1*ones(numTrials,1);
    tgtList=-1*ones(numTrials,1);
    bumpTimeList=-1*ones(numTrials,1);
    bumpList=-1*ones(numTrials,1);
    bumpPhaseList=-1*ones(numTrials,1);
    bumpDirList=-1*ones(numTrials,1);
    goCueList=-1*ones(numTrials,1);
    tgtCornerList=-1*ones(numTrials,4);
    tgtCtrList=-1*ones(numTrials,2);
    % loop thorugh our trials and build our list vectors:
    for trial = 1:numTrials
        %find the current databurst:
        idxDB = find(cds.databursts.ts > times.startTime(trial) & cds.databursts.ts<times.endTime(trial), 1, 'first');
        if cds.databursts.db(idxDB,2)~=1
            error('getCOTaskTable:badDataburstVersion',['getCOTaskTable is not coded to handle databursts of version: ',num2str(cds.databursts.db(idxDB,2))])
        end
        
        % Outer target
        idxOT = find(otOnTimes > start_time & otOnTimes < stop_time, 1, 'first');
        if isempty(idxOT)
            tgtOnTimeList(trial) = nan;
            tgtList(trial) = nan;
            tgtCornerList(trial,:)=[nan nan nan nan];
        else
            tgtOnTimeList(trial) = otOnTimes(idxOT);
            tgtList(trial) = bitand(hex2dec('0f'), otOnCodes(idxOT));
            tgtCornerList(trial,:)=bytes2float(cds.databursts.db(idxDB,15:end))';
        end
        
        % Bump code and time
        idxBump = find(bumpTimes > start_time & bumpTimes < stop_time, 1, 'first');
        if isempty(idxBump)
            bumpTimeList(trial) = -1;
            bumpList(trial) = -1;
        else
            bumpTimeList(trial) = bumpTimes(idxBump);
            bumpList(trial) = bitand(hex2dec('0f'),bumpCodes(idxBump));
        end
        
        % Go cue
        idxGo = find(goCues > start_time & goCues < stop_time, 1, 'first');
        if isempty(idxGo)
            goCueList(trial) = -1;
        else
            goCueList(trial) = goCues(idxGo);
        end

        % Classify bump phasing
        if bumpTimeList(trial) == -1
            bumpPhaseList(trial) = 'none';
        elseif tgtOnTimeList(trial) == -1
            bumpPhaseList(trial) = 'Hold';
        elseif bumpTimeList(trial) > goCueList(trial) + .002
            bumpPhaseList(trial) = 'Move';
        else
            bumpPhaseList(trial) = 'Delay';
        end
    end
    
    %convert target lists into angle:
    tgtCtrList=[tgtCornerList(:,1)+tgtCornerList(:,3),tgtCornerList(:,2)+tgtCornerList(:,4)]/2;
    tgtDirList=atan2(tgtCtrList(2)./tgtCtrList(1));
    %use target info to get angles for bumps based on the 
    bumps=unique(bumpList);
    for b=1:length(bumps)
        bumpDirList(bumpList==bumps(b))=mode(tgtDirList(tgtList==bumps(b)));
    end
    
    %build table:
    trialsTable=table(tgtOnTimeList,goCueList,tgtList,tgtCornerList,tgtDirList,tgtCtrList,bumpTimeList,bumpList,bumpPhaseList,bumpDirList,...
                    'VariableNames',{'tgtOnTime','goCue','tgtID','tgtCorners','tgtDir','tgtCtr','bumpTime','bumpID','bumpPhase','bumpDir'});
    
    trialsTable.Properties.VariableUnits={'s','s','int','cm, cm, cm, cm','rad','cm, cm','s','int','char','deg'};
    trialsTable.Properties.VariableDescriptions={'outer target onset time','go cue time','ID number of outer target',...
                                                    'x-y pairs for upper left and lower right target corners',...
                                                    'direction of target from center of workspace',...
                                                    'x-y pair for center location of target',...
                                                    'time of bump onset','ID number of bump',...
                                                    'what phase of the trial the bump occurs in, e.g. center hold',...
                                                    'direction of the bump'};
    trialsTable=[times,trialsTable];
    trialsTable.Properties.Description='Trial table for the CO task';
    
    %cds.setField('trials',trialsTable)
    set(cds,'trials',trialsTable)
    cds.addOperation(mfilename('fullpath'))
end