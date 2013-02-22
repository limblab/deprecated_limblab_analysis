function numTargets=getNumTargets(out_struct)

% syntax numTargets=getNumTargets(out_struct);
%
% returns the number of targets hit for each rewarded trial of a BDF.
% Useful for determining what the parameter was set to in the behavior
% code.  Currently, only works for RW end-trial codes (32,33,34, should
% there be a 35?).

% for notes on CO, see research notes 02-11-2013.txt

START_TRIAL_WORD=unique(out_struct.words(:,2));
START_TRIAL_WORD(START_TRIAL_WORD<17 | START_TRIAL_WORD>21)=[];

% first, always must account for bad starts/ends.
% make sure to start with the first complete trial in the recording
beginFirstTrial=find(out_struct.words(:,2)==START_TRIAL_WORD,1,'first');
if beginFirstTrial > 1
    out_struct.words(1:beginFirstTrial-1,:)=[];
end
% make sure to end with the last complete trial in the recording
% all of the following codes are valid trial-end codes: success (32),
% abort (33), fail (34)
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
