function numTargets=getNumTargets(out_struct)

% syntax numTargets=getNumTargets(out_struct);
%
% returns the number of targets hit for each rewarded trial of a BDF.
% Useful for determining what the parameter was set to in the behavior
% code.

% for notes on CO, see research notes 02-11-2013.txt

START_TRIAL_WORD=unique(out_struct.words(:,2));
START_TRIAL_WORD(START_TRIAL_WORD<17 | START_TRIAL_WORD>19)=[];
% Weird glitch that happens occasionally in CO but never cropped up in
% recorded history with RW, so it must be a CO if this happens...
if length(START_TRIAL_WORD)>1 && all(START_TRIAL_WORD==17 | START_TRIAL_WORD==18)
    % edit 04-29-2014: this has now reared its head in an RW recording,
    % from 07-04-2013 (file 003 on that day).  So, replace the former
    % behavior:
    % START_TRIAL_WORD=17;
    % with a populist approach:
    if nnz(out_struct.words(:,2)==18) > 10*nnz(out_struct.words(:,2)==17)
        START_TRIAL_WORD=18;
    end
    if nnz(out_struct.words(:,2)==17) > 10*nnz(out_struct.words(:,2)==18)
        START_TRIAL_WORD=17;
    end
    
end

% broader coverage: if any START_TRIAL_WORD occurs only once, then it is
% probably a glitch of some kind, & should be eliminated.
startwordslen=zeros(numel(START_TRIAL_WORD),1);
if numel(START_TRIAL_WORD) > 1
    for n=1:numel(START_TRIAL_WORD)
        startwordslen(n)=nnz(out_struct.words(:,2)==START_TRIAL_WORD(n));
    end
    if any(startwordslen==1)
        START_TRIAL_WORD(startwordslen==1)=[];
    end
end

% first, always must account for bad starts/ends.
% make sure to start with the first complete trial in the recording
beginFirstTrial=find(out_struct.words(:,2)==START_TRIAL_WORD,1,'first');
if beginFirstTrial > 1
    out_struct.words(1:beginFirstTrial-1,:)=[];
end
% make sure to end with the last complete trial in the recording
% all of the following codes are valid trial-end codes: success (32),
% abort (33), fail (34), incomplete (35)
END_TRIAL_WORD=unique(out_struct.words(:,2));
END_TRIAL_WORD(END_TRIAL_WORD<32 | END_TRIAL_WORD>36)=[];
endLastTrial=find(ismember(out_struct.words(:,2),END_TRIAL_WORD),1,'last');
if endLastTrial < size(out_struct.words,1)
    out_struct.words(endLastTrial+1:end,:)=[];
end
rewarded_trials=find(out_struct.words(:,2)==32);
start_trial=zeros(size(rewarded_trials)); numTargets=start_trial;

% #define WORD_GO_CUE 0x31 or 49 for all behaviors, it seems.

for trial_index=1:length(rewarded_trials)
    start_trial(trial_index)= ...
        find(out_struct.words(1:rewarded_trials(trial_index),2)==START_TRIAL_WORD,1,'last');
    numTargets(trial_index)=nnz(out_struct.words(start_trial(trial_index): ...
        rewarded_trials(trial_index),2)==49);
end
