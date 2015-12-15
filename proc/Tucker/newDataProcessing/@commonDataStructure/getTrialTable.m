function getTrialTable(cds)
    %this is a method function for the common_data_structure (cds) class, and
    %should be located in a folder '@common_data_structure' with the class
    %definition file and other method files
    %
    %makes a simple table with trial data that is common to any task. 
    %output is a dataset with the following columns:
    %trial_number   -allows later subtables to maintain trial order
    %start_time     -start of trial
    %go_time        -Time of first go cue, ignores multiple cues as you'd
    %                   get in RW
    %end_time       -end of trial
    %trial_result   -Numeric code: 0=Reward,1=Abort,2=Fail,3=Incomplete
    %
    %assumes that cds.words exists and is non-empty
    %
    %if there is a trial start word and no end word before the next trial
    %start, that trial start will be ignored. Also ignores the first 1s of
    %data to avoid problems associated with the missing 1s of kinematic
    %data

    wordStart = hex2dec('10');
    
    startTime =  cds.words.ts( bitand(hex2dec('f0'),cds.words.word) == wordStart &  cds.words.ts>1.000);
    numTrials = length(startTime);

    wordEnd = hex2dec('20');
    endTime =  cds.words.ts( bitand(hex2dec('f0'), cds.words.word) == wordEnd);
    endCodes =  cds.words.word( bitand(hex2dec('f0'), cds.words.word) == wordEnd);
    
    %preallocate with -1
    stopTime=-1*ones(size(startTime));
    trialResult=cell(size(stopTime));
    resultCodes='RAFI';
    for ind = 1:numTrials-1
        % Find the end of the trial
        if ind==numTrials
            trial_end_idx = find(endTime > startTime(ind), 1, 'first');
        else
            next_trial_start = startTime(ind+1);
            trial_end_idx = find(endTime > startTime(ind) & endTime < next_trial_start, 1, 'first');
        end
        if isempty(trial_end_idx)
            stopTime(ind) = -1;
            trialResult(ind) = {'-'};
        else
            stopTime(ind) = endTime(trial_end_idx);
            trialResult(ind) = {resultCodes(mod(endCodes(trial_end_idx),32)+1)}; %0 is reward, 1 is abort, 2 is fail, and 3 is incomplete (incomplete should never happen)
        end
    end
    mask=stopTime~=-1;
    times=table([1:sum(mask)]',startTime(mask),stopTime(mask),trialResult(mask),'VariableNames',{'number','startTime','endTime','result'});
    
    
    %specific task table code will add operations, so add the operation
    %for this file here, before we run the task specific code:
    cds.addOperation(mfilename('fullpath'))
    if ~strcmpi(cds.meta.task,'Unknown')
        %try to get trial data specific to the task
        switch cds.meta.task
            case 'RW' %Labs standard random walk task for the robot
                cds.getRWTaskTable(times);
            case 'CO' %labs standard center out task for the robot
                
            case 'WF' %wrist flexion task
                cds.getWFTaskTable(times);
            case 'multi_gadget'
                
            case 'BD' %Tucker's psychophysics bump direction task
                
            case 'UNT' %Brian Dekleva's uncertainty task
                
            case 'RP' %Ricardo's resist perturbations task
                
            case 'DCO' %Ricardo's dynamic center out task
                
            otherwise
                warning('getTrialTable:UnknownTask','The task for this data file was not set. Trial table will contain only trial start,stop and result')
        end
    else
        %cds.setField('trials',times)
        set(cds,'trials',times)
    end
end