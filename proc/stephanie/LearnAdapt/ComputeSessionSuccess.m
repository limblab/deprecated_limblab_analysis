function sessionSuccess = ComputeSessionSuccess(TrialsStruct)

allTrials = length(TrialsStruct.TrialsFull(:,1));
successfulTrials = length(find(TrialsStruct.TrialsFull(:,1)==82));
sessionSuccess = successfulTrials/allTrials;

end