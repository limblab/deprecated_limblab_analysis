function [trialStartTimes,trialStopTimes]=COtrialTimes(out_struct)

% syntax [trialStartTimes,trialStopTimes]=COtrialTimes(out_struct)
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

trialStartTimes=out_struct.words(trialStartInds,1);
trialStopTimes=out_struct.words(trialStartInds+4,1);


