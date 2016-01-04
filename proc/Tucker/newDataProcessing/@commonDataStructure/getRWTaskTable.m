function getRWTaskTable(cds,times)
    %this is a method function for the common_data_structure (cds) class, and
    %should be located in a folder '@common_data_structure' with the class
    %definition file and other method files
    %
    %cds.getRWTaskTable(times)
    %getWFTaskTable returns no value, instead it populates the trials field
    %of the cds assuming the task is a wrist flexion task. Takes a single
    %input:times, which is a table with 4 columns: number, startTime,
    %endTime, and result. These times define the start and stop of trials
    %as indicated by the state words for trial start and trial end. the
    %result code will be a character 'R':reward 'A':abort 'F':fail
    %'I':incomplete.
    
    corruptDB=0;
    numTrials = length(times.number);
    wordGo = hex2dec('30');
    goCues =  cds.words.ts(bitand(hex2dec('f0'), cds.words.word) == wordGo);
    goCodes=  cds.words.word(bitand(hex2dec('f0'), cds.words.word) == wordGo)-wordGo;

    %check DB version number and run appropriate parsing code. DB version 0
    %only has 2 words before target positions, while version 1 has 18.
    db_version=cds.databursts.db(1,2);

    if db_version==0
        %check whether we can trust the databurst target information and
        %then either estimate the number of targets from the databurst, or
        %from the go cues:
        if datenum(cds.meta.datetime) < datenum('3/9/2009') 
            numTgt = (cds.databursts.db(1,1)-18)/8;
        else
            warning('rw_trial_table_hdr:MalformedDatabursts',...
                ['Databursts from data files collected around when this '...
                'one was can have malformed databursts. instead of using'...
                'the databurst to find the number of targets, rw_trial_table_hdr '...
                'will use the median number of go cues seen between trial '...
                'start and trial end.'])
            cds.addProblem('Databursts may be malformed, and target information missing. Number of targets reconstructed as mode of #go cues in each trial')
            attempted=-1*ones(numTrials,1);
            for trial=1:numTrials;
                attempted(trial) = numel(find(goCues > times.startTime(trial) & goCues < times.endTime(trial)));
            end
            numTgt=mode(attempted);
        end
        %now that we have the expected number of targets, get the trial
        %data
        goCueList=-1*ones(numTrials,numTgt);
        goCodeList=-1*ones(numTrials,numTgt);
        numTgts=numTgt*ones(numTrials,1);
        numAttempted=-1*ones(numTrials,1);
        for trial = 1:numTrials-1
            % Go cues
            idxGo = find(goCues > times.startTime(trial) & goCues < times.endTime(trial));

            %get the codes and times for the go cues
            goCue = -1*ones(1,numTgt);
            goCode= -1*ones(1,numTgt);
            if isempty(idxGo)
                tgtsAttempted = 0;
            else
                tgtsAttempted = length(idxGo);
                goCue(1:tgtsAttempted) = goCues(idxGo);
                goCode(1:tgtsAttempted)= goCodes(idxGo);
            end

            %identify trials with corrupt end codes that might end up with extra
            %targets
            if length(idxGo) > numTgt
                warning('rw_trial_table: Inconsistent number of targets @ t = %.3f, skipping trial:%d',start_time,trial);
                corruptDB=1;
                continue;
            end

            % Build arrays
            goCueList(trial,:)=        goCue;         % time stamps of go_cue(s)
            goCodeList(trial,:)=       goCode;        % ?
            numTgts(trial,:)=       numTgt;          % max number of targets
            numAttempted(trial,:)=  tgtsAttempted; % ?
        end
        trials=table(goCueList,goCodeList,numTgts,numAttempted,...
                    'VariableNames',{'goCue','tgtID','numTgt','numAttempted'});
        trials.Properties.VariableUnits={'s','int','int','int'};
        trials.Properties.VariableDescriptions={'go cue time','code of the go cue','number of targets','number of targets attempted'};

    elseif db_version==1 || db_version==2
        hdr_size=18;
        numTgt = (cds.databursts.db(1)-18)/8;

        goCueList=      -1*ones(numTrials,numTgt);
        goCodeList=     -1*ones(numTrials,numTgt);
        numTgts=        numTgt*ones(numTrials,1);
        numAttempted=   -1*ones(numTrials,1);
        xOffsets=       -1*ones(numTrials,1); 
        yOffsets=       -1*ones(numTrials,1);
        tgtSizes=       -1*ones(numTrials,1);
        for trial = 1:numel(times.startTime)
            if (cds.databursts.db(trial,1)-18)/8 ~= numTgt
                %catch weird/corrupt databursts with different numbers of targets
                warning('rw_trial_table: Inconsistent number of targets @ t = %.3f, skipping trial',start_time);
                corruptDB=1;
                continue;
            end

            % Go cues
            idxGo = find(goCues > times.startTime(trial) & goCues < times.endTime(trial));

            %get the codes and times for the go cues
            goCue = -1*ones(1,numTgt);
            goCode= -1*ones(1,numTgt);
            if isempty(idxGo)
                tgtsAttempted = 0;
            else
                tgtsAttempted = length(idxGo);
                goCue(1:tgtsAttempted) = goCues(idxGo);
                goCode(1:tgtsAttempted)= goCodes(idxGo);
            end

            %identify trials with corrupt end codes that might end up with extra
            %targets
            if length(idxGo) > numTgt
                warning('rw_trial_table: Inconsistent number of targets @ t = %.3f, skipping trial:%d',start_time,trial);
                corruptDB=1;
                continue;
            end
            %find target centers
            ctr=bytes2float(cds.databursts.db(trial,hdr_size+1:end));
            % Offsets, target size
            xOffset = bytes2float(cds.databursts.db(trial,7:10));
            yOffset = bytes2float(cds.databursts.db(trial,11:14));
            tgtSize = bytes2float(cds.databursts.db(trial,15:18));

            % Build arrays
            goCueList(trial,:)=         goCue;              % time stamps of go_cue(s)
            goCodeList(trial,:)=        goCode;             % ?
            numTgts(trial)=             numTgt;             % max number of targets
            numAttempted(trial,:)=      tgtsAttempted;      % ?
            xOffsets(trial)=            xOffset;            % x offset
            yOffsets(trial)=            yOffset;            % y offset
            tgtSizes(trial)=            tgtSize;            % target size - tolerance
            tgtCtrs(trial,:)=           ctr;                %center positions of the targets
        end

        trials=table(goCueList,goCodeList,numTgts,numAttempted,xOffsets,yOffsets,tgtSizes,tgtCtrs,...
                    'VariableNames',{'goCue','tgtID','numTgt','numAttempted','xOffset','yOffset','tgtSize','tgtCtr'});
        trials.Properties.VariableUnits={'s','int','int','int','cm','cm','cm','cm'};
        trials.Properties.VariableDescriptions={'go cue time','code of the go cue','number of targets','number of targets attempted','x offset','y offset','target size','target center position'};

    else
        error('rw_trial_table_hdr:BadDataburstVersion',['Trial table parsing not implemented for databursts with version: ', num2str(db_version)])
    end
    if corruptDB==1
        cds.addProblem('There are corrupt databursts with more targets than expected. These have been skipped, but this frequently relates to errors in trial table parsting with the RW task')
    end
    trials=[times,trials];
    trials.Properties.Description='Trial table for the RW task';
    %cds.setField('trials',trials)
    set(cds,'trials',trials)
    cds.addOperation(mfilename('fullpath'))
end