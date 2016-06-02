function [trialStartTimes,trialStopTimes,hitRate,hitRate2,trialStartTimes2,trialStopTimes2,slidingAccuracy,slidingTime]=COtrialTimes(out_struct)

% syntax [trialStartTimes,trialStopTimes,hitRate,hitRate2,trialStartTimes2,trialStopTimes2,slidingAccuracy,slidingTime]=COtrialTimes(out_struct);
%
% only works for 2 targets of CO, but could be expanded.



% this is how I would have previously done it:
%
% trialStartInds=find(out_struct.words(1:end-4,2)==17 & ...
%      out_struct.words(2:end-3,2)==48 & ...
%     (out_struct.words(3:end-2,2)==64 | out_struct.words(3:end-2,2)==65) & ...
%      out_struct.words(4:end-1,2)==49 & ...
%      out_struct.words(5:end,2)==32);

trialStartInds=unique([strfind(out_struct.words(:,2)',[17 48 64 49 32]), ...
    strfind(out_struct.words(:,2)',[17 48 65 49 32])]);
hitRate=numel(trialStartInds)/nnz(out_struct.words(:,2)==17);
trialStartTimes=out_struct.words(trialStartInds,1);
trialStopTimes=out_struct.words(trialStartInds+4,1);

% hitRate2 for trials that (1) didn't abort on the center target, and (2)
% did reach the outer target, but (3) did not manage to hold in the outer
% target.  Behavior code markes these as 'incompletes', with code 35.
incompleteStartInds=unique([strfind(out_struct.words(:,2)',[17 48 64 49 35]), ...
    strfind(out_struct.words(:,2)',[17 48 65 49 35])]);
hitRate2=(numel(trialStartInds)+numel(incompleteStartInds))/nnz(out_struct.words(:,2)==17);
trialStartTimes2=out_struct.words(unique([trialStartInds,incompleteStartInds]),1);
trialStopTimes2=out_struct.words(unique([trialStartInds,incompleteStartInds]+4),1);

% compute a sliding window accuracy, to give a smoothed view of the
% accuracy.
trialOnset=find(out_struct.words(:,2)==17);
windowSize=20;
slidingAccuracy=zeros(length(trialOnset)-windowSize,1);
slidingTime=slidingAccuracy;
for n=windowSize:length(trialOnset)
    slidingAccuracy(n-windowSize+1)= ...
        numel(intersect(trialOnset(n-windowSize+1:n),trialStartInds))/windowSize;    
    slidingTime(n-windowSize+1)= ...
        mean(out_struct.words(trialOnset(n-windowSize+1:n),1));
end

