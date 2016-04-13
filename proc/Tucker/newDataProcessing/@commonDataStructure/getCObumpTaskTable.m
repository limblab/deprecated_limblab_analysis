function getCObumpTaskTable(cds,times)
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

    wordOTOn = hex2dec('40');
    otOnTimes = cds.words.ts( bitand(hex2dec('f0'),cds.words.word) == wordOTOn);
    otOnCodes = cds.words.word( bitand(hex2dec('f0'),cds.words.word) == wordOTOn);
    
    wordGo = hex2dec('31');
    goCueTime = cds.words.ts(cds.words.word == wordGo);
    
    wordStim=hex2dec('60');
    stimTimes=cds.words.ts( bitand(hex2dec('f0'),cds.words.word) == wordStim,1);
    stimCode=cds.words.word( bitand(hex2dec('f0'),cds.words.word) == wordStim,2);
    
    %preallocate our trial variables:
    numTrials=numel(times.number);
    tgtOnTime=nan(numTrials,1);
    tgtID=nan(numTrials,1);
    bumpTimeList=nan(numTrials,1);
    bumpList=nan(numTrials,1);
    goCueList=nan(numTrials,1);
    ctrHold=nan(numTrials,1);
    delayHold=nan(numTrials,1);
    movePeriod=nan(numTrials,1);
    bumpDelay=nan(numTrials,1);
    bumpHold=nan(numTrials,1);
    intertrialPeriod=nan(numTrials,1);
    penaltyPeriod=nan(numTrials,1);

    tgtSize=nan(numTrials,1);
    tgtAngle=nan(numTrials,1);
    tgtCtr=nan(numTrials,1);

    hideCursor=false(numTrials,1);
    hideCursorMin=nan(numTrials,1);
    hideCursorMax=nan(numTrials,1);

    abortDuringBump=false(numTrials,1);
    ctrHoldBump=false(numTrials,1);
    delayBump=false(numTrials,1);
    moveBump=false(numTrials,1);
    bumpHoldPeriod=nan(numTrials,1);
    bumpRisePeriod=nan(numTrials,1);
    bumpMagnitude=nan(numTrials,1);
    bumpAngle=nan(numTrials,1);

    stimTrial=false(numTrials,1);
    stimCode=nan(numTrials,1);
    %get the databurst version:
    dbVersion=cds.databursts.db(1,2);
    switch dbVersion
        case 0
            error('getCObumpTaskTable:unrecognizedDBVersion',['the trial table code for CObump is not implemented for databursts with version#:',num2str(dbVersion)])
        case 1
            error('getCObumpTaskTable:unrecognizedDBVersion',['the trial table code for CObump is not implemented for databursts with version#:',num2str(dbVersion)])
        case 2
            % loop thorugh our trials and build our list vectors:
            for trial = 1:numTrials
                %find and parse the current databurst:
                idxDB = find(cds.databursts.ts > times.startTime(trial) & cds.databursts.ts<times.endTime(trial), 1, 'first');
                if cds.databursts.db(idxDB,2)~=1
                    error('getCOTaskTable:badDataburstVersion',['getCOTaskTable is not coded to handle databursts of version: ',num2str(cds.databursts.db(idxDB,2))])
                end

                % * Version 2 (0x02)
                %  * ----------------
                %  * byte  0:		uchar		=> number of bytes to be transmitted
                %  * byte  1:		uchar		=> version number (in this case 0)
                %  * byte  2-4:		uchar		=> task code 'C' 'O' 'B'
                %  * bytes 5-6:		uchar       => version code
                %  * byte  7-8:		uchar		=> version code (micro)

                %  * bytes 9-12:	float		=> center hold time
                %  * bytes 13-16:	float		=> delay time
                %  * bytes 17-20:	float		=> move time
                %  * bytes 21-24:	float		=> bump delay time
                %  * bytes 25-28:	float		=> bump hold time
                %  * bytes 29-32:	float		=> intertrial time
                %  * bytes 33-36:	float		=> penalty time

                %  * bytes 37-40:	float		=> target size
                %  * bytes 41-44:	float		=> target radius
                %  * bytes 45-48:	float		=> target angle

                %  * byte 49:		uchar		=> hide cursor
                %  * bytes 50-53:	float		=> hide radius min
                %  * bytes 54-57:	float		=> hide radius max

                %  * byte 58:		uchar		=> abort during bumps
                %  * bytes 59:      uchar		=> catch trial rate: THIS IS BUGGY-Casts the rate as a uchar, rather than a float
                %  * byte 60:		uchar		=> do center hold bump
                %  * byte 61:		uchar		=> do delay period bump
                %  * byte 62:		uchar		=> do move bump
                %  * bytes 63-66:	float		=> bump hold at peak
                %  * bytes 67-70:	float		=> bump rise time
                %  * bytes 71-74:	float		=> bump magnitude
                %  * bytes 75-78:	float		=> bump direction

                %  * byte 79:		uchar		=> stim trial
                %  * bytes 80-83:	float		=> stim trial rate
                %  */
                ctrHold(trial)=bytes2float(cds.databursts.db(idxDB,10:13));
                delayHold(trial)=bytes2float(cds.databursts.db(idxDB,14:17));
                movePeriod(trial)=bytes2float(cds.databursts.db(idxDB,18:21));
                bumpDelay(trial)=bytes2float(cds.databursts.db(idxDB,22:25));
                bumpHold(trial)=bytes2float(cds.databursts.db(idxDB,26:29));
                intertrialPeriod(trial)=bytes2float(cds.databursts.db(idxDB,30:33));
                penaltyPeriod(trial)=bytes2float(cds.databursts.db(idxDB,34:37));

                tgtSize(trial)=bytes2float(cds.databursts.db(idxDB,38:41));
                tgtAngle(trial)=bytes2float(cds.databursts.db(idxDB,46:49));
                tgtCtr(trial)=bytes2float(cds.databursts.db(idxDB,42:45))*[cos(tgtAngle(trial)*pi/180),sin(tgtAngle(trial)*pi/180)];

                hideCursor(trial)=cds.databursts.db(idxDB,50);
                hideCursorMin(trial)=bytes2float(cds.databursts.db(idxDB,51:54));
                hideCursorMax(trial)=bytes2float(cds.databursts.db(idxDB,55:58));

                abortDuringBump(trial)=cds.databursts.db(idxDB,59);
                ctrHoldBump(trial)=cds.databursts.db(idxDB,61);
                delayBump(trial)=cds.databursts.db(idxDB,62);
                moveBump(trial)=cds.databursts.db(idxDB,63);
                bumpHoldPeriod(trial)=bytes2float(cds.databursts.db(idxDB,64:67));
                bumpRisePeriod(trial)=bytes2float(cds.databursts.db(idxDB,68:71));
                bumpMagnitude(trial)=bytes2float(cds.databursts.db(idxDB,72:75));
                bumpAngle(trial)=bytes2float(cds.databursts.db(idxDB,76:79));

                stimTrial(trial)=cds.databursts.db(idxDB,80);


                %now get things that rely only on words and word timing:
                idxOT=find(otOnTimes>times.startTime(trial) & otOnTimes < times.endTime(trial),1,'first');
                if ~isempty(idxOT)
                    tgtOnTime(trial)=otOnTimes(idxOT);
                    tgtID(trial)=otOnCodes(idxOT);
                else

                end

                % Bump code and time
                idxBump = find(bumpTimes > times.startTime(trial) & bumpTimes < times.endTime(trial), 1, 'first');
                if isempty(idxBump)
                    bumpTimeList(trial) = nan;
                    bumpList(trial) = nan;
                else
                    bumpTimeList(trial) = bumpTimes(idxBump);
                    bumpList(trial) = bitand(hex2dec('0f'),bumpCodes(idxBump));
                end

                % Go cue
                idxGo = find(goCueTime > times.startTime(trial) & goCueTime < times.endTime(trial), 1, 'first');
                if isempty(idxGo)
                    goCueList(trial) = nan;
                else
                    goCueList(trial) = goCueTime(idxGo);
                end

                %Stim code
                idx = find(stimTimes > times.startTime(trial) & stimTimes < times.endTime(trial),1,'first');
                if ~isempty(idx)
                    stimCode(trial) = bitand(hex2dec('0f'),stimCode(idx));%hex2dec('0f') is a bitwise mask for the trailing bit of the word
                else
                    stimCode(trial) = nan;
                end
            end

            %build table:
            trialsTable=table(ctrHold,tgtOnTime,delayHold,goCueList,movePeriod,intertrialPeriod,penaltyPeriod,...
                                tgtID,tgtSize,tgtAngle,tgtCtr,...
                                bumpTimeList,bumpList,abortDuringBump,ctrHoldBump,delayBump,moveBump,bumpHoldPeriod,bumpRisePeriod,bumpMagnitude,bumpAngle,...
                                'VariableNames',{'ctrHold','tgtOnTime','delayHold','goCueTime','movePeriod','intertrialPeriod','penaltyPeriod',...
                                'tgtID','tgtSize','tgtDir','tgtCtr',...
                                'bumpTime','bumpID','abortDuringBump','ctrHoldBump','delayBump','moveBump','bumpHoldPeriod','bumpRisePeriod','bumpMagnitude','bumpDir'});

            trialsTable.Properties.VariableUnits={'s','s','s','s','s','s','s',...
                                                    'int','cm','deg','cm, cm',...
                                                    's','int','bool','bool','bool','bool','s','s','N','deg'};
            trialsTable.Properties.VariableDescriptions={'center hold time','outer target onset time','instructed delay time','go cue time','movement time','intertrial time','penalty time',...
                                                            'ID number of outer target','size of targets','angle of outer target','x-y position of outer target',...
                                                            'time of bump onset','ID number of bump','would we abort during bumps','did we have a center hold bump',...
                                                                'did we have a delay period bump','did we have a movement period bump','the time the bump was held at peak amplitude',...
                                                                'the time the bump took to rise and fall from peak amplitude','magnitude of the bump','direction of the bump'};
            trialsTable=[times,trialsTable];
            trialsTable.Properties.Description='Trial table for the CO task';

            %cds.setField('trials',trialsTable)
            set(cds,'trials',trialsTable)
            cds.addOperation(mfilename('fullpath'))
        case 3
                        % loop thorugh our trials and build our list vectors:
            for trial = 1:numTrials
                %find and parse the current databurst:
                idxDB = find(cds.databursts.ts > times.startTime(trial) & cds.databursts.ts<times.endTime(trial), 1, 'first');
                if cds.databursts.db(idxDB,2)~=1
                    error('getCOTaskTable:badDataburstVersion',['getCOTaskTable is not coded to handle databursts of version: ',num2str(cds.databursts.db(idxDB,2))])
                end

                % * Version 3 (0x03)
                %  * ----------------
                %  * byte  0:		uchar		=> number of bytes to be transmitted
                %  * byte  1:		uchar		=> version number (in this case 0)
                %  * byte  2-4:		uchar		=> task code 'C' 'O' 'B'
                %  * bytes 5-6:		uchar       => version code
                %  * byte  7-8:		uchar		=> version code (micro)
                 
                %  * bytes 9-12:	float		=> center hold time
                %  * bytes 13-16:	float		=> delay time
                %  * bytes 17-20:	float		=> move time
                %  * bytes 21-24:	float		=> bump delay time
                %  * bytes 25-28:	float		=> bump hold time
                %  * bytes 29-32:	float		=> intertrial time
                %  * bytes 33-36:	float		=> penalty time

                %  * bytes 37-40:	float		=> target size
                %  * bytes 41-44:	float		=> target radius
                %  * bytes 45-48:	float		=> target angle

                %  * byte 49:		uchar		=> hide cursor
                %  * bytes 50-53:	float		=> hide radius min
                %  * bytes 54-57:	float		=> hide radius max

                %  * byte 58:		uchar		=> abort during bumps
                %  * byte 59:		uchar		=> do center hold bump
                %  * byte 60:		uchar		=> do delay period bump
                %  * byte 61:		uchar		=> do move bump
                %  * bytes 62-65:	float		=> bump hold at peak
                %  * bytes 66-69:	float		=> bump rise time
                %  * bytes 70-73:	float		=> bump magnitude
                %  * bytes 74-77:	float		=> bump direction

                %  * byte 78:		uchar		=> stim trial
                %  */
                ctrHold(trial)=bytes2float(cds.databursts.db(idxDB,10:13));
                delayHold(trial)=bytes2float(cds.databursts.db(idxDB,14:17));
                movePeriod(trial)=bytes2float(cds.databursts.db(idxDB,18:21));
                bumpDelay(trial)=bytes2float(cds.databursts.db(idxDB,22:25));
                bumpHold(trial)=bytes2float(cds.databursts.db(idxDB,26:29));
                intertrialPeriod(trial)=bytes2float(cds.databursts.db(idxDB,30:33));
                penaltyPeriod(trial)=bytes2float(cds.databursts.db(idxDB,34:37));

                tgtSize(trial)=bytes2float(cds.databursts.db(idxDB,38:41));
                tgtAngle(trial)=bytes2float(cds.databursts.db(idxDB,46:49));
                tgtCtr(trial)=bytes2float(cds.databursts.db(idxDB,42:45))*[cos(tgtAngle(trial)*pi/180),sin(tgtAngle(trial)*pi/180)];

                hideCursor(trial)=cds.databursts.db(idxDB,50);
                hideCursorMin(trial)=bytes2float(cds.databursts.db(idxDB,51:54));
                hideCursorMax(trial)=bytes2float(cds.databursts.db(idxDB,55:58));

                abortDuringBump(trial)=cds.databursts.db(idxDB,59);
                ctrHoldBump(trial)=cds.databursts.db(idxDB,60);
                delayBump(trial)=cds.databursts.db(idxDB,61);
                moveBump(trial)=cds.databursts.db(idxDB,62);
                bumpHoldPeriod(trial)=bytes2float(cds.databursts.db(idxDB,63:66));
                bumpRisePeriod(trial)=bytes2float(cds.databursts.db(idxDB,67:70));
                bumpMagnitude(trial)=bytes2float(cds.databursts.db(idxDB,71:74));
                bumpAngle(trial)=bytes2float(cds.databursts.db(idxDB,75:78));

                stimTrial(trial)=cds.databursts.db(idxDB,79);


                %now get things that rely only on words and word timing:
                idxOT=find(otOnTimes>times.startTime(trial) & otOnTimes < times.endTime(trial),1,'first');
                if ~isempty(idxOT)
                    tgtOnTime(trial)=otOnTimes(idxOT);
                    tgtID(trial)=otOnCodes(idxOT);
                else

                end

                % Bump code and time
                idxBump = find(bumpTimes > times.startTime(trial) & bumpTimes < times.endTime(trial), 1, 'first');
                if isempty(idxBump)
                    bumpTimeList(trial) = nan;
                    bumpList(trial) = nan;
                else
                    bumpTimeList(trial) = bumpTimes(idxBump);
                    bumpList(trial) = bitand(hex2dec('0f'),bumpCodes(idxBump));
                end

                % Go cue
                idxGo = find(goCueTime > times.startTime(trial) & goCueTime < times.endTime(trial), 1, 'first');
                if isempty(idxGo)
                    goCueList(trial) = nan;
                else
                    goCueList(trial) = goCueTime(idxGo);
                end

                %Stim code
                idx = find(stimTimes > times.startTime(trial) & stimTimes < times.endTime(trial),1,'first');
                if ~isempty(idx)
                    stimCode(trial) = bitand(hex2dec('0f'),stimCode(idx));%hex2dec('0f') is a bitwise mask for the trailing bit of the word
                else
                    stimCode(trial) = nan;
                end
            end

            %build table:
            trialsTable=table(ctrHold,tgtOnTime,delayHold,goCueList,movePeriod,intertrialPeriod,penaltyPeriod,...
                                tgtID,tgtSize,tgtAngle,tgtCtr,...
                                bumpTimeList,bumpList,abortDuringBump,ctrHoldBump,delayBump,moveBump,bumpHoldPeriod,bumpRisePeriod,bumpMagnitude,bumpAngle,...
                                'VariableNames',{'ctrHold','tgtOnTime','delayHold','goCueTime','movePeriod','intertrialPeriod','penaltyPeriod',...
                                'tgtID','tgtSize','tgtDir','tgtCtr',...
                                'bumpTime','bumpID','abortDuringBump','ctrHoldBump','delayBump','moveBump','bumpHoldPeriod','bumpRisePeriod','bumpMagnitude','bumpDir'});

            trialsTable.Properties.VariableUnits={'s','s','s','s','s','s','s',...
                                                    'int','cm','deg','cm, cm',...
                                                    's','int','bool','bool','bool','bool','s','s','N','deg'};
            trialsTable.Properties.VariableDescriptions={'center hold time','outer target onset time','instructed delay time','go cue time','movement time','intertrial time','penalty time',...
                                                            'ID number of outer target','size of targets','angle of outer target','x-y position of outer target',...
                                                            'time of bump onset','ID number of bump','would we abort during bumps','did we have a center hold bump',...
                                                                'did we have a delay period bump','did we have a movement period bump','the time the bump was held at peak amplitude',...
                                                                'the time the bump took to rise and fall from peak amplitude','magnitude of the bump','direction of the bump'};
            trialsTable=[times,trialsTable];
            trialsTable.Properties.Description='Trial table for the CO task';

            %cds.setField('trials',trialsTable)
            set(cds,'trials',trialsTable)
            cds.addOperation(mfilename('fullpath'))
        otherwise
            error('getCObumpTaskTable:unrecognizedDBVersion',['the trial table code for CObump is not implemented for databursts with version#:',num2str(dbVersion)])
    end
end